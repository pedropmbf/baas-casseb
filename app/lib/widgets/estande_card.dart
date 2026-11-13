import 'package:flutter/material.dart';

import '../models/estande.dart';

class EstandeCard extends StatelessWidget {
  const EstandeCard({
    super.key,
    required this.estande,
    required this.visitado,
    required this.destacado,
  });

  final Estande estande;
  final bool visitado;
  final bool destacado;

  @override
  Widget build(BuildContext context) {
    final cores = Theme.of(context).colorScheme;
    final textos = Theme.of(context).textTheme;

    return Card(
      elevation: destacado ? 3 : 0,
      color: destacado ? cores.tertiaryContainer : cores.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: destacado ? BorderSide(color: cores.tertiary, width: 2) : BorderSide.none,
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                if (destacado) ...[
                  Icon(Icons.star_rounded, color: cores.tertiary),
                  const SizedBox(width: 6),
                ],
                Expanded(child: Text(estande.nome, style: textos.titleMedium)),
                if (visitado)
                  Chip(
                    avatar: const Icon(Icons.check, size: 18),
                    label: const Text('Visitado'),
                    visualDensity: VisualDensity.compact,
                    backgroundColor: cores.primaryContainer,
                    side: BorderSide.none,
                  ),
              ],
            ),
            if (estande.descricao.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(estande.descricao, style: textos.bodyMedium),
            ],
            if (estande.localizacao.isNotEmpty) ...[
              const SizedBox(height: 10),
              Row(
                children: [
                  Icon(Icons.place_outlined, size: 18, color: cores.onSurfaceVariant),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      estande.localizacao,
                      style: textos.bodySmall?.copyWith(color: cores.onSurfaceVariant),
                    ),
                  ),
                ],
              ),
            ],
            if (destacado) ...[
              const SizedBox(height: 10),
              Text('Faz parte da missão surpresa',
                  style: textos.labelMedium?.copyWith(color: cores.onTertiaryContainer)),
            ],
          ],
        ),
      ),
    );
  }
}
