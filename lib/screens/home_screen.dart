// lib/screens/home_screen.dart
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../widgets/usage_card.dart';
import '../widgets/app_usage_list.dart';
import '../widgets/data_limit_setter.dart';
import '../services/usage_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  final UsageService _usageService = UsageService();
  double _totalUsage = 0;
  double _dailyLimit = 1000; // MB

  @override
  void initState() {
    super.initState();
    _loadUsageData();
  }

  Future<void> _loadUsageData() async {
    final usage = await _usageService.getTotalDataUsage();
    setState(() {
      _totalUsage = usage;
    });
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('Data Usage Tracker'),
        backgroundColor: Colors.transparent,
        border: null,
      ),
      child: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    UsageCard(
                      usedData: _totalUsage,
                      limitData: _dailyLimit,
                    ),
                    const SizedBox(height: 20),
                    DataLimitSetter(
                      currentLimit: _dailyLimit,
                      onLimitChanged: (newLimit) {
                        setState(() {
                          _dailyLimit = newLimit;
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),
            const AppUsageList(),
          ],
        ),
      ),
    );
  }
}
