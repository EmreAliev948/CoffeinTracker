import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'coffee_intake.dart';
import 'beverage_types.dart';
import 'package:flutter/services.dart';
import 'caffeine_calculator.dart';
import 'caffeine_clock.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../routing/routes.dart';
import '../logic/cubit/auth_cubit.dart';
import '../helpers/extensions.dart';
import 'beverage_selection_dialog.dart';
import 'coffee_statistic.dart';
import 'profile.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Coffee Tracker',
      theme: ThemeData(
        primarySwatch: Colors.brown,
      ),
      home: const MyHomePage(title: 'Coffee Tracker'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with TickerProviderStateMixin {
  int currentIndex = 0;
  late final Timer _timer;
  final _homePageKey = GlobalKey<_HomePageState>();

  final List<Widget> _pages = [];

  final List<IconData> listOfIcons = [
    Icons.coffee_rounded,
    Icons.analytics_rounded,
    Icons.person_rounded,
  ];

  @override
  void initState() {
    super.initState();
    _pages.addAll([
      HomePage(key: _homePageKey),
      const CoffeeStatistic(intakes: []),
      const Profile(),
    ]);
    _timer = Timer.periodic(const Duration(minutes: 1), (_) {
      setState(() {});
    });
    context.read<AuthCubit>().loadIntakes();
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, state) {
        List<CoffeeIntake> currentIntakes = [];
        if (state is IntakesLoaded) {
          currentIntakes = state.intakes.map((intake) {
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
          }).toList();
        }

        return Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.brown,
            title:
                Text(widget.title, style: const TextStyle(color: Colors.white)),
            elevation: 0,
            actions: [
              BlocConsumer<AuthCubit, AuthState>(
                listener: (context, state) {
                  if (state is UserSignedOut) {
                    context.pushNamedAndRemoveUntil(
                      Routes.loginScreen,
                      predicate: (route) => false,
                    );
                  }
                },
                builder: (context, state) {
                  return IconButton(
                    icon: const Icon(Icons.logout, color: Colors.white),
                    onPressed: () {
                      try {
                        GoogleSignIn().disconnect();
                      } finally {
                        context.read<AuthCubit>().signOut();
                      }
                    },
                  );
                },
              ),
            ],
          ),
          body: _pages[currentIndex],
          floatingActionButton: currentIndex == 0
              ? FloatingActionButton(
                  onPressed: () {
                    final homePageState = _homePageKey.currentState;
                    if (homePageState != null) {
                      final warningLevel =
                          homePageState._calculateWarningLevel();
                      context.read<AuthCubit>().addBeverageIntake(
                            beverageType: homePageState._selectedBeverage.name,
                            caffeineContentPer250ml: homePageState
                                ._selectedBeverage.caffeineContentPer250ml,
                            sizeInMl: homePageState._selectedSize.round(),
                            warningLevel: warningLevel,
                          );
                    }
                  },
                  backgroundColor: Colors.brown,
                  tooltip: 'Add Intake',
                  child: const Icon(Icons.add, color: Colors.white),
                )
              : null,
          bottomNavigationBar: Container(
            margin: const EdgeInsets.all(20),
            height: size.width * .155,
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(.15),
                  blurRadius: 30,
                  offset: const Offset(0, 10),
                ),
              ],
              borderRadius: BorderRadius.circular(50),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(
                3,
                (index) => InkWell(
                  onTap: () {
                    setState(() {
                      currentIndex = index;
                    });
                  },
                  splashColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 1500),
                        curve: Curves.fastLinearToSlowEaseIn,
                        margin: EdgeInsets.only(
                          bottom: index == currentIndex ? 0 : size.width * .029,
                        ),
                        width: size.width * .128,
                        height: index == currentIndex ? size.width * .014 : 0,
                        decoration: BoxDecoration(
                          color: Colors.brown,
                          borderRadius: const BorderRadius.vertical(
                            bottom: Radius.circular(10),
                          ),
                        ),
                      ),
                      Icon(
                        listOfIcons[index],
                        size: size.width * .076,
                        color: index == currentIndex
                            ? Colors.brown
                            : Colors.black38,
                      ),
                      SizedBox(height: size.width * .03),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

// Create a new widget for the home page content
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<CoffeeIntake> _intakes = [];
  BeverageType _selectedBeverage = BeverageTypes.all[0];
  double _selectedSize = 250;
  final TextEditingController _sizeController =
      TextEditingController(text: '250');

  List<CoffeeIntake> get _last24HourIntakes {
    final now = DateTime.now();
    final yesterday = now.subtract(const Duration(hours: 24));
    return _intakes.where((intake) => intake.time.isAfter(yesterday)).toList();
  }

  @override
  void initState() {
    super.initState();
    // Load intakes when the page is created
    context.read<AuthCubit>().loadIntakes();
  }

  @override
  void dispose() {
    _sizeController.dispose();
    super.dispose();
  }

  String _calculateWarningLevel() {
    final newIntakeCaffeine =
        _selectedBeverage.calculateCaffeine(_selectedSize);
    final currentTotal = CaffeineCalculator.getCurrentCaffeineLevel(_intakes);
    final totalAfterNew = currentTotal + newIntakeCaffeine;

    if (totalAfterNew >= 400) return 'DANGEROUS LEVEL!';
    if (totalAfterNew >= 200) return 'Warning!';
    return '';
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is IntakesLoaded) {
          setState(() {
            _intakes = state.intakes.map((intake) {
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
            }).toList();
          });
        } else if (state is IntakeAdded) {
          context.read<AuthCubit>().loadIntakes();
        } else if (state is IntakeDeleted) {
          setState(() {
            _intakes.removeWhere((intake) =>
                intake.databaseData?['intake_id'] == state.intakeId);
          });

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Intake deleted successfully'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );
        } else if (state is AuthError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.red,
            ),
          );
          context.read<AuthCubit>().loadIntakes();
        }
      },
      builder: (context, state) {
        final currentCaffeineLevel =
            CaffeineCalculator.getCurrentCaffeineLevel(_last24HourIntakes);
        final effectiveLevel =
            CaffeineCalculator.getEffectiveCaffeineLevel(_last24HourIntakes);
        final peakStatus =
            CaffeineCalculator.getPeakEffectStatus(_last24HourIntakes);
        final isFrequent =
            CaffeineCalculator.isFrequentConsumption(_last24HourIntakes);

        double halfLifeProgress = 0;
        if (_last24HourIntakes.isNotEmpty) {
          final mostRecent = _last24HourIntakes.last;
          final timePassed = DateTime.now().difference(mostRecent.time);
          halfLifeProgress = (timePassed.inMinutes %
                  (CaffeineCalculator.HALF_LIFE_HOURS * 60)) /
              (CaffeineCalculator.HALF_LIFE_HOURS * 60);
        }

        return Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.brown.shade50,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
              ),
              child: Column(
                children: [
                  if (isFrequent)
                    Container(
                      padding: const EdgeInsets.all(8),
                      margin: const EdgeInsets.only(bottom: 8),
                      decoration: BoxDecoration(
                        color: Colors.red.shade100,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Text(
                        '⚠️ Too many drinks in the last hour!',
                        style: TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  Text(
                    'Current Caffeine Level: ${currentCaffeineLevel.round()}mg',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Expanded(
                        child: InkWell(
                          onTap: () {
                            showDialog(
                              context: context,
                              builder: (context) => BeverageSelectionDialog(
                                initialSelection: _selectedBeverage,
                                onSelect: (beverage) {
                                  setState(() {
                                    _selectedBeverage = beverage;
                                  });
                                },
                              ),
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(15),
                              border: Border.all(color: Colors.brown.shade200),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  _selectedBeverage.icon,
                                  color: Colors.brown,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    _selectedBeverage.name,
                                    style: const TextStyle(fontSize: 16),
                                  ),
                                ),
                                const Icon(
                                  Icons.arrow_drop_down,
                                  color: Colors.brown,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        width: 100,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(color: Colors.brown.shade200),
                        ),
                        child: TextField(
                          controller: _sizeController,
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly
                          ],
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            hintText: 'ml',
                          ),
                          onChanged: (value) {
                            setState(() {
                              _selectedSize = double.tryParse(value) ?? 250;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: CaffeineClock(
                currentLevel: currentCaffeineLevel,
                effectiveLevel: effectiveLevel,
                halfLifeProgress: halfLifeProgress,
                peakStatus: peakStatus,
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(8),
                itemCount: _last24HourIntakes.length,
                itemBuilder: (context, index) {
                  final intake = _last24HourIntakes[index];
                  return Dismissible(
                    key: Key('intake_${intake.databaseData?['intake_id']}'),
                    background: Container(
                      color: Colors.red,
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.only(right: 16),
                      child: const Icon(Icons.delete, color: Colors.white),
                    ),
                    direction: DismissDirection.endToStart,
                    confirmDismiss: (direction) async {
                      return await showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: const Text('Confirm Delete'),
                            content: const Text(
                                'Are you sure you want to delete this intake?'),
                            actions: <Widget>[
                              TextButton(
                                onPressed: () =>
                                    Navigator.of(context).pop(false),
                                child: const Text('Cancel'),
                              ),
                              TextButton(
                                onPressed: () =>
                                    Navigator.of(context).pop(true),
                                child: const Text('Delete'),
                              ),
                            ],
                          );
                        },
                      );
                    },
                    onDismissed: (direction) {
                      if (intake.databaseData != null) {
                        setState(() {
                          _intakes.removeAt(index);
                        });
                        context
                            .read<AuthCubit>()
                            .deleteIntake(intake.databaseData!['intake_id']);
                      }
                    },
                    child: Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15.0),
                      ),
                      color: intake.getWarningColor(),
                      child: ListTile(
                        title: Text(
                          '${intake.beverageType.name} (${intake.sizeInMl.round()}ml)',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          '${DateFormat('MMM d, y - h:mm a').format(intake.time)}\n'
                          'Initial: ${intake.caffeineContent.round()}mg\n'
                          'Remaining: ${intake.getRemainingCaffeine().round()}mg\n'
                          '${intake.timeRemaining}',
                        ),
                        trailing: intake.warningLevel.isNotEmpty
                            ? Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.7),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  intake.warningLevel,
                                  style: const TextStyle(
                                    color: Colors.red,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              )
                            : null,
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}
