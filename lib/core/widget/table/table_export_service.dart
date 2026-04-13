import 'dart:io';
import 'package:excel/excel.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../table/view_data_table.dart';

class TableExportService {
  static Future<void> exportAsPdf<T>({
    required String title,
    required List<ViewTableColumn> columns,
    required List<T> data,
    required String Function(T item, ViewTableColumn column) cellValueExtractor,
  }) async {
    final fontRegular = await PdfGoogleFonts.openSansRegular();
    final fontBold = await PdfGoogleFonts.openSansBold();
    final pdf = pw.Document(
      theme: pw.ThemeData.withFont(base: fontRegular, bold: fontBold),
    );

    final headers = columns.map((c) => c.label).toList();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4.landscape,
        margin: const pw.EdgeInsets.all(20),
        header: (pw.Context ctx) => pw.Container(
          width: double.infinity,
          padding: const pw.EdgeInsets.only(bottom: 10),
          decoration: const pw.BoxDecoration(
            border: pw.Border(
              bottom: pw.BorderSide(color: PdfColors.grey400, width: 0.5),
            ),
          ),
          child: pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text(
                title,
                style: pw.TextStyle(
                  fontSize: 14,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColor.fromHex('1F4A66'),
                ),
              ),
              pw.Text(
                'Records: ${data.length}',
                style: const pw.TextStyle(
                  fontSize: 9,
                  color: PdfColors.grey600,
                ),
              ),
            ],
          ),
        ),
        build: (pw.Context ctx) {
          return [
            pw.TableHelper.fromTextArray(
              border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
              headerStyle: pw.TextStyle(
                fontSize: 8,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.white,
              ),
              headerDecoration: pw.BoxDecoration(
                color: PdfColor.fromHex('1F4A66'),
              ),
              cellStyle: const pw.TextStyle(fontSize: 7),
              cellAlignment: pw.Alignment.centerLeft,
              headerAlignments: {
                for (int i = 0; i < columns.length; i++)
                  i: columns[i].isNumeric
                      ? pw.Alignment.centerRight
                      : pw.Alignment.centerLeft,
              },
              cellAlignments: {
                for (int i = 0; i < columns.length; i++)
                  i: columns[i].isNumeric
                      ? pw.Alignment.centerRight
                      : pw.Alignment.centerLeft,
              },
              columnWidths: {
                for (int i = 0; i < columns.length; i++)
                  i: const pw.FlexColumnWidth(),
              },
              headers: headers,
              data: data
                  .map(
                    (item) => columns
                        .map((col) => cellValueExtractor(item, col))
                        .toList(),
                  )
                  .toList(),
            ),
          ];
        },
      ),
    );

    await _saveAndOpenFile(
      await pdf.save(),
      '${_sanitizeFileName(title)}_${DateTime.now().millisecondsSinceEpoch}.pdf',
    );
  }

  static Future<void> exportAsExcel<T>({
    required String title,
    required List<ViewTableColumn> columns,
    required List<T> data,
    required String Function(T item, ViewTableColumn column) cellValueExtractor,
  }) async {
    final excel = Excel.createExcel();
    final sheetName = title.length > 31 ? title.substring(0, 31) : title;
    final sheet = excel[sheetName];
    excel.setDefaultSheet(sheetName);

    final headerStyle = CellStyle(
      bold: true,
      fontColorHex: ExcelColor.white,
      backgroundColorHex: ExcelColor.fromHexString('#1F4A66'),
      fontSize: 10,
    );

    sheet.appendRow(columns.map((c) => TextCellValue(c.label)).toList());

    for (int i = 0; i < columns.length; i++) {
      final cell = sheet.cell(
        CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 0),
      );
      cell.cellStyle = headerStyle;
    }

    for (final item in data) {
      sheet.appendRow(
        columns.map((col) {
          final value = cellValueExtractor(item, col);
          if (col.isNumeric) {
            final numVal = double.tryParse(value.replaceAll(',', ''));
            if (numVal != null) return DoubleCellValue(numVal);
          }
          return TextCellValue(value);
        }).toList(),
      );
    }

    for (int i = 0; i < columns.length; i++) {
      sheet.setColumnWidth(i, 18);
    }

    if (excel.sheets.containsKey('Sheet1') && sheetName != 'Sheet1') {
      excel.delete('Sheet1');
    }

    await _saveAndOpenFile(
      excel.save()!,
      '${_sanitizeFileName(title)}_${DateTime.now().millisecondsSinceEpoch}.xlsx',
    );
  }

  static Future<void> _saveAndOpenFile(List<int> bytes, String fileName) async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/$fileName');
    await file.writeAsBytes(bytes, flush: true);
    await OpenFilex.open(file.path);
  }

  static String _sanitizeFileName(String name) {
    return name
        .replaceAll(RegExp(r'[^\w\s-]'), '')
        .replaceAll(RegExp(r'\s+'), '_');
  }
}
