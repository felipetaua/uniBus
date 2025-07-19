import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';

class StudentHistory extends StatefulWidget {
  const StudentHistory({super.key});

  @override
  _StudentHistoryState createState() => _StudentHistoryState();
}

class _StudentHistoryState extends State<StudentHistory> {
  List<Map<String, dynamic>> _attendances = [];
  bool _isLoading = true;
  String _filter = 'all'; // 'all', 'present', 'absent'

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;

    try {
      final response = await Supabase.instance.client
          .from('attendances')
          .select()
          .eq('user_id', user.id)
          .order('date', ascending: false)
          .limit(30);

      setState(() {
        _attendances = List<Map<String, dynamic>>.from(response);
        _isLoading = false;
      });
    } catch (error) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao carregar histórico: $error')),
      );
    }
  }

  List<Map<String, dynamic>> get _filteredAttendances {
    if (_filter == 'present') {
      return _attendances.where((a) => a['will_attend'] == true).toList();
    } else if (_filter == 'absent') {
      return _attendances.where((a) => a['will_attend'] == false).toList();
    }
    return _attendances;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Meu Histórico'),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.filter_list),
            onSelected: (value) => setState(() => _filter = value),
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'all', child: Text('Todos')),
              const PopupMenuItem(
                  value: 'present', child: Text('Só presenças')),
              const PopupMenuItem(value: 'absent', child: Text('Só ausências')),
            ],
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _filteredAttendances.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.history, size: 64, color: Colors.grey),
                      const SizedBox(height: 16),
                      Text(
                        'Nenhum registro encontrado',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Suas confirmações de presença aparecerão aqui',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _filteredAttendances.length,
                  itemBuilder: (context, index) {
                    final attendance = _filteredAttendances[index];
                    final date = DateTime.parse(attendance['date']);
                    final willAttend = attendance['will_attend'] as bool;

                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor:
                              willAttend ? Colors.green : Colors.orange,
                          child: Icon(
                            willAttend ? Icons.check : Icons.close,
                            color: Colors.white,
                          ),
                        ),
                        title: Text(
                          DateFormat('EEEE, dd/MM/yyyy', 'pt_BR').format(date),
                        ),
                        subtitle: Text(
                          willAttend
                              ? 'Confirmou presença'
                              : 'Registrou ausência',
                        ),
                        trailing: Text(
                          DateFormat('HH:mm').format(
                            DateTime.parse(attendance['updated_at']),
                          ),
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
