import 'dart:math';
import 'package:bus_attendance_app/features/estudante/message/message_screen.dart';
import 'package:flutter/material.dart';

enum MessageType { text, audio }

class Message {
  final String text;
  final String time;
  final bool isSentByMe;
  final MessageType type;

  Message({
    required this.text,
    required this.time,
    required this.isSentByMe,
    this.type = MessageType.text,
  });
}

class ChatDetailPage extends StatelessWidget {
  final Chat chat;

  const ChatDetailPage({super.key, required this.chat});

  // Lista de dados para as mensagens da conversa
  static final List<Message> messages = [
    Message(
      text: 'Show! Valeu por avisar! 👍',
      time: '14:40',
      isSentByMe: true,
    ),
    Message(
      text:
          'O motorista avisou que amanhã sairemos 10min mais cedo por causa da prova.',
      time: '14:38',
      isSentByMe: false,
    ),
    Message(
      text: 'Acho que não, o app de trânsito tá mostrando tudo livre.',
      time: '14:36',
      isSentByMe: false,
    ),
    Message(
      text: 'Pessoal, alguma notícia se o ônibus vai atrasar hoje?',
      time: '14:35',
      isSentByMe: true,
    ),
    Message(
      text: '0:05',
      time: '14:30',
      isSentByMe: false,
      type: MessageType.audio,
    ),
    Message(text: 'Boa tarde, galera!', time: '14:28', isSentByMe: false),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFCBDDE4),
      appBar: _buildAppBar(context),
      body: Column(
        children: [
          // Lista de mensagens
          Expanded(
            child: ListView.builder(
              reverse: true, // Começa a lista de baixo para cima
              padding: const EdgeInsets.all(16.0),
              itemCount: messages.length + 1, // +1 para o separador de data
              itemBuilder: (context, index) {
                if (index == messages.length) {
                  return _buildDateSeparator();
                }
                final message = messages[index];
                return _buildMessageBubble(message);
              },
            ),
          ),
          // Caixa de texto para digitar a mensagem
          _buildMessageComposer(),
        ],
      ),
    );
  }

  // AppBar customizada
  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.white,
      foregroundColor: Colors.black,
      leading: IconButton(
        icon: const Icon(
          Icons.arrow_back_ios_new,
          size: 20,
          color: Colors.black87,
        ),
        onPressed: () => Navigator.of(context).pop(),
      ),
      titleSpacing: 0,
      title: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundImage:
                chat.avatarUrl.startsWith('http')
                    ? NetworkImage(chat.avatarUrl)
                    : AssetImage(chat.avatarUrl) as ImageProvider,
          ),
          const SizedBox(width: 12),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  chat.name,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.black87,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                if (chat.isOnline)
                  const Text(
                    'Online',
                    style: TextStyle(fontSize: 12, color: Colors.green),
                  ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.call_outlined, color: Colors.black87),
          onPressed: () {},
        ),
        IconButton(
          icon: const Icon(Icons.search, color: Colors.black87),
          onPressed: () {},
        ),
      ],
    );
  }

  // Widget para o separador de data "Today"
  Widget _buildDateSeparator() {
    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 16.0),
        padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 12.0),
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(12.0),
        ),
        child: const Text(
          'Today',
          style: TextStyle(color: Colors.grey, fontSize: 12),
        ),
      ),
    );
  }

  // Widget para a "bolha" de mensagem
  Widget _buildMessageBubble(Message message) {
    final isMe = message.isSentByMe;
    final bubbleColor =
        isMe ? const Color(0xFF888AF4).withOpacity(0.2) : Colors.grey.shade200;
    final bubbleAlignment = isMe ? Alignment.centerRight : Alignment.centerLeft;
    final borderRadius =
        isMe
            ? const BorderRadius.only(
              topLeft: Radius.circular(18),
              topRight: Radius.circular(18),
              bottomLeft: Radius.circular(18),
            )
            : const BorderRadius.only(
              topLeft: Radius.circular(18),
              topRight: Radius.circular(18),
              bottomRight: Radius.circular(18),
            );

    return Align(
      alignment: bubbleAlignment,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4.0),
        padding: const EdgeInsets.all(12.0),
        decoration: BoxDecoration(
          color: bubbleColor,
          borderRadius: borderRadius,
        ),
        child:
            message.type == MessageType.text
                ? _buildTextMessage(message, isMe)
                : _buildAudioMessage(message, isMe),
      ),
    );
  }

  // Conteúdo de uma mensagem de texto
  Widget _buildTextMessage(Message message, bool isMe) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 250),
          child: Text(message.text, style: const TextStyle(fontSize: 15)),
        ),
        const SizedBox(width: 8),
        Text(
          message.time,
          style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
        ),
        if (isMe) ...[
          const SizedBox(width: 4),
          Icon(Icons.done_all, size: 16, color: Colors.blue.shade300),
        ],
      ],
    );
  }

  // Conteúdo de uma mensagem de áudio
  Widget _buildAudioMessage(Message message, bool isMe) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.play_arrow,
          color: isMe ? Colors.black : Colors.grey.shade700,
        ),
        // Simulação da onda de áudio
        _buildAudioWave(),
        const SizedBox(width: 8),
        Text(
          message.text, // "0:03"
          style: TextStyle(color: Colors.grey.shade700, fontSize: 14),
        ),
        const SizedBox(width: 8),
        Text(
          message.time,
          style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
        ),
      ],
    );
  }

  // Simulação estática da onda de áudio para a UI
  Widget _buildAudioWave() {
    return Row(
      children: List.generate(
        15,
        (index) => Container(
          margin: const EdgeInsets.symmetric(horizontal: 1),
          width: 2,
          height:
              Random().nextDouble() *
              20, // Altura aleatória para simular a onda
          color: Colors.grey.shade500,
        ),
      ),
    );
  }

  // Widget para a caixa de texto inferior
  Widget _buildMessageComposer() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 10.0),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            offset: const Offset(0, -1),
            blurRadius: 4,
            color: Colors.black.withOpacity(0.05),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            // Campo de texto com ícones
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(30.0),
                ),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.sentiment_satisfied_alt_outlined,
                        color: Colors.grey,
                      ),
                      onPressed: () {},
                    ),
                    const Expanded(
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: 'Mensagem',
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.attach_file, color: Colors.grey),
                      onPressed: () {},
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 8),
            // Botão de enviar/microfone
            CircleAvatar(
              backgroundColor: const Color(0xFF888AF4),
              child: IconButton(
                icon: const Icon(
                  Icons.send_rounded,
                  color: Colors.white,
                ), // Ou Icons.send
                onPressed: () {},
              ),
            ),
          ],
        ),
      ),
    );
  }
}
