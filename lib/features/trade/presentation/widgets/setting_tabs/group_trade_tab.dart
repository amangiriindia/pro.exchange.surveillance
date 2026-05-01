import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:open_filex/open_filex.dart';
import 'package:surveillance/core/constants/app_colors.dart';

import '../../../../../core/constants/auth_constants.dart';
import '../../../../../core/network/api_client.dart';
import '../../../../../core/widget/app_dropdown.dart';
import '../../../../../core/widget/common_dilog_box.dart';
import '../../../../../core/widget/custom_action_button.dart';
import '../../../../../core/widget/custom_input_field.dart';
import '../../../../../core/widget/file_select_dialog.dart';
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

  static const String _groupTradeTemplateCsv =
      'exchangeName,symbolName,qtyThreshold,timeFrameSeconds\n'
      'NSE,SENSEX,0,600\n'
      'NSE,ADANIGREEN,0,600\n'
      'NSE,ADANIPORTS,0,600\n'
      'NSE,ADANIPOWER,0,600\n'
      'NSE,360ONE,0,600\n'
      'NSE,ABB,0,600\n'
      'NSE,ABCAPITAL,0,600\n'
      'NSE,ADANIENSOL,0,600\n'
      'NSE,ADANIENT,0,600\n'
      'NSE,ALKEM,0,600\n'
      'NSE,AMBER,0,600\n'
      'NSE,AMBUJACEM,0,600\n';

  final Dio _dio = ApiClient().dio;
  final List<_GroupTradeSettingRow> _rows = [];

  bool _isLoading = true;
  bool _isSaving = false;
  bool _isImporting = false;
  bool _isDownloadingTemplate = false;

  String? _error;
  String? _selectedExchange;

  List<_GroupTradeSettingRow> get _visibleRows {
    if (_selectedExchange == null || _selectedExchange!.isEmpty) {
      return _rows;
    }
    return _rows.where((row) => row.exchangeName == _selectedExchange).toList();
  }

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  @override
  void dispose() {
    for (final row in _rows) {
      row.qtyController.dispose();
      row.timeController.dispose();
    }
    super.dispose();
  }

  Future<void> reload() => _loadSettings();

  Future<bool> saveChanges() async {
    if (_isSaving || _isLoading || _isImporting) return false;

    for (final row in _rows) {
      final qty = double.tryParse(row.qtyController.text.trim());
      final time = int.tryParse(row.timeController.text.trim());
      if (qty == null || time == null) {
        if (!mounted) return false;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Enter valid qty and time values for ${row.exchangeName} / ${row.symbolName}.',
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
            ..sort((a, b) {
              final exchangeCompare = _sortIndex(
                a.exchangeName,
              ).compareTo(_sortIndex(b.exchangeName));
              if (exchangeCompare != 0) return exchangeCompare;
              return a.symbolName.compareTo(b.symbolName);
            });

      if (!mounted) return;
      setState(() {
        for (final row in _rows) {
          row.qtyController.dispose();
          row.timeController.dispose();
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
                'qtyThreshold':
                    double.tryParse(row.qtyController.text.trim()) ?? 0,
                'timeFrameSeconds':
                    int.tryParse(row.timeController.text.trim()) ?? 0,
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
            ..sort((a, b) {
              final exchangeCompare = _sortIndex(
                a.exchangeName,
              ).compareTo(_sortIndex(b.exchangeName));
              if (exchangeCompare != 0) return exchangeCompare;
              return a.symbolName.compareTo(b.symbolName);
            });

      if (!mounted) return false;
      setState(() {
        for (final row in _rows) {
          row.qtyController.dispose();
          row.timeController.dispose();
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

  Future<void> _importCsv() async {
    if (_isImporting || _isLoading || _isSaving) return;

    final selectedFile = await FileSelectDialog.show(
      context: context,
      title: 'Import Group Trade CSV',
      helperText: 'Select a CSV file to import group trade settings.',
      saveText: 'Import',
      allowedExtensions: const ['csv'],
    );

    if (selectedFile == null) {
      return;
    }

    final path = selectedFile.path;
    if (path == null || path.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to read selected file path.')),
      );
      return;
    }

    await _importCsvFromPath(path);
  }

  Future<void> _importCsvFromPath(String path) async {
    if (!path.toLowerCase().endsWith('.csv')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Only .csv files are supported for import.'),
        ),
      );
      return;
    }

    final file = File(path);
    if (!file.existsSync()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selected CSV file was not found.')),
      );
      return;
    }

    setState(() {
      _isImporting = true;
      _error = null;
    });

    try {
      final multipartFile = await MultipartFile.fromFile(
        path,
        filename: file.uri.pathSegments.isNotEmpty
            ? file.uri.pathSegments.last
            : 'group-trade.csv',
      );
      final formData = FormData.fromMap({'file': multipartFile});

      await _dio.post(
        '${AuthConstants.surveillanceSettingsTypeEndpoint}/GROUP_TRADE/import',
        data: formData,
      );

      if (!mounted) return;
      await _loadSettings();
      if (!mounted) return;
      setState(() {
        _isImporting = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${file.uri.pathSegments.last} imported successfully.'),
        ),
      );
    } on DioException catch (error) {
      if (!mounted) return;
      setState(() {
        _isImporting = false;
        _error =
            error.response?.data['message']?.toString() ??
            'Failed to import group trade file.';
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(_error!)));
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _isImporting = false;
        _error = error.toString().replaceFirst('Exception: ', '');
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(_error!)));
    }
  }

  Future<void> _downloadTemplate() async {
    if (_isDownloadingTemplate) return;

    final pathController = TextEditingController(text: _defaultTemplatePath());
    VoidCallback? closeDialog;

    CommonDialog.show(
      context: context,
      title: 'Download Group Trade Format',
      width: 580,
      height: 260,
      scrollable: false,
      autoPop: false,
      saveText: 'Download',
      cancelText: 'Cancel',
      contentBuilder: (dialogContext, close) {
        closeDialog = close;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Enter the full path where the CSV template should be saved.',
              style: GoogleFonts.openSans(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF374151),
              ),
            ),
            const SizedBox(height: 14),
            CustomInputField(
              hintText: '/Users/aman/Downloads/group-trade-template.csv',
              controller: pathController,
              height: 44,
              width: double.infinity,
              borderColor: Colors.grey.shade400,
              fillColor: const Color(0xFFF9F9F9),
            ),
            const SizedBox(height: 10),
            Text(
              'A sample CSV matching the backend import format will be created there.',
              style: GoogleFonts.openSans(
                fontSize: 12,
                color: const Color(0xFF6B7280),
              ),
            ),
          ],
        );
      },
      onSave: () {
        _downloadTemplateToPath(pathController.text.trim(), closeDialog);
      },
      onClose: () {
        pathController.dispose();
      },
    );
  }

  Future<void> _downloadTemplateToPath(
    String path,
    VoidCallback? closeDialog,
  ) async {
    if (path.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Enter a destination path for the template.'),
        ),
      );
      return;
    }

    setState(() {
      _isDownloadingTemplate = true;
    });

    try {
      var outputPath = path;
      if (!outputPath.toLowerCase().endsWith('.csv')) {
        outputPath = '$outputPath.csv';
      }

      final outputFile = File(outputPath);
      await outputFile.parent.create(recursive: true);
      await outputFile.writeAsString(_groupTradeTemplateCsv, flush: true);
      await OpenFilex.open(outputFile.path);

      if (!mounted) return;
      closeDialog?.call();
      setState(() {
        _isDownloadingTemplate = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('CSV template saved to ${outputFile.path}')),
      );
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isDownloadingTemplate = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to download CSV template.')),
      );
    }
  }

  String _defaultTemplatePath() {
    final home = Platform.environment['HOME'];
    if (home != null && home.isNotEmpty) {
      return '$home/Downloads/group-trade-template.csv';
    }
    return '${Directory.current.path}/group-trade-template.csv';
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SizedBox(
              width: 200,
              child: AppDropdown(
                hintText: 'Exchange',
                value: _selectedExchange,
                height: 38,
                items: _exchangeOrder,
                showAllOption: true,
                borderColor: Colors.grey.shade400,
                onChanged: (value) {
                  setState(() {
                    _selectedExchange = value;
                  });
                },
              ),
            ),
            Row(
              children: [
                CustomActionButton(
                  text: 'Download Format',
                  onPressed: _downloadTemplate,
                  width: 175,
                  height: 38,
                  backgroundColor: Colors.white,
                  textColor: AppColors.primaryBlue,
                  icon: Icons.download_outlined,
                  iconColor: AppColors.primaryBlue,
                  isLoading: _isDownloadingTemplate,
                ),
                const SizedBox(width: 12),
                CustomActionButton(
                  text: 'Import File',
                  onPressed: _importCsv,
                  width: 140,
                  height: 38,
                  icon: Icons.upload_file_outlined,
                  isLoading: _isImporting,
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 16),
        Expanded(
          child: Stack(
            children: [
              ViewDataTable<_GroupTradeSettingRow>(
                columns: const [
                  ViewTableColumn(
                    id: 'exchange',
                    label: 'EXCHANGE',
                    width: 260,
                  ),
                  ViewTableColumn(id: 'symbol', label: 'SYMBOL', width: 320),
                  ViewTableColumn(id: 'time', label: 'TIME', width: 320),
                ],
                data: _visibleRows,
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

    if (col.id == 'symbol') {
      return Text(
        row.symbolName,
        style: GoogleFonts.openSans(fontSize: 13, color: Colors.black87),
      );
    }

    return CustomInputField(
      hintText: 'ADD TIME',
      controller: row.timeController,
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
  final String symbolName;
  final bool isActive;
  final TextEditingController qtyController;
  final TextEditingController timeController;

  _GroupTradeSettingRow({
    required this.id,
    required this.exchangeName,
    required this.symbolName,
    required this.isActive,
    required this.qtyController,
    required this.timeController,
  });

  factory _GroupTradeSettingRow.fromJson(Map<String, dynamic> json) {
    return _GroupTradeSettingRow(
      id: json['id'] as int? ?? 0,
      exchangeName: json['exchangeName']?.toString() ?? '',
      symbolName: json['symbolName']?.toString() ?? '',
      isActive: json['isActive'] as bool? ?? false,
      qtyController: TextEditingController(
        text: json['qtyThreshold']?.toString() ?? '0',
      ),
      timeController: TextEditingController(
        text: (json['timeFrameSeconds'] as num?)?.toInt().toString() ?? '0',
      ),
    );
  }
}
