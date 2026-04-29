import 'dart:math' show min;

import 'package:geolocation_ip/geolocation_ip.dart';

class IpCityLookup {
  IpCityLookup._();

  static final IpCityLookup instance = IpCityLookup._();

  final Map<String, String?> _cache = {};

  bool _shouldLookup(String ip) {
    final v = ip.trim();
    if (v.isEmpty || v == '-') return false;
    if (v == '0.0.0.0' || v == '127.0.0.1' || v == '::1') return false;
    return true;
  }

  Future<String?> resolve({required String? ip, String? backendCity}) async {
    final trimmedCity = backendCity?.trim();
    if (trimmedCity != null && trimmedCity.isNotEmpty && trimmedCity != '-') {
      return trimmedCity;
    }

    final rawIp = ip?.trim() ?? '';
    if (!_shouldLookup(rawIp)) return null;

    if (_cache.containsKey(rawIp)) {
      return _cache[rawIp];
    }

    try {
      final info = await GeolocationIP.getInfo(rawIp);
      if (info == null || info.status != 'success') {
        _cache[rawIp] = null;
        return null;
      }
      final city = info.city?.trim();
      final resolved = (city != null && city.isNotEmpty) ? city : null;
      _cache[rawIp] = resolved;
      return resolved;
    } catch (_) {
      _cache[rawIp] = null;
      return null;
    }
  }

  Future<Map<String, String>> prefetchBatch(
    Iterable<({String? ip, String? backendCity})> rows,
  ) async {
    final needed = <String>{};
    for (final r in rows) {
      final apiCity = r.backendCity?.trim();
      if (apiCity != null && apiCity.isNotEmpty && apiCity != '-') {
        continue;
      }
      final ip = r.ip?.trim();
      if (ip == null || !_shouldLookup(ip)) continue;
      needed.add(ip);
    }
    if (needed.isEmpty) return {};

    final list = needed.toList();
    const concurrency = 10;
    for (var i = 0; i < list.length; i += concurrency) {
      final end = min(i + concurrency, list.length);
      final chunk = list.sublist(i, end);
      await Future.wait(chunk.map((ip) => resolve(ip: ip, backendCity: null)));
    }

    final out = <String, String>{};
    for (final ip in needed) {
      final c = _cache[ip];
      if (c != null && c.isNotEmpty) {
        out[ip] = c;
      }
    }
    return out;
  }
}
