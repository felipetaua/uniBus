import 'package:flutter/material.dart';

class AvatarCustomizationScreen extends StatelessWidget {
  const AvatarCustomizationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Meu Avatar'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircleAvatar(
              radius: 80,
              backgroundColor: Colors.blueGrey,
              child: Icon(Icons.person, size: 100, color: Colors.white),
            ),
            const SizedBox(height: 24),
            Text('Em breve!',
                style: Theme.of(context).textTheme.headlineMedium),
            const Text('Aqui você poderá customizar seu avatar.'),
          ],
        ),
      ),
    );
  }
}
