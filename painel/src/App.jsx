import { signOut } from 'firebase/auth'
import { BrowserRouter, Navigate, Route, Routes } from 'react-router-dom'
import { auth, configurado } from './firebase'
import { useAdmin } from './useAdmin'
import Dashboard from './pages/Dashboard.jsx'
import Login from './pages/Login.jsx'
import QrPage from './pages/QrPage.jsx'

export default function App() {
  if (!configurado) return <ConfigFaltando />
  return (
    <BrowserRouter>
      <Shell />
    </BrowserRouter>
  )
}

function Shell() {
  const sessao = useAdmin()

  if (sessao.status === 'carregando') {
    return <div className="centro"><div className="spinner" aria-label="Carregando" /></div>
  }
  if (sessao.status === 'deslogado') return <Login />
  if (sessao.status === 'semPermissao') return <SemPermissao user={sessao.user} erro={sessao.erro} />

  return (
    <Routes>
      <Route path="/" element={<Dashboard user={sessao.user} />} />
      <Route path="/qr/:id" element={<QrPage />} />
      <Route path="*" element={<Navigate to="/" replace />} />
    </Routes>
  )
}

function SemPermissao({ user, erro }) {
  return (
    <div className="centro">
      <div className="cartao estreito">
        <h1>Acesso restrito</h1>
        <p>
          A conta <strong>{user.email ?? 'anônima'}</strong> entrou, mas não está cadastrada como
          administradora da feira.
        </p>
        <p>
          No console do Firebase, abra <strong>Firestore → Dados</strong>, crie a coleção{' '}
          <code>admins</code> e um documento com este ID:
        </p>
        <pre className="codigo">{user.uid}</pre>
        {erro && <p className="erro">{erro}</p>}
        <div className="acoes">
          <button className="btn" onClick={() => navigator.clipboard.writeText(user.uid)}>Copiar UID</button>
          <button className="btn secundario" onClick={() => window.location.reload()}>Já cadastrei</button>
          <button className="btn fantasma" onClick={() => signOut(auth)}>Sair</button>
        </div>
      </div>
    </div>
  )
}

function ConfigFaltando() {
  return (
    <div className="centro">
      <div className="cartao estreito">
        <h1>Firebase não configurado</h1>
        <p>
          Copie <code>painel/.env.example</code> para <code>painel/.env.local</code> e preencha com a
          configuração do app web do seu projeto Firebase. Depois reinicie <code>npm run dev</code>.
        </p>
      </div>
    </div>
  )
}
