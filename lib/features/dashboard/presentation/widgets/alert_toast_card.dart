import 'dart:ui';
import 'package:flutter/material.dart';
import '../../domain/entities/alert_entity.dart';
import '../utils/alert_navigation_bus.dart';
import 'alert_type_theme.dart';

class AlertToastCard extends StatefulWidget {
  final AlertEntity alert;
  final VoidCallback onDismiss;

  const AlertToastCard({
    super.key,
    required this.alert,
    required this.onDismiss,
  });

  @override
  State<AlertToastCard> createState() => _AlertToastCardState();
}

class _AlertToastCardState extends State<AlertToastCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnim;
  late Animation<double> _fadeAnim;
  bool _hovered = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _slideAnim = Tween<Offset>(
      begin: const Offset(1.2, 0.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
    _fadeAnim = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeIn));
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _dismiss() async {
    await _controller.reverse();
    widget.onDismiss();
  }

  void _onTap() {
    AlertNavigationBus.instance.navigateTo(
      widget.alert.alertType.toApiString(),
    );
    _dismiss();
  }

  TextStyle _txt({
    required double size,
    required FontWeight weight,
    required Color color,
    double? height,
    double? spacing,
  }) {
    return TextStyle(
      color: color,
      fontSize: size,
      fontWeight: weight,
      height: height,
      letterSpacing: spacing,
      decoration: TextDecoration.none,
      decorationColor: Colors.transparent,
    );
  }

  @override
  Widget build(BuildContext context) {
    final color = alertTypeColor(widget.alert.alertType);
    final icon = alertTypeIcon(widget.alert.alertType);
    final label = widget.alert.alertType.displayLabel;
    final timeStr = _formatTime(widget.alert.createdAt);

    return SlideTransition(
      position: _slideAnim,
      child: FadeTransition(
        opacity: _fadeAnim,
        child: MouseRegion(
          onEnter: (_) => setState(() => _hovered = true),
          onExit: (_) => setState(() => _hovered = false),
          child: GestureDetector(
            onTap: _onTap,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              width: 340,
              margin: const EdgeInsets.only(bottom: 12),
              transform: Matrix4.identity()
                ..translate(_hovered ? -2.0 : 0.0, _hovered ? -2.0 : 0.0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: color.withOpacity(_hovered ? 0.24 : 0.14),
                    blurRadius: _hovered ? 22 : 14,
                    offset: const Offset(0, 6),
                    spreadRadius: _hovered ? 1 : 0,
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          const Color(0xFF1C2637).withOpacity(0.92),
                          const Color(0xFF141D2D).withOpacity(0.9),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: color.withOpacity(0.35),
                        width: 1,
                      ),
                    ),
                    child: Stack(
                      children: [
                        Positioned(
                          left: 0,
                          top: 0,
                          bottom: 0,
                          child: Container(
                            width: 4,
                            decoration: BoxDecoration(
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(14),
                                bottomLeft: Radius.circular(14),
                              ),
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [color, color.withOpacity(0.4)],
                              ),
                            ),
                          ),
                        ),

                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 12, 10, 12),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      color.withOpacity(0.30),
                                      color.withOpacity(0.10),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: color.withOpacity(0.35),
                                    width: 1,
                                  ),
                                ),
                                child: Icon(icon, color: color, size: 20),
                              ),
                              const SizedBox(width: 12),

                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 3,
                                          ),
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              colors: [
                                                color,
                                                color.withOpacity(0.7),
                                              ],
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              5,
                                            ),
                                          ),
                                          child: Text(
                                            label,
                                            style: _txt(
                                              color: Colors.white,
                                              size: 10,
                                              weight: FontWeight.w800,
                                              spacing: 0.45,
                                            ),
                                          ),
                                        ),
                                        const Spacer(),
                                        Text(
                                          timeStr,
                                          style: _txt(
                                            color: Colors.white.withOpacity(
                                              0.6,
                                            ),
                                            size: 10,
                                            weight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 5),

                                    if (widget.alert.script != null &&
                                        widget.alert.script!.isNotEmpty) ...[
                                      Text(
                                        widget.alert.script!,
                                        style: _txt(
                                          color: color.withOpacity(0.9),
                                          size: 11,
                                          weight: FontWeight.w700,
                                          spacing: 0.15,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 1,
                                      ),
                                      const SizedBox(height: 3),
                                    ],

                                    Text(
                                      widget.alert.message,
                                      style: _txt(
                                        color: Colors.white.withOpacity(0.87),
                                        size: 12,
                                        weight: FontWeight.w500,
                                        height: 1.45,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 8),

                                    Row(
                                      children: [
                                        Icon(
                                          Icons.open_in_new_rounded,
                                          size: 12,
                                          color: color.withOpacity(0.82),
                                        ),
                                        const SizedBox(width: 5),
                                        Text(
                                          'Tap to view in Notifications',
                                          style: _txt(
                                            color: color.withOpacity(0.86),
                                            size: 10,
                                            weight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 4),

                              GestureDetector(
                                onTap: _dismiss,
                                child: Container(
                                  width: 28,
                                  height: 28,
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.06),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Icon(
                                    Icons.close_rounded,
                                    size: 16,
                                    color: Colors.white.withOpacity(0.58),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

String _formatTime(DateTime? dt) {
  if (dt == null) return '';
  final now = DateTime.now();
  final diff = now.difference(dt);
  if (diff.inSeconds < 60) return 'just now';
  if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
  if (diff.inHours < 24) return '${diff.inHours}h ago';
  return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
}
