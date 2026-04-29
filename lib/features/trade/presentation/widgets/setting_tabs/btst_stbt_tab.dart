import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../../core/constants/auth_constants.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/network/api_client.dart';
import '../../../../../core/widget/custom_input_field.dart';
import '../../../../../core/widget/table/view_data_table.dart';

class BtstStbtTab extends StatefulWidget {
  const BtstStbtTab({super.key});

  @override
  State<BtstStbtTab> createState() => BtstStbtTabState();
}

class BtstStbtTabState extends State<BtstStbtTab> {
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
  final List<_BtstSettingRow> _rows = [];

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
      row.timeGapController.dispose();
      row.startTimeController.dispose();
      row.endTimeController.dispose();
    }
    super.dispose();
  }

  Future<bool> saveChanges() async {
    if (_isSaving || _isLoading) return false;

    for (final row in _rows) {
      final timeGap = int.tryParse(row.timeGapController.text.trim());
      if (timeGap == null ||
          !_isValidTimeValue(row.startTimeController.text) ||
          !_isValidTimeValue(row.endTimeController.text)) {
        if (!mounted) return false;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Enter valid start/end time for ${row.exchangeName} in hh:mm AM/PM format.',
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
        '${AuthConstants.surveillanceSettingsTypeEndpoint}/BTST_STBT',
      );
      final rawItems = response.data['data'] as List<dynamic>? ?? [];
      final rows =
          rawItems
              .map(
                (item) =>
                    _BtstSettingRow.fromJson(item as Map<String, dynamic>),
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
          row.timeGapController.dispose();
          row.startTimeController.dispose();
          row.endTimeController.dispose();
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
            'Failed to load BTST/STBT settings.';
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _error = 'Failed to load BTST/STBT settings.';
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
        '${AuthConstants.surveillanceSettingsTypeEndpoint}/BTST_STBT/bulk',
        data: {
          'items': _rows
              .map(
                (row) => {
                  'id': row.id,
                  'isActive': row.isActive,
                  'exchangeTimeGapSeconds':
                      int.tryParse(row.timeGapController.text.trim()) ?? 0,
                  'btstStartTime': _toBackendTime(row.startTimeController.text),
                  'btstEndTime': _toBackendTime(row.endTimeController.text),
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
          content: Text('BTST/STBT settings updated successfully.'),
        ),
      );
      return true;
    } on DioException catch (error) {
      if (!mounted) return false;
      setState(() {
        _isSaving = false;
        _error =
            error.response?.data['message']?.toString() ??
            'Failed to update BTST/STBT settings.';
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(_error!)));
      return false;
    } catch (_) {
      if (!mounted) return false;
      setState(() {
        _isSaving = false;
        _error = 'Failed to update BTST/STBT settings.';
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

  bool _isValidTimeValue(String value) {
    return _parseTime(value) != null;
  }

  Future<void> _pickTime(TextEditingController controller) async {
    final initialTime =
        _parseTime(controller.text) ?? const TimeOfDay(hour: 9, minute: 30);
    final isDarkMode = AppColors.isDarkMode(context);
    final surfaceColor = AppColors.cardBackground(context);
    final textColor = AppColors.textColor(context);
    final borderColor = AppColors.cardBorderColor(context);
    final selected = await showTimePicker(
      context: context,
      initialTime: initialTime,
      builder: (context, child) {
        final themedChild = Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: AppColors.blue,
              onPrimary: Colors.white,
              surface: surfaceColor,
              onSurface: textColor,
            ),
            dialogTheme: DialogThemeData(
              backgroundColor: surfaceColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
                side: BorderSide(color: borderColor),
              ),
            ),
            timePickerTheme: TimePickerThemeData(
              backgroundColor: surfaceColor,
              hourMinuteColor: AppColors.getHighlightColor(context),
              dayPeriodColor: AppColors.getHighlightColor(context),
              dayPeriodTextColor: textColor,
              hourMinuteTextColor: textColor,
              dialBackgroundColor: isDarkMode
                  ? AppColors.getHighlightColor(context)
                  : const Color(0xFFF1F5F9),
              dialHandColor: AppColors.blue,
              dialTextColor: textColor,
              entryModeIconColor: textColor,
              helpTextStyle: GoogleFonts.openSans(
                color: textColor,
                fontWeight: FontWeight.w600,
              ),
              cancelButtonStyle: TextButton.styleFrom(
                foregroundColor: AppColors.blue,
              ),
              confirmButtonStyle: TextButton.styleFrom(
                foregroundColor: AppColors.blue,
              ),
            ),
          ),
          child: MediaQuery(
            data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: false),
            child: Localizations.override(
              context: context,
              locale: const Locale('en', 'IN'),
              child: child ?? const SizedBox.shrink(),
            ),
          ),
        );
        return themedChild;
      },
    );

    if (selected == null || !mounted) return;
    setState(() {
      controller.text = _formatDisplayTime(selected);
      _error = null;
    });
  }

  TimeOfDay? _parseTime(String value) {
    final raw = value.trim().toUpperCase();
    if (raw.isEmpty) return null;

    final amPmMatch = RegExp(
      r'^(0?[1-9]|1[0-2]):([0-5]\d)\s*([AP]M)$',
    ).firstMatch(raw);
    if (amPmMatch != null) {
      final hour12 = int.parse(amPmMatch.group(1)!);
      final minute = int.parse(amPmMatch.group(2)!);
      final period = amPmMatch.group(3)!;
      final hour24 = (hour12 % 12) + (period == 'PM' ? 12 : 0);
      return TimeOfDay(hour: hour24, minute: minute);
    }

    final hhmmssMatch = RegExp(
      r'^([01]\d|2[0-3]):([0-5]\d)(?::[0-5]\d)?$',
    ).firstMatch(raw);
    if (hhmmssMatch != null) {
      final hour = int.parse(hhmmssMatch.group(1)!);
      final minute = int.parse(hhmmssMatch.group(2)!);
      return TimeOfDay(hour: hour, minute: minute);
    }

    return null;
  }

  String _formatDisplayTime(TimeOfDay time) {
    final isAm = time.hour < 12;
    final hour12 = time.hour % 12 == 0 ? 12 : time.hour % 12;
    final hh = hour12.toString().padLeft(2, '0');
    final mm = time.minute.toString().padLeft(2, '0');
    final suffix = isAm ? 'AM' : 'PM';
    return '$hh:$mm $suffix';
  }

  String _toBackendTime(String value) {
    final parsed = _parseTime(value);
    if (parsed == null) {
      return '00:00:00';
    }
    final hh = parsed.hour.toString().padLeft(2, '0');
    final mm = parsed.minute.toString().padLeft(2, '0');
    return '$hh:$mm:00';
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
        ViewDataTable<_BtstSettingRow>(
          columns: const [
            ViewTableColumn(id: 'exchange', label: 'EXCHANGE', width: 350),
            ViewTableColumn(id: 'startTime', label: 'START TIME', width: 250),
            ViewTableColumn(id: 'endTime', label: 'END TIME', width: 250),
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

  Widget _buildCell(_BtstSettingRow row, ViewTableColumn col) {
    final textColor = AppColors.textColor(context);
    final inputFillColor = AppColors.inputFieldBackground(context);
    final inputBorderColor = AppColors.cardBorderColor(context);

    if (col.id == 'exchange') {
      return Text(
        row.exchangeName,
        style: GoogleFonts.openSans(fontSize: 13, color: textColor),
      );
    }

    if (col.id == 'startTime') {
      return CustomInputField(
        hintText: 'Select start time',
        controller: row.startTimeController,
        readOnly: true,
        height: 30,
        width: double.infinity,
        borderColor: inputBorderColor,
        fillColor: inputFillColor,
        suffixIcon: Icons.access_time,
        textColor: textColor,
        onTap: () => _pickTime(row.startTimeController),
        onSuffixIconPressed: () => _pickTime(row.startTimeController),
      );
    }

    if (col.id == 'endTime') {
      return CustomInputField(
        hintText: 'Select end time',
        controller: row.endTimeController,
        readOnly: true,
        height: 30,
        width: double.infinity,
        borderColor: inputBorderColor,
        fillColor: inputFillColor,
        suffixIcon: Icons.access_time,
        textColor: textColor,
        onTap: () => _pickTime(row.endTimeController),
        onSuffixIconPressed: () => _pickTime(row.endTimeController),
      );
    }

    return const SizedBox.shrink();
  }
}

class _BtstSettingRow {
  final int id;
  final String exchangeName;
  final bool isActive;
  final TextEditingController timeGapController;
  final TextEditingController startTimeController;
  final TextEditingController endTimeController;

  _BtstSettingRow({
    required this.id,
    required this.exchangeName,
    required this.isActive,
    required this.timeGapController,
    required this.startTimeController,
    required this.endTimeController,
  });

  factory _BtstSettingRow.fromJson(Map<String, dynamic> json) {
    return _BtstSettingRow(
      id: json['id'] as int? ?? 0,
      exchangeName: json['exchangeName']?.toString() ?? '',
      isActive: json['isActive'] as bool? ?? false,
      timeGapController: TextEditingController(
        text:
            (json['exchangeTimeGapSeconds'] as num?)?.toInt().toString() ?? '0',
      ),
      startTimeController: TextEditingController(
        text: _formatInitialDisplayTime(json['btstStartTime']?.toString()),
      ),
      endTimeController: TextEditingController(
        text: _formatInitialDisplayTime(json['btstEndTime']?.toString()),
      ),
    );
  }
}

String _formatInitialDisplayTime(String? value) {
  final raw = value?.trim();
  if (raw == null || raw.isEmpty) return '09:30 AM';

  final match = RegExp(
    r'^([01]\d|2[0-3]):([0-5]\d)(?::[0-5]\d)?$',
  ).firstMatch(raw);
  if (match == null) return raw;

  final hour24 = int.parse(match.group(1)!);
  final minute = int.parse(match.group(2)!);
  final isAm = hour24 < 12;
  final hour12 = hour24 % 12 == 0 ? 12 : hour24 % 12;
  final hh = hour12.toString().padLeft(2, '0');
  final mm = minute.toString().padLeft(2, '0');
  final suffix = isAm ? 'AM' : 'PM';
  return '$hh:$mm $suffix';
}
