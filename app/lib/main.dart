import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'firebase_options.dart';
import 'screens/home_screen.dart';
import 'services/circuito_service.dart';
import 'services/missao_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  Object? erroConfiguracao;
  MissaoService? missao;
  try {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
    missao = MissaoService();
    await missao.iniciar();
  } catch (e) {
    erroConfiguracao = e;
  }

  runApp(CircuitoApp(missao: missao, erroConfiguracao: erroConfiguracao));
}

class CircuitoApp extends StatelessWidget {
  const CircuitoApp({super.key, required this.missao, this.erroConfiguracao});

  final MissaoService? missao;
  final Object? erroConfiguracao;

  @override
  Widget build(BuildContext context) {
    final esquema = ColorScheme.fromSeed(seedColor: const Color(0xFF0B7A5A));
    return MaterialApp(
      title: 'Circuito de Descobertas',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: esquema,
        useMaterial3: true,
        cardTheme: const CardThemeData(margin: EdgeInsets.zero),
      ),
      home: erroConfiguracao != null || missao == null
          ? _TelaErro(mensagem: '$erroConfiguracao')
          : _AuthGate(missao: missao!),
    );
  }
}

/// Garante uma sessão anônima para o visitante antes de abrir o app.
class _AuthGate extends StatefulWidget {
  const _AuthGate({required this.missao});

  final MissaoService missao;

  @override
  State<_AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<_AuthGate> {
  late Future<User> _sessao = _entrar();

  Future<User> _entrar() async {
    final auth = FirebaseAuth.instance;
    final atual = auth.currentUser;
    if (atual != null) return atual;
    final cred = await auth.signInAnonymously();
    return cred.user!;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<User>(
      future: _sessao,
      builder: (context, snap) {
        if (snap.hasData) {
          return HomeScreen(missao: widget.missao, circuito: CircuitoService());
        }
        if (snap.hasError) {
          return _TelaErro(
            mensagem: 'Não foi possível iniciar a sessão de visitante.\n${snap.error}',
            aoTentarNovamente: () => setState(() => _sessao = _entrar()),
          );
        }
        return const Scaffold(body: Center(child: CircularProgressIndicator()));
      },
    );
  }
}

class _TelaErro extends StatelessWidget {
  const _TelaErro({required this.mensagem, this.aoTentarNovamente});

  final String mensagem;
  final VoidCallback? aoTentarNovamente;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.cloud_off, size: 56),
              const SizedBox(height: 16),
              Text(mensagem, textAlign: TextAlign.center),
              if (aoTentarNovamente != null) ...[
                const SizedBox(height: 16),
                FilledButton(onPressed: aoTentarNovamente, child: const Text('Tentar novamente')),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
