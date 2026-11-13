import 'package:flutter/material.dart';

import '../models/estande.dart';
import '../services/circuito_service.dart';
import '../services/missao_service.dart';
import '../widgets/checkin_flow.dart';
import '../widgets/estande_card.dart';
import 'missao_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.missao, required this.circuito});

  final MissaoService missao;
  final CircuitoService circuito;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final Stream<List<Estande>> _estandes = widget.circuito.estandesAtivos();
  late final Stream<Set<String>> _visitados = widget.circuito.estandesVisitados();

  void _abrirMissao() {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => MissaoScreen(missao: widget.missao, circuito: widget.circuito),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Circuito de Descobertas')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => iniciarCheckin(context, circuito: widget.circuito, missao: widget.missao),
        icon: const Icon(Icons.qr_code_scanner),
        label: const Text('Fazer check-in'),
      ),
      body: ListenableBuilder(
        listenable: widget.missao,
        builder: (context, _) => StreamBuilder<List<Estande>>(
          stream: _estandes,
          builder: (context, snapEstandes) => StreamBuilder<Set<String>>(
            stream: _visitados,
            builder: (context, snapVisitados) {
              if (snapEstandes.hasError) {
                return _Mensagem(icone: Icons.error_outline, texto: 'Erro ao carregar estandes:\n${snapEstandes.error}');
              }
              if (!snapEstandes.hasData) {
                return const Center(child: CircularProgressIndicator());
              }
              final estandes = snapEstandes.data!;
              final visitados = snapVisitados.data ?? const <String>{};
              final missao = widget.missao;
              final daMissao = estandes.where((e) => missao.destacado(e.id)).toList();

              return ListView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
                children: [
                  if (missao.ativa) ...[
                    _ChamadaMissao(
                      titulo: missao.titulo,
                      total: daMissao.length,
                      concluidos: daMissao.where((e) => visitados.contains(e.id)).length,
                      aoAbrir: _abrirMissao,
                    ),
                    const SizedBox(height: 16),
                  ],
                  Text('Estandes da feira', style: Theme.of(context).textTheme.titleSmall),
                  const SizedBox(height: 8),
                  if (estandes.isEmpty)
                    const _Mensagem(icone: Icons.storefront_outlined, texto: 'Nenhum estande ativo no momento.')
                  else
                    for (final e in estandes) ...[
                      EstandeCard(
                        estande: e,
                        visitado: visitados.contains(e.id),
                        destacado: missao.destacado(e.id),
                      ),
                      const SizedBox(height: 12),
                    ],
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _ChamadaMissao extends StatelessWidget {
  const _ChamadaMissao({
    required this.titulo,
    required this.total,
    required this.concluidos,
    required this.aoAbrir,
  });

  final String titulo;
  final int total;
  final int concluidos;
  final VoidCallback aoAbrir;

  @override
  Widget build(BuildContext context) {
    final cores = Theme.of(context).colorScheme;
    return Material(
      borderRadius: BorderRadius.circular(20),
      clipBehavior: Clip.antiAlias,
      child: Ink(
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [cores.tertiary, cores.primary]),
        ),
        child: InkWell(
          onTap: aoAbrir,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                const Icon(Icons.flag_circle, color: Colors.white, size: 48),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(titulo,
                          style: Theme.of(context)
                              .textTheme
                              .titleLarge
                              ?.copyWith(color: Colors.white, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Text(
                        total == 0
                            ? 'Toque para ver os detalhes'
                            : '$concluidos de $total estandes visitados · toque para abrir',
                        style: const TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right, color: Colors.white),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Mensagem extends StatelessWidget {
  const _Mensagem({required this.icone, required this.texto});

  final IconData icone;
  final String texto;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 24),
      child: Column(
        children: [
          Icon(icone, size: 48, color: Theme.of(context).colorScheme.onSurfaceVariant),
          const SizedBox(height: 12),
          Text(texto, textAlign: TextAlign.center),
        ],
      ),
    );
  }
}
