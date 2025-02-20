import 'dart:math';

import 'coffee_intake.dart';

class CaffeineCalculator {
  static const double HALF_LIFE_HOURS = 5.0;
  static const int DANGER_THRESHOLD_ONE_HOUR = 3; // drinks in 1 hour
  static const double DAILY_LIMIT_MG = 400.0; // FDA recommended limit
  
  // Peak effect constants
  static const Duration TIME_TO_PEAK = Duration(minutes: 30);
  static const Duration PEAK_DURATION = Duration(minutes: 60);
  
  static double calculateRemainingCaffeine(double initialAmount, Duration timePassed) {
    double hoursElapsed = timePassed.inMinutes / 60.0;
    return initialAmount * pow(0.5, hoursElapsed / HALF_LIFE_HOURS);
  }

  static double getCurrentCaffeineLevel(List<CoffeeIntake> intakes) {
    final now = DateTime.now();
    double totalCaffeine = 0;

    for (var intake in intakes) {
      Duration timePassed = now.difference(intake.time);
      totalCaffeine += calculateRemainingCaffeine(intake.caffeineContent, timePassed);
    }

    return totalCaffeine;
  }

  static double getPeakEffectMultiplier(List<CoffeeIntake> intakes) {
    final now = DateTime.now();
    double peakMultiplier = 1.0;

    for (var intake in intakes) {
      final timeSinceIntake = now.difference(intake.time);
      
      // Check if this intake is in its peak effect period
      if (timeSinceIntake >= TIME_TO_PEAK && 
          timeSinceIntake <= TIME_TO_PEAK + PEAK_DURATION) {
        // Calculate how far through the peak period we are (0.0 to 1.0)
        final peakProgress = (timeSinceIntake - TIME_TO_PEAK).inMinutes / 
                           PEAK_DURATION.inMinutes;
        
        // Peak effect adds up to 30% more effectiveness, gradually declining
        final thisIntakePeakEffect = 0.3 * (1 - peakProgress);
        peakMultiplier = max(peakMultiplier, 1 + thisIntakePeakEffect);
      }
    }

    return peakMultiplier;
  }

  static double getEffectiveCaffeineLevel(List<CoffeeIntake> intakes) {
    final baseLevel = getCurrentCaffeineLevel(intakes);
    final peakMultiplier = getPeakEffectMultiplier(intakes);
    return baseLevel * peakMultiplier;
  }

  static bool isFrequentConsumption(List<CoffeeIntake> intakes) {
    if (intakes.isEmpty) return false;
    
    final now = DateTime.now();
    final lastHourIntakes = intakes.where((intake) {
      return now.difference(intake.time).inHours < 1;
    }).length;

    return lastHourIntakes >= DANGER_THRESHOLD_ONE_HOUR;
  }

  static bool isOverDailyLimit(List<CoffeeIntake> intakes) {
    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);
    
    final todayIntakes = intakes.where((intake) => 
      intake.time.isAfter(todayStart) || intake.time.isAtSameMomentAs(todayStart));
    
    double totalToday = 0;
    for (var intake in todayIntakes) {
      totalToday += intake.getRemainingCaffeine();
    }
    
    return totalToday > DAILY_LIMIT_MG;
  }

  static String getPeakEffectStatus(List<CoffeeIntake> intakes) {
    final now = DateTime.now();
    DateTime? nextPeakStart;
    DateTime? currentPeakEnd;

    for (var intake in intakes) {
      final peakStart = intake.time.add(TIME_TO_PEAK);
      final peakEnd = peakStart.add(PEAK_DURATION);

      if (now.isBefore(peakStart)) {
        // This intake hasn't reached peak yet
        nextPeakStart ??= peakStart;
        nextPeakStart = nextPeakStart.isBefore(peakStart) ? nextPeakStart : peakStart;
      } else if (now.isBefore(peakEnd)) {
        // This intake is currently at peak
        currentPeakEnd ??= peakEnd;
        currentPeakEnd = currentPeakEnd.isAfter(peakEnd) ? currentPeakEnd : peakEnd;
      }
    }

    if (currentPeakEnd != null) {
      final remainingMinutes = currentPeakEnd.difference(now).inMinutes;
      return 'Peak effects for ${remainingMinutes}m';
    } else if (nextPeakStart != null) {
      final minutesToPeak = nextPeakStart.difference(now).inMinutes;
      return 'Peak in ${minutesToPeak}m';
    }
    
    return 'No active peaks';
  }
}
