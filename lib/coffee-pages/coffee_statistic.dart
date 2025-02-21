import 'package:flutter/material.dart';
import 'coffee_intake.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../logic/cubit/auth_cubit.dart';
import 'beverage_types.dart';
import 'package:fl_chart/fl_chart.dart';

const _monthNames = [
  'January',
  'February',
  'March',
  'April',
  'May',
  'June',
  'July',
  'August',
  'September',
  'October',
  'November',
  'December'
];

class CoffeeStatistic extends StatefulWidget {
  final List<CoffeeIntake> intakes;

  const CoffeeStatistic({super.key, required this.intakes});

  @override
  State<CoffeeStatistic> createState() => _CoffeeStatisticState();
}

class _CoffeeStatisticState extends State<CoffeeStatistic> {
  final ValueNotifier<DateTime> _selectedMonth = ValueNotifier(DateTime.now());

  @override
  void dispose() {
    _selectedMonth.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, state) {
        final currentIntakes = state is IntakesLoaded
            ? state.intakes.map((intake) {
                final beverageType = BeverageTypes.all.firstWhere(
                  (b) => b.name == intake['beverage_type'],
                  orElse: () => BeverageTypes.all[0],
                );
                return CoffeeIntake(
                  DateTime.parse(intake['timestamp']),
                  beverageType,
                  intake['size_in_ml'].toDouble(),
                  databaseData: intake,
                );
              }).toList()
            : widget.intakes;

        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Coffeein Consumption Statistics',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.brown,
                ),
              ),
              const SizedBox(height: 12),
              _buildSummaryCards(currentIntakes),
              const SizedBox(height: 12),
              Expanded(
                child: _buildWeeklyChart(currentIntakes),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSummaryCards(List<CoffeeIntake> intakes) {
    return Row(
      children: [
        _buildStatCard(
          'Today\'s Drinks',
          _getTodayDrinks(intakes).toString(),
          Icons.coffee,
        ),
        const SizedBox(width: 8),
        _buildStatCard(
          'Weekly Average',
          _getWeeklyAverage(intakes).toStringAsFixed(1),
          Icons.analytics,
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.brown.shade50,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.brown.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.brown, size: 24),
            const SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(
                color: Colors.brown.shade700,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              value,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.brown,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeeklyChart(List<CoffeeIntake> intakes) {
    return DefaultTabController(
      length: 3,
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.brown.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Consumption Statistics',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.brown,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TabBar(
                    labelColor: Colors.brown,
                    unselectedLabelColor: Colors.brown.shade200,
                    indicatorColor: Colors.brown,
                    labelStyle: const TextStyle(fontSize: 12),
                    tabs: const [
                      Tab(text: 'Today'),
                      Tab(text: 'Week'),
                      Tab(text: 'Month'),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 4),
            Expanded(
              child: TabBarView(
                children: [
                  _buildDailyChart(intakes),
                  _buildWeekChart(intakes),
                  _buildMonthChart(intakes),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDailyChart(List<CoffeeIntake> intakes) {
    final hourlyData = _getHourlyData(intakes);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: _buildChart(
        data: hourlyData,
        getLabel: (index) {
          if (index % 3 == 0) {
            final hour = index % 24;
            final period = hour >= 12 ? 'PM' : 'AM';
            final displayHour = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour);
            return '$displayHour$period';
          }
          return '';
        },
        isDaily: true,
        barWidth: 12,
      ),
    );
  }

  Widget _buildWeekChart(List<CoffeeIntake> intakes) {
    final weeklyData = _getWeeklyData(intakes);
    return _buildChart(
      data: weeklyData,
      getLabel: (index) => weeklyData[index].dayName,
      isDaily: false,
    );
  }

  Widget _buildMonthChart(List<CoffeeIntake> intakes) {
    return ValueListenableBuilder<DateTime>(
      valueListenable: _selectedMonth,
      builder: (context, selectedDate, child) {
        final monthlyData = _getMonthlyData(intakes, selectedDate);
        final firstDayOfMonth =
            DateTime(selectedDate.year, selectedDate.month, 1);
        final startingWeekday = firstDayOfMonth.weekday;

        return Column(
          children: [
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left),
                  color: Colors.brown,
                  onPressed: () {
                    _selectedMonth.value = DateTime(
                      selectedDate.year,
                      selectedDate.month - 1,
                      1,
                    );
                  },
                ),
                Text(
                  '${_monthNames[selectedDate.month - 1]} ${selectedDate.year}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.brown,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.chevron_right),
                  color: Colors.brown,
                  onPressed: () {
                    _selectedMonth.value = DateTime(
                      selectedDate.year,
                      selectedDate.month + 1,
                      1,
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 4.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _WeekdayLabel('M'),
                  _WeekdayLabel('T'),
                  _WeekdayLabel('W'),
                  _WeekdayLabel('T'),
                  _WeekdayLabel('F'),
                  _WeekdayLabel('S'),
                  _WeekdayLabel('S'),
                ],
              ),
            ),
            const SizedBox(height: 4),
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final availableHeight = constraints.maxHeight - 16;
                  const rows = 6;
                  final cellSize = availableHeight / rows;

                  return GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 7,
                      mainAxisSpacing: 2,
                      crossAxisSpacing: 2,
                      mainAxisExtent: cellSize,
                      childAspectRatio: 1,
                    ),
                    itemCount: 42,
                    itemBuilder: (context, index) {
                      final adjustedIndex = index - (startingWeekday - 1);
                      if (adjustedIndex < 0 ||
                          adjustedIndex >= monthlyData.length) {
                        return Container(
                          decoration: BoxDecoration(
                            color: Colors.brown.shade50.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        );
                      }
                      final dayData = monthlyData[adjustedIndex];
                      return _CalendarCell(data: dayData);
                    },
                  );
                },
              ),
            ),
            const SizedBox(height: 8),
            _buildLegend(),
          ],
        );
      },
    );
  }

  Widget _buildChart({
    required List<DailyData> data,
    required String Function(int) getLabel,
    bool isDaily = false,
    double barWidth = 20,
  }) {
    // Set fixed maximum value to 600mg for both views
    const maxY = 600.0;

    return Padding(
      padding: const EdgeInsets.only(right: 16, left: 8, top: 8, bottom: 24),
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: maxY,
          minY: 0,
          titlesData: FlTitlesData(
            show: true,
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  final label = getLabel(value.toInt());
                  if (label.isEmpty) return const SizedBox();
                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      label,
                      style: const TextStyle(
                        color: Colors.brown,
                        fontSize: 10,
                      ),
                    ),
                  );
                },
                reservedSize: 32,
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 45,
                interval: 100,
                getTitlesWidget: (value, meta) {
                  // Only show labels for multiples of 100
                  if (value % 100 != 0) return const SizedBox();
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: Text(
                      '${value.toInt()}mg',
                      style: const TextStyle(
                        color: Colors.brown,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  );
                },
              ),
            ),
            rightTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          gridData: FlGridData(
            show: true,
            horizontalInterval: 100, // Show grid lines every 100mg
            getDrawingHorizontalLine: (value) {
              return FlLine(
                color: Colors.brown.withOpacity(0.1),
                strokeWidth: 1,
              );
            },
          ),
          barGroups: data.asMap().entries.map((entry) {
            return BarChartGroupData(
              x: entry.key,
              barRods: [
                BarChartRodData(
                  toY: entry.value.caffeine.toDouble(),
                  color: Colors.brown,
                  width: barWidth,
                  borderRadius: BorderRadius.circular(4),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  List<DailyData> _getHourlyData(List<CoffeeIntake> intakes) {
    final now = DateTime.now();
    return List.generate(24, (hour) {
      final hourlyIntakes = intakes.where((intake) =>
          intake.time.year == now.year &&
          intake.time.month == now.month &&
          intake.time.day == now.day &&
          intake.time.hour == hour);

      final totalCaffeine = hourlyIntakes.fold<double>(
          0,
          (sum, intake) =>
              sum + intake.beverageType.calculateCaffeine(intake.sizeInMl));

      return DailyData(hour.toString(), totalCaffeine.round());
    });
  }

  List<DailyData> _getMonthlyData(List<CoffeeIntake> intakes, DateTime date) {
    final daysInMonth = DateTime(date.year, date.month + 1, 0).day;

    return List.generate(daysInMonth, (index) {
      final day = DateTime(date.year, date.month, index + 1);
      final dayIntakes = intakes.where((intake) =>
          intake.time.year == day.year &&
          intake.time.month == day.month &&
          intake.time.day == day.day);

      final totalCaffeine = dayIntakes.fold<double>(
          0,
          (sum, intake) =>
              sum + intake.beverageType.calculateCaffeine(intake.sizeInMl));

      return DailyData(
        '${day.day}',
        totalCaffeine.round(),
      );
    });
  }

  int _getTodayDrinks(List<CoffeeIntake> intakes) {
    final now = DateTime.now();
    return intakes
        .where((intake) =>
            intake.time.year == now.year &&
            intake.time.month == now.month &&
            intake.time.day == now.day)
        .length;
  }

  double _getWeeklyAverage(List<CoffeeIntake> intakes) {
    final now = DateTime.now();
    final weekAgo = now.subtract(const Duration(days: 7));
    final weeklyIntakes =
        intakes.where((intake) => intake.time.isAfter(weekAgo)).length;
    return weeklyIntakes / 7;
  }

  List<DailyData> _getWeeklyData(List<CoffeeIntake> intakes) {
    final now = DateTime.now();
    // Find the most recent Monday
    final mostRecentMonday = now.subtract(Duration(days: now.weekday - 1));

    final dayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

    return List.generate(7, (index) {
      final day = mostRecentMonday.add(Duration(days: index));
      final dayIntakes = intakes.where((intake) =>
          intake.time.year == day.year &&
          intake.time.month == day.month &&
          intake.time.day == day.day);

      final totalCaffeine = dayIntakes.fold<double>(
          0,
          (sum, intake) =>
              sum + intake.beverageType.calculateCaffeine(intake.sizeInMl));

      return DailyData(dayNames[index], totalCaffeine.round());
    });
  }

  Widget _buildLegend() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _LegendItem(color: Colors.brown.shade50, label: '0mg'),
        const SizedBox(width: 8),
        _LegendItem(color: Colors.brown.shade200, label: '100mg'),
        const SizedBox(width: 8),
        _LegendItem(color: Colors.brown.shade400, label: '200mg'),
        const SizedBox(width: 8),
        _LegendItem(color: Colors.brown.shade600, label: '300mg+'),
      ],
    );
  }
}

class DailyData {
  final String dayName;
  final int caffeine;
  DailyData(this.dayName, this.caffeine);
}

class _WeekdayLabel extends StatelessWidget {
  final String label;

  const _WeekdayLabel(this.label);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 40,
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          color: Colors.brown.shade300,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}

class _CalendarCell extends StatelessWidget {
  final DailyData data;

  const _CalendarCell({required this.data});

  Color _getColorForCaffeine(int caffeine) {
    if (caffeine == 0) return Colors.brown.shade50;
    if (caffeine < 100) return Colors.brown.shade200;
    if (caffeine < 200) return Colors.brown.shade400;
    return Colors.brown.shade600;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: _getColorForCaffeine(data.caffeine),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: Center(
              child: Text(
                data.dayName,
                style: TextStyle(
                  color: data.caffeine > 100 ? Colors.white : Colors.brown,
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          if (data.caffeine > 0)
            Positioned(
              right: 2,
              bottom: 2,
              child: Text(
                '${data.caffeine}',
                style: TextStyle(
                  color: data.caffeine > 100
                      ? Colors.white70
                      : Colors.brown.shade400,
                  fontSize: 8,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendItem({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.brown.shade700,
          ),
        ),
      ],
    );
  }
}
