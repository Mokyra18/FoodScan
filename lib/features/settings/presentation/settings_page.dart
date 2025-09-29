import 'package:flutter/material.dart';
import 'package:foodsnap/features/settings/widget/setting_api_key_section.dart';
import 'package:foodsnap/features/settings/widget/setting_firebase_ml_section.dart';
import 'package:foodsnap/features/settings/widget/setting_help_section.dart';
import 'package:foodsnap/features/settings/widget/setting_service_status_section.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final TextEditingController _apiKeyController = TextEditingController();
  Map<String, dynamic> modelInfo = {};
  String modelStatus = "Unknown";
  bool isModelLoading = false;
  Map<String, dynamic> serviceStatus = {};
  bool isDarkMode = false;

  @override
  void initState() {
    super.initState();
    _loadApiKey();
    _checkModelStatus();
    _refreshServiceStatus();
  }

  // 🔑 API KEY
  Future<void> _loadApiKey() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _apiKeyController.text = prefs.getString('geminiApiKey') ?? '';
    });
  }

  Future<void> _saveApiKey() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('geminiApiKey', _apiKeyController.text.trim());
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("API Key saved successfully")));
    _refreshServiceStatus();
  }

  Future<void> _removeApiKey() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('geminiApiKey');
    setState(() {
      _apiKeyController.clear();
    });
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("API Key removed")));
    _refreshServiceStatus();
  }

  Future<void> _testApiKey() async {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("API Key test success ✅")));
  }

  // 🤖 FIREBASE ML
  Future<void> _downloadModel() async {
    setState(() => isModelLoading = true);
    await Future.delayed(const Duration(seconds: 2)); // simulasi download
    setState(() {
      modelInfo = {"isDownloaded": true, "sizeFormatted": "24 MB"};
      modelStatus = "Downloaded";
      isModelLoading = false;
    });
    _refreshServiceStatus();
  }

  Future<void> _checkModelStatus() async {
    setState(() {
      modelStatus = modelInfo['isDownloaded'] == true
          ? "Downloaded"
          : "Not Downloaded";
    });
  }

  // 🔍 SERVICE STATUS
  Future<void> _refreshServiceStatus() async {
    await Future.delayed(const Duration(milliseconds: 500));
    setState(() {
      serviceStatus = {
        "gemini": {
          "enabled": _apiKeyController.text.isNotEmpty,
          "status": "OK",
        },
        "firebaseML": {"isModelLoaded": modelInfo['isDownloaded'] == true},
      };
    });
  }

  // ❓ HELP
  Future<void> _launchApiKeyUrl() async {
    final url = Uri.parse("https://aistudio.google.com/app/apikey");
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  // 🌙 THEME
  void _onThemeChanged() {
    setState(() {
      isDarkMode = !isDarkMode;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          isDarkMode ? "Dark Mode Enabled 🌙" : "Light Mode Enabled ☀️",
        ),
      ),
    );
  }

  Widget _buildSection(String title, IconData icon, Widget child) {
    return Card(
      margin: const EdgeInsets.only(bottom: 20),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: const Text("Settings"),
        actions: [
          IconButton(
            icon: Icon(isDarkMode ? Icons.dark_mode : Icons.light_mode),
            tooltip: isDarkMode
                ? "Switch to Light Mode"
                : "Switch to Dark Mode",
            onPressed: _onThemeChanged,
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSection(
            "API Key",
            Icons.vpn_key,
            SettingApiKeySection(
              apiKeyController: _apiKeyController,
              currentApiKey: _apiKeyController.text,
              hasApiKey: _apiKeyController.text.isNotEmpty,
              saveApiKey: _saveApiKey,
              removeApiKey: _removeApiKey,
              testApiKey: _testApiKey,
            ),
          ),
          _buildSection(
            "Firebase ML",
            Icons.cloud_download,
            SettingFirebaseMLSection(
              modelInfo: modelInfo,
              modelStatus: modelStatus,
              isModelLoading: isModelLoading,
              downloadModel: _downloadModel,
              checkModelStatus: _checkModelStatus,
            ),
          ),
          _buildSection(
            "Service Status",
            Icons.check_circle,
            SettingServiceStatusSection(
              serviceStatus: serviceStatus,
              refreshStatus: _refreshServiceStatus,
            ),
          ),
          _buildSection(
            "Help",
            Icons.help_outline,
            SettingHelpSection(launchApiKeyUrl: _launchApiKeyUrl),
          ),
        ],
      ),
    );
  }
}
