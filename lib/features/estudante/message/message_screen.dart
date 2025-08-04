import 'package:flutter/material.dart';

// Classe modelo para representar os dados de um chat
class Chat {
  final String avatarUrl;
  final String name;
  final String message;
  final String time;
  final bool isTyping;
  final bool isOnline;
  final bool isPinned;
  final int unreadCount; // Usaremos 0 para 'lido' (✓✓)
  final IconData readStatusIcon;

  Chat({
    required this.avatarUrl,
    required this.name,
    required this.message,
    required this.time,
    this.isTyping = false,
    this.isOnline = false,
    this.isPinned = false,
    this.unreadCount = 0,
    required this.readStatusIcon,
  });
}

// Tela de Mensagens
class MessagePage extends StatelessWidget {
  const MessagePage({super.key});

  // Lista de dados para popular a tela (simulando uma API ou banco de dados)
  static final List<Chat> chatData = [
    Chat(
      name: 'Avisos da Gestão',
      message: 'Atenção: O ônibus das 18h sairá 15 minutos mais cedo hoje.',
      time: '10:05',
      avatarUrl: 'https://i.pravatar.cc/150?img=7', // Placeholder para logo
      readStatusIcon: Icons.done_all,
      isPinned: true,
    ),
    Chat(
      name: 'Galera do B-12 (Centro)',
      message: 'Ana: Alguém sabe se o ar condicionado foi consertado?',
      time: '14:35',
      avatarUrl: 'https://i.pravatar.cc/150?img=32', // Placeholder
      readStatusIcon: Icons.done_all,
      isOnline: true,
    ),
    Chat(
      name: 'Juliana Paiva',
      message: 'Digitando...',
      time: '14:34',
      avatarUrl: 'https://i.pravatar.cc/150?img=36', // Placeholder
      readStatusIcon: Icons.done_all,
      isTyping: true,
      isOnline: true,
    ),
    Chat(
      name: 'Carlos Souza',
      message: 'Você: Ei, guarda um lugar pra mim hoje?',
      time: '13:50',
      avatarUrl: 'https://i.pravatar.cc/150?img=12', // Placeholder
      readStatusIcon: Icons.done, // Apenas um check (enviado)
      isOnline: true,
    ),
    Chat(
      name: 'UniBus Bot',
      message: 'Lembrete: Confirme sua presença para a viagem de amanhã.',
      time: 'Ontem',
      avatarUrl:
          'https://i.pravatar.cc/150?img=5', // Placeholder de um ícone roxo
      readStatusIcon: Icons.done_all,
      isOnline: true,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: SafeArea(
        child: Column(
          children: [
            // Cabeçalho: "Chats" e ícones
            _buildHeader(),

            // Barra de Pesquisa
            _buildSearchBar(),

            // Lista de Chats
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.only(top: 10.0),
                itemCount: chatData.length,
                itemBuilder: (context, index) {
                  return _buildChatListItem(chatData[index]);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget para o cabeçalho
  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Chats',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.more_horiz, color: Colors.black54),
                onPressed: () {},
              ),
              IconButton(
                icon: const Icon(Icons.edit_square, color: Colors.black54),
                onPressed: () {},
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Barra de pesquisa
  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30.0),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 5,
            ),
          ],
        ),
        child: const TextField(
          decoration: InputDecoration(
            icon: Icon(Icons.search, color: Colors.grey),
            hintText: 'Search for chats & messages',
            border: InputBorder.none,
            hintStyle: TextStyle(color: Colors.grey),
          ),
        ),
      ),
    );
  }

  // Construir cada item da lista de chat
  Widget _buildChatListItem(Chat chat) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      child: ListTile(
        leading: Stack(
          children: [
            CircleAvatar(
              radius: 28,
              backgroundImage: NetworkImage(chat.avatarUrl),
            ),
            if (chat.isOnline)
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  height: 14,
                  width: 14,
                  decoration: BoxDecoration(
                    color: const Color(0xFF4CAF50),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                ),
              ),
          ],
        ),
        title: Row(
          children: [
            Text(
              chat.name,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(width: 4),
            if (chat.isPinned)
              const Icon(Icons.push_pin, size: 16, color: Colors.grey),
          ],
        ),
        subtitle: Text(
          chat.message,
          style: TextStyle(
            color: chat.isTyping ? Colors.green : Colors.grey.shade600,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        trailing: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              chat.time,
              style: const TextStyle(color: Colors.grey, fontSize: 12),
            ),
            const SizedBox(height: 4),
            Icon(chat.readStatusIcon, color: Colors.blueAccent, size: 18),
          ],
        ),
        onTap: () {
          // Ação ao clicar no chat
        },
      ),
    );
  }
}
