import 'package:bus_attendance_app/screens/qr_scanner_screen.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/supabase_config.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class OrganizerDashboard extends StatefulWidget {
  @override
  _OrganizerDashboardState createState() => _OrganizerDashboardState();
}

class _OrganizerDashboardState extends State<OrganizerDashboard> {
  List<Map<String, dynamic>> _todayAttendances = [];
  bool _isLoading = true;
  int _totalConfirmed = 0;
  final int _busCapacity = SupabaseConfig.busCapacity;

  @override
  void initState() {
    super.initState();
    _loadTodayAttendances();
    _setupRealTimeUpdates();
  }

  void _setupRealTimeUpdates() {
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());

    Supabase.instance.client
        .from('attendances')
        .stream(primaryKey: ['id'])
        .eq('date', today)
        .listen((data) {
          setState(() {
            _todayAttendances = data;
            _totalConfirmed =
                data.where((a) => a['will_attend'] == true).length;
          });
        });
  }

  Future<void> _loadTodayAttendances() async {
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());

    try {
      final response = await Supabase.instance.client
          .from('attendances')
          .select()
          .eq('date', today)
          .order('student_name');

      setState(() {
        _todayAttendances = List<Map<String, dynamic>>.from(response);
        _totalConfirmed =
            _todayAttendances.where((a) => a['will_attend'] == true).length;
        _isLoading = false;
      });
    } catch (error) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao carregar dados: $error')),
      );
    }
  }

  Future<void> _scanQRCode() async {
    // Antes de navegar, verificar se o contexto ainda é válido
    if (!mounted) return;

    final result = await Navigator.of(context).push<String>(
      MaterialPageRoute(builder: (context) => const QRScannerScreen()),
    );

    if (result != null && result.isNotEmpty) {
      _handleScannedQR(result);
    }
  }

  Future<void> _handleScannedQR(String studentId) async {
    // Mostrar um indicador de carregamento
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
      final response = await Supabase.instance.client
          .from('attendances')
          .select('will_attend, student_name')
          .eq('user_id', studentId)
          .eq('date', today)
          .maybeSingle();

      // Fechar o indicador de carregamento
      if (mounted) Navigator.of(context).pop();

      if (!mounted) return;

      String title;
      String content;
      IconData icon;
      Color iconColor;

      if (response == null) {
        title = 'Não Encontrado';
        content = 'Nenhum registro de presença para este estudante hoje.';
        icon = Icons.error_outline;
        iconColor = Colors.red;
      } else {
        final willAttend = response['will_attend'] as bool;
        final studentName = response['student_name'] ?? 'Estudante';
        if (willAttend) {
          title = 'Confirmado!';
          content = '$studentName está na lista de hoje.';
          icon = Icons.check_circle_outline;
          iconColor = Colors.green;
        } else {
          title = 'Atenção';
          content = '$studentName marcou que NÃO IRIA hoje.';
          icon = Icons.warning_amber_rounded;
          iconColor = Colors.orange;
        }
      }

      _showScanResultDialog(title, content, icon, iconColor);
    } catch (e) {
      // Fechar o indicador de carregamento em caso de erro
      if (mounted) Navigator.of(context).pop();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao verificar QR Code: $e')),
        );
      }
    }
  }

  void _showScanResultDialog(
      String title, String content, IconData icon, Color iconColor) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(icon, color: iconColor),
            const SizedBox(width: 10),
            Text(title),
          ],
        ),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<void> _generatePDF() async {
    final pdf = pw.Document();
    final today = DateFormat('dd/MM/yyyy').format(DateTime.now());
    final confirmedStudents =
        _todayAttendances.where((a) => a['will_attend'] == true).toList();

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Header(
                level: 0,
                child: pw.Text('Lista de Presença - Ônibus'),
              ),
              pw.SizedBox(height: 20),
              pw.Text('Data: $today'),
              pw.Text(
                  'Total confirmados: ${confirmedStudents.length}/$_busCapacity'),
              pw.SizedBox(height: 20),
              pw.Table.fromTextArray(
                headers: ['#', 'Nome do Estudante', 'Status'],
                data: confirmedStudents.asMap().entries.map((entry) {
                  return [
                    '${entry.key + 1}',
                    entry.value['student_name'] ?? 'Nome não informado',
                    'Confirmado'
                  ];
                }).toList(),
              ),
            ],
          );
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
    );
  }

  @override
  Widget build(BuildContext context) {
    DateFormat('EEEE, dd/MM/yyyy', 'pt_BR').format(DateTime.now());
    final confirmedStudents =
        _todayAttendances.where((a) => a['will_attend'] == true).toList();
    final availableSeats = _busCapacity - _totalConfirmed;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Painel Organizador'),
        actions: [
          IconButton(
            icon: const Icon(Icons.qr_code_scanner),
            onPressed: _scanQRCode,
            tooltip: 'Escanear QR Code',
          ),
          IconButton(
            icon: const Icon(Icons.picture_as_pdf),
            onPressed: confirmedStudents.isNotEmpty ? _generatePDF : null,
            tooltip: 'Exportar PDF',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadTodayAttendances,
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => Supabase.instance.client.auth.signOut(),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Cards de resumo
                Container(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Expanded(
                        child: Card(
                          color: Colors.green[50],
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              children: [
                                const Icon(Icons.people,
                                    color: Colors.green, size: 32),
                                const SizedBox(height: 8),
                                Text(
                                  '$_totalConfirmed',
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineMedium
                                      ?.copyWith(
                                        color: Colors.green,
                                        fontWeight: FontWeight.bold,
                                      ),
                                ),
                                const Text('Confirmados'),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Card(
                          color: Colors.blue[50],
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              children: [
                                const Icon(Icons.event_seat,
                                    color: Colors.blue, size: 32),
                                const SizedBox(height: 8),
                                Text(
                                  '$availableSeats',
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineMedium
                                      ?.copyWith(
                                        color: Colors.blue,
                                        fontWeight: FontWeight.bold,
                                      ),
                                ),
                                const Text('Vagas livres'),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Indicador de capacidade
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Capacidade do ônibus',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      LinearProgressIndicator(
                        value: _totalConfirmed / _busCapacity,
                        backgroundColor: Colors.grey[300],
                        valueColor: AlwaysStoppedAnimation<Color>(
                          _totalConfirmed > _busCapacity * 0.8
                              ? Colors.red
                              : Colors.green,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '$_totalConfirmed/$_busCapacity lugares',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Lista de estudantes
                Expanded(
                  child: DefaultTabController(
                    length: 2,
                    child: Column(
                      children: [
                        TabBar(
                          tabs: [
                            Tab(
                                text:
                                    'Confirmados (${confirmedStudents.length})'),
                            Tab(text: 'Todos (${_todayAttendances.length})'),
                          ],
                        ),
                        Expanded(
                          child: TabBarView(
                            children: [
                              _buildStudentList(confirmedStudents,
                                  showOnlyConfirmed: true),
                              _buildStudentList(_todayAttendances,
                                  showOnlyConfirmed: false),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildStudentList(List<Map<String, dynamic>> students,
      {required bool showOnlyConfirmed}) {
    if (students.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.people_outline, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              showOnlyConfirmed
                  ? 'Nenhum estudante confirmou presença ainda'
                  : 'Nenhum registro para hoje',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: students.length,
      itemBuilder: (context, index) {
        final student = students[index];
        final willAttend = student['will_attend'] as bool;
        final studentName = student['student_name'] ?? 'Nome não informado';
        final updatedAt = DateTime.parse(student['updated_at']);

        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: willAttend ? Colors.green : Colors.orange,
              child: Icon(
                willAttend ? Icons.check : Icons.close,
                color: Colors.white,
              ),
            ),
            title: Text(studentName),
            subtitle: Text(
              '${willAttend ? 'Confirmou' : 'Não vai'} às ${DateFormat('HH:mm').format(updatedAt)}',
            ),
            trailing: willAttend
                ? const Icon(Icons.directions_bus, color: Colors.green)
                : const Icon(Icons.cancel, color: Colors.orange),
          ),
        );
      },
    );
  }
}
