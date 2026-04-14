import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/app_colors.dart';
import 'app_dropdown.dart';


/// The standard list of exchanges shown across all feature pages.
const kExchangeItems = [
  'ALL',
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

/// The standard list of symbols shown across all feature pages.
const kSymbolItems = [
  'SGX GIFTNIFTY Oct 28',
  'NSE NIFTY Oct 28',
  'NSE BANKNIFTY Oct 28',
  'MINI GOLDMINI Dec 05',
  'MINI SILVERMINI Dec 05',
  'OTHER DOW Dec 19',
  'OTHER NASDAQ Dec 19',
  'OTHER S & P Dec 19',
];

/// A reusable modern filters section used across all feature pages.
///
/// Renders a clean frosted-glass filter card with:
/// - "FILTERS" label with accent divider
/// - Date, Exchange, Symbol dropdowns
/// - [extraFilters] for page-specific additions
/// - Gradient "Apply Filter" button
class PageFiltersBar extends StatelessWidget {
  final VoidCallback? onApply;
  final List<Widget> extraFilters;

  const PageFiltersBar({
    super.key,
    this.onApply,
    this.extraFilters = const [],
  });

  @override
  Widget build(BuildContext context) {
    final isDark = AppColors.isDarkMode(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: isDark
            ? const Color(0xFF1C2535).withOpacity(0.85)
            : Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark
              ? Colors.white.withOpacity(0.07)
              : const Color(0xFFE2E8F0),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withOpacity(0.2)
                : Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Section label ──
          Row(
            children: [
              // Accent pip
              Container(
                width: 3,
                height: 14,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0xFFFF3B30), Color(0xFFFF8C00)],
                  ),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'FILTERS',
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.4,
                  color: isDark
                      ? Colors.white.withOpacity(0.5)
                      : const Color(0xFF64748B),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Container(
                  height: 1,
                  color: isDark
                      ? Colors.white.withOpacity(0.06)
                      : const Color(0xFFE2E8F0),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // ── Filter controls row ──
          Row(
            children: [
              // Date
              _FilterDropdownSlot(
                child: AppDropdown(
                  hintText: 'Select Date',
                  height: 36,
                  items: const ['Today', 'Yesterday', 'Custom Date Range'],
                  borderColor: isDark
                      ? Colors.white.withOpacity(0.15)
                      : const Color(0xFFCBD5E1),
                  isDarkMode: isDark,
                ),
              ),
              const SizedBox(width: 10),

              // Exchange
              _FilterDropdownSlot(
                child: AppDropdown(
                  hintText: 'Exchange',
                  height: 36,
                  items: kExchangeItems,
                  showAllOption: true,
                  borderColor: isDark
                      ? Colors.white.withOpacity(0.15)
                      : const Color(0xFFCBD5E1),
                  isDarkMode: isDark,
                ),
              ),
              const SizedBox(width: 10),

              // Symbol
              _FilterDropdownSlot(
                child: AppDropdown(
                  type: AppDropdownType.search,
                  hintText: 'Symbol',
                  height: 36,
                  items: kSymbolItems,
                  borderColor: isDark
                      ? Colors.white.withOpacity(0.15)
                      : const Color(0xFFCBD5E1),
                  isDarkMode: isDark,
                ),
              ),

              // Extra feature-specific filter slots
              for (final extra in extraFilters) ...[
                const SizedBox(width: 10),
                extra,
              ],

              const Spacer(),

              // Apply Filter – gradient button
              _GradientApplyButton(onPressed: onApply ?? () {}),
            ],
          ),
        ],
      ),
    );
  }
}

/// Fixed-width wrapper used for each dropdown in [PageFiltersBar].
class _FilterDropdownSlot extends StatelessWidget {
  final Widget child;
  const _FilterDropdownSlot({required this.child});

  @override
  Widget build(BuildContext context) {
    return SizedBox(width: 190, child: child);
  }
}

/// Gradient "Apply Filter" button matching the BazaarPro brand.
class _GradientApplyButton extends StatefulWidget {
  final VoidCallback onPressed;
  const _GradientApplyButton({required this.onPressed});

  @override
  State<_GradientApplyButton> createState() => _GradientApplyButtonState();
}

class _GradientApplyButtonState extends State<_GradientApplyButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onPressed,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          height: 36,
          padding: const EdgeInsets.symmetric(horizontal: 22),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: _hovered
                  ? [const Color(0xFF263547), const Color(0xFF0066CC)]
                  : [const Color(0xFF202D3B), const Color(0xFF005CBB)],
            ),
            borderRadius: BorderRadius.circular(8),
            boxShadow: _hovered
                ? [
                    BoxShadow(
                      color: const Color(0xFF0066FF).withOpacity(0.35),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ]
                : [],
          ),
          child: Center(
            child: Text(
              'Apply Filter',
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.white,
                letterSpacing: 0.2,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
