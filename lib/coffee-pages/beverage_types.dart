import 'package:flutter/material.dart';

//TO DO SHOULD BE DELETED AND ONLY TAKE THE LIST FROM THE DB
class BeverageType {
  final String name;
  final double caffeineContentPer250ml;
  final IconData icon;
  final double caffeinePerMl;

  const BeverageType({
    required this.name,
    required this.caffeineContentPer250ml,
    required this.icon,
    required this.caffeinePerMl,
  });

  double calculateCaffeine(double sizeInMl) {
    return (caffeineContentPer250ml * sizeInMl) / 250;
  }
}

class BeverageTypes {
  static const List<BeverageType> all = [
    BeverageType(
      name: 'Espresso',
      caffeineContentPer250ml: 63,
      icon: Icons.coffee,
      caffeinePerMl: 2.0,
    ),
    BeverageType(
      name: 'Double Espresso',
      caffeineContentPer250ml: 126,
      icon: Icons.coffee,
      caffeinePerMl: 2.0,
    ),
    BeverageType(
      name: 'Drip coffee',
      caffeineContentPer250ml: 95,
      icon: Icons.coffee_maker,
      caffeinePerMl: 2.0,
    ),
    BeverageType(
      name: 'Cold Brew',
      caffeineContentPer250ml: 200,
      icon: Icons.ac_unit,
      caffeinePerMl: 0.8,
    ),
    BeverageType(
      name: 'Instant coffee',
      caffeineContentPer250ml: 60,
      icon: Icons.coffee,
      caffeinePerMl: 2.0,
    ),
    BeverageType(
      name: 'Decaf coffee',
      caffeineContentPer250ml: 4,
      icon: Icons.coffee_outlined,
      caffeinePerMl: 2.0,
    ),
    BeverageType(
      name: 'Black tea',
      caffeineContentPer250ml: 47,
      icon: Icons.emoji_food_beverage,
      caffeinePerMl: 2.0,
    ),
    BeverageType(
      name: 'Green tea',
      caffeineContentPer250ml: 28,
      icon: Icons.emoji_food_beverage_outlined,
      caffeinePerMl: 2.0,
    ),
    BeverageType(
      name: 'Cola drink',
      caffeineContentPer250ml: 34,
      icon: Icons.local_drink,
      caffeinePerMl: 2.0,
    ),
    BeverageType(
      name: 'Red Bull',
      caffeineContentPer250ml: 80,
      icon: Icons.flash_on,
      caffeinePerMl: 2.0,
    ),
    BeverageType(
      name: 'Monster',
      caffeineContentPer250ml: 160,
      icon: Icons.battery_charging_full,
      caffeinePerMl: 2.0,
    ),
    BeverageType(
      name: 'Chocolate drink',
      caffeineContentPer250ml: 5,
      icon: Icons.cookie,
      caffeinePerMl: 2.0,
    ),
    BeverageType(
      name: 'Matcha tea',
      caffeineContentPer250ml: 70,
      icon: Icons.grass,
      caffeinePerMl: 2.0,
    ),
  ];
}
