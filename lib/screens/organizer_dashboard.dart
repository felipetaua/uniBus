import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
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
  final int _busCapacity = 45; // Capacidade do ônibus

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
            _totalConfirmed = data.where((a) => a['will_attend'] == true).length;
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
        _totalConfirmed = _todayAttendances.where((a) => a['will_attend'] == true).length;
        _isLoading = false;
      });
    } catch (error) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao carregar dados: $error')),
      );
    }
  }

  Future<void> _generatePDF() async {
    final pdf = pw.Document();
    final today = DateFormat('dd/MM/yyyy').format(DateTime.now());
    final confirmedStudents = _todayAttendances
        .where((a) => a['will_attend'] == true)
        .toList();

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
              pw.Text('Total confirmados: ${confirmedStudents.length}/$_busCapacity'),
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
    final today = DateFormat('EEEE, dd/MM/yyyy', 'pt_BR').format(DateTime.now());
    final confirmedStudents = _todayAttendances
        .where((a) => a['will_attend'] == true)
        .toList();
    final availableSeats = _busCapacity - _totalConfirmed;

    return Scaffold(
      appBar: AppBar(
        title: Text('Painel Organizador'),
        actions: [
          IconButton(
            icon: Icon(Icons.picture_as_pdf),
            onPressed: confirmedStudents.isNotEmpty ? _generatePDF : null,
            tooltip: 'Exportar PDF',
          ),
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _loadTodayAttendances,
          ),
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () => Supabase.instance.client.auth.signOut(),
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Cards de resumo
                Container(
                  padding: EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Expanded(
                        child: Card(
                          color: Colors.green[50],
                          child: Padding(
                            padding: EdgeInsets.all(16),
                            child: Column(
                              children: [
                                Icon(Icons.people, color: Colors.green, size: 32),
                                SizedBox(height: 8),
                                Text(
                                  '$_totalConfirmed',
                                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                    color: Colors.green,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text('Confirmados'),
                              ],
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: Card(
                          color: Colors.blue[50],
                          child: Padding(
                            padding: EdgeInsets.all(16),
                            child: Column(
                              children: [
                                Icon(Icons.event_seat, color: Colors.blue, size: 32),
                                SizedBox(height: 8),
                                Text(
                                  '$availableSeats',
                                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                    color: Colors.blue,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text('Vagas livres'),
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
                  margin: EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Capacidade do ônibus',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      SizedBox(height: 8),
                      LinearProgressIndicator(
                        value: _totalConfirmed / _busCapacity,
                        backgroundColor: Colors.grey[300],
                        valueColor: AlwaysStoppedAnimation<Color>(
                          _totalConfirmed > _busCapacity * 0.8 
                              ? Colors.red 
                              : Colors.green,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        '$_totalConfirmed/$_busCapacity lugares',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 16),

                // Lista de estudantes
                Expanded(
                  child: DefaultTabController(
                    length: 2,
                    child: Column(
                      children: [
                        TabBar(
                          tabs: [
                            Tab(text: 'Confirmados (${confirmedStudents.length})'),
                            Tab(text: 'Todos (${_todayAttendances.length})'),
                          ],
                        ),
                        Expanded(
                          child: TabBarView(
                            children: [
                              _buildStudentList(confirmedStudents, showOnlyConfirmed: true),
                              _buildStudentList(_todayAttendances, showOnlyConfirmed: false),
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

  Widget _buildStudentList(List<Map<String, dynamic>> students, {required bool showOnlyConfirmed}) {
    if (students.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.people_outline, size: 64, color: Colors.grey),
            SizedBox(height: 16),
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
      padding: EdgeInsets.all(16),
      itemCount: students.length,
      itemBuilder: (context, index) {
        final student = students[index];
        final willAttend = student['will_attend'] as bool;
        final studentName = student['student_name'] ?? 'Nome não informado';
        final updatedAt = DateTime.parse(student['updated_at']);

        return Card(
          margin: EdgeInsets.only(bottom: 8),
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
                ? Icon(Icons.directions_bus, color: Colors.green)
                : Icon(Icons.cancel, color: Colors.orange),
          ),
        );
      },
    );
  }
}
