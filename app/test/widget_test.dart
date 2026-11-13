import 'package:circuito_descobertas/qr_payload.dart';
import 'package:circuito_descobertas/services/missao_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('QrPayload', () {
    test('extrai o id de um QR do circuito', () {
      expect(QrPayload.extrairEstandeId('circuito://estande/abc123XYZ'), 'abc123XYZ');
      expect(QrPayload.extrairEstandeId('  circuito://estande/a_b-c \n'), 'a_b-c');
    });

    test('gerar e extrair são inversos', () {
      expect(QrPayload.extrairEstandeId(QrPayload.gerar('K9xQ2')), 'K9xQ2');
    });

    test('rejeita QRs que não são do circuito', () {
      for (final invalido in [
        null,
        '',
        'abc123',
        'https://exemplo.com',
        'circuito://estande/',
        'circuito://estande/a/b',
        'circuito://outra/abc',
      ]) {
        expect(QrPayload.extrairEstandeId(invalido), isNull, reason: '$invalido');
      }
    });
  });

  group('MissaoService.interpretarIds', () {
    test('aceita vírgulas, espaços e JSON', () {
      expect(MissaoService.interpretarIds(''), isEmpty);
      expect(MissaoService.interpretarIds('a,b , c'), {'a', 'b', 'c'});
      expect(MissaoService.interpretarIds('a b\nc'), {'a', 'b', 'c'});
      expect(MissaoService.interpretarIds('["a","b"]'), {'a', 'b'});
    });
  });
}
