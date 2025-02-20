import 'package:flutter/material.dart';

class RiveAnimationControllerHelper {
  // Singleton class for managing Rive animation controllers.
  // This class ensures that only one instance is created throughout
  // the application's lifecycle, allowing easy access to animation
  // controllers across different parts of the app without the need
  // to recreate them. The Singleton pattern is used to maintain
  // consistency and avoid unnecessary resource consumption.

  static final RiveAnimationControllerHelper _instance =
      RiveAnimationControllerHelper._internal();

  factory RiveAnimationControllerHelper() {
    return _instance;
  }

  RiveAnimationControllerHelper._internal();

  Widget? _currentWidget;
  bool isLookingRight = false;
  bool isLookingLeft = false;
  
  Widget? get currentWidget => _currentWidget;

  void addHandsUpController() {
    removeAllControllers();
    _currentWidget = Image.asset('assets/animation/icon.PNG');
  }

  void addHandsDownController() {
    removeAllControllers();
    _currentWidget = Image.asset('assets/animation/icon.PNG');
  }

  void addFailController() {
    removeAllControllers();
    _currentWidget = Image.asset('assets/animation/icon.PNG');
  }

  void addSuccessController() {
    removeAllControllers();
    _currentWidget = Image.asset('assets/animation/icon.PNG');
  }

  void addDownLeftController() {
    removeAllControllers();
    _currentWidget = Image.asset('assets/animation/icon.PNG');
    isLookingLeft = true;
  }

  void addDownRightController() {
    removeAllControllers();
    _currentWidget = Image.asset('assets/animation/icon.PNG');
    isLookingRight = true;
  }

  Future<void> loadRiveFile(String assetPath) async {
    _currentWidget = Image.asset('assets/animation/icon.PNG');
  }

  void removeAllControllers() {
    isLookingLeft = false;
    isLookingRight = false;
  }

  void dispose() {
    _currentWidget = null;
    removeAllControllers();
  }
}
