import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<firebase_auth.User?> registerStudent({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      final result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      firebase_auth.User? user = result.user;
      if (user != null) {
        // Adicionar o nome de exibição do usuário
        await user.updateDisplayName(name);
        // Recarregar o usuário para obter os dados atualizados
        await user.reload();
        user = _auth.currentUser;
      }
      return user;
    } catch (e) {
      print(e.toString());
      return null;
    }
  }
}
