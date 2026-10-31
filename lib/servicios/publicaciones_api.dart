
import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

class Publicacion {
  final int id;
  final int userId;
  final String titulo;
  final String contenido;

  const Publicacion({
    required this.id,
    required this.userId,
    required this.titulo,
    required this.contenido,
  });

  factory Publicacion.fromJson(Map<String, dynamic> json) {
    return Publicacion(
      id: json['id'] as int,
      userId: json['userId'] as int,
      titulo: json['title'] as String,
      contenido: json['body'] as String,
    );
  }
}

class ApiException implements Exception {
  final String mensaje;

  const ApiException(this.mensaje);

  @override
  String toString() => mensaje;
}

class PublicacionesApi {
  static const String _urlBase =
      'https://jsonplaceholder.typicode.com/posts';

  Future<List<Publicacion>> obtenerPublicaciones({
    required int pagina,
    int limite = 15,
  }) async {
    try {
      final uri = Uri.parse(_urlBase).replace(
        queryParameters: {
          '_page': pagina.toString(),
          '_limit': limite.toString(),
        },
      );

      final respuesta = await http.get(uri).timeout(
        const Duration(seconds: 10),
      );

      if (respuesta.statusCode != 200) {
        throw ApiException(
          'No se pudieron cargar las publicaciones. '
          'Código: ${respuesta.statusCode}',
        );
      }

      final datos = jsonDecode(respuesta.body);

      if (datos is! List) {
        throw const FormatException(
          'La respuesta no es una lista.',
        );
      }

      return datos.map((elemento) {
        if (elemento is! Map<String, dynamic>) {
          throw const FormatException(
            'Publicación inválida.',
          );
        }

        return Publicacion.fromJson(elemento);
      }).toList();
    } on TimeoutException {
      throw const ApiException(
        'El servidor tardó demasiado en responder.',
      );
    } on http.ClientException {
      throw const ApiException(
        'No fue posible conectar con el servidor. '
        'Revisa tu conexión a internet.',
      );
    } on FormatException {
      throw const ApiException(
        'Los datos recibidos no tienen el formato esperado.',
      );
    } on TypeError {
      throw const ApiException(
        'La información recibida está incompleta.',
      );
    }
  }
}
