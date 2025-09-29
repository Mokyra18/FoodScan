import 'package:flutter/material.dart';
import 'package:foodsnap/features/settings/widget/setting_api_key_section.dart';
import 'package:foodsnap/features/settings/widget/setting_firebase_ml_section.dart';
import 'package:foodsnap/features/settings/widget/setting_help_section.dart';
import 'package:foodsnap/features/settings/widget/setting_service_status_section.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final TextEditingController _apiKeyController = TextEditingController();
  String? _savedApiKey;

  Map<String, dynamic> modelInfo = {};
  String modelStatus = "Unknown";
  bool isModelLoading = false;
  bool isCheckingModel = false;
  Map<String, dynamic> serviceStatus = {};
  bool isRefreshingStatus = false;

  @override
  void initState() {
    super.initState();
    _loadApiKey();
    _checkModelStatus(showSnackBar: false);
    _refreshServiceStatus(showSnackBar: false);
  }

  Future<void> _loadApiKey() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _savedApiKey = prefs.getString('geminiApiKey');
    });
  }

  Future<void> _saveApiKey() async {
    final prefs = await SharedPreferences.getInstance();
    final newKey = _apiKeyController.text.trim();
    await prefs.setString('geminiApiKey', newKey);
    setState(() {
      _savedApiKey = newKey;
    });
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("API Key saved successfully")),
      );
    }
    _refreshServiceStatus();
  }

  Future<void> _removeApiKey() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('geminiApiKey');
    setState(() {
      _savedApiKey = null;
      _apiKeyController.clear();
    });
    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("API Key removed")));
    }
    _refreshServiceStatus();
  }

  Future<void> _editApiKey() async {
    setState(() {
      _savedApiKey = null;
    });
  }

  Future<void> _testApiKey() async {
    final apiKey = _apiKeyController.text.trim().isNotEmpty
        ? _apiKeyController.text.trim()
        : _savedApiKey ?? '';
    if (apiKey.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("API Key cannot be empty")),
        );
      }
      return;
    }
    final url = Uri.parse(
      "https://generativelanguage.googleapis.com/v1/models?key=$apiKey",
    );
    try {
      final res = await http.get(url);
      if (!mounted) return;
      if (res.statusCode == 200) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("✅ API Key is valid")));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("❌ Invalid API Key (code: ${res.statusCode})"),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("⚠️ Error testing API Key: $e")));
      }
    }
  }

  Future<void> _downloadModel() async {
    setState(() => isModelLoading = true);
    await Future.delayed(const Duration(seconds: 2));
    setState(() {
      modelInfo = {"isDownloaded": true, "sizeFormatted": "24 MB"};
      modelStatus = "Downloaded";
    });
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("✅ Model downloaded successfully")),
      );
    }
    setState(() => isModelLoading = false);
    _refreshServiceStatus();
  }

  Future<void> _checkModelStatus({bool showSnackBar = true}) async {
    setState(() => isCheckingModel = true);
    try {
      await Future.delayed(const Duration(milliseconds: 700));
      bool isDownloaded = modelInfo['isDownloaded'] == true;
      setState(() {
        modelStatus = isDownloaded ? "Downloaded" : "Not Downloaded";
      });
      if (showSnackBar && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isDownloaded
                  ? "✅ Model is already downloaded."
                  : "ℹ️ Model is not downloaded yet.",
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => isCheckingModel = false);
      }
    }
  }

  Future<void> _refreshServiceStatus({bool showSnackBar = true}) async {
    setState(() => isRefreshingStatus = true);
    try {
      await Future.delayed(const Duration(milliseconds: 500));
      final hasKey = _savedApiKey != null && _savedApiKey!.isNotEmpty;
      setState(() {
        serviceStatus = {
          "gemini": {
            "enabled": hasKey,
            "status": hasKey ? "OK" : "Missing API Key",
          },
          "firebaseML": {"isModelLoaded": modelInfo['isDownloaded'] == true},
        };
      });
      if (showSnackBar && mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("🔄 Status refreshed")));
      }
    } finally {
      if (mounted) {
        setState(() => isRefreshingStatus = false);
      }
    }
  }

  Future<void> _launchApiKeyUrl() async {
    final url = Uri.parse("https://aistudio.google.com/app/apikey");
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  Widget _buildSection(
    String title,
    IconData icon,
    Widget child, {
    required Color color,
  }) {
    return Card(
      elevation: 1,
      margin: const EdgeInsets.only(bottom: 20),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: color.withAlpha(30),
                  child: Icon(icon, color: color),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: color,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            child,
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: scheme.surface,
      appBar: AppBar(title: const Text("Settings")),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSection(
            "API Key",
            Icons.vpn_key,
            SettingApiKeySection(
              apiKeyController: _apiKeyController,
              currentApiKey: _savedApiKey,
              hasApiKey: _savedApiKey != null && _savedApiKey!.isNotEmpty,
              saveApiKey: _saveApiKey,
              removeApiKey: _removeApiKey,
              testApiKey: _testApiKey,
              onEdit: _editApiKey,
            ),
            color: scheme.primary,
          ),
          _buildSection(
            "Firebase ML",
            Icons.cloud_download,
            SettingFirebaseMLSection(
              modelInfo: modelInfo,
              modelStatus: modelStatus,
              isModelLoading: isModelLoading,
              isCheckingModel: isCheckingModel,
              downloadModel: _downloadModel,
              checkModelStatus: _checkModelStatus,
            ),
            color: scheme.secondary,
          ),
          _buildSection(
            "Service Status",
            Icons.check_circle,
            SettingServiceStatusSection(
              serviceStatus: serviceStatus,
              refreshStatus: _refreshServiceStatus,
              isRefreshing: isRefreshingStatus,
            ),
            color: scheme.tertiary,
          ),
          _buildSection(
            "Help",
            Icons.help_outline,
            SettingHelpSection(launchApiKeyUrl: _launchApiKeyUrl),
            color: scheme.inversePrimary,
          ),
        ],
      ),
    );
  }
}
