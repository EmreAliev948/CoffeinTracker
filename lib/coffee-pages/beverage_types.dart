import 'package:flutter/material.dart';

class BeverageType {
  final String name;
  final double caffeineContentPer250ml;
  final IconData icon;
  
  const BeverageType(this.name, this.caffeineContentPer250ml, this.icon);
  
  double calculateCaffeine(double sizeInMl) {
    return (caffeineContentPer250ml * sizeInMl) / 250;
  }
}

class BeverageTypes {
  static const List<BeverageType> all = [
    BeverageType('Espresso', 63, Icons.coffee),
    BeverageType('Double Espresso', 126, Icons.coffee),
    BeverageType('Drip coffee', 95, Icons.coffee_maker),
    BeverageType('Cold Brew', 200, Icons.ac_unit),
    BeverageType('Instant coffee', 60, Icons.coffee),
    BeverageType('Decaf coffee', 4, Icons.coffee_outlined),
    BeverageType('Black tea', 47, Icons.emoji_food_beverage),
    BeverageType('Green tea', 28, Icons.emoji_food_beverage_outlined),
    BeverageType('Cola drink', 34, Icons.local_drink),
    BeverageType('Red Bull', 80, Icons.flash_on),
    BeverageType('Monster', 160, Icons.battery_charging_full),
    BeverageType('Chocolate drink', 5, Icons.cookie),
    BeverageType('Matcha tea', 70, Icons.grass),
  ];
}
