import 'package:flutter/material.dart';

import '../models/estande.dart';
import '../services/circuito_service.dart';
import '../services/missao_service.dart';
import '../widgets/checkin_flow.dart';
import '../widgets/estande_card.dart';

/// Tela da missão surpresa. Ao abrir, registra o evento `missao_aberta`.
class MissaoScreen extends StatefulWidget {
  const MissaoScreen({super.key, required this.missao, required this.circuito});

  final MissaoService missao;
  final CircuitoService circuito;

  @override
  State<MissaoScreen> createState() => _MissaoScreenState();
}

class _MissaoScreenState extends State<MissaoScreen> {
  // Escutas próprias desta tela: os streams do Firestore não repetem o último
  // resultado para quem se inscreve depois, então não dá para reaproveitar os
  // da tela inicial.
  late final Stream<List<Estande>> _estandes = widget.circuito.estandesAtivos();
  late final Stream<Set<String>> _visitados = widget.circuito.estandesVisitados();

  @override
  void initState() {
    super.initState();
    widget.circuito.registrarMissaoAberta(
      quantidadeEstandes: widget.missao.estandesDestacados.length,
    );
  }

  @override
  Widget build(BuildContext context) {
    final textos = Theme.of(context).textTheme;

    return ListenableBuilder(
      listenable: widget.missao,
      builder: (context, _) {
        final missao = widget.missao;
        return Scaffold(
          appBar: AppBar(title: Text(missao.ativa ? missao.titulo : 'Missão')),
          floatingActionButton: missao.ativa
              ? FloatingActionButton.extended(
                  onPressed: () => iniciarCheckin(context, circuito: widget.circuito, missao: missao),
                  icon: const Icon(Icons.qr_code_scanner),
                  label: const Text('Fazer check-in'),
                )
              : null,
          body: !missao.ativa
              ? _MissaoEncerrada(aoVoltar: () => Navigator.of(context).pop())
              : StreamBuilder<List<Estande>>(
                  stream: _estandes,
                  builder: (context, snapEstandes) => StreamBuilder<Set<String>>(
                    stream: _visitados,
                    builder: (context, snapVisitados) {
                      if (!snapEstandes.hasData) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      final participantes =
                          snapEstandes.data!.where((e) => missao.destacado(e.id)).toList();
                      final visitados = snapVisitados.data ?? const <String>{};
                      final concluidos = participantes.where((e) => visitados.contains(e.id)).length;
                      final completa = participantes.isNotEmpty && concluidos == participantes.length;

                      return ListView(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
                        children: [
                          Text(missao.descricao, style: textos.bodyLarge),
                          const SizedBox(height: 16),
                          LinearProgressIndicator(
                            value: participantes.isEmpty ? 0 : concluidos / participantes.length,
                            minHeight: 10,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            completa
                                ? 'Missão completa! Você visitou todos os estandes.'
                                : '$concluidos de ${participantes.length} estandes visitados',
                            style: textos.titleSmall,
                          ),
                          const SizedBox(height: 20),
                          Text('Estandes participantes', style: textos.titleSmall),
                          const SizedBox(height: 8),
                          if (participantes.isEmpty)
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 24),
                              child: Text('Nenhum estande ativo foi selecionado para a missão.'),
                            )
                          else
                            for (final e in participantes) ...[
                              EstandeCard(estande: e, visitado: visitados.contains(e.id), destacado: true),
                              const SizedBox(height: 12),
                            ],
                        ],
                      );
                    },
                  ),
                ),
        );
      },
    );
  }
}

class _MissaoEncerrada extends StatelessWidget {
  const _MissaoEncerrada({required this.aoVoltar});

  final VoidCallback aoVoltar;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.flag_outlined, size: 56),
            const SizedBox(height: 12),
            const Text('A missão surpresa foi encerrada pela organização.', textAlign: TextAlign.center),
            const SizedBox(height: 16),
            FilledButton(onPressed: aoVoltar, child: const Text('Voltar aos estandes')),
          ],
        ),
      ),
    );
  }
}
