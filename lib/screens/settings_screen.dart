import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../services/image_labeling_service.dart';
import '../services/llm_service.dart';
import '../services/storage_service.dart';
import '../services/theme_service.dart';
import '../theme/app_theme.dart';
import 'data_management_screen.dart';
import 'folder_management_screen.dart';
import 'onboarding_screen.dart';

class SettingsScreen extends StatefulWidget {
  final StorageService storageService;
  final ImageLabelingService imageLabelingService;

  const SettingsScreen({
    super.key,
    required this.storageService,
    required this.imageLabelingService,
  });

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
          SnackBar(
            content: Text('API Key saved successfully'),
            backgroundColor: AppColors.success.withValues(alpha: 0.9),
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

  bool get _isJapanese => ui.PlatformDispatcher.instance.locale.languageCode == 'ja';

  Future<void> _clearApiKey() async {
    final isJa = _isJapanese;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: context.canvasSecondaryColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.surface),
        ),
        title: Text(
          isJa ? 'APIキーを削除しますか？' : 'Clear API Key?',
          style: AppTypography.subtitle(
              color: context.onCanvasColor, opacity: AppOpacity.textHero),
        ),
        content: Text(
          isJa
              ? '${_activeService.providerName}のAPIキーが削除されます。画像ラベリングは他のプロバイダーまたはML Kitにフォールバックします。'
              : '${_activeService.providerName} API key will be removed. Image labeling will fall back to another provider or ML Kit.',
          style: AppTypography.body(
              color: context.onCanvasColor, opacity: AppOpacity.textBody),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              isJa ? 'キャンセル' : 'Cancel',
              style: AppTypography.label(
                  color: context.onCanvasColor,
                  opacity: AppOpacity.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              isJa ? '削除' : 'Clear',
              style: AppTypography.label().copyWith(color: AppColors.error),
            ),
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
    if (_isJapanese) {
      return switch (provider) {
        LlmProvider.gemini => '無料キーはai.google.devで取得できます',
        LlmProvider.openai => 'キーはplatform.openai.comで取得できます',
        LlmProvider.claude => 'キーはconsole.anthropic.comで取得できます',
      };
    }
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
    final tc = context.onCanvasColor;

    return Scaffold(
      backgroundColor: context.canvasColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back,
              color: tc.withValues(alpha: AppOpacity.textHigh)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          _isJapanese ? '設定' : 'Settings',
          style: AppTypography.subtitle(
              color: tc, opacity: AppOpacity.textHigh),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── 外観セクション ──────────────────────────
            _buildSectionTitle(_isJapanese ? '外観' : 'Appearance'),
            const SizedBox(height: AppSpacing.md),
            _buildAppearanceSection(),
            const SizedBox(height: AppSpacing.xxl),

            // AI Image Analysis Section
            _buildSectionTitle(_isJapanese ? 'AI画像解析' : 'AI Image Analysis'),
            const SizedBox(height: AppSpacing.md),

            // Provider Selector
            Container(
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                color: tc.withValues(alpha: AppOpacity.surfaceSubtle),
                borderRadius: BorderRadius.circular(AppRadius.container),
                border: Border.all(
                  color: tc.withValues(alpha: AppOpacity.borderSubtle),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _isJapanese ? 'AIプロバイダー' : 'AI Provider',
                    style: AppTypography.label(
                        color: tc, opacity: AppOpacity.textBody),
                  ),
                  const SizedBox(height: AppSpacing.sm),
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
                              right: provider != LlmProvider.claude ? AppSpacing.xs : 0,
                            ),
                            padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? tc.withValues(alpha: AppOpacity.surfaceElevated)
                                  : tc.withValues(alpha: AppOpacity.surfaceFaint),
                              borderRadius: BorderRadius.circular(AppRadius.container),
                              border: Border.all(
                                color: isSelected
                                    ? tc.withValues(alpha: AppOpacity.borderStrong)
                                    : tc.withValues(alpha: AppOpacity.borderSubtle),
                                width: isSelected ? 1.5 : 1,
                              ),
                            ),
                            child: Column(
                              children: [
                                Text(
                                  _getProviderDisplayName(provider),
                                  style: isSelected
                                      ? AppTypography.label(
                                          color: tc,
                                          opacity: AppOpacity.textHero)
                                      : AppTypography.label(
                                          color: tc,
                                          opacity: AppOpacity.textTertiary),
                                ),
                                const SizedBox(height: AppSpacing.xxs),
                                Icon(
                                  isProviderConfigured ? Icons.check_circle : Icons.circle_outlined,
                                  color: isProviderConfigured
                                      ? AppColors.success.withValues(alpha: 0.8)
                                      : tc.withValues(alpha: AppOpacity.textGhost),
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

            const SizedBox(height: AppSpacing.sm),

            // API Key Configuration for selected provider
            Container(
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                color: tc.withValues(alpha: AppOpacity.surfaceSubtle),
                borderRadius: BorderRadius.circular(AppRadius.container),
                border: Border.all(
                  color: tc.withValues(alpha: AppOpacity.borderSubtle),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        isConfigured ? Icons.check_circle : Icons.info_outline,
                        color: isConfigured ? AppColors.success : AppColors.warning,
                        size: 20,
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Text(
                          isConfigured
                              ? (_isJapanese
                                  ? '${_activeService.providerName} API設定済み'
                                  : '${_activeService.providerName} API configured')
                              : (_isJapanese
                                  ? '${_activeService.providerName} API未設定'
                                  : '${_activeService.providerName} API not configured'),
                          style: AppTypography.body(
                              color: tc, opacity: AppOpacity.textHigh),
                        ),
                      ),
                    ],
                  ),

                  if (isConfigured) ...[
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      'Key: ${_activeService.maskedApiKey}',
                      style: AppTypography.mono(
                          color: tc, opacity: AppOpacity.textTertiary),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    // Clear API key — pill button
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: _clearApiKey,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.error,
                          side: BorderSide(color: AppColors.error),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppRadius.pill),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: Text(
                          _isJapanese ? 'APIキーを削除' : 'Clear API Key',
                          style: AppTypography.label().copyWith(color: AppColors.error),
                        ),
                      ),
                    ),
                  ] else ...[
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      _isJapanese
                          ? '${_activeService.providerName}のAPIキーを追加してAI画像ラベリングを有効にしましょう。${_getProviderHint(selectedProvider)}'
                          : 'Add your ${_activeService.providerName} API key to enable AI-powered image labeling. '
                            '${_getProviderHint(selectedProvider)}',
                      style: AppTypography.body(
                          color: tc, opacity: AppOpacity.textTertiary),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    TextField(
                      controller: _apiKeyController,
                      obscureText: _isObscured,
                      style: AppTypography.body(
                          color: tc, opacity: AppOpacity.textHigh),
                      decoration: InputDecoration(
                        hintText: _isJapanese ? 'APIキーを入力' : 'Enter API Key',
                        hintStyle: AppTypography.body(
                            color: tc, opacity: AppOpacity.textMuted),
                        filled: true,
                        fillColor: tc.withValues(alpha: AppOpacity.surfaceSubtle),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppRadius.container),
                          borderSide: BorderSide.none,
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _isObscured ? Icons.visibility : Icons.visibility_off,
                            color: tc.withValues(alpha: AppOpacity.textTertiary),
                          ),
                          onPressed: () {
                            setState(() => _isObscured = !_isObscured);
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    // Save button — pill shape
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isSaving ? null : _saveApiKey,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: tc.withValues(alpha: AppOpacity.surfaceElevated),
                          foregroundColor: tc,
                          padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppRadius.pill),
                            side: BorderSide(
                              color: tc.withValues(alpha: AppOpacity.borderDefault),
                            ),
                          ),
                        ),
                        child: _isSaving
                            ? SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: tc.withValues(alpha: AppOpacity.textHigh),
                                ),
                              )
                            : Text(
                                _isJapanese ? 'APIキーを保存' : 'Save API Key',
                                style: AppTypography.label(
                                    color: tc, opacity: AppOpacity.textHigh),
                              ),
                      ),
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: AppSpacing.xxl),

            // General Section
            _buildSectionTitle(_isJapanese ? '一般' : 'General'),
            const SizedBox(height: AppSpacing.md),

            Container(
              decoration: BoxDecoration(
                color: tc.withValues(alpha: AppOpacity.surfaceSubtle),
                borderRadius: BorderRadius.circular(AppRadius.container),
                border: Border.all(
                  color: tc.withValues(alpha: AppOpacity.borderSubtle),
                ),
              ),
              child: Column(
                children: [
                  // Folder Management
                  _buildListTile(
                    icon: Icons.folder_outlined,
                    title: _isJapanese ? 'フォルダ管理' : 'Folder Management',
                    subtitle: _isJapanese
                        ? 'フォルダを作成・名前変更・削除'
                        : 'Create, rename, and delete folders',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => FolderManagementScreen(
                          folderService:
                              widget.storageService.folderService,
                        ),
                      ),
                    ),
                  ),
                  _buildDivider(),
                  _buildListTile(
                    icon: Icons.storage_outlined,
                    title: _isJapanese ? 'データ管理' : 'Data Management',
                    subtitle: _isJapanese
                        ? 'JSON/CSVの書き出しとJSONの読み込み'
                        : 'Export JSON/CSV and import JSON',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => DataManagementScreen(
                          storageService: widget.storageService,
                        ),
                      ),
                    ),
                  ),
                  _buildDivider(),
                  // About
                  _buildListTile(
                    icon: Icons.info_outline,
                    title: _isJapanese ? 'アプリについて' : 'About',
                    subtitle: _appVersion.isNotEmpty
                        ? (_isJapanese ? 'バージョン $_appVersion ($_buildNumber)' : 'Version $_appVersion ($_buildNumber)')
                        : (_isJapanese ? '読み込み中...' : 'Loading...'),
                    onTap: _showAboutDialog,
                  ),
                  _buildDivider(),
                  // Licenses
                  _buildListTile(
                    icon: Icons.description_outlined,
                    title: _isJapanese ? 'オープンソースライセンス' : 'Open Source Licenses',
                    onTap: () => _showLicenses(context),
                  ),
                  _buildDivider(),
                  // Privacy Policy
                  _buildListTile(
                    icon: Icons.privacy_tip_outlined,
                    title: _isJapanese ? 'プライバシーポリシー' : 'Privacy Policy',
                    onTap: _showPrivacyPolicy,
                  ),
                  _buildDivider(),
                  // View Tutorial
                  _buildListTile(
                    icon: Icons.play_circle_outline,
                    title: _isJapanese ? 'チュートリアルを見る' : 'View Tutorial',
                    subtitle: _isJapanese ? 'イントロダクションをもう一度見る' : 'See the introduction again',
                    onTap: _showTutorial,
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppSpacing.xxl),

            // App Info
            Center(
              child: Column(
                children: [
                  Text(
                    'AMBIENTRACE',
                    style: AppTypography.section(
                        color: tc, opacity: AppOpacity.textMuted),
                  ),
                  const SizedBox(height: AppSpacing.xxs),
                  Text(
                    _isJapanese ? '写真ではなく、感覚を記録する。' : 'Capture the feeling, not the photo.',
                    style: AppTypography.mono(color: tc, opacity: AppOpacity.textGhost)
                        .copyWith(fontStyle: FontStyle.italic),
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppSpacing.xl),
          ],
        ),
      ),
    );
  }

  Widget _buildAppearanceSection() {
    final tc = context.onCanvasColor;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: tc.withValues(alpha: AppOpacity.surfaceSubtle),
        borderRadius: BorderRadius.circular(AppRadius.container),
        border: Border.all(
          color: tc.withValues(alpha: AppOpacity.borderSubtle),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _isJapanese ? 'テーマ' : 'Theme',
            style: AppTypography.label(
                color: tc, opacity: AppOpacity.textBody),
          ),
          const SizedBox(height: AppSpacing.sm),
          ValueListenableBuilder<ThemeMode>(
            valueListenable: ThemeService.instance.themeNotifier,
            builder: (context, currentMode, _) {
              return Row(
                children: [
                  _buildThemeOption(
                    label: _isJapanese ? 'ダーク' : 'Dark',
                    icon: Icons.dark_mode_outlined,
                    mode: ThemeMode.dark,
                    currentMode: currentMode,
                    tc: tc,
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  _buildThemeOption(
                    label: _isJapanese ? 'ライト' : 'Light',
                    icon: Icons.light_mode_outlined,
                    mode: ThemeMode.light,
                    currentMode: currentMode,
                    tc: tc,
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  _buildThemeOption(
                    label: _isJapanese ? '自動' : 'System',
                    icon: Icons.brightness_auto_outlined,
                    mode: ThemeMode.system,
                    currentMode: currentMode,
                    tc: tc,
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildThemeOption({
    required String label,
    required IconData icon,
    required ThemeMode mode,
    required ThemeMode currentMode,
    required Color tc,
  }) {
    final isSelected = currentMode == mode;
    return Expanded(
      child: GestureDetector(
        onTap: () => ThemeService.instance.setMode(mode),
        child: Container(
          padding: const EdgeInsets.symmetric(
              vertical: AppSpacing.sm, horizontal: AppSpacing.xs),
          decoration: BoxDecoration(
            color: isSelected
                ? tc.withValues(alpha: AppOpacity.surfaceElevated)
                : tc.withValues(alpha: AppOpacity.surfaceFaint),
            borderRadius: BorderRadius.circular(AppRadius.container),
            border: Border.all(
              color: isSelected
                  ? tc.withValues(alpha: AppOpacity.borderStrong)
                  : tc.withValues(alpha: AppOpacity.borderSubtle),
              width: isSelected ? 1.5 : 1,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                color: tc.withValues(
                    alpha: isSelected
                        ? AppOpacity.textHigh
                        : AppOpacity.textTertiary),
                size: 20,
              ),
              const SizedBox(height: AppSpacing.xxs),
              Text(
                label,
                style: AppTypography.mono(
                  color: tc,
                  opacity: isSelected
                      ? AppOpacity.textHigh
                      : AppOpacity.textTertiary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAboutDialog() {
    final isJa = _isJapanese;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: context.canvasSecondaryColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.surface),
        ),
        title: Text(
          'Ambientrace',
          style: AppTypography.title(
              color: context.onCanvasColor, opacity: AppOpacity.textHero),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isJa
                  ? '写真ではなく、その瞬間の雰囲気を記録するアプリです。'
                  : 'Capture the ambient trace of your moments - not the photo, just the feeling.',
              style: AppTypography.body(
                  color: context.onCanvasColor, opacity: AppOpacity.textBody),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              isJa
                  ? 'バージョン $_appVersion (ビルド $_buildNumber)'
                  : 'Version $_appVersion (Build $_buildNumber)',
              style: AppTypography.mono(
                  color: context.onCanvasColor, opacity: AppOpacity.textTertiary),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'OK',
              style: AppTypography.label(
                  color: context.onCanvasColor, opacity: AppOpacity.textHigh),
            ),
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
    final tc = context.onCanvasColor;
    return ListTile(
      leading: Icon(
        icon,
        color: tc.withValues(alpha: AppOpacity.textSecondary),
        size: 22,
      ),
      title: Text(
        title,
        style: AppTypography.body(color: tc, opacity: AppOpacity.textHigh),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle,
              style: AppTypography.mono(
                  color: tc, opacity: AppOpacity.textCaption),
            )
          : null,
      trailing: Icon(
        Icons.chevron_right,
        color: tc.withValues(alpha: AppOpacity.textMuted),
      ),
      onTap: onTap,
    );
  }

  Widget _buildDivider() {
    final tc = context.onCanvasColor;
    return Divider(
      height: 1,
      indent: 56,
      color: tc.withValues(alpha: AppOpacity.borderSubtle),
    );
  }

  Widget _buildSectionTitle(String title) {
    final tc = context.onCanvasColor;
    return Text(
      title.toUpperCase(),
      style: AppTypography.section(color: tc),
    );
  }
}

/// Privacy Policy Screen
class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final tc = context.onCanvasColor;
    return Scaffold(
      backgroundColor: context.canvasColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back,
              color: tc.withValues(alpha: AppOpacity.textHigh)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          ui.PlatformDispatcher.instance.locale.languageCode == 'ja' ? 'プライバシーポリシー' : 'Privacy Policy',
          style: AppTypography.subtitle(
              color: tc, opacity: AppOpacity.textHigh),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSection(
              context,
              'Overview',
              'Ambientrace is designed with privacy as a core principle. '
              'Unlike traditional photo apps, Ambientrace intentionally does not store your photos. '
              'Instead, it extracts environmental data (the "ambient trace") from your images and then permanently deletes the original photo.',
            ),
            _buildSection(
              context,
              'Data We Collect',
              '• Color palette — The dominant colors in the image\n'
              '• Ambient labels — Descriptive tags about the atmosphere\n'
              '• Noise level — The ambient sound level (if microphone permission is granted)\n'
              '• Location — GPS coordinates and place name (if location permission is granted)\n'
              '• Weather — Temperature and weather condition',
            ),
            _buildSection(
              context,
              'Data We Do NOT Collect',
              '• Photos — Images are processed locally and immediately deleted\n'
              '• Personal information — No names, emails, or account information\n'
              '• Usage analytics — No tracking or analytics services\n'
              '• Advertising data — No ad networks or identifiers',
            ),
            _buildSection(
              context,
              'Third-Party Services',
              '• Google ML Kit — On-device image labeling (no data sent to servers)\n'
              '• Gemini API (Optional) — Enhanced labeling if you provide an API key\n'
              '• OpenAI API (Optional) — Alternative AI labeling provider\n'
              '• Anthropic API (Optional) — Alternative AI labeling provider\n'
              '• Open-Meteo — Weather data (only GPS coordinates sent)',
            ),
            _buildSection(
              context,
              'Data Storage',
              'All ambient trace data is stored locally on your device only:\n'
              '• Data is saved in the app\'s private storage\n'
              '• No cloud sync or backup to external servers\n'
              '• Deleting the app removes all data',
            ),
            _buildSection(
              context,
              'Your Rights',
              '• Delete individual traces using the delete button\n'
              '• Delete all data by uninstalling the app\n'
              '• Deny permissions — The app works with limited functionality',
            ),
            _buildSection(
              context,
              'Contact',
              'For questions about this Privacy Policy:\n'
              'GitHub: github.com/taishikamiya21/Ambientrace',
            ),
            const SizedBox(height: AppSpacing.md),
            Center(
              child: Text(
                'Last Updated: February 7, 2026',
                style: AppTypography.mono(
                    color: tc, opacity: AppOpacity.textMuted),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(BuildContext context, String title, String content) {
    final tc = context.onCanvasColor;
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title.toUpperCase(),
            style: AppTypography.section(
                color: tc, opacity: AppOpacity.textHigh),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            content,
            style: AppTypography.body(color: tc, opacity: AppOpacity.textBody),
          ),
        ],
      ),
    );
  }
}
