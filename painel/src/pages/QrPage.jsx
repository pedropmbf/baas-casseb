import { doc, getDoc } from 'firebase/firestore'
import { QRCodeSVG } from 'qrcode.react'
import { useEffect, useState } from 'react'
import { Link, useParams } from 'react-router-dom'
import { db } from '../firebase'
import { conteudoQr } from '../qr'

/** QR de um estande em tela cheia, pronto para exibir em outra tela ou imprimir. */
export default function QrPage() {
  const { id } = useParams()
  const [estado, setEstado] = useState({ carregando: true })

  useEffect(() => {
    getDoc(doc(db, 'estandes', id))
      .then((snap) => setEstado(snap.exists() ? { estande: snap.data() } : { erro: 'Estande não encontrado.' }))
      .catch((e) => setEstado({ erro: e.message }))
  }, [id])

  if (estado.carregando) return <div className="centro"><div className="spinner" /></div>
  if (estado.erro) {
    return (
      <div className="centro">
        <div className="cartao estreito">
          <h1>QR indisponível</h1>
          <p className="erro">{estado.erro}</p>
          <Link className="btn" to="/">Voltar ao painel</Link>
        </div>
      </div>
    )
  }

  const { estande } = estado
  return (
    <div className="qr-pagina">
      <div className="qr-folha">
        <p className="sobretitulo">Circuito de Descobertas · Amazon Hacking</p>
        <h1>{estande.nome}</h1>
        {estande.localizacao && <p className="qr-local">{estande.localizacao}</p>}
        <div className="qr-codigo">
          <QRCodeSVG value={conteudoQr(id)} size={340} level="M" marginSize={2} title={`QR do estande ${estande.nome}`} />
        </div>
        <p className="qr-instrucao">Abra o app <strong>Circuito de Descobertas</strong>, toque em
          “Fazer check-in” e aponte a câmera para este código.</p>
        {!estande.ativo && <p className="aviso">Este estande está INATIVO: o app recusa o check-in.</p>}
        <p className="qr-id">{conteudoQr(id)}</p>
      </div>
      <div className="acoes nao-imprimir">
        <button className="btn" onClick={() => window.print()}>Imprimir</button>
        <Link className="btn fantasma" to="/">Voltar ao painel</Link>
      </div>
    </div>
  )
}
