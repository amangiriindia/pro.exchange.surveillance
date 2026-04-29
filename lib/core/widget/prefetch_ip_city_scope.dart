import 'package:flutter/material.dart';

import '../services/ip_city_lookup.dart';

class PrefetchIpCityScope extends StatefulWidget {
  final List<({String? ip, String? backendCity})> rowSources;
  final Widget Function(
    BuildContext context,
    Map<String, String> resolvedCityByIp,
  )
  builder;

  const PrefetchIpCityScope({
    super.key,
    required this.rowSources,
    required this.builder,
  });

  @override
  State<PrefetchIpCityScope> createState() => _PrefetchIpCityScopeState();
}

class _PrefetchIpCityScopeState extends State<PrefetchIpCityScope> {
  Map<String, String> _resolved = {};
  int _generation = 0;

  static String _signature(List<({String? ip, String? backendCity})> rows) {
    return rows.map((r) => '${r.ip ?? ''}|${r.backendCity ?? ''}').join('\x1e');
  }

  @override
  void initState() {
    super.initState();
    _kick(widget.rowSources);
  }

  @override
  void didUpdateWidget(PrefetchIpCityScope oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_signature(oldWidget.rowSources) != _signature(widget.rowSources)) {
      _kick(widget.rowSources);
    }
  }

  Future<void> _kick(List<({String? ip, String? backendCity})> rows) async {
    final gen = ++_generation;
    final map = await IpCityLookup.instance.prefetchBatch(rows);
    if (!mounted || gen != _generation) return;
    setState(() => _resolved = map);
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder(context, _resolved);
  }
}
