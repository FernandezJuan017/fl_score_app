import 'package:flutter/material.dart';

class ABMMatchPage extends StatelessWidget {
  final Key formKey;
  final void Function(int) redirectTo;

  const ABMMatchPage({
    required this.formKey,
    required this.redirectTo,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            const Text("New Match"),
            const SizedBox(height: 10),
            const Row(
              children: [
                Flexible(
                  flex:9,
                  child: TextField(
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Local Team',
                    ),
                  ),
                ),
                SizedBox(width: 10),
                Flexible(
                  flex: 1,
                  child: TextField(
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Visit Team',
                    ),
                  ),
                ),
              ],
            ),
            const Text("vs"),
            const TextField(
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Visit Team',
              ),
            ),
            const SizedBox(height: 10),
            FilledButton(
              onPressed: () {
                redirectTo(0);
              },
              child: const Text("Save"),
            ),
          ],
        ),
      ),
    );
  }
}