import 'package:bus_attendance_app/data/auth_services.dart';
import 'package:bus_attendance_app/features/auth/login_student.dart';
import 'package:flutter/material.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            const SizedBox(height: 30),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      Container(
                        width: 100,
                        height: 150,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          color: Colors.grey[200],
                          image: const DecorationImage(
                            image: AssetImage(
                              'assets/items/bg/bg-10.png',
                            ), // aqui onde temos os background que o usuario tiver
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.orange,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Text(
                            '1',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        const Text(
                          'Tanya',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Text(
                              'YFKQKN',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[600],
                              ),
                            ),
                            const SizedBox(width: 4),
                            Icon(Icons.copy, size: 16, color: Colors.grey[600]),
                          ],
                        ),
                        const SizedBox(height: 15),
                        const Text(
                          'Level',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: const SizedBox(
                                  height: 10,
                                  child: LinearProgressIndicator(
                                    value:
                                        0.7, // Exemplo de progresso da barra em %
                                    backgroundColor: Color(0xFFE0E0E0),
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Color(
                                        0xFFB06DF9,
                                      ), // Adicionar a funcionalidade de trocar a cor da barra de progresso entre essas cores: Color(0xFFB06DF9), Color(0xFF828EF3), Color(0xFF84CFB2), Color(0xFFCAFF5C),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 15),
                            Column(
                              children: [
                                Image.asset(
                                  'assets/icons/stack-coins.png',
                                  width: 30,
                                  height: 30,
                                ),
                                const Text(
                                  'x2',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 24.0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  Column(
                    children: [
                      Image.asset(
                        'assets/icons/tropy_icon.png',
                        width: 40,
                        height: 40,
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        '-',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Melhor Rank',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      Image.asset(
                        'assets/icons/coin_icon.png',
                        width: 40,
                        height: 40,
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        '100',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Unicoins',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      Image.asset(
                        'assets/icons/xp_icon.png',
                        width: 40,
                        height: 40,
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        '0',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Experiência',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            DefaultTabController(
              length: 2,
              child: Column(
                children: [
                  const TabBar(
                    labelColor: Colors.black,
                    unselectedLabelColor: Colors.grey,
                    indicatorColor: Colors.purple,
                    indicatorWeight: 4.0,
                    tabs: [Tab(text: 'Configurações'), Tab(text: 'Coleção')],
                  ),
                  SizedBox(
                    height: 200,
                    child: TabBarView(
                      children: [
                        ListView(
                          children: [
                            ListTile(
                              leading: const Icon(Icons.logout),
                              title: const Text('Sair'),
                              onTap: () async {
                                await AuthService().signOut();
                                Navigator.of(context).pushReplacement(
                                  MaterialPageRoute(
                                    builder: (context) => const LoginStudentPage(),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                        Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Container(
                                padding: const EdgeInsets.all(16.0),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Colors.purple[700]!,
                                      Colors.blue[400]!,
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                child: Row(
                                  children: [
                                    // Ícone de diamante (você pode usar um Image.asset ou Icon)
                                    Image.asset(
                                      'assets/icons/coin_icon.png',
                                      width: 60,
                                      height: 60,
                                    ),
                                    const SizedBox(width: 16),
                                    const Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Desbloqueie Cosméticos',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          SizedBox(height: 4),
                                          Text(
                                            'Use suas moedas para liberar visuais únicos e turbinar seu avatar!',
                                            style: TextStyle(
                                              color: Colors.white70,
                                              fontSize: 14,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            Center(
                              child: Text(
                                'Desbloqueie itens exclusivos (10)',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

