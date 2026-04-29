import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:dio/dio.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/auth_constants.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/widget/app_tab_bar.dart';
import '../../../../core/widget/page_header.dart';

class AlertItem {
  final int id;
  final String alertType;
  final String script;
  final String exchange;
  final List<int> clientIds;
  final List<int> tradeIds;
  final Map<String, dynamic> details;
  final String message;
  final bool isRead;
  final String investigateStatus;
  final String? investigateComment;
  final DateTime createdAt;

  const AlertItem({
    required this.id,
    required this.alertType,
    required this.script,
    required this.exchange,
    required this.clientIds,
    required this.tradeIds,
    required this.details,
    required this.message,
    required this.isRead,
    required this.investigateStatus,
    this.investigateComment,
    required this.createdAt,
  });

  factory AlertItem.fromJson(Map<String, dynamic> j) {
    return AlertItem(
      id: (j['id'] as num).toInt(),
      alertType: j['alertType'] as String? ?? '',
      script: j['script'] as String? ?? '',
      exchange: j['exchange'] as String? ?? '',
      clientIds: ((j['clientIds'] as List<dynamic>?) ?? [])
          .map((e) => (e as num).toInt())
          .toList(),
      tradeIds: ((j['tradeIds'] as List<dynamic>?) ?? [])
          .map((e) => (e as num).toInt())
          .toList(),
      details: (j['details'] as Map<String, dynamic>?) ?? {},
      message: j['message'] as String? ?? '',
      isRead: j['isRead'] as bool? ?? false,
      investigateStatus: j['investigateStatus'] as String? ?? 'NEW',
      investigateComment: j['investigateComment'] as String?,
      createdAt:
          DateTime.tryParse(j['createdAt'] as String? ?? '') ?? DateTime.now(),
    );
  }

  AlertItem copyWith({bool? isRead}) {
    return AlertItem(
      id: id,
      alertType: alertType,
      script: script,
      exchange: exchange,
      clientIds: clientIds,
      tradeIds: tradeIds,
      details: details,
      message: message,
      isRead: isRead ?? this.isRead,
      investigateStatus: investigateStatus,
      investigateComment: investigateComment,
      createdAt: createdAt,
    );
  }
}

class _TabConfig {
  final String label;
  final String alertType;
  final Color accentColor;
  final IconData icon;

  const _TabConfig({
    required this.label,
    required this.alertType,
    required this.accentColor,
    required this.icon,
  });
}

const _kTabs = [
  _TabConfig(
    label: 'Group Trade',
    alertType: 'GROUP_TRADE',
    accentColor: Color(0xFF0066FF),
    icon: Icons.group_rounded,
  ),
  _TabConfig(
    label: 'Bulk Order',
    alertType: 'BULK_ORDER',
    accentColor: Color(0xFFFF8C00),
    icon: Icons.layers_rounded,
  ),
  _TabConfig(
    label: 'Trade Comparison',
    alertType: 'TRADE_COMPARISON',
    accentColor: Color(0xFF9C27B0),
    icon: Icons.compare_arrows_rounded,
  ),
  _TabConfig(
    label: 'Same IP',
    alertType: 'SAME_IP',
    accentColor: Color(0xFF00BCD4),
    icon: Icons.router_rounded,
  ),
  _TabConfig(
    label: 'Profit Cross',
    alertType: 'PROFIT_CROSS',
    accentColor: Color(0xFF4CAF50),
    icon: Icons.trending_up_rounded,
  ),
  _TabConfig(
    label: 'BTST/STBT',
    alertType: 'BTST_STBT',
    accentColor: Color(0xFFFF3B30),
    icon: Icons.swap_vert_rounded,
  ),
];

class NotificationPage extends StatefulWidget {
  final VoidCallback? onNotificationTap;

  final String? initialTabAlertType;

  const NotificationPage({
    super.key,
    this.onNotificationTap,
    this.initialTabAlertType,
  });

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  late int _activeTabIndex;
  int _refreshVersion = 0;
  int _totalUnread = 0;
  Map<String, int> _unreadByType = const {};

  int _tabIndexFromAlertType(String? alertType) {
    if (alertType == null || alertType.isEmpty) {
      return 0;
    }
    final idx = _kTabs.indexWhere((t) => t.alertType == alertType);
    return idx >= 0 ? idx : 0;
  }

  @override
  void initState() {
    super.initState();
    _activeTabIndex = _tabIndexFromAlertType(widget.initialTabAlertType);
    unawaited(_fetchUnreadCounts());
  }

  @override
  void didUpdateWidget(covariant NotificationPage oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.initialTabAlertType != widget.initialTabAlertType) {
      final nextIndex = _tabIndexFromAlertType(widget.initialTabAlertType);
      if (nextIndex != _activeTabIndex) {
        setState(() {
          _activeTabIndex = nextIndex;
        });
      }
    }
  }

  Future<void> _fetchUnreadCounts() async {
    try {
      final resp = await ApiClient().dio.get(
        AuthConstants.alertUnreadCountEndpoint,
      );
      final root = resp.data as Map<String, dynamic>? ?? {};
      final data = root['data'] as Map<String, dynamic>? ?? {};
      final byTypeRaw = data['byType'] as Map<String, dynamic>? ?? {};
      final byType = <String, int>{
        for (final entry in byTypeRaw.entries)
          entry.key: (entry.value as num?)?.toInt() ?? 0,
      };

      if (!mounted) return;
      setState(() {
        _totalUnread = (data['total'] as num?)?.toInt() ?? 0;
        _unreadByType = byType;
      });
    } catch (_) {}
  }

  Future<void> _refreshCurrentTab() async {
    setState(() {
      _refreshVersion++;
    });
    await _fetchUnreadCounts();
  }

  void _handleAlertMarkedRead(String alertType) {
    final currentForType = _unreadByType[alertType] ?? 0;
    final nextTypeCount = currentForType > 0 ? currentForType - 1 : 0;

    setState(() {
      _totalUnread = _totalUnread > 0 ? _totalUnread - 1 : 0;
      _unreadByType = {..._unreadByType, alertType: nextTypeCount};
    });
  }

  String _tabLabel(_TabConfig tab) {
    final count = _unreadByType[tab.alertType] ?? 0;
    if (count <= 0) return tab.label;
    return '${tab.label} ($count)';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = AppColors.isDarkMode(context);

    return Container(
      color: Colors.transparent,
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PageHeader(
            title: 'Notifications',
            subtitle: _totalUnread > 0
                ? '$_totalUnread unread alerts across all modules'
                : 'Real-time surveillance alerts across all modules',
            onRefresh: _refreshCurrentTab,
            showNotificationButton: false,
          ),
          const SizedBox(height: 16),
          AppTabBar(
            tabs: _kTabs.map(_tabLabel).toList(),
            activeTab: _activeTabIndex,
            onTabChanged: (i) => setState(() => _activeTabIndex = i),
            style: AppTabBarStyle.pill,
            autoFocus: false,
            useExpanded: false,
            isDarkMode: isDark,
          ),
          const SizedBox(height: 16),
          Expanded(
            child: _AlertTabContent(
              key: ValueKey(
                '${_kTabs[_activeTabIndex].alertType}_$_refreshVersion',
              ),
              config: _kTabs[_activeTabIndex],
              onAlertMarkedRead: _handleAlertMarkedRead,
              onRefreshParent: _fetchUnreadCounts,
            ),
          ),
        ],
      ),
    );
  }
}

class _AlertTabContent extends StatefulWidget {
  final _TabConfig config;
  final ValueChanged<String>? onAlertMarkedRead;
  final Future<void> Function()? onRefreshParent;

  const _AlertTabContent({
    super.key,
    required this.config,
    this.onAlertMarkedRead,
    this.onRefreshParent,
  });

  @override
  State<_AlertTabContent> createState() => _AlertTabContentState();
}

class _AlertTabContentState extends State<_AlertTabContent> {
  List<AlertItem> _items = [];
  bool _loading = false;
  String? _error;
  int _page = 1;
  int _totalPages = 1;
  bool _loadingMore = false;
  final Set<int> _markingReadIds = <int>{};

  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _fetch(reset: true);
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _loadNextPage();
    }
  }

  Future<void> _fetch({bool reset = false}) async {
    if (reset) {
      setState(() {
        _loading = true;
        _error = null;
        _page = 1;
        _items = [];
      });
    }
    try {
      final resp = await ApiClient().dio.get(
        AuthConstants.alertListEndpoint,
        queryParameters: {
          'page': _page,
          'sizePerPage': 20,
          'alertType': widget.config.alertType,
        },
      );
      final data = resp.data as Map<String, dynamic>;
      final body = data['data'] as Map<String, dynamic>? ?? {};
      final list = (body['alerts'] as List<dynamic>? ?? [])
          .map((e) => AlertItem.fromJson(e as Map<String, dynamic>))
          .toList();
      if (mounted) {
        setState(() {
          _items = reset ? list : [..._items, ...list];
          _totalPages = (body['totalPages'] as num?)?.toInt() ?? 1;
          _loading = false;
          _loadingMore = false;
        });
      }
    } on DioException catch (e) {
      if (mounted) {
        setState(() {
          _error =
              e.response?.data?['message'] as String? ??
              e.message ??
              'Failed to load alerts';
          _loading = false;
          _loadingMore = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _loading = false;
          _loadingMore = false;
        });
      }
    }
  }

  void _loadNextPage() {
    if (_loadingMore || _page >= _totalPages) return;
    setState(() {
      _loadingMore = true;
      _page++;
    });
    _fetch();
  }

  Future<void> _markAsRead(AlertItem item, int index) async {
    if (item.isRead || _markingReadIds.contains(item.id)) return;

    final previous = _items[index];
    setState(() {
      _markingReadIds.add(item.id);
      _items[index] = item.copyWith(isRead: true);
    });

    widget.onAlertMarkedRead?.call(item.alertType);

    try {
      await ApiClient().dio.put(
        '${AuthConstants.alertMarkReadEndpoint}/${item.id}',
      );
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _items[index] = previous;
      });
      await widget.onRefreshParent?.call();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Unable to mark alert #${item.id} as read',
            style: GoogleFonts.inter(fontSize: 12),
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _markingReadIds.remove(item.id);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Center(
        child: Text(
          'Preparing alerts...',
          style: GoogleFonts.inter(
            fontSize: 13,
            color: widget.config.accentColor,
            fontWeight: FontWeight.w600,
          ),
        ),
      );
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline_rounded,
              color: const Color(0xFFFF3B30),
              size: 40,
            ),
            const SizedBox(height: 12),
            Text(
              _error!,
              style: GoogleFonts.inter(
                fontSize: 13,
                color: const Color(0xFFFF3B30),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () => _fetch(reset: true),
              child: Text(
                'Retry',
                style: GoogleFonts.inter(
                  color: widget.config.accentColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      );
    }

    if (_items.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              widget.config.icon,
              color: widget.config.accentColor.withOpacity(0.35),
              size: 56,
            ),
            const SizedBox(height: 14),
            Text(
              'No ${widget.config.label} alerts',
              style: GoogleFonts.inter(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: AppColors.isDarkMode(context)
                    ? Colors.white38
                    : Colors.black38,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      color: widget.config.accentColor,
      onRefresh: () async {
        await _fetch(reset: true);
        await widget.onRefreshParent?.call();
      },
      child: ListView.separated(
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: _items.length + (_loadingMore ? 1 : 0),
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (context, i) {
          if (i == _items.length) {
            return const SizedBox.shrink();
          }
          final item = _items[i];
          final isMarking = _markingReadIds.contains(item.id);

          return GestureDetector(
            onTap: () => _markAsRead(item, i),
            behavior: HitTestBehavior.opaque,
            child: Opacity(
              opacity: isMarking ? 0.7 : 1,
              child: _buildCard(item, context),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCard(AlertItem item, BuildContext context) {
    switch (item.alertType) {
      case 'GROUP_TRADE':
        return _GroupTradeCard(item: item, accent: widget.config.accentColor);
      case 'BULK_ORDER':
        return _BulkOrderCard(item: item, accent: widget.config.accentColor);
      case 'TRADE_COMPARISON':
        return _TradeComparisonCard(
          item: item,
          accent: widget.config.accentColor,
        );
      case 'SAME_IP':
        return _SameIpCard(item: item, accent: widget.config.accentColor);
      case 'PROFIT_CROSS':
        return _ProfitCrossCard(item: item, accent: widget.config.accentColor);
      case 'BTST_STBT':
        return _BtstStbtCard(item: item, accent: widget.config.accentColor);
      default:
        return _GenericCard(item: item, accent: widget.config.accentColor);
    }
  }
}

class _BaseCard extends StatelessWidget {
  final AlertItem item;
  final Color accent;
  final Widget child;

  const _BaseCard({
    required this.item,
    required this.accent,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = AppColors.isDarkMode(context);
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A2535) : Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isDark ? const Color(0xFF2A3A50) : const Color(0xFFE2E8F0),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.25 : 0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          Positioned(
            left: 0,
            top: 0,
            bottom: 0,
            child: Container(
              width: 4,
              decoration: BoxDecoration(
                color: accent,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(10),
                  bottomLeft: Radius.circular(10),
                ),
              ),
            ),
          ),
          Padding(padding: const EdgeInsets.all(14), child: child),
          if (!item.isRead)
            Positioned(
              top: 10,
              right: 12,
              child: Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: accent,
                  shape: BoxShape.circle,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

String _formatTime(DateTime dt) {
  final diff = DateTime.now().difference(dt);
  if (diff.inDays > 0) return '${diff.inDays}d ago';
  if (diff.inHours > 0) return '${diff.inHours}h ago';
  if (diff.inMinutes > 0) return '${diff.inMinutes}m ago';
  return 'Just now';
}

Widget _scriptBadge(String script, String exchange, Color accent) {
  return Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: accent.withOpacity(0.12),
          borderRadius: BorderRadius.circular(5),
          border: Border.all(color: accent.withOpacity(0.3)),
        ),
        child: Text(
          script,
          style: GoogleFonts.inter(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: accent,
          ),
        ),
      ),
      const SizedBox(width: 6),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
        decoration: BoxDecoration(
          color: const Color(0xFF202D3B).withOpacity(0.08),
          borderRadius: BorderRadius.circular(5),
        ),
        child: Text(
          exchange,
          style: GoogleFonts.inter(
            fontSize: 10,
            fontWeight: FontWeight.w500,
            color: const Color(0xFF8B96A7),
          ),
        ),
      ),
    ],
  );
}

Widget _statusBadge(String status) {
  final Color bg;
  final Color fg;
  switch (status) {
    case 'INVESTIGATING':
      bg = const Color(0xFFFFF3E0);
      fg = const Color(0xFFFF8C00);
      break;
    case 'RESOLVED':
      bg = const Color(0xFFE8F5E9);
      fg = const Color(0xFF4CAF50);
      break;
    default:
      bg = const Color(0xFFE3F2FD);
      fg = const Color(0xFF0066FF);
  }
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
    decoration: BoxDecoration(
      color: bg,
      borderRadius: BorderRadius.circular(4),
    ),
    child: Text(
      status,
      style: GoogleFonts.inter(
        fontSize: 10,
        fontWeight: FontWeight.w700,
        color: fg,
      ),
    ),
  );
}

Widget _infoChip(String label, String value, Color accent) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label,
        style: GoogleFonts.inter(
          fontSize: 9,
          fontWeight: FontWeight.w500,
          color: const Color(0xFF8B96A7),
          letterSpacing: 0.4,
        ),
      ),
      const SizedBox(height: 2),
      Text(
        value,
        style: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: accent,
        ),
      ),
    ],
  );
}

class _GroupTradeCard extends StatelessWidget {
  final AlertItem item;
  final Color accent;

  const _GroupTradeCard({required this.item, required this.accent});

  @override
  Widget build(BuildContext context) {
    final isDark = AppColors.isDarkMode(context);
    final details = item.details;
    final tradeType = details['tradeType'] as String? ?? '';
    final clientCount = details['clientCount'] as int? ?? 0;
    final mergeCount = details['mergeCount'] as int? ?? 0;
    final timeFrame = details['timeFrameSeconds'] as int? ?? 0;
    final isBuy = tradeType.toLowerCase() == 'buy';

    return _BaseCard(
      item: item,
      accent: accent,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: accent.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.group_rounded, color: accent, size: 16),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Group Trade',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white60 : Colors.black45,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 2),
                    _scriptBadge(item.script, item.exchange, accent),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  _statusBadge(item.investigateStatus),
                  const SizedBox(height: 4),
                  Text(
                    _formatTime(item.createdAt),
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      color: const Color(0xFF8B96A7),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF0F1623) : const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _infoChip('CLIENTS', '$clientCount', accent),
                _vertDivider(),
                _infoChip('TRADES', '$mergeCount', accent),
                _vertDivider(),
                _infoChip(
                  'DIRECTION',
                  tradeType.toUpperCase(),
                  isBuy ? const Color(0xFF0066FF) : const Color(0xFFFF3B30),
                ),
                _vertDivider(),
                _infoChip(
                  'TIMEFRAME',
                  _formatSeconds(timeFrame),
                  const Color(0xFF8B96A7),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            item.message,
            style: GoogleFonts.inter(
              fontSize: 11,
              color: isDark ? Colors.white54 : Colors.black45,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _BulkOrderCard extends StatelessWidget {
  final AlertItem item;
  final Color accent;

  const _BulkOrderCard({required this.item, required this.accent});

  @override
  Widget build(BuildContext context) {
    final isDark = AppColors.isDarkMode(context);
    final details = item.details;
    final totalQty = details['totalQty'] as num? ?? 0;
    final qtyThreshold = details['qtyThreshold'] as num? ?? 0;
    final clientCount = details['clientCount'] as int? ?? 0;
    final tradeType = details['tradeType'] as String? ?? '';
    final isBuy = tradeType.toLowerCase() == 'buy';
    final fillRatio = qtyThreshold > 0
        ? (totalQty / qtyThreshold).clamp(0.0, 1.0).toDouble()
        : 1.0;

    return _BaseCard(
      item: item,
      accent: accent,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: accent.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.layers_rounded, color: accent, size: 16),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Bulk Order',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white60 : Colors.black45,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 2),
                    _scriptBadge(item.script, item.exchange, accent),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  _statusBadge(item.investigateStatus),
                  const SizedBox(height: 4),
                  Text(
                    _formatTime(item.createdAt),
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      color: const Color(0xFF8B96A7),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _infoChip('TOTAL QTY', totalQty.toString(), accent),
              const SizedBox(width: 20),
              _infoChip(
                'THRESHOLD',
                qtyThreshold.toString(),
                const Color(0xFF8B96A7),
              ),
              const SizedBox(width: 20),
              _infoChip('CLIENTS', '$clientCount', accent),
              const SizedBox(width: 20),
              _infoChip(
                'SIDE',
                tradeType.toUpperCase(),
                isBuy ? const Color(0xFF0066FF) : const Color(0xFFFF3B30),
              ),
            ],
          ),
          const SizedBox(height: 10),

          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Qty vs Threshold',
                    style: GoogleFonts.inter(
                      fontSize: 9,
                      color: const Color(0xFF8B96A7),
                      letterSpacing: 0.4,
                    ),
                  ),
                  Text(
                    '${(fillRatio * 100).toStringAsFixed(0)}%',
                    style: GoogleFonts.inter(
                      fontSize: 9,
                      color: accent,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              ClipRRect(
                borderRadius: BorderRadius.circular(3),
                child: SizedBox(
                  height: 5,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      ColoredBox(color: accent.withOpacity(0.15)),
                      FractionallySizedBox(
                        alignment: Alignment.centerLeft,
                        widthFactor: fillRatio.clamp(0.0, 1.0),
                        child: ColoredBox(color: accent),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TradeComparisonCard extends StatelessWidget {
  final AlertItem item;
  final Color accent;

  const _TradeComparisonCard({required this.item, required this.accent});

  @override
  Widget build(BuildContext context) {
    final isDark = AppColors.isDarkMode(context);
    final details = item.details;
    final basePrice = details['basePrice'] as num? ?? 0;
    final tradeType = details['tradeType'] as String? ?? '';
    final clientCount = details['clientCount'] as int? ?? 0;
    final threshold = details['similarityThreshold'] as num? ?? 0;
    final matchedTrades = (details['matchedTrades'] as List<dynamic>?) ?? [];
    final isBuy = tradeType.toLowerCase() == 'buy';

    return _BaseCard(
      item: item,
      accent: accent,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: accent.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.compare_arrows_rounded,
                  color: accent,
                  size: 16,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Trade Comparison',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white60 : Colors.black45,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 2),
                    _scriptBadge(item.script, item.exchange, accent),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  _statusBadge(item.investigateStatus),
                  const SizedBox(height: 4),
                  Text(
                    _formatTime(item.createdAt),
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      color: const Color(0xFF8B96A7),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [accent.withOpacity(0.1), accent.withOpacity(0.03)],
              ),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: accent.withOpacity(0.2)),
            ),
            child: Row(
              children: [
                Icon(
                  isBuy
                      ? Icons.arrow_upward_rounded
                      : Icons.arrow_downward_rounded,
                  color: isBuy
                      ? const Color(0xFF0066FF)
                      : const Color(0xFFFF3B30),
                  size: 18,
                ),
                const SizedBox(width: 8),
                Text(
                  tradeType.toUpperCase(),
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: isBuy
                        ? const Color(0xFF0066FF)
                        : const Color(0xFFFF3B30),
                  ),
                ),
                const SizedBox(width: 16),
                Text(
                  '@ ₹${basePrice.toStringAsFixed(2)}',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                const Spacer(),
                _infoChip('CLIENTS', '$clientCount', accent),
                const SizedBox(width: 16),
                _infoChip('WITHIN', '$threshold%', accent),
              ],
            ),
          ),
          if (matchedTrades.isNotEmpty) ...[
            const SizedBox(height: 8),
            SizedBox(
              height: 28,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: matchedTrades.length,
                separatorBuilder: (_, __) => const SizedBox(width: 6),
                itemBuilder: (_, i) {
                  final mt = matchedTrades[i] as Map<String, dynamic>;
                  final uid = mt['userId'] as int? ?? 0;
                  final qty = mt['quantity'] as num? ?? 0;
                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: accent.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(5),
                      border: Border.all(color: accent.withOpacity(0.2)),
                    ),
                    child: Text(
                      'U$uid · $qty',
                      style: GoogleFonts.inter(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: accent,
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _SameIpCard extends StatelessWidget {
  final AlertItem item;
  final Color accent;

  const _SameIpCard({required this.item, required this.accent});

  @override
  Widget build(BuildContext context) {
    final isDark = AppColors.isDarkMode(context);
    final details = item.details;
    final ipAddress = details['ipAddress'] as String? ?? '—';
    final clientCount = details['clientCount'] as int? ?? 0;
    final timeFrame = details['timeFrameSeconds'] as int? ?? 0;

    return _BaseCard(
      item: item,
      accent: accent,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: accent.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.router_rounded, color: accent, size: 16),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Same IP',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white60 : Colors.black45,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 2),
                    _scriptBadge(item.script, item.exchange, accent),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  _statusBadge(item.investigateStatus),
                  const SizedBox(height: 4),
                  Text(
                    _formatTime(item.createdAt),
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      color: const Color(0xFF8B96A7),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: accent.withOpacity(0.08),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: accent.withOpacity(0.25)),
            ),
            child: Row(
              children: [
                Icon(Icons.lan_rounded, color: accent, size: 20),
                const SizedBox(width: 10),
                Text(
                  ipAddress,
                  style: GoogleFonts.robotoMono(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: accent,
                    letterSpacing: 1.2,
                  ),
                ),
                const Spacer(),
                _infoChip('CLIENTS', '$clientCount', accent),
                const SizedBox(width: 20),
                _infoChip('TIMEFRAME', _formatSeconds(timeFrame), accent),
              ],
            ),
          ),
          const SizedBox(height: 8),

          if (item.clientIds.isNotEmpty)
            Wrap(
              spacing: 6,
              runSpacing: 4,
              children: item.clientIds.take(8).map((cid) {
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 7,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: accent.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    'C$cid',
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: accent,
                    ),
                  ),
                );
              }).toList(),
            ),
        ],
      ),
    );
  }
}

class _ProfitCrossCard extends StatelessWidget {
  final AlertItem item;
  final Color accent;

  const _ProfitCrossCard({required this.item, required this.accent});

  @override
  Widget build(BuildContext context) {
    final isDark = AppColors.isDarkMode(context);
    final details = item.details;
    final userId = details['userId'] as int? ?? 0;
    final buyPrice = details['buyPrice'] as num? ?? 0;
    final sellPrice = details['sellPrice'] as num? ?? 0;
    final profitPct = details['profitPercent'] as num? ?? 0;
    final threshold = details['profitPercentThreshold'] as num? ?? 0;
    final fillRatio = threshold > 0
        ? (profitPct / threshold).clamp(0.0, 10.0).toDouble()
        : 1.0;

    return _BaseCard(
      item: item,
      accent: accent,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: accent.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.trending_up_rounded, color: accent, size: 16),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Profit Cross',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white60 : Colors.black45,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 2),
                    _scriptBadge(item.script, item.exchange, accent),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  _statusBadge(item.investigateStatus),
                  const SizedBox(height: 4),
                  Text(
                    _formatTime(item.createdAt),
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      color: const Color(0xFF8B96A7),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0066FF).withOpacity(0.08),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: const Color(0xFF0066FF).withOpacity(0.2),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'BUY',
                        style: GoogleFonts.inter(
                          fontSize: 9,
                          color: const Color(0xFF0066FF),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        '₹${buyPrice.toStringAsFixed(2)}',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF0066FF),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Icon(Icons.arrow_forward_rounded, color: accent, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: accent.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: accent.withOpacity(0.2)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'SELL',
                        style: GoogleFonts.inter(
                          fontSize: 9,
                          color: accent,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        '₹${sellPrice.toStringAsFixed(2)}',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: accent,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${profitPct.toStringAsFixed(2)}%',
                    style: GoogleFonts.inter(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: accent,
                    ),
                  ),
                  Text(
                    'threshold ${threshold}%',
                    style: GoogleFonts.inter(
                      fontSize: 9,
                      color: const Color(0xFF8B96A7),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Text(
                'User $userId',
                style: GoogleFonts.inter(
                  fontSize: 10,
                  color: const Color(0xFF8B96A7),
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Spacer(),
              SizedBox(
                width: 120,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(3),
                  child: SizedBox(
                    height: 5,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        ColoredBox(color: accent.withOpacity(0.15)),
                        FractionallySizedBox(
                          alignment: Alignment.centerLeft,
                          widthFactor: (fillRatio / 10.0).clamp(0.0, 1.0),
                          child: ColoredBox(color: accent),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _BtstStbtCard extends StatelessWidget {
  final AlertItem item;
  final Color accent;

  const _BtstStbtCard({required this.item, required this.accent});

  @override
  Widget build(BuildContext context) {
    final isDark = AppColors.isDarkMode(context);
    final details = item.details;
    final label = details['label'] as String? ?? 'BTST';
    final userId = details['userId'] as int? ?? 0;
    final inTime = details['inTime'] as String? ?? '';
    final outTime = details['outTime'] as String? ?? '';
    final timeDiffHours = details['timeDiffHours'] as num? ?? 0;
    final firstTradeType = details['firstTradeType'] as String? ?? '';
    final secondTradeType = details['secondTradeType'] as String? ?? '';

    final inDt = DateTime.tryParse(inTime);
    final outDt = DateTime.tryParse(outTime);

    return _BaseCard(
      item: item,
      accent: accent,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: accent.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.swap_vert_rounded, color: accent, size: 16),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          label,
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            color: accent,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'User $userId',
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            color: isDark ? Colors.white60 : Colors.black45,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    _scriptBadge(item.script, item.exchange, accent),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  _statusBadge(item.investigateStatus),
                  const SizedBox(height: 4),
                  Text(
                    _formatTime(item.createdAt),
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      color: const Color(0xFF8B96A7),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),

          Row(
            children: [
              _TimelineNode(
                label: firstTradeType.toUpperCase(),
                time: inDt != null ? _formatDateTime(inDt) : inTime,
                color: firstTradeType.toLowerCase() == 'buy'
                    ? const Color(0xFF0066FF)
                    : const Color(0xFFFF3B30),
              ),
              Expanded(
                child: Column(
                  children: [
                    Container(height: 2, color: accent.withOpacity(0.4)),
                    const SizedBox(height: 4),
                    Text(
                      '${timeDiffHours.toStringAsFixed(1)}h',
                      style: GoogleFonts.inter(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: accent,
                      ),
                    ),
                  ],
                ),
              ),
              _TimelineNode(
                label: secondTradeType.toUpperCase(),
                time: outDt != null ? _formatDateTime(outDt) : outTime,
                color: secondTradeType.toLowerCase() == 'buy'
                    ? const Color(0xFF0066FF)
                    : const Color(0xFFFF3B30),
                isRight: true,
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            item.message,
            style: GoogleFonts.inter(
              fontSize: 11,
              color: isDark ? Colors.white60 : Colors.black54,
              height: 1.35,
            ),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _TimelineNode extends StatelessWidget {
  final String label;
  final String time;
  final Color color;
  final bool isRight;

  const _TimelineNode({
    required this.label,
    required this.time,
    required this.color,
    this.isRight = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: isRight
          ? CrossAxisAlignment.end
          : CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: color.withOpacity(0.12),
            borderRadius: BorderRadius.circular(5),
            border: Border.all(color: color.withOpacity(0.3)),
          ),
          child: Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          time,
          style: GoogleFonts.inter(fontSize: 9, color: const Color(0xFF8B96A7)),
        ),
      ],
    );
  }
}

class _GenericCard extends StatelessWidget {
  final AlertItem item;
  final Color accent;

  const _GenericCard({required this.item, required this.accent});

  @override
  Widget build(BuildContext context) {
    return _BaseCard(
      item: item,
      accent: accent,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _scriptBadge(item.script, item.exchange, accent),
          const SizedBox(height: 8),
          Text(item.message, style: GoogleFonts.inter(fontSize: 12)),
        ],
      ),
    );
  }
}

Widget _vertDivider() {
  return Container(width: 1, height: 28, color: Colors.white.withOpacity(0.08));
}

String _formatSeconds(int seconds) {
  if (seconds >= 86400) return '${(seconds / 86400).toStringAsFixed(0)}d';
  if (seconds >= 3600) return '${(seconds / 3600).toStringAsFixed(0)}h';
  if (seconds >= 60) return '${(seconds / 60).toStringAsFixed(0)}m';
  return '${seconds}s';
}

String _formatDateTime(DateTime dt) {
  return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')} '
      '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
}
