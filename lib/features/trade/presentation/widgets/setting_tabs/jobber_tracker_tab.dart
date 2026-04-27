import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../../core/constants/auth_constants.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/network/api_client.dart';
import '../../../../../core/widget/custom_input_field.dart';
import '../../../../../core/widget/table/view_data_table.dart';

class JobberTrackerTab extends StatefulWidget {
  const JobberTrackerTab({super.key});

  @override
  State<JobberTrackerTab> createState() => JobberTrackerTabState();
}

class JobberTrackerTabState extends State<JobberTrackerTab> {
  static const List<String> _exchangeOrder = [
    'NSE',
    'MCX',
    'CE/PE',
    'OTHERS',
    'COMEX FUTURE',
    'COMEX SPOT',
    'CRYPTO',
    'GIFT',
    'FOREX',
    'CDS',
  ];

  final Dio _dio = ApiClient().dio;
  final List<_JobberSettingRow> _rows = [];

  bool _isLoading = true;
  bool _isSaving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  @override
  void dispose() {
    for (final row in _rows) {
      row.tradeFrequencyController.dispose();
    }
    super.dispose();
  }

  Future<bool> saveChanges() async {
    if (_isSaving || _isLoading) return false;

    for (final row in _rows) {
      final frequency = int.tryParse(row.tradeFrequencyController.text.trim());
      if (frequency == null) {
        if (!mounted) return false;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Enter valid trade frequency for ${row.exchangeName}.',
            ),
          ),
        );
        return false;
      }
    }

    return _saveSettings();
  }

  Future<void> _loadSettings() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final response = await _dio.get(
        '${AuthConstants.surveillanceSettingsTypeEndpoint}/JOBBER_TRACKER',
      );
      final rawItems = response.data['data'] as List<dynamic>? ?? [];
      final rows =
          rawItems
              .map(
                (item) =>
                    _JobberSettingRow.fromJson(item as Map<String, dynamic>),
              )
              .toList()
            ..sort(
              (a, b) => _sortIndex(
                a.exchangeName,
              ).compareTo(_sortIndex(b.exchangeName)),
            );

      if (!mounted) return;
      setState(() {
        for (final row in _rows) {
          row.tradeFrequencyController.dispose();
        }
        _rows
          ..clear()
          ..addAll(rows);
        _isLoading = false;
      });
    } on DioException catch (error) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _error =
            error.response?.data['message']?.toString() ??
            'Failed to load jobber tracker settings.';
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _error = 'Failed to load jobber tracker settings.';
      });
    }
  }

  Future<bool> _saveSettings() async {
    setState(() {
      _isSaving = true;
      _error = null;
    });

    try {
      await _dio.put(
        '${AuthConstants.surveillanceSettingsTypeEndpoint}/JOBBER_TRACKER/bulk',
        data: {
          'items': _rows
              .map(
                (row) => {
                  'id': row.id,
                  'isActive': row.isActive,
                  'timeFrameSeconds': row.timeFrameSeconds,
                  'tradeFrequencyLimit':
                      int.tryParse(row.tradeFrequencyController.text.trim()) ??
                      0,
                },
              )
              .toList(),
        },
      );

      if (!mounted) return false;
      await _loadSettings();
      if (!mounted) return false;
      setState(() {
        _isSaving = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Jobber tracker settings updated successfully.'),
        ),
      );
      return true;
    } on DioException catch (error) {
      if (!mounted) return false;
      setState(() {
        _isSaving = false;
        _error =
            error.response?.data['message']?.toString() ??
            'Failed to update jobber tracker settings.';
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(_error!)));
      return false;
    } catch (_) {
      if (!mounted) return false;
      setState(() {
        _isSaving = false;
        _error = 'Failed to update jobber tracker settings.';
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(_error!)));
      return false;
    }
  }

  int _sortIndex(String exchangeName) {
    final index = _exchangeOrder.indexOf(exchangeName);
    return index == -1 ? _exchangeOrder.length : index;
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const SizedBox.shrink();
    }

    if (_error != null && _rows.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _error!,
              style: GoogleFonts.openSans(
                color: Colors.red,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            TextButton(onPressed: _loadSettings, child: const Text('Retry')),
          ],
        ),
      );
    }

    return Stack(
      children: [
        ViewDataTable<_JobberSettingRow>(
          columns: const [
            ViewTableColumn(id: 'exchange', label: 'EXCHANGE', width: 350),
            ViewTableColumn(
              id: 'frequency',
              label: 'Trade frequency',
              width: 500,
            ),
          ],
          data: _rows,
          idExtractor: (item) => item.id.toString(),
          autoFit: true,
          isDarkMode: AppColors.isDarkMode(context),
          cellBuilder: _buildCell,
        ),
        if (_isSaving)
          Positioned.fill(
            child: Container(
              color: Colors.white.withOpacity(0.45),
              child: const SizedBox.shrink(),
            ),
          ),
      ],
    );
  }

  Widget _buildCell(_JobberSettingRow row, ViewTableColumn col) {
    if (col.id == 'exchange') {
      return Text(
        row.exchangeName,
        style: GoogleFonts.openSans(fontSize: 13, color: Colors.black87),
      );
    }

    return CustomInputField(
      hintText: 'Type here',
      controller: row.tradeFrequencyController,
      keyboardType: TextInputType.number,
      height: 30,
      width: double.infinity,
      borderColor: Colors.grey.shade400,
      fillColor: const Color(0xFFF9F9F9),
      onChanged: (_) {
        if (_error != null) {
          setState(() {
            _error = null;
          });
        }
      },
    );
  }
}

class _JobberSettingRow {
  final int id;
  final String exchangeName;
  final bool isActive;
  final int timeFrameSeconds;
  final TextEditingController tradeFrequencyController;

  _JobberSettingRow({
    required this.id,
    required this.exchangeName,
    required this.isActive,
    required this.timeFrameSeconds,
    required this.tradeFrequencyController,
  });

  factory _JobberSettingRow.fromJson(Map<String, dynamic> json) {
    return _JobberSettingRow(
      id: json['id'] as int? ?? 0,
      exchangeName: json['exchangeName']?.toString() ?? '',
      isActive: json['isActive'] as bool? ?? false,
      timeFrameSeconds: (json['timeFrameSeconds'] as num?)?.toInt() ?? 0,
      tradeFrequencyController: TextEditingController(
        text: (json['tradeFrequencyLimit'] as num?)?.toInt().toString() ?? '0',
      ),
    );
  }
}
