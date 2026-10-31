
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../servicios/publicaciones_api.dart';

// Estado que utiliza la pantalla de publicaciones.
class EstadoPublicaciones {
  final List<Publicacion> publicaciones;
  final bool cargando;
  final bool cargandoMas;
  final bool hayMas;
  final int siguientePagina;
  final String? error;
  final String? errorMas;

  const EstadoPublicaciones({
    this.publicaciones = const [],
    this.cargando = false,
    this.cargandoMas = false,
    this.hayMas = true,
    this.siguientePagina = 1,
    this.error,
    this.errorMas,
  });
}

class PublicacionesNotifier extends Notifier<EstadoPublicaciones> {
  final PublicacionesApi _api = PublicacionesApi();

  @override
  EstadoPublicaciones build() {
    return const EstadoPublicaciones();
  }

  // Obtiene las primeras 15 publicaciones.
  Future<void> cargarInicial() async {
    state = const EstadoPublicaciones(
      cargando: true,
    );

    try {
      final resultado = await _api.obtenerPublicaciones(
        pagina: 1,
        limite: 15,
      );

      state = EstadoPublicaciones(
        publicaciones: resultado,
        hayMas: resultado.length == 15,
        siguientePagina: 2,
      );
    } catch (e) {
      state = EstadoPublicaciones(
        error: _mensajeError(e),
      );
    }
  }

  // Descarga más publicaciones al llegar al final.
  Future<void> cargarMas() async {
    if (state.cargando ||
        state.cargandoMas ||
        !state.hayMas ||
        state.error != null ||
        state.errorMas != null) {
      return;
    }

    final anteriores = state.publicaciones;
    final pagina = state.siguientePagina;

    state = EstadoPublicaciones(
      publicaciones: anteriores,
      cargandoMas: true,
      hayMas: true,
      siguientePagina: pagina,
    );

    try {
      final nuevas = await _api.obtenerPublicaciones(
        pagina: pagina,
        limite: 15,
      );

      state = EstadoPublicaciones(
        publicaciones: [...anteriores, ...nuevas],
        hayMas: nuevas.length == 15,
        siguientePagina: pagina + 1,
      );
    } catch (e) {
      state = EstadoPublicaciones(
        publicaciones: anteriores,
        hayMas: true,
        siguientePagina: pagina,
        errorMas: _mensajeError(e),
      );
    }
  }

  // Reintenta una página que falló.
  Future<void> reintentarCargaMas() async {
    if (state.errorMas == null) return;

    state = EstadoPublicaciones(
      publicaciones: state.publicaciones,
      hayMas: state.hayMas,
      siguientePagina: state.siguientePagina,
    );

    await cargarMas();
  }

  // Actualiza desde la primera página.
  Future<void> recargar() async {
    await cargarInicial();
  }

  String _mensajeError(Object error) {
    if (error is ApiException) {
      return error.mensaje;
    }

    return 'Ocurrió un error inesperado al cargar los datos.';
  }
}

final publicacionesProvider =
    NotifierProvider<PublicacionesNotifier, EstadoPublicaciones>(
  PublicacionesNotifier.new,
);
