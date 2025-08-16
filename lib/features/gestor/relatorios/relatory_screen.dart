import 'package:bus_attendance_app/core/theme/colors.dart';
import 'package:bus_attendance_app/core/theme/text_styles.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
// Para o PDF, você precisará dos pacotes:
import 'package:pdf/pdf.dart' as pdf;
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

    final pdfDoc = pw.Document();

    pdfDoc.addPage(
      pw.Page(
        pageFormat: pdf.PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Center(child: pw.Text('Relatório de Presença - UniBus'));
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (pdf.PdfPageFormat format) async => pdfDoc.save(),
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
    final Color onPrimaryColor =
        isDarkMode ? AppColors.darkOnPrimary : AppColors.lightOnPrimary;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: Stack(
        children: [
          // Fundo com gradiente
          Container(
            height: MediaQuery.of(context).size.height * 0.35,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFFB06DF9),
                  Color(0xFF828EF3),
                  Color(0xFF84CFB2),
                  Color(0xFFCAFF5C),
                ],
                stops: [0.0, 0.33, 0.66, 1.0],
              ),
            ),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [backgroundColor.withOpacity(0.0), backgroundColor],
                  stops: const [0.2, 1.0],
                ),
              ),
            ),
          ),
          // Conteúdo principal rolável
          SafeArea(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(onPrimaryColor),
                  const SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: _buildDateFilter(primaryColor, textSecondaryColor),
                  ),
                  const SizedBox(height: 24),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Text(
                      'Resumo do Período',
                      style: AppTextStyles.lightTitle.copyWith(
                        fontSize: 20,
                        color: textPrimaryColor,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: _buildMetricsGrid(),
                  ),
                  const SizedBox(height: 24),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Text(
                      'Presença na Semana',
                      style: AppTextStyles.lightTitle.copyWith(
                        fontSize: 20,
                        color: textPrimaryColor,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: _buildAttendanceChart(
                      surfaceColor,
                      primaryColor,
                      textSecondaryColor,
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(Color onPrimaryColor) {
    return Padding(
      padding: const EdgeInsets.only(top: 20.0, left: 20.0, right: 20.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Relatórios',
            style: AppTextStyles.lightTitle.copyWith(
              color: onPrimaryColor,
              fontSize: 24,
            ),
          ),
          Container(
            width: 45,
            height: 45,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(0.3),
            ),
            child: IconButton(
              icon: Icon(Icons.picture_as_pdf_outlined, color: onPrimaryColor),
              tooltip: 'Gerar Relatório em PDF',
              onPressed: _generatePdf,
            ),
          ),
        ],
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
              barTouchData: BarTouchData(
                enabled: true,
                touchTooltipData: BarTouchTooltipData(
                  getTooltipColor: (group) => Colors.black87,
                  getTooltipItem: (group, groupIndex, rod, rodIndex) {
                    return BarTooltipItem(
                      '${rod.toY.round()}',
                      const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    );
                  },
                ),
              ),
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
                _makeBarData(0, 30),
                _makeBarData(1, 35),
                _makeBarData(2, 28),
                _makeBarData(3, 40),
                _makeBarData(4, 42),
              ],
            ),
          ),
        ),
      ),
    );
  }

  BarChartGroupData _makeBarData(int x, double y) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: y,
          width: 20,
          gradient: const LinearGradient(
            colors: [AppColors.lightPrimary, Color(0xFF84CFB2)],
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
          ),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(6),
            topRight: Radius.circular(6),
          ),
        ),
      ],
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
