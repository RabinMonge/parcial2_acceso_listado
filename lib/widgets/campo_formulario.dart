
import 'package:flutter/material.dart';

class CampoFormulario extends StatelessWidget {
  const CampoFormulario({
    super.key,
    required this.controlador,
    required this.etiqueta,
    required this.icono,
    this.ocultarTexto = false,
    this.tipoTeclado,
    this.validador,
    this.alCambiar,
  });

  final TextEditingController controlador;
  final String etiqueta;
  final IconData icono;
  final bool ocultarTexto;
  final TextInputType? tipoTeclado;
  final String? Function(String?)? validador;
  final ValueChanged<String>? alCambiar;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controlador,
      obscureText: ocultarTexto,
      keyboardType: tipoTeclado,
      validator: validador,
      onChanged: alCambiar,
      decoration: InputDecoration(
        labelText: etiqueta,
        prefixIcon: Icon(icono),
        border: const OutlineInputBorder(),
      ),
    );
  }
}
