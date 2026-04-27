import 'package:dio/dio.dart';
import 'package:surveillance/core/constants/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../../core/constants/auth_constants.dart';
import '../../../../../core/network/api_client.dart';
import '../../../../../core/widget/custom_input_field.dart';
import '../../../../../core/widget/table/view_data_table.dart';

class GroupTradeTab extends StatefulWidget {
  const GroupTradeTab({super.key});

  @override
  State<GroupTradeTab> createState() => GroupTradeTabState();
}

class GroupTradeTabState extends State<GroupTradeTab> {
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
  final List<_GroupTradeSettingRow> _rows = [];
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
      row.controller.dispose();
    }
    super.dispose();
  }

  Future<void> reload() => _loadSettings();

  Future<bool> saveChanges() async {
    if (_isSaving || _isLoading) return false;

    final invalidExchange = _rows.firstWhere(
      (row) => int.tryParse(row.controller.text.trim()) == null,
      orElse: () => _GroupTradeSettingRow.empty(),
    );

    if (invalidExchange.id == -1) {
      return _saveSettings();
    }

    if (!mounted) return false;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Enter a valid time in seconds for ${invalidExchange.exchangeName}.',
        ),
      ),
    );
    return false;
  }

  Future<void> _loadSettings() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final response = await _dio.get(
        '${AuthConstants.surveillanceSettingsTypeEndpoint}/GROUP_TRADE',
      );
      final rawItems = response.data['data'] as List<dynamic>? ?? [];
      final rows =
          rawItems
              .map(
                (item) => _GroupTradeSettingRow.fromJson(
                  item as Map<String, dynamic>,
                ),
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
          row.controller.dispose();
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
            'Failed to load group trade settings.';
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _error = 'Failed to load group trade settings.';
      });
    }
  }

  Future<bool> _saveSettings() async {
    setState(() {
      _isSaving = true;
      _error = null;
    });

    try {
      final payload = {
        'items': _rows
            .map(
              (row) => {
                'id': row.id,
                'isActive': row.isActive,
                'timeFrameSeconds': int.parse(row.controller.text.trim()),
              },
            )
            .toList(),
      };

      final response = await _dio.put(
        '${AuthConstants.surveillanceSettingsTypeEndpoint}/GROUP_TRADE/bulk',
        data: payload,
      );
      final rawItems = response.data['data'] as List<dynamic>? ?? [];
      final updatedRows =
          rawItems
              .map(
                (item) => _GroupTradeSettingRow.fromJson(
                  item as Map<String, dynamic>,
                ),
              )
              .toList()
            ..sort(
              (a, b) => _sortIndex(
                a.exchangeName,
              ).compareTo(_sortIndex(b.exchangeName)),
            );

      if (!mounted) return false;
      setState(() {
        for (final row in _rows) {
          row.controller.dispose();
        }
        _rows
          ..clear()
          ..addAll(updatedRows);
        _isSaving = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Group trade settings updated successfully.'),
        ),
      );
      return true;
    } on DioException catch (error) {
      if (!mounted) return false;
      setState(() {
        _isSaving = false;
        _error =
            error.response?.data['message']?.toString() ??
            'Failed to update group trade settings.';
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(_error!)));
      return false;
    } catch (_) {
      if (!mounted) return false;
      setState(() {
        _isSaving = false;
        _error = 'Failed to update group trade settings.';
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
        ViewDataTable<_GroupTradeSettingRow>(
          columns: const [
            ViewTableColumn(id: 'exchange', label: 'EXCHANGE', width: 250),
            ViewTableColumn(id: 'time', label: 'TIME', width: 700),
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

  Widget _buildCell(_GroupTradeSettingRow row, ViewTableColumn col) {
    if (col.id == 'exchange') {
      return Text(
        row.exchangeName,
        style: GoogleFonts.openSans(fontSize: 13, color: Colors.black87),
      );
    }

    return CustomInputField(
      hintText: 'Time',
      controller: row.controller,
      keyboardType: TextInputType.number,
      height: 30,
      width: double.infinity,
      borderColor: Colors.grey.shade400,
      fillColor: const Color(0xFFF9F9F9),
      suffixIcon: Icons.access_time,
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

class _GroupTradeSettingRow {
  final int id;
  final String exchangeName;
  final bool isActive;
  final TextEditingController controller;

  _GroupTradeSettingRow({
    required this.id,
    required this.exchangeName,
    required this.isActive,
    required this.controller,
  });

  factory _GroupTradeSettingRow.fromJson(Map<String, dynamic> json) {
    return _GroupTradeSettingRow(
      id: json['id'] as int? ?? 0,
      exchangeName: json['exchangeName']?.toString() ?? '',
      isActive: json['isActive'] as bool? ?? false,
      controller: TextEditingController(
        text: (json['timeFrameSeconds'] as num?)?.toInt().toString() ?? '0',
      ),
    );
  }

  factory _GroupTradeSettingRow.empty() {
    return _GroupTradeSettingRow(
      id: -1,
      exchangeName: '',
      isActive: false,
      controller: TextEditingController(),
    );
  }
}
