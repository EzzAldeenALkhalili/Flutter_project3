import 'package:flutter/material.dart';
import 'dart:math';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _darkMode = false;
  bool _smartAlerts = true;
  bool _monthlyReports = false;
  String _privacySetting = "private";
  String _language = "en";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFEBF7FC),
      appBar: AppBar(
        title: const Text("Settings"),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            "Data Display",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          _buildSettingSwitch("Dark Mode", _darkMode, (value) {
            setState(() => _darkMode = value);
          }),
          _buildSettingDropdown(
            "Time Range",
            ["Daily", "Weekly", "Monthly"],
            "Weekly",
          ),
          const Divider(height: 32),

          const Text(
            "Notifications",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          _buildSettingSwitch("Smart Alerts", _smartAlerts, (value) {
            setState(() => _smartAlerts = value);
          }),
          const Divider(height: 32),

          const Text(
            "Privacy",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          _buildSettingRadio(
            "Who can see my analysis?",
            ["Only Me", "Selected Friends", "Everyone"],
            _privacySetting,
                (value) => setState(() => _privacySetting = value),
          ),
          const Divider(height: 32),

          const Text(
            "Language",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          _buildSettingRadio(
            "Choose Language",
            ["English", "Arabic"],
            _language,
                (value) => setState(() => _language = value),
          ),
          const Divider(height: 32),

          _buildSettingButton(
            "Delete All Data",
            Icons.delete,
            Colors.red,
                () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text("Delete Data"),
                  content: const Text("Are you sure you want to delete all your data? This action cannot be undone."),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text("Cancel"),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("All data deleted")),
                        );
                      },
                      child: const Text("Delete", style: TextStyle(color: Colors.red)),
                    ),
                  ],
                ),
              );
            },
          ),
          _buildSettingButton(
            "Share App",
            Icons.share,
            Colors.blue,
                () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Preparing share link...")),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSettingSwitch(String title, bool value, Function(bool) onChanged) {
    return SwitchListTile(
      title: Text(title),
      value: value,
      onChanged: onChanged,
    );
  }

  Widget _buildSettingDropdown(String title, List<String> options, String value) {
    return ListTile(
      title: Text(title),
      trailing: DropdownButton<String>(
        value: value,
        items: options.map((String option) {
          return DropdownMenuItem<String>(
            value: option,
            child: Text(option),
          );
        }).toList(),
        onChanged: (String? newValue) {},
      ),
    );
  }

  Widget _buildSettingRadio(String title, List<String> options, String value, Function(String) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 16, top: 8),
          child: Text(title),
        ),
        Column(
          children: options.map((option) {
            return RadioListTile<String>(
              title: Text(option),
              value: option,
              groupValue: value,
              onChanged: (String? newValue) {
                if (newValue != null) {
                  onChanged(newValue);
                }
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildSettingButton(String text, IconData icon, Color color, VoidCallback onPressed) {
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(text, style: TextStyle(color: color)),
      onTap: onPressed,
    );
  }
}
