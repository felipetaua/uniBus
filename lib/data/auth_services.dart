// ignore_for_file: avoid_print

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Criar conta de estudante (sem mudanças, mas mantido para contexto)
  Future<User?> registerStudent({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      User? user = result.user;
      if (user != null) {
        await user.updateDisplayName(name);
        // Adiciona o usuário ao Firestore com o papel de 'estudante'
        await _firestore.collection('users').doc(user.uid).set({
          'email': email,
          'name': name,
          'role': 'estudante',
        });
      }
      return user;
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  // Método para criar a conta do gestor
  Future<User?> registerGestor({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      User? user = result.user;
      if (user != null) {
        await user.updateDisplayName(name);
        // Adiciona o usuário ao Firestore com o papel de 'gestor'
        await _firestore.collection('users').doc(user.uid).set({
          'email': email,
          'name': name,
          'role': 'gestor',
        });
      }
      return user;
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  // Login para gestores com email e senha
  Future<User?> signInGestor(String email, String password) async {
    try {
      // 1. Tenta fazer o login com email e senha
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      User? user = result.user;

      if (user != null) {
        // 2. Se o login for bem-sucedido, busca o documento do usuário no Firestore
        DocumentSnapshot userDoc =
            await _firestore.collection('users').doc(user.uid).get();

        // 3. Verifica se o documento existe e se o papel é 'gestor'
        if (userDoc.exists && userDoc['role'] == 'gestor') {
          print("Login de gestor bem-sucedido!");
          return user;
        } else {
          // Se não for um gestor, faz o logout imediatamente para evitar acesso indevido
          print("Acesso negado: Usuário não é um gestor.");
          await _auth.signOut();
          return null;
        }
      }
      return null;
    } on FirebaseAuthException catch (e) {
      print('Erro de autenticação: ${e.code}');
      return null;
    } catch (e) {
      print('Erro inesperado: ${e.toString()}');
      return null;
    }
  }

  // O método signInWithEmailAndPassword original pode ser mantido para o login de estudante
  Future<User?> signInWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return result.user;
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  // Redefinir senha (sem mudanças)
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      print(e.toString());
    }
  }

  // Logout (sem mudanças)
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      print(e.toString());
    }
  }
}
