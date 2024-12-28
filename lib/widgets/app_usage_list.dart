// lib/widgets/app_usage_list.dart
import 'package:flutter/cupertino.dart';
import 'package:app_usage/app_usage.dart';
import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';

class AppUsageList extends StatefulWidget {
  const AppUsageList({super.key});

  @override
  AppUsageListState createState() => AppUsageListState();
}

class AppUsageListState extends State<AppUsageList> {
  List<AppUsageInfo> _usageList = [];
  bool _isLoading = true;
  final DeviceInfoPlugin _deviceInfo = DeviceInfoPlugin();

  @override
  void initState() {
    super.initState();
    _loadUsageData();
  }

  Future<void> _loadUsageData() async {
    try {
      DateTime endDate = DateTime.now();
      DateTime startDate = endDate.subtract(const Duration(days: 1));

      if (Platform.isAndroid) {
        final androidInfo = await _deviceInfo.androidInfo;
        if (androidInfo.version.sdkInt >= 21) {
          List<AppUsageInfo> usageInfo = await AppUsage().getAppUsage(
            startDate,
            endDate,
          );
          
          // Sort by usage duration
          usageInfo.sort((a, b) => b.usage.compareTo(a.usage));
          
          setState(() {
            _usageList = usageInfo;
            _isLoading = false;
          });
        }
      } else {
        // iOS implementation would go here
        // Note: iOS has limited app usage tracking capabilities
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  String _formatDuration(Duration duration) {
    if (duration.inHours > 0) {
      return '${duration.inHours}h ${duration.inMinutes.remainder(60)}m';
    } else if (duration.inMinutes > 0) {
      return '${duration.inMinutes}m ${duration.inSeconds.remainder(60)}s';
    } else {
      return '${duration.inSeconds}s';
    }
  }

  String _formatDataUsage(double bytes) {
    if (bytes > 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
    } else if (bytes > 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    } else {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const SliverToBoxAdapter(
        child: Center(
          child: CupertinoActivityIndicator(),
        ),
      );
    }

    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          if (index >= _usageList.length) return null;
          
          final app = _usageList[index];
          final usage = app.usage;
          // Simulated data usage - you'll need to implement actual data tracking
          final dataUsage = (usage.inMinutes * 1024 * 1024 * 0.5).toDouble();
          
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
            child: Container(
              decoration: BoxDecoration(
                color: CupertinoColors.systemBackground,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: CupertinoColors.systemGrey.withOpacity(0.1),
                    blurRadius: 5,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: CupertinoListTile(
                  leading: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Color(((index * 12345) % 0xFFFFFF) | 0xFF000000),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text(
                        app.packageName.split('.').last[0].toUpperCase(),
                        style: const TextStyle(
                          color: CupertinoColors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  title: Text(
                    app.packageName.split('.').last,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  subtitle: Text(
                    'Time: ${_formatDuration(usage)}',
                    style: const TextStyle(
                      color: CupertinoColors.systemGrey,
                      fontSize: 12,
                    ),
                  ),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        _formatDataUsage(dataUsage),
                        style: const TextStyle(
                          color: CupertinoColors.activeBlue,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const Text(
                        'Mobile Data',
                        style: TextStyle(
                          color: CupertinoColors.systemGrey,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

// Add this custom CupertinoListTile widget since it might not be available in all Flutter versions
class CupertinoListTile extends StatelessWidget {
  final Widget leading;
  final Widget title;
  final Widget subtitle;
  final Widget trailing;

  const CupertinoListTile({
    super.key,
    required this.leading,
    required this.title,
    required this.subtitle,
    required this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          leading,
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                title,
                const SizedBox(height: 4),
                subtitle,
              ],
            ),
          ),
          const SizedBox(width: 16),
          trailing,
        ],
      ),
    );
  }
}