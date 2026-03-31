import 'package:flutter/material.dart';
import 'package:sosapp/services/notification_service.dart';
// ignore: unused_import
import 'dart:math' as math;
import '../theme.dart';
import '../models/emergency_contact.dart';
import 'alert_screen.dart';

class MainMonitoringScreen extends StatefulWidget {
  final List<EmergencyContact> contacts;

  const MainMonitoringScreen({super.key, required this.contacts});

  @override
  State<MainMonitoringScreen> createState() => _MainMonitoringScreenState();
}

class _MainMonitoringScreenState extends State<MainMonitoringScreen>
    with TickerProviderStateMixin {
  bool _isMonitoring = false;
  late AnimationController _pulseController;
  late AnimationController _waveController;
  late Animation<double> _pulseAnim;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );
    _pulseAnim = Tween<double>(begin: 1.0, end: 1.12).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _waveController.dispose();
    super.dispose();
  }

  void _toggleMonitoring() {
  setState(() => _isMonitoring = !_isMonitoring);

  if (_isMonitoring) {
    _pulseController.repeat(reverse: true);
    _waveController.repeat();

    // ✅ SHOW NOTIFICATION
    NotificationService.showNotification(
      title: "Monitoring Started",
      body: "Your safety monitoring is active 🚨",
    );

  } else {
    _pulseController.stop();
    _pulseController.reset();
    _waveController.stop();
    _waveController.reset();

    // ✅ OPTIONAL: CANCEL NOTIFICATION
    NotificationService.cancelNotification();
  }
}

  // For demo: trigger emergency
  void _simulateAlert() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => AlertScreen(
          contactCount: widget.contacts.isEmpty ? 5 : widget.contacts.length,
          onBack: () => Navigator.of(context).pop(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Self Live Monitoring'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.people_outline_rounded,
                color: AppTheme.textSecondary),
            onPressed: () => _showContactsSheet(),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Status bar
            _StatusBanner(isMonitoring: _isMonitoring),

            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Big monitoring button
                    _MonitoringButton(
                      isMonitoring: _isMonitoring,
                      pulseAnim: _pulseAnim,
                      waveController: _waveController,
                      onPressed: _toggleMonitoring,
                    ),

                    const SizedBox(height: 32),

                    // Status text
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      child: _isMonitoring
                          ? const _ActiveStatusText()
                          : const _InactiveStatusText(),
                    ),

                    const SizedBox(height: 48),

                    // Info cards row
                    Row(
                      children: [
                        Expanded(
                          child: _InfoCard(
                            icon: Icons.people_rounded,
                            label: 'Contacts',
                            value: widget.contacts.isEmpty
                                ? '0'
                                : '${widget.contacts.length}',
                            color: AppTheme.accentBlue,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _InfoCard(
                            icon: Icons.mic_rounded,
                            label: 'Voice AI',
                            value: 'Ready',
                            color: AppTheme.green,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _InfoCard(
                            icon: Icons.location_on_rounded,
                            label: 'Location',
                            value: 'GPS On',
                            color: const Color(0xFFFFAB40),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Demo button to simulate alert
            if (_isMonitoring)
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                child: GestureDetector(
                  onTap: _simulateAlert,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      color: AppTheme.red.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color: AppTheme.red.withValues(alpha: 0.3)),
                    ),
                    child: const Center(
                      child: Text(
                        '⚠️  Simulate Emergency Alert (Demo)',
                        style: TextStyle(
                          color: AppTheme.red,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _showContactsSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _ContactsSheet(contacts: widget.contacts),
    );
  }
}

// ─── Sub-widgets ────────────────────────────────────────────────────────────

class _StatusBanner extends StatelessWidget {
  final bool isMonitoring;
  const _StatusBanner({required this.isMonitoring});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 10),
      color: isMonitoring
          ? AppTheme.green.withValues(alpha: 0.1)
          : AppTheme.surfaceLight,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color:
                  isMonitoring ? AppTheme.green : AppTheme.textHint,
              boxShadow: isMonitoring
                  ? [
                      BoxShadow(
                        color: AppTheme.green.withValues(alpha: 0.6),
                        blurRadius: 6,
                        spreadRadius: 1,
                      )
                    ]
                  : null,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            isMonitoring ? 'Monitoring Active' : 'Monitoring: OFF',
            style: TextStyle(
              color: isMonitoring
                  ? AppTheme.green
                  : AppTheme.textSecondary,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}

class _MonitoringButton extends StatelessWidget {
  final bool isMonitoring;
  final Animation<double> pulseAnim;
  final AnimationController waveController;
  final VoidCallback onPressed;

  const _MonitoringButton({
    required this.isMonitoring,
    required this.pulseAnim,
    required this.waveController,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Animated rings when active
        if (isMonitoring) ...[
          AnimatedBuilder(
            animation: waveController,
            builder: (_, __) => _WaveRing(
              size: 220,
              opacity: (1 - waveController.value) * 0.25,
              color: AppTheme.green,
            ),
          ),
          AnimatedBuilder(
            animation: waveController,
            builder: (_, __) => _WaveRing(
              size: 260,
              opacity: (1 - waveController.value) * 0.12,
              color: AppTheme.green,
            ),
          ),
        ],

        // Main button
        AnimatedBuilder(
          animation: pulseAnim,
          builder: (_, child) => Transform.scale(
            scale: isMonitoring ? pulseAnim.value : 1.0,
            child: child,
          ),
          child: GestureDetector(
            onTap: onPressed,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 400),
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isMonitoring
                    ? AppTheme.green
                    : AppTheme.surfaceLight,
                border: Border.all(
                  color: isMonitoring
                      ? AppTheme.green
                      : AppTheme.borderColor,
                  width: 2,
                ),
                boxShadow: isMonitoring
                    ? [
                        BoxShadow(
                          color: AppTheme.green.withValues(alpha: 0.35),
                          blurRadius: 40,
                          spreadRadius: 6,
                        )
                      ]
                    : [
                        const BoxShadow(
                          color: Colors.black38,
                          blurRadius: 20,
                          offset: Offset(0, 4),
                        )
                      ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    isMonitoring
                        ? Icons.stop_rounded
                        : Icons.play_arrow_rounded,
                    color: isMonitoring
                        ? AppTheme.background
                        : AppTheme.textPrimary,
                    size: 52,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    isMonitoring ? 'STOP' : 'START',
                    style: TextStyle(
                      color: isMonitoring
                          ? AppTheme.background
                          : AppTheme.textPrimary,
                      fontWeight: FontWeight.w900,
                      fontSize: 16,
                      letterSpacing: 2,
                    ),
                  ),
                  Text(
                    'MONITORING',
                    style: TextStyle(
                      color: isMonitoring
                          ? AppTheme.background.withValues(alpha: 0.7)
                          : AppTheme.textSecondary,
                      fontWeight: FontWeight.w600,
                      fontSize: 10,
                      letterSpacing: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _WaveRing extends StatelessWidget {
  final double size;
  final double opacity;
  final Color color;

  const _WaveRing(
      {required this.size, required this.opacity, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: color.withValues(alpha: opacity),
          width: 2,
        ),
      ),
    );
  }
}

class _ActiveStatusText extends StatelessWidget {
  const _ActiveStatusText();

  @override
  Widget build(BuildContext context) {
    return Column(
      key: const ValueKey('active'),
      children: [
        const Text(
          '🟢 Monitoring Active',
          style: TextStyle(
            color: AppTheme.green,
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Listening for distress signals…',
          style: TextStyle(
            color: AppTheme.textSecondary,
            fontSize: 13,
          ),
        ),
      ],
    );
  }
}

class _InactiveStatusText extends StatelessWidget {
  const _InactiveStatusText();

  @override
  Widget build(BuildContext context) {
    return Column(
      key: const ValueKey('inactive'),
      children: [
        const Text(
          'Tap to Start',
          style: TextStyle(
            color: AppTheme.textPrimary,
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'Monitoring is currently off',
          style: AppTheme.bodyText,
        ),
      ],
    );
  }
}

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _InfoCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
      decoration: BoxDecoration(
        color: AppTheme.cardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.borderColor),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w800,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              color: AppTheme.textHint,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}

class _ContactsSheet extends StatelessWidget {
  final List<EmergencyContact> contacts;
  const _ContactsSheet({required this.contacts});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Emergency Contacts', style: AppTheme.headingSmall),
          const SizedBox(height: 4),
          Text(
            '${contacts.length} contacts added',
            style: const TextStyle(color: AppTheme.textHint, fontSize: 12),
          ),
          const SizedBox(height: 16),
          if (contacts.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Center(
                child: Text(
                  'No contacts added yet',
                  style: TextStyle(color: AppTheme.textSecondary),
                ),
              ),
            )
          else
            ...contacts.map(
              (c) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppTheme.green.withValues(alpha: 0.1),
                      ),
                      child: Center(
                        child: Text(
                          c.name[0].toUpperCase(),
                          style: const TextStyle(
                            color: AppTheme.green,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(c.name,
                            style: const TextStyle(
                                color: AppTheme.textPrimary,
                                fontWeight: FontWeight.w500)),
                        Text(c.phone,
                            style: const TextStyle(
                                color: AppTheme.textHint, fontSize: 12)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}