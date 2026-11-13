/// Formato do conteúdo dos QR codes gerados pelo painel web.
///
/// O painel codifica `circuito://estande/<id-do-documento>`. Qualquer outro
/// conteúdo é tratado como QR inválido.
class QrPayload {
  static const prefixo = 'circuito://estande/';

  static final _formato = RegExp(r'^circuito://estande/([A-Za-z0-9_-]{1,128})$');

  /// Retorna o identificador do estande ou `null` se o QR não for do circuito.
  static String? extrairEstandeId(String? conteudo) {
    if (conteudo == null) return null;
    final match = _formato.firstMatch(conteudo.trim());
    return match?.group(1);
  }

  static String gerar(String estandeId) => '$prefixo$estandeId';
}
