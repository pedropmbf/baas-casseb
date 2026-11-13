import 'dart:async';
import 'dart:convert';

import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/foundation.dart';

/// Lê a "missão surpresa" do Firebase Remote Config e avisa a interface
/// sempre que o console publica uma alteração (atualização em tempo real).
///
/// Parâmetros usados no console:
/// - `missao_ativa` (booleano)          — liga/desliga a missão.
/// - `missao_estandes` (string)         — IDs dos estandes destacados,
///                                        separados por vírgula ou em JSON.
/// - `missao_titulo` (string, opcional)
/// - `missao_descricao` (string, opcional)
class MissaoService extends ChangeNotifier {
  MissaoService({FirebaseRemoteConfig? remoteConfig})
      : _rc = remoteConfig ?? FirebaseRemoteConfig.instance;

  final FirebaseRemoteConfig _rc;
  StreamSubscription<RemoteConfigUpdate>? _tempoReal;

  /// Padrões locais: a missão começa DESLIGADA, como pede a atividade.
  static const padroes = <String, dynamic>{
    'missao_ativa': false,
    'missao_estandes': '',
    'missao_titulo': 'Missão surpresa!',
    'missao_descricao':
        'Visite os estandes destacados e faça o check-in em cada um deles.',
  };

  bool get ativa => _rc.getBool('missao_ativa');
  String get titulo => _rc.getString('missao_titulo');
  String get descricao => _rc.getString('missao_descricao');
  Set<String> get estandesDestacados =>
      interpretarIds(_rc.getString('missao_estandes'));

  bool destacado(String estandeId) => ativa && estandesDestacados.contains(estandeId);

  Future<void> iniciar() async {
    await _rc.setConfigSettings(RemoteConfigSettings(
      fetchTimeout: const Duration(seconds: 10),
      minimumFetchInterval: const Duration(minutes: 1),
    ));
    await _rc.setDefaults(padroes);

    // Busca inicial sem travar a abertura do app: a interface começa com os
    // valores em cache/padrão e é atualizada quando a resposta chega.
    unawaited(_buscarInicial());

    // Atualização em tempo real: o console publica, o app ativa na hora,
    // sem recompilar nem reinstalar.
    _tempoReal = _rc.onConfigUpdated.listen(
      (_) async {
        await _rc.activate();
        notifyListeners();
      },
      onError: (Object e) => debugPrint('Remote Config tempo real: $e'),
    );
  }

  Future<void> _buscarInicial() async {
    try {
      await _rc.fetchAndActivate();
    } catch (e) {
      debugPrint('Remote Config fetch: $e');
    }
    notifyListeners();
  }

  /// Aceita `id1,id2`, `id1 id2` ou `["id1","id2"]`.
  static Set<String> interpretarIds(String bruto) {
    final texto = bruto.trim();
    if (texto.isEmpty) return {};
    if (texto.startsWith('[')) {
      try {
        final lista = jsonDecode(texto) as List<dynamic>;
        return lista.map((e) => e.toString().trim()).where((e) => e.isNotEmpty).toSet();
      } catch (_) {
        // cai no formato separado por vírgula
      }
    }
    return texto
        .split(RegExp(r'[,;\s]+'))
        .map((e) => e.replaceAll('"', '').trim())
        .where((e) => e.isNotEmpty)
        .toSet();
  }

  @override
  void dispose() {
    _tempoReal?.cancel();
    super.dispose();
  }
}
