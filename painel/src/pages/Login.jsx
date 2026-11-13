import { signInWithEmailAndPassword } from 'firebase/auth'
import { useState } from 'react'
import { auth } from '../firebase'

const mensagens = {
  'auth/invalid-credential': 'E-mail ou senha incorretos.',
  'auth/invalid-email': 'E-mail inválido.',
  'auth/too-many-requests': 'Muitas tentativas. Aguarde um pouco e tente de novo.',
  'auth/network-request-failed': 'Sem conexão com o Firebase.',
  'auth/operation-not-allowed': 'Ative o provedor E-mail/senha em Authentication no console.',
}

export default function Login() {
  const [email, setEmail] = useState('')
  const [senha, setSenha] = useState('')
  const [erro, setErro] = useState('')
  const [enviando, setEnviando] = useState(false)

  async function entrar(e) {
    e.preventDefault()
    setErro('')
    setEnviando(true)
    try {
      await signInWithEmailAndPassword(auth, email.trim(), senha)
    } catch (err) {
      setErro(mensagens[err.code] ?? err.message)
      setEnviando(false)
    }
  }

  return (
    <div className="centro fundo-marca">
      <form className="cartao estreito" onSubmit={entrar}>
        <p className="sobretitulo">Amazon Hacking · Organização</p>
        <h1>Circuito de Descobertas</h1>
        <p className="suave">Painel administrativo da feira.</p>

        <label className="campo">
          <span>E-mail</span>
          <input type="email" autoComplete="username" value={email}
            onChange={(e) => setEmail(e.target.value)} required />
        </label>
        <label className="campo">
          <span>Senha</span>
          <input type="password" autoComplete="current-password" value={senha}
            onChange={(e) => setSenha(e.target.value)} required />
        </label>

        {erro && <p className="erro" role="alert">{erro}</p>}

        <button className="btn largo" type="submit" disabled={enviando}>
          {enviando ? 'Entrando…' : 'Entrar'}
        </button>
      </form>
    </div>
  )
}
