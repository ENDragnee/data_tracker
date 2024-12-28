// lib/widgets/usage_card.dart
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class UsageCard extends StatelessWidget {
  final double usedData;
  final double limitData;

  const UsageCard({
    super.key,
    required this.usedData,
    required this.limitData,
  });

  @override
  Widget build(BuildContext context) {
    final percentage = (usedData / limitData).clamp(0.0, 1.0);
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: CupertinoColors.systemBackground,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: CupertinoColors.systemGrey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                height: 200,
                width: 200,
                child: CircularProgressIndicator(
                  value: percentage,
                  strokeWidth: 12,
                  backgroundColor: CupertinoColors.systemGrey5,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    percentage > 0.9
                        ? CupertinoColors.systemRed
                        : CupertinoColors.activeBlue,
                  ),
                ),
              ),
              Column(
                children: [
                  Text(
                    '${(usedData / 1024).toStringAsFixed(1)} GB',
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'of ${(limitData / 1024).toStringAsFixed(1)} GB',
                    style: const TextStyle(
                      fontSize: 16,
                      color: CupertinoColors.systemGrey,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem('Upload', '2.1 GB', CupertinoColors.activeGreen),
              _buildStatItem('Download', '5.3 GB', CupertinoColors.activeBlue),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            color: CupertinoColors.systemGrey,
          ),
        ),
      ],
    );
  }
}