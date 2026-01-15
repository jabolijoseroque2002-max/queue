import 'dart:async';
import 'package:flutter/material.dart';
import 'package:printing/printing.dart';
import 'information_form_screen.dart';
import 'admin_login_screen.dart';
import 'view_queue_screen.dart';
import '../services/supabase_service.dart';
import '../services/print_service.dart';
import '../models/queue_entry.dart';

class QueueHomeScreen extends StatefulWidget {
  const QueueHomeScreen({super.key});

  @override
  State<QueueHomeScreen> createState() => _QueueHomeScreenState();
}

class _QueueHomeScreenState extends State<QueueHomeScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late AnimationController _staggerController;

  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late final List<Animation<double>> _staggerAnimations = [];

  final SupabaseService _supabaseService = SupabaseService();

  @override
  void initState() {
    super.initState();

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _staggerController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero).animate(
          CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic),
        );

    // Create staggered animations for buttons
    for (int i = 0; i < 3; i++) {
      _staggerAnimations.add(
        Tween<double>(begin: 0.0, end: 1.0).animate(
          CurvedAnimation(
            parent: _staggerController,
            curve: Interval(i * 0.2, (i + 1) * 0.2, curve: Curves.easeOutBack),
          ),
        ),
      );
    }

    // Start animations
    _fadeController.forward();
    Future.delayed(const Duration(milliseconds: 200), () {
      _slideController.forward();
    });
    Future.delayed(const Duration(milliseconds: 400), () {
      _staggerController.forward();
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _staggerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F2F8),
      body: SafeArea(
        child: Column(
          children: [
            // Header with back button
            FadeTransition(
              opacity: _fadeAnimation,
              child: Container(
                margin: const EdgeInsets.only(top: 12, left: 12),
                alignment: Alignment.topLeft,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: IconButton(
                    icon: const Icon(
                      Icons.arrow_back_rounded,
                      color: Color(0xFF263277),
                      size: 24,
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Logo and Welcome Text
            SlideTransition(
              position: _slideAnimation,
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: const Color(0xFF263277),
                          width: 3,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF263277).withOpacity(0.2),
                            blurRadius: 15,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: CircleAvatar(
                        backgroundColor: Colors.white,
                        radius: 50,
                        child: ClipOval(
                          child: Image.asset(
                            'assets/queue_logo.jpg',
                            height: 100,
                            width: 100,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    ShaderMask(
                      shaderCallback: (bounds) => const LinearGradient(
                        colors: [Color(0xFF263277), Color(0xFF4A90E2)],
                      ).createShader(bounds),
                      child: Text(
                        'Welcome to Queue!',
                        style: Theme.of(context)
                            .textTheme
                            .headlineLarge
                            ?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 48),

            // Animated buttons
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    // Entry Queue Button
                    AnimatedBuilder(
                      animation: _staggerAnimations[0],
                      builder: (context, child) {
                        return Transform.scale(
                          scale: _staggerAnimations[0].value,
                          child: _buildMenuButton(
                            context,
                            icon: Icons.info_outline_rounded,
                            label: 'Entry Queue',
                            onTap: () {
                              _showEntryTypeDialog(context);
                            },
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 16),

                    // Admin Button
                    AnimatedBuilder(
                      animation: _staggerAnimations[1],
                      builder: (context, child) {
                        return Transform.scale(
                          scale: _staggerAnimations[1].value,
                          child: _buildMenuButton(
                            context,
                            icon: Icons.admin_panel_settings_rounded,
                            label: 'Admin',
                            onTap: () {
                              Navigator.push(
                                context,
                                PageRouteBuilder(
                                  pageBuilder:
                                      (
                                        context,
                                        animation,
                                        secondaryAnimation,
                                      ) => const AdminLoginScreen(),
                                  transitionsBuilder:
                                      (
                                        context,
                                        animation,
                                        secondaryAnimation,
                                        child,
                                      ) {
                                        return SlideTransition(
                                          position:
                                              Tween<Offset>(
                                                begin: const Offset(1.0, 0.0),
                                                end: Offset.zero,
                                              ).animate(
                                                CurvedAnimation(
                                                  parent: animation,
                                                  curve: Curves.easeInOutCubic,
                                                ),
                                              ),
                                          child: child,
                                        );
                                      },
                                  transitionDuration: const Duration(
                                    milliseconds: 500,
                                  ),
                                ),
                              );
                            },
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 16),

                    // View Queue Button
                    AnimatedBuilder(
                      animation: _staggerAnimations[2],
                      builder: (context, child) {
                        return Transform.scale(
                          scale: _staggerAnimations[2].value,
                          child: _buildMenuButton(
                            context,
                            icon: Icons.list_alt_rounded,
                            label: 'View Queue',
                            onTap: () {
                              Navigator.push(
                                context,
                                PageRouteBuilder(
                                  pageBuilder:
                                      (
                                        context,
                                        animation,
                                        secondaryAnimation,
                                      ) => const ViewQueueScreen(),
                                  transitionsBuilder:
                                      (
                                        context,
                                        animation,
                                        secondaryAnimation,
                                        child,
                                      ) {
                                        return SlideTransition(
                                          position:
                                              Tween<Offset>(
                                                begin: const Offset(1.0, 0.0),
                                                end: Offset.zero,
                                              ).animate(
                                                CurvedAnimation(
                                                  parent: animation,
                                                  curve: Curves.easeInOutCubic,
                                                ),
                                              ),
                                          child: child,
                                        );
                                      },
                                  transitionDuration: const Duration(
                                    milliseconds: 500,
                                  ),
                                ),
                              );
                            },
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 24),

                    const SizedBox.shrink(),
                  ],
                ),
              ),
            ),

            // Bottom bar
            Container(
              height: 4,
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [const Color(0xFF263277), const Color(0xFF4A90E2)],
                ),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(2),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showEntryTypeDialog(BuildContext context) async {
    final result = await showDialog<String>(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.9, end: 1.0),
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOutCubic,
            builder: (context, value, child) {
              return Transform.scale(
                scale: value,
                child: child,
              );
            },
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 18,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Select entry type',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleLarge
                                  ?.copyWith(
                                    color: const Color(0xFF263277),
                                    fontWeight: FontWeight.w700,
                                    fontSize: (Theme.of(context)
                                                .textTheme
                                                .titleLarge
                                                ?.fontSize ??
                                            22) *
                                        1.6,
                                  ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Pick how you want to line up today',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                    color: Colors.grey[600],
                                    fontSize: (Theme.of(context)
                                                .textTheme
                                                .bodySmall
                                                ?.fontSize ??
                                            12) *
                                        1.6,
                                  ),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color:
                                const Color(0xFF263277).withOpacity(0.06),
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: const Icon(
                            Icons.queue_rounded,
                            color: Color(0xFF263277),
                            size: 26,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            borderRadius: BorderRadius.circular(20),
                            onTap: () {
                              Navigator.of(context).pop('request');
                            },
                            child: Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                gradient: const LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    Color(0xFF3F8CFF),
                                    Color(0xFF64B5FF),
                                  ],
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color:
                                        const Color(0xFF3F8CFF).withOpacity(0.35),
                                    blurRadius: 16,
                                    offset: const Offset(0, 6),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(9),
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.white.withOpacity(0.18),
                                    ),
                                    child: const Icon(
                                      Icons.playlist_add_rounded,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    'Request',
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium
                                        ?.copyWith(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w700,
                                          fontSize: (Theme.of(context)
                                                      .textTheme
                                                      .titleMedium
                                                      ?.fontSize ??
                                                  18) *
                                              1.6,
                                        ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Create a new queue ticket\nfor your transaction.',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodySmall
                                        ?.copyWith(
                                          color: Colors.white.withOpacity(0.9),
                                          height: 1.3,
                                          fontSize: (Theme.of(context)
                                                      .textTheme
                                                      .bodySmall
                                                      ?.fontSize ??
                                                  12) *
                                              1.6,
                                        ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: InkWell(
                            borderRadius: BorderRadius.circular(20),
                            onTap: () {
                              Navigator.of(context).pop('releasing');
                            },
                            child: Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                gradient: const LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    Color(0xFF00C9A7),
                                    Color(0xFF02AAB0),
                                  ],
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color:
                                        const Color(0xFF00C9A7).withOpacity(0.35),
                                    blurRadius: 16,
                                    offset: const Offset(0, 6),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(9),
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.white.withOpacity(0.16),
                                    ),
                                    child: const Icon(
                                      Icons.assignment_turned_in_rounded,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    'For Releasing',
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium
                                        ?.copyWith(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w700,
                                          fontSize: (Theme.of(context)
                                                      .textTheme
                                                      .titleMedium
                                                      ?.fontSize ??
                                                  18) *
                                              1.6,
                                        ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Use your reference number\nfor document release.',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodySmall
                                        ?.copyWith(
                                          color: Colors.white.withOpacity(0.9),
                                          height: 1.3,
                                          fontSize: (Theme.of(context)
                                                      .textTheme
                                                      .bodySmall
                                                      ?.fontSize ??
                                                  12) *
                                              1.6,
                                        ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: Text(
                          'Close',
                          style: TextStyle(
                            color: Colors.grey[700],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );

    if (!context.mounted || result == null) return;

    if (result == 'request') {
      Navigator.push(
        context,
        PageRouteBuilder(
          pageBuilder: (
            context,
            animation,
            secondaryAnimation,
          ) =>
              const InformationFormScreen(),
          transitionsBuilder: (
            context,
            animation,
            secondaryAnimation,
            child,
          ) {
            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(1.0, 0.0),
                end: Offset.zero,
              ).animate(
                CurvedAnimation(
                  parent: animation,
                  curve: Curves.easeInOutCubic,
                ),
              ),
              child: child,
            );
          },
          transitionDuration: const Duration(
            milliseconds: 500,
          ),
        ),
      );
    } else if (result == 'releasing') {
      await _handleReleasingFlow(context);
    }
  }

  Future<void> _handleReleasingFlow(BuildContext context) async {
    final refController = TextEditingController();
    QueueEntry? foundEntry;

    try {
      final entered = await showDialog<String>(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return AlertDialog(
            title: const Text('Releasing'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Please enter your Reference Number to proceed with releasing.',
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: refController,
                  decoration: const InputDecoration(
                    labelText: 'Reference Number',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(null);
                },
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop(refController.text.trim());
                },
                child: const Text('Search'),
              ),
            ],
          );
        },
      );

      if (!context.mounted || entered == null || entered.isEmpty) {
        return;
      }

      foundEntry = await _supabaseService.getQueueEntryByReference(entered);

      if (!context.mounted) return;

      if (foundEntry == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Reference number not found.'),
          ),
        );
        return;
      }

      await showDialog<void>(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Confirm Details'),
            content: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Name: ${foundEntry!.name}'),
                  Text('SSU ID: ${foundEntry.ssuId}'),
                  Text('Email: ${foundEntry.email}'),
                  Text('Phone: ${foundEntry.phoneNumber}'),
                  Text('Department: ${foundEntry.department}'),
                  Text('Purpose: ${foundEntry.purpose}'),
                  if (foundEntry.course != null &&
                      foundEntry.course!.isNotEmpty)
                    Text('Course: ${foundEntry.course}'),
                  if (foundEntry.referenceNumber != null)
                    Text('Reference: ${foundEntry.referenceNumber}'),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('Proceed'),
              ),
            ],
          );
        },
      );

      if (!context.mounted) return;

      // Ensure RELEASING purpose exists and use uppercase to satisfy FK constraint
      try {
        final existingPurpose =
            await _supabaseService.getPurposeByName('RELEASING');
        if (existingPurpose == null) {
          await _supabaseService.addPurpose(
            name: 'RELEASING',
            description: 'Document releasing',
          );
        }
      } catch (_) {}

      final newEntry = await _supabaseService.addQueueEntry(
        name: foundEntry.name,
        ssuId: foundEntry.ssuId,
        email: foundEntry.email,
        phoneNumber: foundEntry.phoneNumber,
        department: 'R',
        purpose: 'RELEASING',
        course: foundEntry.course ?? '',
        isPwd: foundEntry.isPwd,
        isSenior: foundEntry.isSenior,
        isPregnant: foundEntry.isPregnant,
        userType: foundEntry.userType,
        gender: foundEntry.gender,
        age: foundEntry.age,
        graduationYear: foundEntry.graduationYear,
        notes: foundEntry.notes,
      );

      if (!context.mounted || newEntry == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to create new releasing queue entry.'),
          ),
        );
        return;
      }

      try {
        final pdfBytes = await PrintService.generateTicketPdfBytes(
          entry: newEntry,
        );
        await Printing.layoutPdf(
          onLayout: (format) async => pdfBytes,
        );
      } catch (_) {}

      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Your new queue number is #${newEntry.queueNumber.toString().padLeft(3, '0')}',
          ),
        ),
      );
    } finally {
      refController.dispose();
    }
  }

  Widget _buildMenuButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Container(
      width: double.infinity,
      height: 64,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [const Color(0xFF263277), const Color(0xFF4A90E2)],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF263277).withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Row(
              children: [
                Icon(icon, color: Colors.white, size: 28),
                const SizedBox(width: 16),
                Text(
                  label,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                const Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: Colors.white,
                  size: 16,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
