import { onAuthStateChanged } from 'firebase/auth'
import { doc, getDoc } from 'firebase/firestore'
import { useEffect, useState } from 'react'
import { auth, db } from './firebase'

/**
 * Sessão do painel. Um usuário só é administrador se existir o documento
 * `admins/{uid}` no Firestore (o mesmo critério usado nas regras de segurança).
 */
export function useAdmin() {
  const [estado, setEstado] = useState({ status: 'carregando' })

  useEffect(() => {
    if (!auth) return undefined
    let atual = 0
    return onAuthStateChanged(auth, async (user) => {
      const chamada = ++atual
      if (!user) {
        setEstado({ status: 'deslogado' })
        return
      }
      if (user.isAnonymous) {
        setEstado({ status: 'semPermissao', user })
        return
      }
      setEstado({ status: 'carregando' })
      try {
        const snap = await getDoc(doc(db, 'admins', user.uid))
        if (chamada !== atual) return
        setEstado({ status: snap.exists() ? 'admin' : 'semPermissao', user })
      } catch (e) {
        if (chamada !== atual) return
        setEstado({ status: 'semPermissao', user, erro: e.message })
      }
    })
  }, [])

  return estado
}
