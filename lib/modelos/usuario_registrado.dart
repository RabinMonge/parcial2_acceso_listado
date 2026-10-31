
class UsuarioRegistrado {
  final String nombre;
  final String correo;
  final String contrasena;

  const UsuarioRegistrado({
    required this.nombre,
    required this.correo,
    required this.contrasena,
  });

  bool validarCredenciales(
    String correoIngresado,
    String contrasenaIngresada,
  ) {
    return correo.trim().toLowerCase() ==
            correoIngresado.trim().toLowerCase() &&
        contrasena == contrasenaIngresada;
  }
}
