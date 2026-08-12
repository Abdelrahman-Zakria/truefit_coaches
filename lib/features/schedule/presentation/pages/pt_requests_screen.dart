import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:truefit_coaches/core/theme/app_theme.dart';

class PTRequestsScreen extends StatelessWidget {
  const PTRequestsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildRequestCard(
          name: "Faisal Al-Dosari",
          initials: "FD",
          plan: "Premium PT (3x/week)",
          preferredTimes: "Mornings 7–10am",
          date: "2025-07-14",
        ),
        const SizedBox(height: 12),
        _buildRequestCard(
          name: "Dana Nasser",
          initials: "DN",
          plan: "Elite PT (5x/week)",
          preferredTimes: "Evenings 6–9pm",
          date: "2025-07-13",
        ),
        const SizedBox(height: 12),
        _buildRequestCard(
          name: "Tariq Salem",
          initials: "TS",
          plan: "Basic PT (2x/week)",
          preferredTimes: "Weekends, any time",
          date: "2025-07-12",
        ),
      ],
    );
  }

  Widget _buildRequestCard({
    required String name,
    required String initials,
    required String plan,
    required String preferredTimes,
    required String date,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceDark,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withValues(alpha:0.06)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppTheme.primaryRed.withValues(alpha:0.15),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Center(
                  child: Text(
                    initials,
                    style: GoogleFonts.barlowCondensed(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: GoogleFonts.barlowCondensed(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      "Requested on $date",
                      style: GoogleFonts.jetBrainsMono(
                        fontSize: 10,
                        color: Colors.white.withValues(alpha:0.3),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFF59E0B).withValues(alpha:0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  "PENDING",
                  style: GoogleFonts.barlowCondensed(
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    color: const Color(0xFFF59E0B),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildInfoRow("Requested Plan", plan),
          const SizedBox(height: 8),
          _buildInfoRow("Preferred Times", preferredTimes),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildActionButton(
                  label: "REJECT",
                  color: Colors.white.withValues(alpha:0.05),
                  textColor: Colors.white.withValues(alpha:0.4),
                  onTap: () {},
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildActionButton(
                  label: "ACCEPT",
                  color: AppTheme.primaryRed,
                  textColor: Colors.white,
                  onTap: () {},
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: GoogleFonts.barlowCondensed(
            fontSize: 10,
            color: Colors.white.withValues(alpha:0.3),
            fontWeight: FontWeight.bold,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.white,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required String label,
    required Color color,
    required Color textColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 44,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Text(
            label,
            style: GoogleFonts.barlowCondensed(
              fontSize: 14,
              fontWeight: FontWeight.w900,
              color: textColor,
              letterSpacing: 1,
            ),
          ),
        ),
      ),
    );
  }
}
