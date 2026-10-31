
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../modelos/usuario_registrado.dart';

class UsuarioRegistradoNotifier
    extends Notifier<UsuarioRegistrado?> {
  @override
  UsuarioRegistrado? build() {
    return null;
  }

  void registrar(UsuarioRegistrado usuario) {
    state = usuario;
  }

  bool verificar(String correo, String contrasena) {
    final usuario = state;

    if (usuario == null) {
      return false;
    }

    return usuario.validarCredenciales(
      correo,
      contrasena,
    );
  }
}

final usuarioRegistradoProvider =
    NotifierProvider<UsuarioRegistradoNotifier, UsuarioRegistrado?>(
  UsuarioRegistradoNotifier.new,
);
