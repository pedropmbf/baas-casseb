// Mesmo formato lido pelo app Flutter (app/lib/qr_payload.dart).
export const QR_PREFIXO = 'circuito://estande/'

export const conteudoQr = (estandeId) => `${QR_PREFIXO}${estandeId}`
