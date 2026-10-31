
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../estado/sesion_provider.dart';
import '../estado/publicaciones_provider.dart';

class ListadoScreen extends ConsumerStatefulWidget {
  const ListadoScreen({super.key});

  @override
  ConsumerState<ListadoScreen> createState() =>
      _ListadoScreenState();
}

class _ListadoScreenState extends ConsumerState<ListadoScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    _scrollController.addListener(_detectarFinal);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      ref.read(publicacionesProvider.notifier).cargarInicial();
    });
  }

  void _detectarFinal() {
    if (!_scrollController.hasClients) return;

    final posicion = _scrollController.position;

    if (posicion.pixels >= posicion.maxScrollExtent - 250) {
      ref.read(publicacionesProvider.notifier).cargarMas();
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_detectarFinal);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final correo = ref.watch(sesionProvider);
    final estado = ref.watch(publicacionesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Listado de publicaciones'),
        actions: [
          IconButton(
            tooltip: 'Cerrar sesión',
            icon: const Icon(Icons.logout),
            onPressed: () {
              ref.read(sesionProvider.notifier).cerrarSesion();
            },
          ),
        ],
      ),
      body: _construirContenido(estado),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(12),
        child: Text(
          'Usuario: ${correo ?? "Sin sesión"}',
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _construirContenido(EstadoPublicaciones estado) {
    // Estado 1: carga inicial.
    if (estado.cargando) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    // Estado 2: error en la primera petición.
    if (estado.error != null) {
      return _pantallaError(estado.error!);
    }

    // Estado 3: lista vacía.
    if (estado.publicaciones.isEmpty) {
      return RefreshIndicator(
        onRefresh: () =>
            ref.read(publicacionesProvider.notifier).recargar(),
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: const [
            SizedBox(height: 120),
            Icon(Icons.inbox_outlined, size: 60),
            SizedBox(height: 12),
            Center(
              child: Text('No hay publicaciones disponibles.'),
            ),
          ],
        ),
      );
    }

    // Estado 4: publicaciones disponibles.
    return RefreshIndicator(
      onRefresh: () =>
          ref.read(publicacionesProvider.notifier).recargar(),
      child: ListView.builder(
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: estado.publicaciones.length + 1,
        itemBuilder: (context, index) {
          if (index == estado.publicaciones.length) {
            return _pieDeLista(estado);
          }

          final publicacion = estado.publicaciones[index];

          return Card(
            margin: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 6,
            ),
            child: ListTile(
              leading: CircleAvatar(
                child: Text('${publicacion.id}'),
              ),
              title: Text(
                publicacion.titulo,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(publicacion.contenido),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _pieDeLista(EstadoPublicaciones estado) {
    if (estado.cargandoMas) {
      return const Padding(
        padding: EdgeInsets.all(20),
        child: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (estado.errorMas != null) {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              estado.errorMas!,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            TextButton.icon(
              onPressed: () {
                ref
                    .read(publicacionesProvider.notifier)
                    .reintentarCargaMas();
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Reintentar carga'),
            ),
          ],
        ),
      );
    }

    if (!estado.hayMas) {
      return const Padding(
        padding: EdgeInsets.all(20),
        child: Center(
          child: Text('Has llegado al final de la lista.'),
        ),
      );
    }

    return const SizedBox(height: 20);
  }

  Widget _pantallaError(String mensaje) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.cloud_off,
              size: 60,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            Text(
              mensaje,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: () {
                ref
                    .read(publicacionesProvider.notifier)
                    .cargarInicial();
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Reintentar'),
            ),
          ],
        ),
      ),
    );
  }
}
