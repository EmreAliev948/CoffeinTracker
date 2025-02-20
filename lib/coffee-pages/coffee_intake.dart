import 'package:flutter/material.dart';
import 'caffeine_calculator.dart';
import 'beverage_types.dart';
import 'dart:math';

class CoffeeIntake {
  final DateTime time;
  final BeverageType beverageType;
  final double sizeInMl;
  final double caffeineContent;
  final Map<String, dynamic>? databaseData;

  CoffeeIntake(this.time, this.beverageType, this.sizeInMl, {this.databaseData})
      : caffeineContent = beverageType.calculateCaffeine(sizeInMl);

  double getRemainingCaffeine() {
    final timePassed = DateTime.now().difference(time);
    return CaffeineCalculator.calculateRemainingCaffeine(
        caffeineContent, timePassed);
  }

  String get warningLevel {
    final remainingCaffeine = getRemainingCaffeine();
    if (remainingCaffeine >= 400) return 'DANGEROUS LEVEL!';
    if (remainingCaffeine >= 200) return 'Warning!';
    return '';
  }

  String get timeRemaining {
    final remaining = getRemainingCaffeine();
    if (remaining < 1) return 'Cleared';

    const hoursToHalf = CaffeineCalculator.HALF_LIFE_HOURS;
    final halfLifeCycles = log(remaining / caffeineContent) / log(0.5);
    final hoursRemaining = (hoursToHalf * (halfLifeCycles + 1)).abs();

    return '${hoursRemaining.toStringAsFixed(1)}h remaining';
  }

  Color getWarningColor() {
    final remainingCaffeine = getRemainingCaffeine();
    if (remainingCaffeine >= 400) return Colors.red.shade200;
    if (remainingCaffeine >= 200) return Colors.orange.shade200;
    return Colors.green.shade200;
  }
}
