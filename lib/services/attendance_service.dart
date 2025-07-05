import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/attendance.dart';
import 'package:intl/intl.dart';

class AttendanceService {
  final SupabaseClient _client = Supabase.instance.client;

  Future<List<Attendance>> getTodayAttendances() async {
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    
    final response = await _client
        .from('attendances')
        .select()
        .eq('date', today)
        .order('student_name');

    return response.map<Attendance>((json) => Attendance.fromJson(json)).toList();
  }

  Future<Attendance?> getUserTodayAttendance(String userId) async {
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    
    final response = await _client
        .from('attendances')
        .select()
        .eq('user_id', userId)
        .eq('date', today)
        .maybeSingle();

    return response != null ? Attendance.fromJson(response) : null;
  }

  Future<List<Attendance>> getUserAttendanceHistory(String userId, {int limit = 30}) async {
    final response = await _client
        .from('attendances')
        .select()
        .eq('user_id', userId)
        .order('date', ascending: false)
        .limit(limit);

    return response.map<Attendance>((json) => Attendance.fromJson(json)).toList();
  }

  Future<void> updateAttendance({
    required String userId,
    required bool willAttend,
    required String studentName,
  }) async {
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    
    await _client.from('attendances').upsert({
      'user_id': userId,
      'date': today,
      'will_attend': willAttend,
      'student_name': studentName,
      'updated_at': DateTime.now().toIso8601String(),
    });
  }

  Stream<List<Attendance>> watchTodayAttendances() {
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    
    return _client
        .from('attendances')
        .stream(primaryKey: ['id'])
        .eq('date', today)
        .map((data) => data.map<Attendance>((json) => Attendance.fromJson(json)).toList());
  }
}
