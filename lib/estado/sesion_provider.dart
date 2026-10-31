
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SesionNotifier extends Notifier<String?> {
  @override
  String? build() {
    return null;
  }

  void iniciarSesion(String correo) {
    state = correo;
  }

  void cerrarSesion() {
    state = null;
  }
}

final sesionProvider =
    NotifierProvider<SesionNotifier, String?>(
  SesionNotifier.new,
);
