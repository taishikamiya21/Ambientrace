import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../services/image_labeling_service.dart';
import '../services/llm_service.dart';
import 'onboarding_screen.dart';

class SettingsScreen extends StatefulWidget {
  final ImageLabelingService imageLabelingService;

  const SettingsScreen({super.key, required this.imageLabelingService});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _apiKeyController = TextEditingController();
  bool _isObscured = true;
  bool _isSaving = false;
  String _appVersion = '';
  String _buildNumber = '';

  @override
  void initState() {
    super.initState();
    _loadAppInfo();
  }

  Future<void> _loadAppInfo() async {
    final info = await PackageInfo.fromPlatform();
    if (mounted) {
      setState(() {
        _appVersion = info.version;
        _buildNumber = info.buildNumber;
      });
    }
  }

  @override
  void dispose() {
    _apiKeyController.dispose();
    super.dispose();
  }

  LlmService get _activeService => widget.imageLabelingService.activeLlmService;

  Future<void> _saveApiKey() async {
    if (_apiKeyController.text.trim().isEmpty) return;

    setState(() => _isSaving = true);

    try {
      await _activeService.setApiKey(_apiKeyController.text.trim());
      _apiKeyController.clear();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('API Key saved successfully'),
            backgroundColor: Colors.green,
          ),
        );
        setState(() {});
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  Future<void> _clearApiKey() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A2E),
        title: const Text('Clear API Key?', style: TextStyle(color: Colors.white)),
        content: Text(
          '${_activeService.providerName} API key will be removed. Image labeling will fall back to another provider or ML Kit.',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Clear', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _activeService.clearApiKey();
      setState(() {});
    }
  }

  String _getProviderHint(LlmProvider provider) {
    return switch (provider) {
      LlmProvider.gemini => 'Get a free key at ai.google.dev',
      LlmProvider.openai => 'Get a key at platform.openai.com',
      LlmProvider.claude => 'Get a key at console.anthropic.com',
    };
  }

  String _getProviderDisplayName(LlmProvider provider) {
    return switch (provider) {
      LlmProvider.gemini => 'Gemini',
      LlmProvider.openai => 'ChatGPT',
      LlmProvider.claude => 'Claude',
    };
  }

  @override
  Widget build(BuildContext context) {
    final isConfigured = _activeService.isConfigured;
    final selectedProvider = widget.imageLabelingService.selectedProvider;

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0F),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Settings',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // AI Image Analysis Section
            _buildSectionTitle('AI Image Analysis'),
            const SizedBox(height: 16),

            // Provider Selector
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.1),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'AI Provider',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.7),
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: LlmProvider.values.map((provider) {
                      final isSelected = selectedProvider == provider;
                      final service = switch (provider) {
                        LlmProvider.gemini => widget.imageLabelingService.geminiService,
                        LlmProvider.openai => widget.imageLabelingService.openaiService,
                        LlmProvider.claude => widget.imageLabelingService.claudeService,
                      };
                      final isProviderConfigured = service.isConfigured;

                      return Expanded(
                        child: GestureDetector(
                          onTap: () async {
                            await widget.imageLabelingService.setSelectedProvider(provider);
                            setState(() {});
                          },
                          child: Container(
                            margin: EdgeInsets.only(
                              right: provider != LlmProvider.claude ? 8 : 0,
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? Colors.white.withValues(alpha: 0.12)
                                  : Colors.white.withValues(alpha: 0.03),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isSelected
                                    ? Colors.white.withValues(alpha: 0.3)
                                    : Colors.white.withValues(alpha: 0.08),
                                width: isSelected ? 1.5 : 1,
                              ),
                            ),
                            child: Column(
                              children: [
                                Text(
                                  _getProviderDisplayName(provider),
                                  style: TextStyle(
                                    color: isSelected
                                        ? Colors.white
                                        : Colors.white.withValues(alpha: 0.5),
                                    fontSize: 13,
                                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Icon(
                                  isProviderConfigured ? Icons.check_circle : Icons.circle_outlined,
                                  color: isProviderConfigured
                                      ? Colors.green.withValues(alpha: 0.8)
                                      : Colors.white.withValues(alpha: 0.2),
                                  size: 14,
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // API Key Configuration for selected provider
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.1),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        isConfigured ? Icons.check_circle : Icons.info_outline,
                        color: isConfigured ? Colors.green : Colors.orange,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          isConfigured
                              ? '${_activeService.providerName} API configured'
                              : '${_activeService.providerName} API not configured',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ],
                  ),

                  if (isConfigured) ...[
                    const SizedBox(height: 12),
                    Text(
                      'Key: ${_activeService.maskedApiKey}',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.5),
                        fontSize: 14,
                        fontFamily: 'monospace',
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: _clearApiKey,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.red,
                          side: const BorderSide(color: Colors.red),
                        ),
                        child: const Text('Clear API Key'),
                      ),
                    ),
                  ] else ...[
                    const SizedBox(height: 16),
                    Text(
                      'Add your ${_activeService.providerName} API key to enable AI-powered image labeling. '
                      '${_getProviderHint(selectedProvider)}',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.5),
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _apiKeyController,
                      obscureText: _isObscured,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: 'Enter API Key',
                        hintStyle: TextStyle(
                          color: Colors.white.withValues(alpha: 0.3),
                        ),
                        filled: true,
                        fillColor: Colors.white.withValues(alpha: 0.05),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _isObscured ? Icons.visibility : Icons.visibility_off,
                            color: Colors.white54,
                          ),
                          onPressed: () {
                            setState(() => _isObscured = !_isObscured);
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isSaving ? null : _saveApiKey,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white.withValues(alpha: 0.1),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: _isSaving
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text('Save API Key'),
                      ),
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 32),

            // General Section
            _buildSectionTitle('General'),
            const SizedBox(height: 16),

            Container(
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.1),
                ),
              ),
              child: Column(
                children: [
                  // About
                  _buildListTile(
                    icon: Icons.info_outline,
                    title: 'About',
                    subtitle: _appVersion.isNotEmpty
                        ? 'Version $_appVersion ($_buildNumber)'
                        : 'Loading...',
                    onTap: _showAboutDialog,
                  ),
                  _buildDivider(),
                  // Licenses
                  _buildListTile(
                    icon: Icons.description_outlined,
                    title: 'Open Source Licenses',
                    onTap: () => _showLicenses(context),
                  ),
                  _buildDivider(),
                  // Privacy Policy
                  _buildListTile(
                    icon: Icons.privacy_tip_outlined,
                    title: 'Privacy Policy',
                    onTap: _showPrivacyPolicy,
                  ),
                  _buildDivider(),
                  // View Tutorial
                  _buildListTile(
                    icon: Icons.play_circle_outline,
                    title: 'View Tutorial',
                    subtitle: 'See the introduction again',
                    onTap: _showTutorial,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // App Info
            Center(
              child: Column(
                children: [
                  Text(
                    'Ambientrace',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.3),
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Capture the feeling, not the photo.',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.2),
                      fontSize: 12,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  void _showAboutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A2E),
        title: const Text(
          'Ambientrace',
          style: TextStyle(color: Colors.white),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Capture the ambient trace of your moments - not the photo, just the feeling.',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.7),
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Version $_appVersion (Build $_buildNumber)',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.5),
                fontSize: 12,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showTutorial() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => OnboardingScreen(
          onComplete: () => Navigator.pop(context),
          showSplashFirst: false,
        ),
      ),
    );
  }

  void _showLicenses(BuildContext context) {
    showLicensePage(
      context: context,
      applicationName: 'Ambientrace',
      applicationVersion: _appVersion,
      applicationLegalese: '© 2026 Ambientrace',
    );
  }

  void _showPrivacyPolicy() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const PrivacyPolicyScreen(),
      ),
    );
  }

  Widget _buildListTile({
    required IconData icon,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: Colors.white.withValues(alpha: 0.6),
        size: 22,
      ),
      title: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
        ),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.4),
                fontSize: 12,
              ),
            )
          : null,
      trailing: Icon(
        Icons.chevron_right,
        color: Colors.white.withValues(alpha: 0.3),
      ),
      onTap: onTap,
    );
  }

  Widget _buildDivider() {
    return Divider(
      height: 1,
      indent: 56,
      color: Colors.white.withValues(alpha: 0.1),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title.toUpperCase(),
      style: TextStyle(
        color: Colors.white.withValues(alpha: 0.4),
        fontSize: 12,
        fontWeight: FontWeight.w600,
        letterSpacing: 2,
      ),
    );
  }
}

/// Privacy Policy Screen
class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0F),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Privacy Policy',
          style: TextStyle(color: Colors.white, fontSize: 18),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSection(
              'Overview',
              'Ambientrace is designed with privacy as a core principle. '
              'Unlike traditional photo apps, Ambientrace intentionally does not store your photos. '
              'Instead, it extracts environmental data (the "ambient trace") from your images and then permanently deletes the original photo.',
            ),
            _buildSection(
              'Data We Collect',
              '• Color palette — The dominant colors in the image\n'
              '• Ambient labels — Descriptive tags about the atmosphere\n'
              '• Noise level — The ambient sound level (if microphone permission is granted)\n'
              '• Location — GPS coordinates and place name (if location permission is granted)\n'
              '• Weather — Temperature and weather condition',
            ),
            _buildSection(
              'Data We Do NOT Collect',
              '• Photos — Images are processed locally and immediately deleted\n'
              '• Personal information — No names, emails, or account information\n'
              '• Usage analytics — No tracking or analytics services\n'
              '• Advertising data — No ad networks or identifiers',
            ),
            _buildSection(
              'Third-Party Services',
              '• Google ML Kit — On-device image labeling (no data sent to servers)\n'
              '• Gemini API (Optional) — Enhanced labeling if you provide an API key\n'
              '• OpenAI API (Optional) — Alternative AI labeling provider\n'
              '• Anthropic API (Optional) — Alternative AI labeling provider\n'
              '• Open-Meteo — Weather data (only GPS coordinates sent)',
            ),
            _buildSection(
              'Data Storage',
              'All ambient trace data is stored locally on your device only:\n'
              '• Data is saved in the app\'s private storage\n'
              '• No cloud sync or backup to external servers\n'
              '• Deleting the app removes all data',
            ),
            _buildSection(
              'Your Rights',
              '• Delete individual traces using the delete button\n'
              '• Delete all data by uninstalling the app\n'
              '• Deny permissions — The app works with limited functionality',
            ),
            _buildSection(
              'Contact',
              'For questions about this Privacy Policy:\n'
              'GitHub: github.com/taishikamiya21/Ambientrace',
            ),
            const SizedBox(height: 16),
            Center(
              child: Text(
                'Last Updated: February 7, 2026',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.3),
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            content,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.7),
              fontSize: 14,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}
