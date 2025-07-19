import 'package:bus_attendance_app/screens/store_page.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';
import 'student_history.dart';
import 'organizer_dashboard.dart';
import 'qr_hub_screen.dart';

class StudentNavigationController extends GetxController {
  final Rx<int> selectedIndex = 0.obs;

  final screens = [
    const StudentHomeTab(),
    const StorePage(),
    // Placeholder para Favoritos
    const Scaffold(
        body: Center(
            child:
                Text('Favoritos em breve!', style: TextStyle(fontSize: 24)))),
    // Placeholder para Perfil
    const Scaffold(
        body: Center(
            child: Text('Perfil em breve!', style: TextStyle(fontSize: 24)))),
  ];
}

class StudentDashboard extends StatelessWidget {
  const StudentDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(StudentNavigationController());
    final darkmode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Obx(() => controller.screens[controller.selectedIndex.value]),
      bottomNavigationBar: Obx(
        () => NavigationBar(
          height: 80,
          elevation: 0,
          selectedIndex: controller.selectedIndex.value,
          onDestinationSelected: (index) =>
              controller.selectedIndex.value = index,
          backgroundColor: darkmode ? Colors.black : Colors.white,
          indicatorColor: darkmode
              ? Colors.white.withOpacity(0.1)
              : Colors.black.withOpacity(0.1),
          destinations: const [
            NavigationDestination(icon: Icon(Icons.home), label: 'Home'),
            NavigationDestination(icon: Icon(Icons.store), label: 'Loja'),
            NavigationDestination(
                icon: Icon(Icons.favorite), label: 'Favoritos'),
            NavigationDestination(icon: Icon(Icons.person), label: 'Perfil'),
          ],
        ),
      ),
    );
  }
}

class StudentHomeTab extends StatefulWidget {
  const StudentHomeTab({super.key});

  @override
  State<StudentHomeTab> createState() => _StudentHomeTabState();
}

class _StudentHomeTabState extends State<StudentHomeTab> {
  bool? _todayAttendance;
  bool _isLoading = false;
  String _studentName = '';

  @override
  void initState() {
    super.initState();
    _loadTodayAttendance();
    _loadStudentInfo();
  }

  Future<void> _loadStudentInfo() async {
    final user = Supabase.instance.client.auth.currentUser;
    setState(() {
      _studentName = user?.userMetadata?['name'] ??
          user?.email?.split('@')[0] ??
          'Estudante';
    });
  }

  Future<void> _loadTodayAttendance() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;

    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());

    try {
      final response = await Supabase.instance.client
          .from('attendances')
          .select()
          .eq('user_id', user.id)
          .eq('date', today)
          .maybeSingle();

      setState(() {
        _todayAttendance = response?['will_attend'];
      });
    } catch (error) {
      print('Erro ao carregar presença: $error');
    }
  }

  Future<void> _updateAttendance(bool willAttend) async {
    setState(() => _isLoading = true);

    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;

    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());

    try {
      await Supabase.instance.client.from('attendances').upsert({
        'user_id': user.id,
        'date': today,
        'will_attend': willAttend,
        'student_name': _studentName,
        'updated_at': DateTime.now().toIso8601String(),
      });

      setState(() {
        _todayAttendance = willAttend;
      });

      // Mostrar confirmação
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(willAttend
              ? '✅ Presença confirmada para hoje!'
              : '❌ Ausência registrada para hoje'),
          backgroundColor: willAttend ? Colors.green : Colors.orange,
        ),
      );

      // Opcional: Enviar mensagem para WhatsApp (simulado)
      if (willAttend) {
        _simulateWhatsAppMessage();
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro: ${error.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _simulateWhatsAppMessage() {
    // Simulação da mensagem automática para WhatsApp
    final time = DateFormat('HH:mm').format(DateTime.now());
    print(
        '📱 WhatsApp: "$_studentName confirmou presença no ônibus das 17h. ($time)');
  }

  void _showQRCode() {
    final user = Supabase.instance.client.auth.currentUser;
    if (user != null && user.id.isNotEmpty) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) =>
              QrHubScreen(studentId: user.id, initialIndex: 1),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content:
              Text('Não foi possível gerar o QR Code. Faça login novamente.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _scanToConfirm() async {
    if (!mounted) return;

    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;

    // Navega para a tela de scanner e aguarda o resultado
    final scannedCode = await Navigator.of(context).push<String>(
      MaterialPageRoute(builder: (context) => QrHubScreen(studentId: user.id)),
    );

    if (scannedCode == null || scannedCode.isEmpty) {
      return; // Usuário cancelou
    }

    // Define o código esperado para o dia.
    // Este código deve ser gerado e exibido no ônibus.
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final expectedCode = 'UNIBUS_CHECKIN_$today';

    if (scannedCode == expectedCode) {
      // Se o código for válido, confirma a presença
      await _updateAttendance(true);
    } else {
      // Se for inválido, mostra um erro
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content:
                Text('QR Code inválido ou não corresponde ao dia de hoje.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final today =
        DateFormat('EEEE, dd/MM/yyyy', 'pt_BR').format(DateTime.now());

    return Scaffold(
      appBar: AppBar(
        title: Text('Olá, $_studentName'),
        actions: [
          IconButton(
            icon: const Icon(Icons.qr_code_2),
            onPressed: _showQRCode,
            tooltip: 'Meu QR Code',
          ),
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const StudentHistory()),
            ),
          ),
          // Botão temporário para o painel do organizador
          IconButton(
            icon: const Icon(Icons.admin_panel_settings_outlined),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => OrganizerDashboard()),
              );
            },
            tooltip: 'Painel Organizador (Temp)',
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => Supabase.instance.client.auth.signOut(),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    const Icon(
                      Icons.today,
                      size: 48,
                      color: Colors.blue,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      today,
                      style: Theme.of(context).textTheme.titleLarge,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Ônibus das 17h',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: Colors.grey[600],
                          ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),
            Text(
              'Você vai hoje?',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            if (_todayAttendance != null) ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color:
                      _todayAttendance! ? Colors.green[50] : Colors.orange[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: _todayAttendance! ? Colors.green : Colors.orange,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      _todayAttendance! ? Icons.check_circle : Icons.cancel,
                      color: _todayAttendance! ? Colors.green : Colors.orange,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _todayAttendance!
                            ? 'Presença confirmada para hoje'
                            : 'Ausência registrada para hoje',
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          color: _todayAttendance!
                              ? Colors.green[800]
                              : Colors.orange[800],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Quer alterar?',
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
            ],
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed:
                        _isLoading ? null : () => _updateAttendance(true),
                    icon: const Icon(Icons.check),
                    label: const Text('Vou hoje'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed:
                        _isLoading ? null : () => _updateAttendance(false),
                    icon: const Icon(Icons.close),
                    label: const Text('Não vou'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _isLoading ? null : _scanToConfirm,
                icon: const Icon(Icons.qr_code_scanner),
                label: const Text('Escanear para confirmar'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  side: BorderSide(color: Theme.of(context).primaryColor),
                  foregroundColor: Theme.of(context).primaryColor,
                ),
              ),
            ),
            if (_isLoading) ...[
              const SizedBox(height: 24),
              const Center(child: CircularProgressIndicator()),
            ],
            const Spacer(),
            Card(
              color: Colors.blue[50],
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    const Icon(Icons.info, color: Colors.blue),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Confirme sua presença até às 16h para garantir sua vaga no ônibus.',
                        style: TextStyle(color: Colors.blue[800]),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
