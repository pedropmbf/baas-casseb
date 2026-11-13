import { signOut } from 'firebase/auth'
import {
  addDoc, collection, doc, onSnapshot, serverTimestamp, updateDoc, writeBatch,
} from 'firebase/firestore'
import { useEffect, useMemo, useRef, useState } from 'react'
import { auth, db, projectId } from '../firebase'

const VAZIO = { nome: '', descricao: '', localizacao: '', ativo: true }

const EXEMPLOS = [
  {
    nome: 'EcoRota — Coleta Seletiva',
    descricao: 'App que mostra pontos de coleta e recompensa o descarte correto de resíduos.',
    localizacao: 'Corredor A · Estande 03',
    ativo: true,
  },
  {
    nome: 'AçaíTech — Rastreio do Açaí',
    descricao: 'Rastreabilidade do açaí do ribeirinho ao consumidor com QR codes nos lotes.',
    localizacao: 'Corredor B · Estande 11',
    ativo: true,
  },
  {
    nome: 'MaréAlerta — Previsão de Cheias',
    descricao: 'Sensores de baixo custo e alertas por SMS para comunidades ribeirinhas.',
    localizacao: 'Corredor C · Estande 18',
    ativo: true,
  },
  {
    nome: 'Visão Amazônica — Museu em RA',
    descricao: 'Realidade aumentada para acervos de museus da região. (Em montagem.)',
    localizacao: 'Corredor D · Estande 22',
    ativo: false,
  },
]

/** Escuta uma coleção inteira do Firestore em tempo real. */
function useColecao(nome) {
  const [estado, setEstado] = useState({ docs: [], carregando: true, erro: null })
  useEffect(() => onSnapshot(
    collection(db, nome),
    (snap) => setEstado({ docs: snap.docs.map((d) => ({ id: d.id, ...d.data() })), carregando: false, erro: null }),
    (erro) => setEstado({ docs: [], carregando: false, erro: erro.message }),
  ), [nome])
  return estado
}

export default function Dashboard({ user }) {
  const estandes = useColecao('estandes')
  const checkins = useColecao('checkins')

  const [form, setForm] = useState(VAZIO)
  const [editandoId, setEditandoId] = useState(null)
  const [salvando, setSalvando] = useState(false)
  const [erro, setErro] = useState('')
  const [selecionados, setSelecionados] = useState(() => new Set())
  const [copiado, setCopiado] = useState('')
  const [pulsando, setPulsando] = useState(() => new Set())

  const lista = useMemo(
    () => [...estandes.docs].sort((a, b) => (a.nome ?? '').localeCompare(b.nome ?? '', 'pt-BR')),
    [estandes.docs],
  )
  const nomes = useMemo(() => Object.fromEntries(lista.map((e) => [e.id, e.nome])), [lista])

  // Total de check-ins confirmados por estande, calculado a partir dos registros.
  const totais = useMemo(() => {
    const t = {}
    for (const c of checkins.docs) t[c.estandeId] = (t[c.estandeId] ?? 0) + 1
    return t
  }, [checkins.docs])

  const recentes = useMemo(
    () => [...checkins.docs]
      .sort((a, b) => (b.criadoEm?.toMillis?.() ?? 0) - (a.criadoEm?.toMillis?.() ?? 0))
      .slice(0, 6),
    [checkins.docs],
  )

  // Destaca por alguns segundos a linha cujo total acabou de mudar.
  const anteriores = useRef(null)
  useEffect(() => {
    if (checkins.carregando) return undefined
    const antes = anteriores.current
    anteriores.current = totais
    if (!antes) return undefined
    const mudaram = Object.keys(totais).filter((id) => totais[id] !== antes[id])
    if (mudaram.length === 0) return undefined
    setPulsando(new Set(mudaram))
    const t = setTimeout(() => setPulsando(new Set()), 2500)
    return () => clearTimeout(t)
  }, [totais, checkins.carregando])

  const ativos = lista.filter((e) => e.ativo).length

  function editar(e) {
    setEditandoId(e.id)
    setForm({ nome: e.nome ?? '', descricao: e.descricao ?? '', localizacao: e.localizacao ?? '', ativo: e.ativo === true })
    setErro('')
    window.scrollTo({ top: 0, behavior: 'smooth' })
  }

  function cancelar() {
    setEditandoId(null)
    setForm(VAZIO)
    setErro('')
  }

  async function salvar(ev) {
    ev.preventDefault()
    const dados = {
      nome: form.nome.trim(),
      descricao: form.descricao.trim(),
      localizacao: form.localizacao.trim(),
      ativo: form.ativo,
    }
    if (!dados.nome) return setErro('Informe o nome do estande.')
    setSalvando(true)
    setErro('')
    try {
      if (editandoId) {
        await updateDoc(doc(db, 'estandes', editandoId), { ...dados, atualizadoEm: serverTimestamp() })
      } else {
        await addDoc(collection(db, 'estandes'), { ...dados, criadoEm: serverTimestamp(), atualizadoEm: serverTimestamp() })
      }
      cancelar()
    } catch (e) {
      setErro(e.message)
    } finally {
      setSalvando(false)
    }
  }

  async function alternarAtivo(e) {
    try {
      await updateDoc(doc(db, 'estandes', e.id), { ativo: !e.ativo, atualizadoEm: serverTimestamp() })
    } catch (err) {
      setErro(err.message)
    }
  }

  async function criarExemplos() {
    const lote = writeBatch(db)
    for (const ex of EXEMPLOS) {
      lote.set(doc(collection(db, 'estandes')), { ...ex, criadoEm: serverTimestamp(), atualizadoEm: serverTimestamp() })
    }
    try {
      await lote.commit()
    } catch (e) {
      setErro(e.message)
    }
  }

  function alternarSelecao(id) {
    setSelecionados((s) => {
      const n = new Set(s)
      if (n.has(id)) n.delete(id)
      else n.add(id)
      return n
    })
  }

  async function copiar(texto, rotulo) {
    try {
      await navigator.clipboard.writeText(texto)
      setCopiado(rotulo)
      setTimeout(() => setCopiado(''), 1800)
    } catch {
      setCopiado('')
    }
  }

  const valorMissao = lista.filter((e) => selecionados.has(e.id)).map((e) => e.id).join(',')
  const linkRemoteConfig = projectId
    ? `https://console.firebase.google.com/project/${projectId}/config`
    : 'https://console.firebase.google.com/'

  return (
    <div className="pagina">
      <header className="topo">
        <div>
          <p className="sobretitulo">Amazon Hacking · Organização</p>
          <h1>Circuito de Descobertas</h1>
        </div>
        <div className="topo-usuario">
          <span className="suave">{user.email}</span>
          <button className="btn fantasma" onClick={() => signOut(auth)}>Sair</button>
        </div>
      </header>

      <section className="metricas">
        <Metrica rotulo="Estandes cadastrados" valor={lista.length} />
        <Metrica rotulo="Estandes ativos" valor={ativos} />
        <Metrica rotulo="Check-ins confirmados" valor={checkins.docs.length} destaque={pulsando.size > 0} />
      </section>

      {(estandes.erro || checkins.erro) && (
        <p className="erro">Erro ao ler o Firestore: {estandes.erro || checkins.erro}</p>
      )}

      <div className="grade">
        <section className="cartao">
          <h2>{editandoId ? 'Editar estande' : 'Novo estande'}</h2>
          <form onSubmit={salvar}>
            <label className="campo">
              <span>Nome</span>
              <input value={form.nome} maxLength={80} required
                onChange={(e) => setForm({ ...form, nome: e.target.value })} />
            </label>
            <label className="campo">
              <span>Descrição breve</span>
              <textarea value={form.descricao} maxLength={300} rows={3}
                onChange={(e) => setForm({ ...form, descricao: e.target.value })} />
            </label>
            <label className="campo">
              <span>Localização</span>
              <input value={form.localizacao} maxLength={80} placeholder="Ex.: Corredor B · Estande 11"
                onChange={(e) => setForm({ ...form, localizacao: e.target.value })} />
            </label>
            <label className="interruptor">
              <input type="checkbox" checked={form.ativo}
                onChange={(e) => setForm({ ...form, ativo: e.target.checked })} />
              <span>Estande ativo (visível no app e aceita check-in)</span>
            </label>
            {erro && <p className="erro" role="alert">{erro}</p>}
            <div className="acoes">
              <button className="btn" type="submit" disabled={salvando}>
                {salvando ? 'Salvando…' : editandoId ? 'Salvar alterações' : 'Cadastrar estande'}
              </button>
              {editandoId && <button className="btn fantasma" type="button" onClick={cancelar}>Cancelar</button>}
            </div>
          </form>
        </section>

        <section className="cartao">
          <h2>Missão surpresa</h2>
          <p className="suave">
            Marque na tabela os estandes da missão e cole o valor abaixo no parâmetro{' '}
            <code>missao_estandes</code> do Remote Config. Depois ligue <code>missao_ativa</code> e publique.
          </p>
          <pre className="codigo">{valorMissao || '(nenhum estande marcado)'}</pre>
          <div className="acoes">
            <button className="btn secundario" disabled={!valorMissao}
              onClick={() => copiar(valorMissao, 'missao')}>
              {copiado === 'missao' ? 'Copiado!' : 'Copiar valor'}
            </button>
            <a className="btn fantasma" href={linkRemoteConfig} target="_blank" rel="noreferrer">
              Abrir Remote Config ↗
            </a>
          </div>

          <h3>Últimos check-ins</h3>
          {recentes.length === 0 ? (
            <p className="suave">Nenhum check-in ainda.</p>
          ) : (
            <ul className="feed">
              {recentes.map((c) => (
                <li key={c.id}>
                  <strong>{nomes[c.estandeId] ?? c.estandeId}</strong>
                  <span className="suave">
                    visitante {String(c.visitanteId).slice(0, 6)}… · {formatarHora(c.criadoEm)}
                  </span>
                </li>
              ))}
            </ul>
          )}
        </section>
      </div>

      <section className="cartao">
        <div className="cabecalho-secao">
          <h2>Estandes</h2>
          {!estandes.carregando && lista.length === 0 && (
            <button className="btn secundario" onClick={criarExemplos}>Criar estandes de exemplo</button>
          )}
        </div>

        {estandes.carregando ? (
          <div className="spinner" />
        ) : lista.length === 0 ? (
          <p className="suave">Nenhum estande cadastrado. Use o formulário ou crie os exemplos fictícios.</p>
        ) : (
          <div className="tabela-rolagem">
            <table className="tabela">
              <thead>
                <tr>
                  <th title="Incluir na missão">Missão</th>
                  <th>Estande</th>
                  <th>Localização</th>
                  <th>Status</th>
                  <th className="num">Check-ins</th>
                  <th>Ações</th>
                </tr>
              </thead>
              <tbody>
                {lista.map((e) => (
                  <tr key={e.id} className={pulsando.has(e.id) ? 'pulsar' : ''}>
                    <td>
                      <input type="checkbox" aria-label={`Incluir ${e.nome} na missão`}
                        checked={selecionados.has(e.id)} onChange={() => alternarSelecao(e.id)} />
                    </td>
                    <td>
                      <strong>{e.nome}</strong>
                      {e.descricao && <div className="suave pequeno">{e.descricao}</div>}
                      <button className="id-estande" title="Copiar ID" onClick={() => copiar(e.id, e.id)}>
                        {copiado === e.id ? 'ID copiado!' : e.id}
                      </button>
                    </td>
                    <td>{e.localizacao}</td>
                    <td>
                      <button className={`etiqueta ${e.ativo ? 'ativo' : 'inativo'}`} onClick={() => alternarAtivo(e)}
                        title="Clique para alternar">
                        {e.ativo ? 'Ativo' : 'Inativo'}
                      </button>
                    </td>
                    <td className="num total">{totais[e.id] ?? 0}</td>
                    <td className="acoes-linha">
                      <a className="btn pequeno" href={`/qr/${e.id}`} target="_blank" rel="noreferrer">QR code ↗</a>
                      <button className="btn pequeno fantasma" onClick={() => editar(e)}>Editar</button>
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        )}
      </section>
    </div>
  )
}

function Metrica({ rotulo, valor, destaque }) {
  return (
    <div className={`metrica ${destaque ? 'pulsar' : ''}`}>
      <span className="metrica-valor">{valor}</span>
      <span className="metrica-rotulo">{rotulo}</span>
    </div>
  )
}

function formatarHora(ts) {
  const d = ts?.toDate?.()
  return d ? d.toLocaleTimeString('pt-BR', { hour: '2-digit', minute: '2-digit', second: '2-digit' }) : 'agora'
}
