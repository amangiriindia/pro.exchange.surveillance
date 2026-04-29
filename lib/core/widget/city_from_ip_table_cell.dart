import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../constants/app_colors.dart';

String effectiveCityLabel({
  required String? backendCity,
  required String? ip,
  required Map<String, String> resolvedCityByIp,
}) {
  final api = backendCity?.trim();
  if (api != null && api.isNotEmpty && api != '-') {
    return api;
  }
  final rawIp = ip?.trim();
  if (rawIp != null &&
      rawIp.isNotEmpty &&
      rawIp != '-' &&
      resolvedCityByIp.containsKey(rawIp)) {
    return resolvedCityByIp[rawIp]!;
  }
  return '-';
}

Widget buildCityFromIpCell(
  BuildContext context, {
  required String? backendCity,
  required String? ip,
  required Map<String, String> resolvedCityByIp,
  double fontSize = 13,
  FontWeight fontWeight = FontWeight.normal,
  Color? textColor,
}) {
  final label = effectiveCityLabel(
    backendCity: backendCity,
    ip: ip,
    resolvedCityByIp: resolvedCityByIp,
  );
  final rawIp = ip?.trim();
  final tooltip = (rawIp != null && rawIp.isNotEmpty && rawIp != '-')
      ? 'IP: $rawIp'
      : null;

  final cellText = Text(
    label,
    maxLines: 1,
    softWrap: false,
    overflow: TextOverflow.ellipsis,
    style: GoogleFonts.openSans(
      color: textColor ?? AppColors.textColor(context),
      fontSize: fontSize,
      fontWeight: fontWeight,
    ),
  );

  if (tooltip == null) return cellText;
  return Tooltip(message: tooltip, child: cellText);
}
