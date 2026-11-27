import 'package:firebase_auth/firebase_auth.dart';

//senha usuarios Senha2511@

/// Falha de autenticação já traduzida; [mensagem] pode ser exibida direto na tela.
class FalhaAutenticacaoException implements Exception {
  final String mensagem;
  const FalhaAutenticacaoException(this.mensagem);

  @override
  String toString() => mensagem;
}

/// Emite o usuário logado, ou null quando não há ninguém logado.
Stream<User?> usuarioLogado() => FirebaseAuth.instance.authStateChanges();

Future<void> entrar(String email, String senha) async {
  try {
    await FirebaseAuth.instance.signInWithEmailAndPassword(
      email: email.trim(),
      password: senha,
    );
  } on FirebaseAuthException catch (erro) {
    throw FalhaAutenticacaoException(mensagemDeErro(erro.code));
  } catch (_) {
    throw const FalhaAutenticacaoException(
      'Não foi possível entrar. Tente novamente.',
    );
  }
}

/// Cria a conta; o Firebase já deixa o novo usuário logado ao concluir.
Future<void> cadastrar(String email, String senha) async {
  try {
    await FirebaseAuth.instance.createUserWithEmailAndPassword(
      email: email.trim(),
      password: senha,
    );
  } on FirebaseAuthException catch (erro) {
    throw FalhaAutenticacaoException(mensagemDeErro(erro.code));
  } catch (_) {
    throw const FalhaAutenticacaoException(
      'Não foi possível criar a conta. Tente novamente.',
    );
  }
}

Future<void> sair() => FirebaseAuth.instance.signOut();

String mensagemDeErro(String codigo) {
  switch (codigo) {
    // 'invalid-credential' é o código atual para e-mail ou senha incorretos.
    case 'invalid-credential':
    case 'wrong-password':
    case 'user-not-found':
      return 'E-mail ou senha incorretos.';
    case 'invalid-email':
      return 'O e-mail informado não é válido.';
    case 'user-disabled':
      return 'Esta conta foi desativada.';
    case 'too-many-requests':
      return 'Muitas tentativas seguidas. Aguarde um pouco e tente de novo.';
    case 'network-request-failed':
      return 'Sem conexão com a internet. Verifique sua rede e tente de novo.';
    case 'email-already-in-use':
      return 'Já existe uma conta com este e-mail.';
    case 'weak-password':
      return 'Senha muito fraca. Use pelo menos 6 caracteres.';
    case 'operation-not-allowed':
      return 'Login por e-mail e senha não está habilitado no Firebase.';
    default:
      return 'Algo deu errado ($codigo). Tente novamente.';
  }
}
