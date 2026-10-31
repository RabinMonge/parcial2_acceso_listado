
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../estado/usuario_registrado_provider.dart';
import '../modelos/usuario_registrado.dart';
import '../widgets/campo_formulario.dart';

class RegistroScreen extends ConsumerStatefulWidget {
  const RegistroScreen({super.key});

  @override
  ConsumerState<RegistroScreen> createState() =>
      _RegistroScreenState();
}

class _RegistroScreenState
    extends ConsumerState<RegistroScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nombreController = TextEditingController();
  final _correoController = TextEditingController();
  final _contrasenaController = TextEditingController();
  final _confirmacionController = TextEditingController();

  bool _aceptaTerminos = false;
  bool _cargando = false;

  @override
  void dispose() {
    _nombreController.dispose();
    _correoController.dispose();
    _contrasenaController.dispose();
    _confirmacionController.dispose();
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
      return 'Ingrese una contraseña';
    }

    if (valor.length < 8) {
      return 'Debe tener al menos 8 caracteres';
    }

    return null;
  }

  String? _validarConfirmacion(String? valor) {
    if (valor == null || valor.isEmpty) {
      return 'Confirme su contraseña';
    }

    if (valor != _contrasenaController.text) {
      return 'Las contraseñas no coinciden';
    }

    return null;
  }

  Future<void> _registrarse() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (!_aceptaTerminos) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Debe aceptar los términos y condiciones',
          ),
        ),
      );
      return;
    }

    setState(() {
      _cargando = true;
    });

    // Simulamos el proceso de registro.
    await Future.delayed(
      const Duration(seconds: 1),
    );

    if (!mounted) return;

    final usuario = UsuarioRegistrado(
      nombre: _nombreController.text.trim(),
      correo: _correoController.text.trim(),
      contrasena: _contrasenaController.text,
    );

    // Guardamos la cuenta en Riverpod.
    ref
        .read(usuarioRegistradoProvider.notifier)
        .registrar(usuario);

    // DIAGNÓSTICO: confirma que el registro guardó la cuenta.
    debugPrint(
      'REGISTRO - Cuenta guardada: '
      '${ref.read(usuarioRegistradoProvider) != null}',
    );

    setState(() {
      _cargando = false;
    });

    // Devolvemos el correo al Login.
    Navigator.pop(context, usuario.correo);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Crear cuenta'),
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
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Icon(
                    Icons.person_add_alt_1,
                    size: 72,
                    color: Colors.indigo,
                  ),

                  const SizedBox(height: 16),

                  const Text(
                    'Crear cuenta',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 24),

                  CampoFormulario(
                    controlador: _nombreController,
                    etiqueta: 'Nombre completo',
                    icono: Icons.person,
                    validador: (valor) {
                      if (valor == null ||
                          valor.trim().isEmpty) {
                        return 'Ingrese su nombre';
                      }

                      return null;
                    },
                  ),

                  const SizedBox(height: 16),

                  CampoFormulario(
                    controlador: _correoController,
                    etiqueta: 'Correo electrónico',
                    icono: Icons.email,
                    tipoTeclado: TextInputType.emailAddress,
                    validador: _validarCorreo,
                  ),

                  const SizedBox(height: 16),

                  CampoFormulario(
                    controlador: _contrasenaController,
                    etiqueta: 'Contraseña',
                    icono: Icons.lock,
                    ocultarTexto: true,
                    validador: _validarContrasena,
                    alCambiar: (_) {
                      // Si cambia la contraseña,
                      // verificamos nuevamente la confirmación.
                      if (_confirmacionController.text.isNotEmpty) {
                        _formKey.currentState?.validate();
                      }
                    },
                  ),

                  const SizedBox(height: 16),

                  CampoFormulario(
                    controlador: _confirmacionController,
                    etiqueta: 'Confirmar contraseña',
                    icono: Icons.lock_outline,
                    ocultarTexto: true,
                    validador: _validarConfirmacion,
                  ),

                  const SizedBox(height: 12),

                  CheckboxListTile(
                    value: _aceptaTerminos,
                    onChanged: _cargando
                        ? null
                        : (valor) {
                            setState(() {
                              _aceptaTerminos = valor ?? false;
                            });
                          },
                    title: const Text(
                      'Acepto los términos y condiciones',
                    ),
                    controlAffinity:
                        ListTileControlAffinity.leading,
                  ),

                  const SizedBox(height: 20),

                  FilledButton(
                    onPressed: _cargando ? null : _registrarse,
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
                          : const Text('Registrarme'),
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
