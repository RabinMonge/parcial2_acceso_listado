
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../estado/sesion_provider.dart';
import '../estado/usuario_registrado_provider.dart';
import '../widgets/campo_formulario.dart';
import 'registro_screen.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() =>
      _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();

  final _correoController = TextEditingController();
  final _contrasenaController = TextEditingController();

  bool _cargando = false;

  @override
  void dispose() {
    _correoController.dispose();
    _contrasenaController.dispose();
    super.dispose();
  }

  String? _validarCorreo(String? valor) {
    final correo = valor?.trim() ?? '';

    if (correo.isEmpty) {
      return 'Ingrese su correo electrónico';
    }

    if (!RegExp(
      r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
    ).hasMatch(correo)) {
      return 'Ingrese un correo válido';
    }

    return null;
  }

  String? _validarContrasena(String? valor) {
    if (valor == null || valor.isEmpty) {
      return 'Ingrese su contraseña';
    }

    if (valor.length < 8) {
      return 'Debe tener al menos 8 caracteres';
    }

    return null;
  }

  Future<void> _iniciarSesion() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _cargando = true;
    });

    // Simulamos una autenticación de dos segundos.
    await Future.delayed(
      const Duration(seconds: 2),
    );

    if (!mounted) return;

    final correo = _correoController.text.trim();
    final contrasena = _contrasenaController.text;

    // Usuario de demostración.
    final esDemo =
        correo == 'demo@correo.com' &&
        contrasena == '12345678';

    // Verificamos las credenciales registradas.
    final esRegistrado = ref
        .read(usuarioRegistradoProvider.notifier)
        .verificar(correo, contrasena);

    // DIAGNÓSTICO: no imprime correos ni contraseñas.
    debugPrint(
      'LOGIN - Existe cuenta registrada: '
      '${ref.read(usuarioRegistradoProvider) != null}',
    );

    debugPrint(
      'LOGIN - Credenciales coinciden: $esRegistrado',
    );

    setState(() {
      _cargando = false;
    });

    if (esDemo || esRegistrado) {
      ref
          .read(sesionProvider.notifier)
          .iniciarSesion(correo);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Correo o contraseña incorrectos.',
          ),
          duration: Duration(seconds: 4),
        ),
      );
    }
  }

  Future<void> _abrirRegistro() async {
    final correoRegistrado =
        await Navigator.push<String>(
      context,
      MaterialPageRoute(
        builder: (_) => const RegistroScreen(),
      ),
    );

    if (!mounted) return;

    if (correoRegistrado != null) {
      _correoController.text = correoRegistrado;
      _contrasenaController.clear();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Registro completado. Inicia sesión.',
          ),
          duration: Duration(seconds: 4),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Iniciar sesión'),
        centerTitle: true,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: 420,
            ),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.stretch,
                children: [
                  const Icon(
                    Icons.account_circle,
                    size: 90,
                    color: Colors.indigo,
                  ),

                  const SizedBox(height: 20),

                  const Text(
                    'Bienvenido',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 8),

                  const Text(
                    'Ingresa tus datos para continuar',
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 30),

                  CampoFormulario(
                    controlador: _correoController,
                    etiqueta: 'Correo electrónico',
                    icono: Icons.email,
                    tipoTeclado:
                        TextInputType.emailAddress,
                    validador: _validarCorreo,
                  ),

                  const SizedBox(height: 16),

                  CampoFormulario(
                    controlador: _contrasenaController,
                    etiqueta: 'Contraseña',
                    icono: Icons.lock,
                    ocultarTexto: true,
                    validador: _validarContrasena,
                  ),

                  const SizedBox(height: 24),

                  FilledButton(
                    onPressed:
                        _cargando ? null : _iniciarSesion,
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: _cargando
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                              ),
                            )
                          : const Text('Iniciar sesión'),
                    ),
                  ),

                  const SizedBox(height: 16),

                  TextButton(
                    onPressed:
                        _cargando ? null : _abrirRegistro,
                    child: const Text(
                      '¿No tienes cuenta? Regístrate',
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
