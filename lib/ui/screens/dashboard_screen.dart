import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/tracking_provider.dart';
import '../../models/log_entry.dart';
import '../widgets/cycle_ring_widget.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Overview'),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today_outlined),
            onPressed: () {}, // For V2 calendar
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {}, // For V2 settings
          ),
        ],
      ),
      body: Consumer<TrackingProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          int currentDay = 1;
          int totalDays = 28;
          if (provider.cycles.isNotEmpty) {
             final latestCycle = provider.cycles.first;
             currentDay = DateTime.now().difference(latestCycle.startDate).inDays + 1;
             
             if (provider.predictedStartWindow != null) {
                totalDays = provider.predictedStartWindow!.difference(latestCycle.startDate).inDays;
                if (totalDays <= 0) totalDays = 28;
             }
             // Cap currentDay for the visualizer if it goes over
             if (currentDay > totalDays) currentDay = totalDays;
          }

          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 20),
                  // The Circular Visualizer
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      CycleRingWidget(
                        currentDay: currentDay,
                        totalDays: totalDays,
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Day',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              letterSpacing: 1.2,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            provider.cycles.isEmpty ? '-' : '$currentDay',
                            style: Theme.of(context).textTheme.displayLarge?.copyWith(
                              fontWeight: FontWeight.w300,
                              fontSize: 72,
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 40),
                  _buildStatusText(context, provider),
                  const Spacer(),
                  _buildQuickLogSection(context, provider),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatusText(BuildContext context, TrackingProvider provider) {
    if (provider.cycles.isEmpty) {
      return Text(
        "Ready to start tracking.\nLog your first period below.",
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          color: Theme.of(context).textTheme.bodyMedium?.color,
          height: 1.5,
        ),
      );
    }

    if (provider.predictedStartWindow != null && provider.predictedEndWindow != null) {
      final startFormat = DateFormat('MMM d').format(provider.predictedStartWindow!);
      final endFormat = DateFormat('MMM d').format(provider.predictedEndWindow!);
      return Column(
        children: [
          Text(
            "Period Expected",
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "$startFormat — $endFormat",
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Theme.of(context).primaryColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      );
    }
    return const SizedBox.shrink();
  }

  Widget _buildQuickLogSection(BuildContext context, TrackingProvider provider) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 20,
            offset: const Offset(0, 8),
          )
        ],
      ),
      child: Column(
        children: [
          Text(
            'How are you feeling today?',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildLogActionButton(
                context, 
                icon: Icons.water_drop_outlined, 
                label: 'Flow', 
                onTap: () => _showFlowLogSheet(context, provider)
              ),
              _buildLogActionButton(
                context, 
                icon: Icons.add_reaction_outlined, 
                label: 'Symptoms', 
                onTap: () {} // Placeholder for full symptoms
              ),
              _buildLogActionButton(
                context, 
                icon: Icons.edit_note_outlined, 
                label: 'Notes', 
                onTap: () {} // Placeholder for notes
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLogActionButton(BuildContext context, {required IconData icon, required String label, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Theme.of(context).primaryColor, size: 28),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  void _showFlowLogSheet(BuildContext context, TrackingProvider provider) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
          ),
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Log Flow',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'Select your flow intensity for today.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 32),
              Row(
                children: [
                  Expanded(child: _buildFlowOption(context, 'Light', provider, ctx)),
                  const SizedBox(width: 12),
                  Expanded(child: _buildFlowOption(context, 'Medium', provider, ctx)),
                  const SizedBox(width: 12),
                  Expanded(child: _buildFlowOption(context, 'Heavy', provider, ctx)),
                ],
              ),
              const SizedBox(height: 32),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFlowOption(BuildContext context, String level, TrackingProvider provider, BuildContext sheetContext) {
    return InkWell(
      onTap: () {
        if(provider.cycles.isEmpty) {
           provider.logPeriodStart(DateTime.now());
        } else {
           provider.saveLog(
             LogEntry(date: DateTime.now(), flowIntensity: level.toLowerCase())
           );
        }
        Navigator.pop(sheetContext);
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: Theme.of(context).cardTheme.color,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Theme.of(context).primaryColor.withOpacity(0.1)),
        ),
        alignment: Alignment.center,
        child: Text(
          level,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: Theme.of(context).primaryColor,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
