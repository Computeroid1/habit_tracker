import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../services/theme_service.dart';
import '../services/notification_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late Box _settingsBox;
  bool _notificationsEnabled = false;
  TimeOfDay _notificationTime = const TimeOfDay(hour: 9, minute: 0);

  @override
  void initState() {
    super.initState();
    _settingsBox = Hive.box('settings');
    _loadSettings();
  }

  void _loadSettings() {
    setState(() {
      _notificationsEnabled = _settingsBox.get('notificationsEnabled', defaultValue: false);
      final hour = _settingsBox.get('notificationHour', defaultValue: 9);
      final minute = _settingsBox.get('notificationMinute', defaultValue: 0);
      _notificationTime = TimeOfDay(hour: hour, minute: minute);
    });
  }

  Future<void> _toggleNotifications(bool value) async {
    setState(() {
      _notificationsEnabled = value;
    });
    await _settingsBox.put('notificationsEnabled', value);

    if (value) {
      await NotificationService().scheduleDailyNotification(
        hour: _notificationTime.hour,
        minute: _notificationTime.minute,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Daily reminders enabled! 🔔')),
        );
      }
    } else {
      await NotificationService().cancelAllNotifications();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Daily reminders disabled')),
        );
      }
    }
  }

  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _notificationTime,
    );

    if (picked != null) {
      setState(() {
        _notificationTime = picked;
      });

      await _settingsBox.put('notificationHour', picked.hour);
      await _settingsBox.put('notificationMinute', picked.minute);

      if (_notificationsEnabled) {
        await NotificationService().scheduleDailyNotification(
          hour: picked.hour,
          minute: picked.minute,
        );
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Reminder time updated to ${picked.format(context)}')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        children: [
          const SizedBox(height: 8),
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              children: [
                const ListTile(
                  leading: Icon(Icons.notifications_outlined),
                  title: Text('Daily Reminders'),
                  subtitle: Text('Get notified to track your habits'),
                ),
                SwitchListTile(
                  title: const Text('Enable Notifications'),
                  value: _notificationsEnabled,
                  onChanged: _toggleNotifications,
                ),
                if (_notificationsEnabled)
                  ListTile(
                    leading: const Icon(Icons.access_time),
                    title: const Text('Reminder Time'),
                    subtitle: Text(_notificationTime.format(context)),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: _selectTime,
                  ),
              ],
            ),
          ),
          Consumer<ThemeService>(
            builder: (context, themeService, _) {
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Column(
                  children: [
                    const ListTile(
                      leading: Icon(Icons.palette_outlined),
                      title: Text('Theme'),
                      subtitle: Text('Choose your preferred theme'),
                    ),
                    RadioListTile<ThemeMode>(
                      title: const Text('Light'),
                      value: ThemeMode.light,
                      groupValue: themeService.themeMode,
                      onChanged: (value) {
                        themeService.setThemeMode(value!);
                      },
                    ),
                    RadioListTile<ThemeMode>(
                      title: const Text('Dark'),
                      value: ThemeMode.dark,
                      groupValue: themeService.themeMode,
                      onChanged: (value) {
                        themeService.setThemeMode(value!);
                      },
                    ),
                    RadioListTile<ThemeMode>(
                      title: const Text('System'),
                      value: ThemeMode.system,
                      groupValue: themeService.themeMode,
                      onChanged: (value) {
                        themeService.setThemeMode(value!);
                      },
                    ),
                  ],
                ),
              );
            },
          ),
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              children: const [
                ListTile(
                  leading: Icon(Icons.info_outline),
                  title: Text('About'),
                  subtitle: Text('Habit Tracker v1.0.0'),
                ),
                Divider(height: 1),
                ListTile(
                  leading: Icon(Icons.code),
                  title: Text('Made with Flutter'),
                  subtitle: Text('Build better habits, one day at a time'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}