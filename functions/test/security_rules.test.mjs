import assert from 'node:assert/strict';
import { readFile } from 'node:fs/promises';
import { test, before, after, beforeEach } from 'node:test';
import { fileURLToPath } from 'node:url';
import path from 'node:path';

import { initializeTestEnvironment, assertFails, assertSucceeds } from '@firebase/rules-unit-testing';
import { doc, getDoc, serverTimestamp, setDoc, Timestamp } from 'firebase/firestore';
import { get, ref, set } from 'firebase/database';

const root = path.resolve(path.dirname(fileURLToPath(import.meta.url)), '../..');
let environment;

before(async () => {
  const [firestoreRules, databaseRules] = await Promise.all([
    readFile(path.join(root, 'firestore.rules'), 'utf8'),
    readFile(path.join(root, 'database.rules.json'), 'utf8'),
  ]);
  environment = await initializeTestEnvironment({
    projectId: 'demo-mapato-security',
    firestore: { rules: firestoreRules },
    database: {
      rules: databaseRules,
      host: process.env.DATABASE_EMULATOR_HOST?.split(':')[0] ?? '127.0.0.1',
      port: Number(process.env.DATABASE_EMULATOR_HOST?.split(':')[1] ?? 9000),
    },
  });
});

after(async () => environment?.cleanup());

beforeEach(async () => {
  await environment.clearFirestore();
  await environment.clearDatabase();
});

function profileData() {
  return {
    displayName: 'Amina Juma',
    email: 'amina@example.test',
    currency: 'TZS',
    language: 'sw',
    monthlyIncomeMinor: 1200000,
    monthlyBudgetMinor: 600000,
    financialGoal: 'emergency',
    setupComplete: true,
    createdAt: serverTimestamp(),
    updatedAt: serverTimestamp(),
  };
}

function transactionData(amountMinor = 35000) {
  return {
    type: 'expense',
    amountMinor,
    currency: 'TZS',
    categoryId: 'food',
    description: 'Lunch',
    date: Timestamp.fromDate(new Date('2026-10-02T10:00:00Z')),
    note: '',
    monthKey: '2026-10',
    createdAt: serverTimestamp(),
    updatedAt: serverTimestamp(),
  };
}

test('a user can create and read their valid profile and ledger', async () => {
  const db = environment.authenticatedContext('alice').firestore();
  await assertSucceeds(setDoc(doc(db, 'users/alice'), profileData()));
  await assertSucceeds(getDoc(doc(db, 'users/alice')));
  await assertSucceeds(setDoc(doc(db, 'users/alice/transactions/lunch'), transactionData()));
});

test('a user cannot read or write another account', async () => {
  const alice = environment.authenticatedContext('alice').firestore();
  await assertFails(setDoc(doc(alice, 'users/bob'), profileData()));
  await assertFails(getDoc(doc(alice, 'users/bob')));
  await assertFails(setDoc(doc(alice, 'users/bob/transactions/lunch'), transactionData()));
});

test('invalid transaction amounts and client summary writes are rejected', async () => {
  const db = environment.authenticatedContext('alice').firestore();
  await assertFails(setDoc(doc(db, 'users/alice/transactions/invalid'), transactionData(0)));
  await environment.withSecurityRulesDisabled(async (context) => {
    await setDoc(doc(context.firestore(), 'users/alice/summaries/lifetime'), {
      incomeMinor: 100,
      expenseMinor: 0,
      updatedAt: serverTimestamp(),
    });
  });
  await assertSucceeds(getDoc(doc(db, 'users/alice/summaries/lifetime')));
  await assertFails(setDoc(doc(db, 'users/alice/summaries/lifetime'), { incomeMinor: 999999 }));
});

test('clients cannot read or write the server-only OTP challenge database', async () => {
  const database = environment.authenticatedContext('alice').database();
  await assertFails(get(ref(database, '_authChallenges/challenge')));
  await assertFails(set(ref(database, '_authChallenges/challenge'), { code: '123456' }));
  assert.equal(typeof environment.clearDatabase, 'function');
});
