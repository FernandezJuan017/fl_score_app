
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class TeamInputRow extends StatelessWidget {
  final String labelTeam;

  const TeamInputRow({
    required this.labelTeam,
    super.key
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          width: 200,
          child: TextField(
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              labelText: labelTeam,
            ),
          ),
        ),
        SizedBox(width: 10),
        SizedBox(
          width: 70,
          child: TextField(
            textAlign: TextAlign.right,
            keyboardType: TextInputType.number,
            inputFormatters: [
             FilteringTextInputFormatter.digitsOnly// Permitir solo dígitos numéricos
            ],  
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'Score',
            ),
          ),
        ),
      ],
    );
  }
}