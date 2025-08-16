import 'package:bus_attendance_app/core/theme/colors.dart';
import 'package:bus_attendance_app/core/theme/text_styles.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
// Para o PDF, você precisará dos pacotes:
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class GestorRelatoryPage extends StatefulWidget {
  const GestorRelatoryPage({super.key});

  @override
  State<GestorRelatoryPage> createState() => _GestorRelatoryPageState();
}

class _GestorRelatoryPageState extends State<GestorRelatoryPage> {
  String _selectedFilter = 'Esta Semana';

  // TODO: Adicionar a lógica para gerar o PDF com os dados do relatório
  Future<void> _generatePdf() async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Gerando PDF... (funcionalidade a ser implementada)'),
        backgroundColor: AppColors.lightPrimary,
      ),
    );

    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Center(child: pw.Text('Relatório de Presença - UniBus'));
        },
      ),
    ); // Fim do pw.Page

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final Brightness brightness = Theme.of(context).brightness;
    final bool isDarkMode = brightness == Brightness.dark;

    // Cores do tema
    final Color backgroundColor =
        isDarkMode ? AppColors.darkBackground : AppColors.lightBackground;
    final Color surfaceColor =
        isDarkMode ? AppColors.darkSurface : AppColors.lightSurface;
    final Color textPrimaryColor =
        isDarkMode ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final Color textSecondaryColor =
        isDarkMode ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
    final Color primaryColor =
        isDarkMode ? AppColors.darkPrimary : AppColors.lightPrimary;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: Text(
          'Relatórios',
          style: AppTextStyles.lightTitle.copyWith(color: textPrimaryColor),
        ),
        backgroundColor: backgroundColor,
        elevation: 0,
        iconTheme: IconThemeData(color: textPrimaryColor),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDateFilter(primaryColor, textSecondaryColor),
            const SizedBox(height: 24),
            Text(
              'Resumo do Período',
              style: AppTextStyles.lightTitle.copyWith(
                fontSize: 20,
                color: textPrimaryColor,
              ),
            ),
            const SizedBox(height: 16),
            _buildMetricsGrid(),
            const SizedBox(height: 24),
            Text(
              'Presença na Semana',
              style: AppTextStyles.lightTitle.copyWith(
                fontSize: 20,
                color: textPrimaryColor,
              ),
            ),
            const SizedBox(height: 16),
            _buildAttendanceChart(
              surfaceColor,
              primaryColor,
              textSecondaryColor,
            ),
            const SizedBox(height: 32),
            _buildPdfButton(primaryColor),
          ],
        ),
      ),
    );
  }

  Widget _buildDateFilter(Color primaryColor, Color textSecondaryColor) {
    final filters = ['Hoje', 'Esta Semana', 'Este Mês'];
    return SizedBox(
      height: 40,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          ...filters.map(
            (filter) => GestureDetector(
              onTap: () => setState(() => _selectedFilter = filter),
              child: Container(
                margin: const EdgeInsets.only(right: 10),
                padding: const EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  color:
                      _selectedFilter == filter
                          ? primaryColor
                          : Colors.transparent,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color:
                        _selectedFilter == filter
                            ? primaryColor
                            : textSecondaryColor.withOpacity(0.5),
                  ),
                ),
                alignment: Alignment.center,
                child: Text(
                  filter,
                  style: AppTextStyles.lightBody.copyWith(
                    fontWeight: FontWeight.bold,
                    color:
                        _selectedFilter == filter
                            ? Colors.white
                            : textSecondaryColor,
                  ),
                ),
              ),
            ),
          ),
          // Botão para um seletor de data customizado
          Container(
            margin: const EdgeInsets.only(right: 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: textSecondaryColor.withOpacity(0.5)),
            ),
            child: IconButton(
              icon: Icon(
                Icons.calendar_today_outlined,
                size: 20,
                color: textSecondaryColor,
              ),
              onPressed: () {
                // TODO: Implementar Date Range Picker
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricsGrid() {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 15,
      mainAxisSpacing: 15,
      childAspectRatio: 1.5,
      children: const [
        _MetricCard(
          title: 'Média Diária',
          value: '35',
          icon: Icons.people_alt_outlined,
          color: Color(0xFF828EF3),
        ),
        _MetricCard(
          title: 'Pico de Presença',
          value: '42',
          icon: Icons.trending_up_rounded,
          color: Color(0xFF84CFB2),
        ),
        _MetricCard(
          title: 'Total de Ausências',
          value: '15',
          icon: Icons.person_off_outlined,
          color: Color(0xFFF3C482),
        ),
        _MetricCard(
          title: 'Dia Mais Cheio',
          value: 'Sexta',
          icon: Icons.calendar_view_week_outlined,
          color: Color(0xFFB687E7),
        ),
      ],
    );
  }

  Widget _buildAttendanceChart(
    Color surfaceColor,
    Color primaryColor,
    Color textSecondaryColor,
  ) {
    return Card(
      color: surfaceColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: SizedBox(
          height: 200,
          child: BarChart(
            BarChartData(
              alignment: BarChartAlignment.spaceAround,
              maxY: 50, // Capacidade máxima do ônibus
              barTouchData: BarTouchData(enabled: true),
              titlesData: FlTitlesData(
                show: true,
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      final style = TextStyle(
                        fontSize: 12,
                        color: textSecondaryColor,
                      );
                      String text;
                      switch (value.toInt()) {
                        case 0:
                          text = 'Seg';
                          break;
                        case 1:
                          text = 'Ter';
                          break;
                        case 2:
                          text = 'Qua';
                          break;
                        case 3:
                          text = 'Qui';
                          break;
                        case 4:
                          text = 'Sex';
                          break;
                        default:
                          text = '';
                          break;
                      }
                      return Padding(
                        padding: const EdgeInsets.only(top: 4.0),
                        child: Text(text, style: style),
                      );
                    },
                    reservedSize: 28,
                  ),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 30,
                    getTitlesWidget: (value, meta) {
                      final style = TextStyle(
                        fontSize: 12,
                        color: textSecondaryColor,
                      );
                      // Mostra apenas os valores de 10 em 10 para não poluir
                      if (value % 10 != 0) {
                        return Container();
                      }
                      return Text(
                        value.toInt().toString(),
                        style: style,
                        textAlign: TextAlign.left,
                      );
                    },
                  ),
                ),
                topTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                rightTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
              ),
              gridData: FlGridData(
                show: true,
                drawVerticalLine: false,
                horizontalInterval: 10,
                getDrawingHorizontalLine: (value) {
                  return FlLine(
                    color: textSecondaryColor.withOpacity(0.2),
                    strokeWidth: 1,
                  );
                },
              ),
              borderData: FlBorderData(show: false),
              barGroups: [
                _makeBarData(0, 30, primaryColor),
                _makeBarData(1, 35, primaryColor),
                _makeBarData(2, 28, primaryColor),
                _makeBarData(3, 40, primaryColor),
                _makeBarData(4, 42, primaryColor),
              ],
            ),
          ),
        ),
      ),
    );
  }

  BarChartGroupData _makeBarData(int x, double y, Color color) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: y,
          color: color,
          width: 20,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(6),
            topRight: Radius.circular(6),
          ),
        ),
      ],
    );
  }

  Widget _buildPdfButton(Color primaryColor) {
    return ElevatedButton.icon(
      icon: const Icon(Icons.picture_as_pdf_outlined, color: Colors.white),
      label: const Text(
        'Gerar Relatório em PDF',
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
      onPressed: _generatePdf,
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        minimumSize: const Size(double.infinity, 50),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 5,
      ),
    );
  }
}

// Widget para os cards de métricas
class _MetricCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _MetricCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      color: color.withOpacity(0.9),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(icon, size: 28, color: Colors.white.withOpacity(0.8)),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: AppTextStyles.lightTitle.copyWith(
                    color: Colors.white,
                    fontSize: 24,
                  ),
                ),
                Text(
                  title,
                  style: AppTextStyles.lightBody.copyWith(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
