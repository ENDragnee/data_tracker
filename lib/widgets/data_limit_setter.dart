// lib/widgets/data_limit_setter.dart
import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DataLimitSetter extends StatefulWidget {
  final double currentLimit;
  final Function(double) onLimitChanged;

  const DataLimitSetter({
    super.key,
    required this.currentLimit,
    required this.onLimitChanged,
  });

  @override
  _DataLimitSetterState createState() => _DataLimitSetterState();
}

class _DataLimitSetterState extends State<DataLimitSetter> {
  late TextEditingController _controller;
  late SharedPreferences _prefs;
  final bool _isEditing = false;
  final List<double> _quickSelectValues = [1024, 2048, 5120, 10240]; // MB values

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: (widget.currentLimit / 1024).toStringAsFixed(1),
    );
    _initPrefs();
  }

  Future<void> _initPrefs() async {
    _prefs = await SharedPreferences.getInstance();
    final savedLimit = _prefs.getDouble('data_limit');
    if (savedLimit != null && savedLimit != widget.currentLimit) {
      widget.onLimitChanged(savedLimit);
    }
  }

  Future<void> _saveLimit(double value) async {
    await _prefs.setDouble('data_limit', value);
    widget.onLimitChanged(value);
  }

  void _showLimitPicker() {
    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) {
        return Container(
          height: 320,
          decoration: BoxDecoration(
            color: CupertinoColors.systemBackground.resolveFrom(context),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CupertinoButton(
                      child: const Text('Cancel'),
                      onPressed: () => Navigator.pop(context),
                    ),
                    CupertinoButton(
                      child: const Text('Done'),
                      onPressed: () {
                        double value = double.tryParse(_controller.text) ?? 1.0;
                        _saveLimit(value * 1024);
                        Navigator.pop(context);
                      },
                    ),
                  ],
                ),
              ),
              Expanded(
                child: CupertinoPicker(
                  magnification: 1.2,
                  squeeze: 1.2,
                  useMagnifier: true,
                  itemExtent: 40,
                  onSelectedItemChanged: (int index) {
                    setState(() {
                      _controller.text = ((index + 1) * 0.5).toStringAsFixed(1);
                    });
                  },
                  children: List<Widget>.generate(20, (index) {
                    return Center(
                      child: Text(
                        '${((index + 1) * 0.5).toStringAsFixed(1)} GB',
                        style: const TextStyle(fontSize: 20),
                      ),
                    );
                  }),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Daily Data Limit',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              CupertinoButton(
                padding: EdgeInsets.zero,
                onPressed: _showLimitPicker,
                child: Row(
                  children: [
                    Text(
                      '${(widget.currentLimit / 1024).toStringAsFixed(1)} GB',
                      style: TextStyle(
                        fontSize: 18,
                        color: CupertinoColors.activeBlue.resolveFrom(context),
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      CupertinoIcons.pencil_circle_fill,
                      color: CupertinoColors.activeBlue.resolveFrom(context),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'Quick Select',
            style: TextStyle(
              fontSize: 14,
              color: CupertinoColors.systemGrey,
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 40,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _quickSelectValues.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: CupertinoButton(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 4,
                    ),
                    color: widget.currentLimit == _quickSelectValues[index]
                        ? CupertinoColors.activeBlue
                        : CupertinoColors.systemGrey5,
                    borderRadius: BorderRadius.circular(20),
                    minSize: 0,
                    onPressed: () {
                      _saveLimit(_quickSelectValues[index]);
                    },
                    child: Text(
                      '${(_quickSelectValues[index] / 1024).toStringAsFixed(1)} GB',
                      style: TextStyle(
                        fontSize: 14,
                        color: widget.currentLimit == _quickSelectValues[index]
                            ? CupertinoColors.white
                            : CupertinoColors.label,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: CupertinoColors.systemGrey6.withOpacity(0.5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: const [
                Icon(
                  CupertinoIcons.info_circle_fill,
                  color: CupertinoColors.systemGrey,
                  size: 20,
                ),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'You\'ll receive a notification when your data usage exceeds the daily limit.',
                    style: TextStyle(
                      fontSize: 13,
                      color: CupertinoColors.systemGrey,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}