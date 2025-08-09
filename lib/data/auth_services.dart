// ignore_for_file: avoid_print

import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crypto/crypto.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

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

  // Login com Google
  Future<User?> signInWithGoogle() async {
    try {
      // 1. Iniciar o fluxo de login do Google
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) {
        // O usuário cancelou o login
        return null;
      }

      // 2. Obter os detalhes de autenticação da solicitação
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // 3. Criar uma credencial do Firebase
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // 4. Fazer login no Firebase com a credencial
      UserCredential userCredential = await _auth.signInWithCredential(
        credential,
      );
      User? user = userCredential.user;

      // 5. Verificar se é um novo usuário e salvar no Firestore se for
      if (user != null) {
        final userDoc = _firestore.collection('users').doc(user.uid);
        final docSnapshot = await userDoc.get();

        if (!docSnapshot.exists) {
          // Novo usuário, cria o documento
          await userDoc.set({
            'email': user.email,
            'name': user.displayName,
            'role': 'estudante', // Define o papel padrão para login com Google
          });
        }
      }
      return user;
    } catch (e) {
      print('Erro no login com Google: $e');
      return null;
    }
  }

  // Login com Apple
  Future<User?> signInWithApple() async {
    // O login com Apple só está disponível em dispositivos Apple.
    if (!Platform.isIOS && !Platform.isMacOS) {
      print('Sign in with Apple não é suportado nesta plataforma.');
      return null;
    }

    try {
      // Gera um nonce para segurança (previne replay attacks)
      final rawNonce = _generateNonce();
      final hashedNonce = _sha256(rawNonce);

      // 1. Solicita a credencial da Apple
      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
        nonce: hashedNonce,
      );

      // 2. Cria um provedor OAuth para o Firebase
      final oauthProvider = OAuthProvider('apple.com');

      // 3. Cria a credencial do Firebase com o token da Apple
      final credential = oauthProvider.credential(
        idToken: appleCredential.identityToken,
        rawNonce: rawNonce,
      );

      // 4. Faz login no Firebase
      final userCredential = await _auth.signInWithCredential(credential);
      final user = userCredential.user;

      // 5. Se for um novo usuário, salva os dados no Firestore
      if (user != null) {
        final userDoc = _firestore.collection('users').doc(user.uid);
        final docSnapshot = await userDoc.get();

        if (!docSnapshot.exists) {
          await userDoc.set({
            'email': user.email ?? appleCredential.email,
            'name': appleCredential.givenName != null
                ? '${appleCredential.givenName} ${appleCredential.familyName ?? ''}'.trim()
                : user.displayName,
            'role': 'estudante',
          });
        }
      }

      return user;
    } catch (e) {
      print('Erro durante o login com Apple: $e');
      return null;
    }
  }
}

/// Gera um nonce aleatório e criptograficamente seguro.
String _generateNonce([int length = 32]) {
  const charset = '0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._';
  final random = Random.secure();
  return List.generate(length, (_) => charset[random.nextInt(charset.length)]).join();
}

/// Retorna o hash sha256 de uma string.
String _sha256(String input) {
  final bytes = utf8.encode(input);
  final digest = sha256.convert(bytes);
  return digest.toString();
}
