import 'package:flutter/material.dart';
import 'coffee_intake.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../logic/cubit/auth_cubit.dart';
import 'beverage_types.dart';

class CoffeeStatistic extends StatelessWidget {
  final List<CoffeeIntake> intakes;

  const CoffeeStatistic({super.key, required this.intakes});

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
            : intakes;

        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Coffeein Consumption Statistics',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.brown,
                ),
              ),
              const SizedBox(height: 20),
              _buildSummaryCards(currentIntakes),
              const SizedBox(height: 20),
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
        const SizedBox(width: 16),
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
        padding: const EdgeInsets.all(16),
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
          children: [
            Icon(icon, color: Colors.brown, size: 32),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                color: Colors.brown.shade700,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(
                fontSize: 24,
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
    return Container(
      padding: const EdgeInsets.all(16),
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
      child: const Center(
        child: Text('TO DO: WEEKLY CHART'),
      ),
    );
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
}
