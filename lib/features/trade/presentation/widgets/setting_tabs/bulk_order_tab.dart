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

class BulkOrderTab extends StatefulWidget {
  const BulkOrderTab({super.key});

  @override
  State<BulkOrderTab> createState() => BulkOrderTabState();
}

class BulkOrderTabState extends State<BulkOrderTab> {
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

  static const String _bulkOrderTemplateCsv =
      'exchangeName,symbolName,qtyThreshold,timeFrameSeconds\n'
      'NSE,RELIANCE,1000,60\n'
      'NSE,TCS,500,60\n'
      'NSE,NIFTY2641323300CE,2000,120\n'
      'CE/PE,BANKNIFTY2641350000PE,1500,120\n'
      'CE/PE,NIFTY2641323300PE,2000,120\n'
      'MCX,GOLD24DEC,100,300\n'
      'MCX,SILVER24DEC,200,300\n'
      'MCX,CRUDEOIL24DEC,150,300\n'
      'COMEX FUTURE,GCZ24,50,300\n'
      'COMEX SPOT,XAUUSD,75,60\n'
      'CRYPTO,BTCUSDT,10,30\n'
      'CRYPTO,ETHUSDT,25,30\n'
      'FOREX,EURUSD,500,60\n'
      'FOREX,USDJPY,500,60\n'
      'CDS,USDINR,1000,60\n'
      'GIFT,NIFTY50,1500,120\n'
      'OTHERS,CUSTOM1,100,60\n';

  final Dio _dio = ApiClient().dio;
  final List<_BulkOrderSettingRow> _rows = [];

  bool _isLoading = true;
  bool _isSaving = false;
  bool _isImporting = false;
  bool _isDownloadingTemplate = false;

  String? _error;
  String? _selectedExchange;

  List<_BulkOrderSettingRow> get _visibleRows {
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
        '${AuthConstants.surveillanceSettingsTypeEndpoint}/BULK_ORDER',
      );
      final rawItems = response.data['data'] as List<dynamic>? ?? [];
      final rows =
          rawItems
              .map(
                (item) =>
                    _BulkOrderSettingRow.fromJson(item as Map<String, dynamic>),
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
            'Failed to load bulk order settings.';
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _error = 'Failed to load bulk order settings.';
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
        '${AuthConstants.surveillanceSettingsTypeEndpoint}/BULK_ORDER/bulk',
        data: {
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
          content: Text('Bulk order settings updated successfully.'),
        ),
      );
      return true;
    } on DioException catch (error) {
      if (!mounted) return false;
      setState(() {
        _isSaving = false;
        _error =
            error.response?.data['message']?.toString() ??
            'Failed to update bulk order settings.';
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(_error!)));
      return false;
    } catch (_) {
      if (!mounted) return false;
      setState(() {
        _isSaving = false;
        _error = 'Failed to update bulk order settings.';
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
      title: 'Import Bulk Order CSV',
      helperText: 'Select a CSV file to import bulk order settings.',
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
            : 'bulk-order.csv',
      );
      final formData = FormData.fromMap({'file': multipartFile});
      await _dio.post(
        '${AuthConstants.surveillanceSettingsTypeEndpoint}/BULK_ORDER/import',
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
            'Failed to import bulk order file.';
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
      title: 'Download Bulk Order Format',
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
              hintText: '/Users/aman/Downloads/bulk-order-template.csv',
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
      await outputFile.writeAsString(_bulkOrderTemplateCsv, flush: true);
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
      return '$home/Downloads/bulk-order-template.csv';
    }
    return '${Directory.current.path}/bulk-order-template.csv';
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
              ViewDataTable<_BulkOrderSettingRow>(
                columns: const [
                  ViewTableColumn(
                    id: 'exchange',
                    label: 'EXCHANGE',
                    width: 200,
                  ),
                  ViewTableColumn(id: 'symbol', label: 'SYMBOL', width: 240),
                  ViewTableColumn(id: 'qty', label: 'QTY', width: 250),
                  ViewTableColumn(id: 'time', label: 'TIME', width: 250),
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

  Widget _buildCell(_BulkOrderSettingRow row, ViewTableColumn col) {
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

    if (col.id == 'qty') {
      return CustomInputField(
        hintText: 'Type here',
        controller: row.qtyController,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        height: 30,
        width: double.infinity,
        borderColor: Colors.grey.shade400,
        onChanged: (_) {
          if (_error != null) {
            setState(() {
              _error = null;
            });
          }
        },
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

class _BulkOrderSettingRow {
  final int id;
  final String exchangeName;
  final String symbolName;
  final bool isActive;
  final TextEditingController qtyController;
  final TextEditingController timeController;

  _BulkOrderSettingRow({
    required this.id,
    required this.exchangeName,
    required this.symbolName,
    required this.isActive,
    required this.qtyController,
    required this.timeController,
  });

  factory _BulkOrderSettingRow.fromJson(Map<String, dynamic> json) {
    return _BulkOrderSettingRow(
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
