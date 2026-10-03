import { createHmac, randomInt, timingSafeEqual } from 'node:crypto';

import { getAuth } from 'firebase-admin/auth';
import { getDatabase } from 'firebase-admin/database';
import { FieldValue, getFirestore, Timestamp } from 'firebase-admin/firestore';
import { initializeApp } from 'firebase-admin/app';
import { onDocumentWritten } from 'firebase-functions/v2/firestore';
import { HttpsError, onCall } from 'firebase-functions/v2/https';
import { defineSecret, defineString } from 'firebase-functions/params';
import { logger } from 'firebase-functions';

initializeApp();

const otpHmacKey = defineSecret('MAPATO_OTP_HMAC_KEY');
const resendApiKey = defineSecret('RESEND_API_KEY');
const senderEmail = defineString('MAPATO_FROM_EMAIL');
const codeLifetimeMs = 10 * 60 * 1000;
const requestWindowMs = 15 * 60 * 1000;
const maximumRequestsPerWindow = 3;
const maximumAttempts = 5;

type Challenge = {
  codeHash: string;
  issuedAt: number;
  expiresAt: number;
  attempts: number;
  windowStartedAt: number;
  requestCount: number;
};

function normalizedEmail(value: unknown): string {
  if (typeof value !== 'string') {
    throw new HttpsError('invalid-argument', 'Email is required.');
  }
  const email = value.trim().toLowerCase();
  if (email.length > 320 || !/^[^@\s]+@[^@\s]+\.[^@\s]+$/.test(email)) {
    throw new HttpsError('invalid-argument', 'Enter a valid email address.');
  }
  return email;
}

function languageCode(value: unknown): 'en' | 'sw' {
  return value === 'sw' ? 'sw' : 'en';
}

function digest(value: string): string {
  return createHmac('sha256', otpHmacKey.value()).update(value).digest('hex');
}

function challengeReference(email: string) {
  const emailKey = digest(`email:${email}`);
  return getDatabase().ref(`_authChallenges/${emailKey}`);
}

async function sendCode(email: string, code: string, language: 'en' | 'sw') {
  const swahili = language === 'sw';
  const subject = swahili
    ? 'Msimbo wako wa kuingia Mapato Binafsi'
    : 'Your Mapato Binafsi sign-in code';
  const text = swahili
    ? `Msimbo wako wa uthibitisho ni ${code}. Msimbo huu utaisha baada ya dakika 10. Kama hukuomba msimbo huu, puuza barua pepe hii.`
    : `Your verification code is ${code}. It expires in 10 minutes. If you did not request this code, you can ignore this email.`;
  const response = await fetch('https://api.resend.com/emails', {
    method: 'POST',
    headers: {
      Authorization: `Bearer ${resendApiKey.value()}`,
      'Content-Type': 'application/json',
    },
    body: JSON.stringify({ from: senderEmail.value(), to: [email], subject, text }),
  });
  if (!response.ok) {
    throw new HttpsError('unavailable', 'Email delivery is temporarily unavailable.');
  }
}

export const requestEmailCode = onCall(
  {
    region: 'africa-south1',
    enforceAppCheck: true,
    maxInstances: 20,
    secrets: [otpHmacKey, resendApiKey],
  },
  async (request) => {
    const email = normalizedEmail(request.data?.email);
    const language = languageCode(request.data?.language);
    const reference = challengeReference(email);
    const now = Date.now();
    const code = randomInt(100000, 1000000).toString();
    let rateLimited = false;

    await reference.transaction((current: Challenge | null) => {
      const withinWindow =
        current != null && now - current.windowStartedAt < requestWindowMs;
      const requestCount = withinWindow ? current.requestCount : 0;
      if (requestCount >= maximumRequestsPerWindow) {
        rateLimited = true;
        return;
      }
      return {
        codeHash: digest(`otp:${email}:${code}`),
        issuedAt: now,
        expiresAt: now + codeLifetimeMs,
        attempts: 0,
        windowStartedAt: withinWindow ? current.windowStartedAt : now,
        requestCount: requestCount + 1,
      } satisfies Challenge;
    }, undefined, false);

    if (rateLimited) {
      throw new HttpsError('resource-exhausted', 'Too many code requests. Try again later.');
    }

    try {
      await sendCode(email, code, language);
    } catch (error) {
      await reference.remove();
      logger.warn('Email code delivery failed.');
      if (error instanceof HttpsError) throw error;
      throw new HttpsError('unavailable', 'Email delivery is temporarily unavailable.');
    }
  },
);

export const verifyEmailCode = onCall(
  {
    region: 'africa-south1',
    enforceAppCheck: true,
    maxInstances: 20,
    secrets: [otpHmacKey],
  },
  async (request) => {
    const email = normalizedEmail(request.data?.email);
    const code = request.data?.code;
    if (typeof code !== 'string' || !/^\d{6}$/.test(code)) {
      throw new HttpsError('invalid-argument', 'Enter the six-digit code.');
    }

    const reference = challengeReference(email);
    const supplied = Buffer.from(digest(`otp:${email}:${code}`), 'hex');
    const now = Date.now();
    let outcome: string = 'invalid';

    await reference.transaction((current: Challenge | null) => {
      if (current == null) return;
      if (current.expiresAt <= now) {
        outcome = 'expired';
        return null;
      }
      if (current.attempts >= maximumAttempts) {
        outcome = 'locked';
        return null;
      }
      const expected = Buffer.from(current.codeHash, 'hex');
      if (expected.length === supplied.length && timingSafeEqual(expected, supplied)) {
        outcome = 'valid';
        return null;
      }
      current.attempts += 1;
      outcome = current.attempts >= maximumAttempts ? 'locked' : 'invalid';
      return current;
    }, undefined, false);

    if (outcome !== 'valid') {
      if (outcome === 'locked' || outcome === 'expired') await reference.remove();
      throw new HttpsError('permission-denied', 'The code is invalid or has expired.');
    }

    const auth = getAuth();
    let user;
    try {
      user = await auth.getUserByEmail(email);
    } catch (error) {
      if ((error as { code?: string }).code !== 'auth/user-not-found') throw error;
      user = await auth.createUser({ email, emailVerified: true });
    }
    const customToken = await auth.createCustomToken(user.uid);
    return { customToken };
  },
);

type SummaryDelta = {
  incomeMinor: number;
  expenseMinor: number;
  incomeByCategory: Record<string, number>;
  expenseByCategory: Record<string, number>;
};

function emptySummaryDelta(): SummaryDelta {
  return {
    incomeMinor: 0,
    expenseMinor: 0,
    incomeByCategory: {},
    expenseByCategory: {},
  };
}

function applyTransactionDelta(
  delta: SummaryDelta,
  data: Record<string, unknown>,
  direction: 1 | -1,
) {
  const type = data.type;
  const amount = data.amountMinor;
  const categoryId = data.categoryId;
  if (
    (type !== 'income' && type !== 'expense') ||
    typeof amount !== 'number' ||
    typeof categoryId !== 'string' ||
    categoryId.length === 0
  ) {
    return;
  }
  const amountDelta = amount * direction;
  if (type === 'income') {
    delta.incomeMinor += amountDelta;
    delta.incomeByCategory[categoryId] =
      (delta.incomeByCategory[categoryId] ?? 0) + amountDelta;
  } else {
    delta.expenseMinor += amountDelta;
    delta.expenseByCategory[categoryId] =
      (delta.expenseByCategory[categoryId] ?? 0) + amountDelta;
  }
}

function integerMap(value: unknown): Record<string, number> {
  if (typeof value !== 'object' || value === null || Array.isArray(value)) return {};
  return Object.fromEntries(
    Object.entries(value).filter((entry): entry is [string, number] =>
      typeof entry[1] === 'number' && Number.isSafeInteger(entry[1]),
    ),
  );
}

function addCategoryDeltas(
  current: Record<string, number>,
  delta: Record<string, number>,
) {
  const result = { ...current };
  for (const [categoryId, amount] of Object.entries(delta)) {
    const next = (result[categoryId] ?? 0) + amount;
    if (next === 0) delete result[categoryId];
    else result[categoryId] = next;
  }
  return result;
}

export const updateTransactionSummary = onDocumentWritten(
  {
    region: 'africa-south1',
    document: 'users/{userId}/transactions/{transactionId}',
    retry: true,
    maxInstances: 30,
  },
  async (event) => {
    const userId = event.params.userId;
    const before = event.data?.before.exists
      ? event.data.before.data() as Record<string, unknown>
      : null;
    const after = event.data?.after.exists
      ? event.data.after.data() as Record<string, unknown>
      : null;
    if (before == null && after == null) return;

    const deltas = new Map<string, SummaryDelta>();
    const deltaFor = (key: string) => {
      let delta = deltas.get(key);
      if (delta == null) {
        delta = emptySummaryDelta();
        deltas.set(key, delta);
      }
      return delta;
    };
    const addRecord = (record: Record<string, unknown> | null, direction: 1 | -1) => {
      if (record == null) return;
      const monthKey = record.monthKey;
      if (typeof monthKey !== 'string' || !/^\d{4}-(0[1-9]|1[0-2])$/.test(monthKey)) return;
      applyTransactionDelta(deltaFor(monthKey), record, direction);
      applyTransactionDelta(deltaFor('lifetime'), record, direction);
    };
    addRecord(before, -1);
    addRecord(after, 1);
    if (deltas.size === 0) return;

    const firestore = getFirestore();
    const userReference = firestore.collection('users').doc(userId);
    const operationReference = userReference
      .collection('summaryOperations')
      .doc(event.id);
    const summaryReferences = new Map(
      [...deltas.keys()].map((key) => [
        key,
        userReference.collection('summaries').doc(key),
      ]),
    );

    await firestore.runTransaction(async (transaction) => {
      const operation = await transaction.get(operationReference);
      if (operation.exists) return;
      const summaries = await Promise.all(
        [...summaryReferences.values()].map((reference) => transaction.get(reference)),
      );
      const keys = [...summaryReferences.keys()];
      for (let index = 0; index < keys.length; index += 1) {
        const key = keys[index];
        const reference = summaryReferences.get(key)!;
        const previous = summaries[index].data() ?? {};
        const delta = deltas.get(key)!;
        transaction.set(reference, {
          incomeMinor: ((previous.incomeMinor as number | undefined) ?? 0) + delta.incomeMinor,
          expenseMinor: ((previous.expenseMinor as number | undefined) ?? 0) + delta.expenseMinor,
          incomeByCategory: addCategoryDeltas(
            integerMap(previous.incomeByCategory),
            delta.incomeByCategory,
          ),
          expenseByCategory: addCategoryDeltas(
            integerMap(previous.expenseByCategory),
            delta.expenseByCategory,
          ),
          ...(key === 'lifetime' ? {} : { monthKey: key }),
          updatedAt: FieldValue.serverTimestamp(),
        }, { merge: true });
      }
      transaction.create(operationReference, {
        createdAt: FieldValue.serverTimestamp(),
        expiresAt: Timestamp.fromMillis(Date.now() + 30 * 24 * 60 * 60 * 1000),
      });
    });
  },
);
