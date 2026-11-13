import 'package:flutter/material.dart';

import '../screens/scanner_screen.dart';
import '../services/circuito_service.dart';
import '../services/missao_service.dart';

/// Fluxo completo de check-in: câmera → validação/gravação → retorno visual.
Future<void> iniciarCheckin(
  BuildContext context, {
  required CircuitoService circuito,
  required MissaoService missao,
}) async {
  final conteudo = await Navigator.of(context).push<String>(
    MaterialPageRoute(builder: (_) => const ScannerScreen()),
  );
  if (conteudo == null || !context.mounted) return;

  showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (_) => const Center(child: CircularProgressIndicator()),
  );
  final resultado = await circuito.registrarCheckin(conteudo, emMissao: missao.destacado);
  if (!context.mounted) return;
  Navigator.of(context).pop(); // fecha o carregando

  await showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    builder: (_) => _ResultadoSheet(resultado: resultado),
  );
}

class _ResultadoSheet extends StatelessWidget {
  const _ResultadoSheet({required this.resultado});

  final ResultadoCheckin resultado;

  @override
  Widget build(BuildContext context) {
    final nome = resultado.estande?.nome;
    final (IconData icone, Color cor, String titulo, String texto) = switch (resultado.tipo) {
      TipoResultado.sucesso => (
          Icons.check_circle,
          Colors.green.shade700,
          'Check-in confirmado!',
          'Sua visita ao estande "$nome" foi registrada.',
        ),
      TipoResultado.jaRegistrado => (
          Icons.history,
          Colors.blue.shade700,
          'Visita já registrada',
          'Você já fez check-in no estande "$nome". Cada visitante registra uma visita por estande.',
        ),
      TipoResultado.estandeInativo => (
          Icons.block,
          Colors.orange.shade800,
          'Estande inativo',
          nome == null
              ? 'Este estande não está ativo no momento. Nada foi registrado.'
              : 'O estande "$nome" não está ativo no momento. Nada foi registrado.',
        ),
      TipoResultado.estandeInexistente => (
          Icons.qr_code_2,
          Colors.red.shade700,
          'QR inválido',
          'Este QR aponta para um estande que não existe no circuito.',
        ),
      TipoResultado.qrInvalido => (
          Icons.qr_code_2,
          Colors.red.shade700,
          'QR inválido',
          'Este QR code não pertence ao Circuito de Descobertas.',
        ),
      TipoResultado.erro => (
          Icons.error_outline,
          Colors.red.shade700,
          'Não foi possível registrar',
          resultado.detalhe ?? 'Tente novamente em instantes.',
        ),
    };

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icone, color: cor, size: 64),
            const SizedBox(height: 12),
            Text(titulo, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            Text(texto, textAlign: TextAlign.center),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
