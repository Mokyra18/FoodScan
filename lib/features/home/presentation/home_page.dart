import 'package:flutter/material.dart';
import 'package:foodsnap/core/services/api/gemini_api.service.dart';
import 'package:foodsnap/core/services/image_service.dart';
import 'package:foodsnap/core/utils/ui_utils.dart';
import 'package:foodsnap/features/home/widget/home_api_banner.dart';
import 'package:foodsnap/features/home/widget/home_header.dart';
import 'package:foodsnap/features/home/widget/home_menu.dart';
import 'package:foodsnap/features/home/widget/home_tips.dart';
import 'package:go_router/go_router.dart';


class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with WidgetsBindingObserver {
  bool _isLoading = false;
  bool _hasApiKey = false;

  Future<void> _requestPermissions() async {
    final hasPermissions = await ImageService.requestPermissions();
    if (!hasPermissions) {
      SnackBarUtil.showError(
        context,
        'Camera or photo permissions denied',
        onRetry: _requestPermissions,
      );
    }
  }

  Future<void> _navigateToSettings() async {
    await context.push('/settings');
    _checkApiKeyStatus();
  }

  Future<void> _checkApiKeyStatus() async {
    try {
      final hasApiKey = await ApiKeyService.instance.hasGeminiApiKey();
      if (mounted) {
        setState(() => _hasApiKey = hasApiKey);
      }
    } catch (_) {
      if (mounted) setState(() => _hasApiKey = false);
    }
  }

  Future<void> _captureImage() async {
    if (_isLoading) return;
    setState(() => _isLoading = true);
    try {
      final imagePath = await ImageService.pickImageFromCamera();
      if (imagePath != null && mounted) {
        SnackBarUtil.showSuccess(context, 'Image captured successfully!');
        context.push('/preview', extra: imagePath);
      }
    } catch (e) {
      SnackBarUtil.showError(context, 'Failed to capture: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _selectFromGallery() async {
    if (_isLoading) return;
    setState(() => _isLoading = true);
    try {
      final imagePath = await ImageService.pickImageFromGallery();
      if (imagePath != null && mounted) {
        SnackBarUtil.showSuccess(context, 'Image selected successfully!');
        context.push('/preview', extra: imagePath);
      }
    } catch (e) {
      SnackBarUtil.showError(context, 'Failed to select: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _requestPermissions();
    _checkApiKeyStatus();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _checkApiKeyStatus();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _checkApiKeyStatus,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              HomeHeader(
                onSettingsTap: _navigateToSettings,
                hasApiKey: _hasApiKey,
              ),
              const SizedBox(height: 20),
              if (!_hasApiKey)
                HomeApiBanner(onSettingsTap: _navigateToSettings),
              const SizedBox(height: 20),
              HomeMenu(
                onCapture: _captureImage,
                onGallery: _selectFromGallery,
                isLoading: _isLoading,
              ),
              const SizedBox(height: 20),
              const HomeTips(),
            ],
          ),
        ),
      ),
    );
  }
}
