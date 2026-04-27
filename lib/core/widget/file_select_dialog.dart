import 'dart:async';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_file_picker.dart';
import 'common_dilog_box.dart';

class FileSelectDialog {
  FileSelectDialog._();

  static Future<PlatformFile?> show({
    required BuildContext context,
    String title = 'Select File',
    String helperText = 'Choose a file to continue.',
    String saveText = 'Use File',
    List<String>? allowedExtensions,
  }) async {
    final completer = Completer<PlatformFile?>();
    final selectedFile = ValueNotifier<PlatformFile?>(null);

    void complete(PlatformFile? file) {
      if (!completer.isCompleted) {
        completer.complete(file);
      }
    }

    CommonDialog.show(
      context: context,
      title: title,
      width: 560,
      height: 260,
      scrollable: false,
      autoPop: false,
      showButtons: true,
      cancelText: 'Cancel',
      saveText: saveText,
      contentBuilder: (dialogContext, closeDialog) {
        return ValueListenableBuilder<PlatformFile?>(
          valueListenable: selectedFile,
          builder: (context, file, _) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  helperText,
                  style: GoogleFonts.openSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF374151),
                  ),
                ),
                const SizedBox(height: 14),
                AppFilePicker(
                  hintText: 'Select file',
                  allowedExtensions: allowedExtensions,
                  height: 42,
                  onFilePicked: (picked) {
                    selectedFile.value = picked;
                  },
                ),
                const SizedBox(height: 10),
                Text(
                  file?.name ?? 'No file selected yet.',
                  style: GoogleFonts.openSans(
                    fontSize: 12,
                    color: const Color(0xFF6B7280),
                  ),
                ),
              ],
            );
          },
        );
      },
      onSave: () {
        if (selectedFile.value == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Please select a file first.')),
          );
          return;
        }
        complete(selectedFile.value);
      },
      onCancel: () {
        complete(null);
      },
      onClose: () {
        complete(null);
        selectedFile.dispose();
      },
    );

    return completer.future;
  }
}
