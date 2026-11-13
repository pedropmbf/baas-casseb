// Testes das regras do Firestore no emulador local.
// Rodar:  cd testes-regras && npm install && npm test
import { readFileSync } from 'node:fs'
import { after, before, beforeEach, describe, test } from 'node:test'
import {
  assertFails, assertSucceeds, initializeTestEnvironment,
} from '@firebase/rules-unit-testing'
import {
  collection, doc, getDoc, getDocs, query, serverTimestamp, setDoc, updateDoc, where, deleteDoc,
} from 'firebase/firestore'

let env

const estande = (ativo) => ({ nome: 'Estande', descricao: 'desc', localizacao: 'A1', ativo })

before(async () => {
  env = await initializeTestEnvironment({
    projectId: 'demo-circuito',
    firestore: { rules: readFileSync(new URL('../firestore.rules', import.meta.url), 'utf8') },
  })
})

after(() => env.cleanup())

beforeEach(async () => {
  await env.clearFirestore()
  await env.withSecurityRulesDisabled(async (ctx) => {
    const db = ctx.firestore()
    await setDoc(doc(db, 'admins/admin1'), { email: 'org@exemplo.com' })
    await setDoc(doc(db, 'estandes/ativo1'), estande(true))
    await setDoc(doc(db, 'estandes/inativo1'), estande(false))
  })
})

const admin = () => env.authenticatedContext('admin1').firestore()
const visitante = (uid = 'vis1') => env.authenticatedContext(uid).firestore()
const anonimo = () => env.unauthenticatedContext().firestore()
const checkin = (uid, estandeId) => ({ visitanteId: uid, estandeId, criadoEm: serverTimestamp() })

describe('estandes', () => {
  test('admin cria, edita e lê inativos', async () => {
    await assertSucceeds(setDoc(doc(admin(), 'estandes/novo'), { ...estande(true), criadoEm: serverTimestamp() }))
    await assertSucceeds(updateDoc(doc(admin(), 'estandes/novo'), { ativo: false }))
    await assertSucceeds(getDoc(doc(admin(), 'estandes/inativo1')))
    await assertSucceeds(getDocs(collection(admin(), 'estandes')))
  })

  test('admin não grava estande com campos inválidos', async () => {
    await assertFails(setDoc(doc(admin(), 'estandes/x'), { ...estande(true), nome: '' }))
    await assertFails(setDoc(doc(admin(), 'estandes/x'), { ...estande(true), extra: 1 }))
    await assertFails(setDoc(doc(admin(), 'estandes/x'), { ...estande(true), ativo: 'sim' }))
  })

  test('visitante não altera estandes', async () => {
    await assertFails(setDoc(doc(visitante(), 'estandes/novo'), estande(true)))
    await assertFails(updateDoc(doc(visitante(), 'estandes/ativo1'), { nome: 'hack' }))
    await assertFails(deleteDoc(doc(visitante(), 'estandes/ativo1')))
  })

  test('visitante lê ativos e descobre ID inexistente, mas não lê inativos', async () => {
    await assertSucceeds(getDoc(doc(visitante(), 'estandes/ativo1')))
    await assertSucceeds(getDoc(doc(visitante(), 'estandes/nao-existe')))
    await assertFails(getDoc(doc(visitante(), 'estandes/inativo1')))
    await assertSucceeds(getDocs(query(collection(visitante(), 'estandes'), where('ativo', '==', true))))
    await assertFails(getDocs(collection(visitante(), 'estandes')))
  })

  test('sem login não lê nada', async () => {
    await assertFails(getDoc(doc(anonimo(), 'estandes/ativo1')))
  })
})

describe('checkins', () => {
  test('visitante cria o próprio check-in em estande ativo', async () => {
    await assertSucceeds(setDoc(doc(visitante(), 'checkins/vis1_ativo1'), checkin('vis1', 'ativo1')))
  })

  test('segundo check-in no mesmo estande é recusado', async () => {
    const db = visitante()
    await assertSucceeds(setDoc(doc(db, 'checkins/vis1_ativo1'), checkin('vis1', 'ativo1')))
    await assertFails(setDoc(doc(db, 'checkins/vis1_ativo1'), checkin('vis1', 'ativo1')))
  })

  test('não grava check-in em nome de outra pessoa ou com ID fora do padrão', async () => {
    await assertFails(setDoc(doc(visitante(), 'checkins/vis2_ativo1'), checkin('vis2', 'ativo1')))
    await assertFails(setDoc(doc(visitante(), 'checkins/qualquer'), checkin('vis1', 'ativo1')))
  })

  test('não grava check-in em estande inativo ou inexistente', async () => {
    await assertFails(setDoc(doc(visitante(), 'checkins/vis1_inativo1'), checkin('vis1', 'inativo1')))
    await assertFails(setDoc(doc(visitante(), 'checkins/vis1_naoexiste'), checkin('vis1', 'naoexiste')))
  })

  test('não aceita data forjada', async () => {
    await assertFails(setDoc(doc(visitante(), 'checkins/vis1_ativo1'),
      { visitanteId: 'vis1', estandeId: 'ativo1', criadoEm: new Date(2000, 0, 1) }))
  })

  test('visitante lê apenas os próprios check-ins; admin lê todos', async () => {
    await setDoc(doc(visitante('vis1'), 'checkins/vis1_ativo1'), checkin('vis1', 'ativo1'))
    await setDoc(doc(visitante('vis2'), 'checkins/vis2_ativo1'), checkin('vis2', 'ativo1'))

    await assertSucceeds(getDoc(doc(visitante('vis1'), 'checkins/vis1_ativo1')))
    await assertSucceeds(getDoc(doc(visitante('vis1'), 'checkins/vis1_outro')))
    await assertFails(getDoc(doc(visitante('vis1'), 'checkins/vis2_ativo1')))
    await assertSucceeds(getDocs(query(collection(visitante('vis1'), 'checkins'), where('visitanteId', '==', 'vis1'))))
    await assertFails(getDocs(collection(visitante('vis1'), 'checkins')))

    const todos = await assertSucceeds(getDocs(collection(admin(), 'checkins')))
    if (todos.size !== 2) throw new Error(`admin deveria ver 2 check-ins, viu ${todos.size}`)
  })

  test('check-in não pode ser alterado nem apagado', async () => {
    await setDoc(doc(visitante(), 'checkins/vis1_ativo1'), checkin('vis1', 'ativo1'))
    await assertFails(updateDoc(doc(visitante(), 'checkins/vis1_ativo1'), { estandeId: 'x' }))
    await assertFails(deleteDoc(doc(admin(), 'checkins/vis1_ativo1')))
  })
})

describe('admins', () => {
  test('cada um lê só o próprio registro e ninguém escreve', async () => {
    await assertSucceeds(getDoc(doc(admin(), 'admins/admin1')))
    await assertSucceeds(getDoc(doc(visitante(), 'admins/vis1')))
    await assertFails(getDoc(doc(visitante(), 'admins/admin1')))
    await assertFails(setDoc(doc(visitante(), 'admins/vis1'), { email: 'x' }))
  })
})
