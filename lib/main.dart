
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'estado/sesion_provider.dart';
import 'pantallas/login_screen.dart';
import 'pantallas/listado_screen.dart';

void main() {
  runApp(
    const ProviderScope(
      child: Parcial2App(),
    ),
  );
}

class Parcial2App extends ConsumerWidget {
  const Parcial2App({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final correo = ref.watch(sesionProvider);

    return MaterialApp(
      title: 'Acceso y listado',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.indigo,
        ),
        useMaterial3: true,
      ),
      home: correo == null
          ? const LoginScreen()
          : const ListadoScreen(),
    );
  }
}
