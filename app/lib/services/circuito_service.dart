import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/estande.dart';
import '../qr_payload.dart';

enum TipoResultado { sucesso, qrInvalido, estandeInexistente, estandeInativo, jaRegistrado, erro }

class ResultadoCheckin {
  const ResultadoCheckin(this.tipo, {this.estande, this.detalhe});

  final TipoResultado tipo;
  final Estande? estande;
  final String? detalhe;
}

/// Acesso ao Firestore (estandes e check-ins) e eventos do Analytics.
class CircuitoService {
  CircuitoService({FirebaseFirestore? db, FirebaseAuth? auth, FirebaseAnalytics? analytics})
      : _db = db ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance,
        _analytics = analytics ?? FirebaseAnalytics.instance;

  final FirebaseFirestore _db;
  final FirebaseAuth _auth;
  final FirebaseAnalytics _analytics;

  static const _limite = Duration(seconds: 15);

  CollectionReference<Map<String, dynamic>> get _estandes => _db.collection('estandes');
  CollectionReference<Map<String, dynamic>> get _checkins => _db.collection('checkins');

  String get _uid {
    final user = _auth.currentUser;
    if (user == null) throw StateError('Visitante não autenticado.');
    return user.uid;
  }

  /// Estandes ativos, em ordem alfabética. A consulta filtra `ativo == true`
  /// porque as regras só liberam ao visitante a leitura de estandes ativos.
  Stream<List<Estande>> estandesAtivos() {
    return _estandes.where('ativo', isEqualTo: true).snapshots().map((snap) {
      final lista = snap.docs.map(Estande.fromDoc).toList()
        ..sort((a, b) => a.nome.toLowerCase().compareTo(b.nome.toLowerCase()));
      return lista;
    });
  }

  /// IDs dos estandes que este visitante já visitou.
  Stream<Set<String>> estandesVisitados() {
    return _checkins.where('visitanteId', isEqualTo: _uid).snapshots().map(
          (snap) => snap.docs.map((d) => d.data()['estandeId'] as String).toSet(),
        );
  }

  Future<void> registrarMissaoAberta({required int quantidadeEstandes}) {
    return _analytics.logEvent(
      name: 'missao_aberta',
      parameters: {'quantidade_estandes': quantidadeEstandes},
    );
  }

  /// Valida o QR, o estande e a duplicidade antes de gravar o check-in.
  Future<ResultadoCheckin> registrarCheckin(String? conteudoQr, {required bool Function(String) emMissao}) async {
    final estandeId = QrPayload.extrairEstandeId(conteudoQr);
    if (estandeId == null) {
      return const ResultadoCheckin(TipoResultado.qrInvalido);
    }

    // 1. O estande existe e está ativo?
    final Estande estande;
    try {
      final snap = await _estandes.doc(estandeId).get(const GetOptions(source: Source.server)).timeout(_limite);
      if (!snap.exists) {
        return const ResultadoCheckin(TipoResultado.estandeInexistente);
      }
      estande = Estande.fromDoc(snap);
      if (!estande.ativo) {
        return ResultadoCheckin(TipoResultado.estandeInativo, estande: estande);
      }
    } on FirebaseException catch (e) {
      // As regras negam ao visitante a leitura de um estande inativo.
      if (e.code == 'permission-denied') {
        return const ResultadoCheckin(TipoResultado.estandeInativo);
      }
      return ResultadoCheckin(TipoResultado.erro, detalhe: _mensagem(e));
    } on TimeoutException {
      return const ResultadoCheckin(TipoResultado.erro, detalhe: 'Sem conexão com o servidor.');
    }

    // 2. Uma visita por visitante e por estande: chave composta uid_estande.
    final uid = _uid;
    final ref = _checkins.doc('${uid}_$estandeId');
    try {
      final existente = await ref.get(const GetOptions(source: Source.server)).timeout(_limite);
      if (existente.exists) {
        return ResultadoCheckin(TipoResultado.jaRegistrado, estande: estande);
      }
      await ref.set({
        'visitanteId': uid,
        'estandeId': estandeId,
        'criadoEm': FieldValue.serverTimestamp(),
      }).timeout(_limite);
    } on FirebaseException catch (e) {
      return ResultadoCheckin(TipoResultado.erro, estande: estande, detalhe: _mensagem(e));
    } on TimeoutException {
      return ResultadoCheckin(TipoResultado.erro, estande: estande, detalhe: 'Sem conexão com o servidor.');
    }

    // 3. Evento de uso no Google Analytics (somente dados fictícios).
    await _analytics.logEvent(
      name: 'checkin_concluido',
      parameters: {
        'estande_id': estandeId,
        'em_missao': emMissao(estandeId) ? 'sim' : 'nao',
      },
    );

    return ResultadoCheckin(TipoResultado.sucesso, estande: estande);
  }

  String _mensagem(FirebaseException e) {
    switch (e.code) {
      case 'permission-denied':
        return 'O servidor recusou o registro (permissão negada).';
      case 'unavailable':
        return 'Servidor indisponível. Verifique a internet.';
      default:
        return e.message ?? e.code;
    }
  }
}
