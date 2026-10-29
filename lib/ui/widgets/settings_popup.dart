import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../services/app_settings.dart';
import '../l10n/app_strings.dart';
import '../theme/app_theme.dart';

class SettingsPopup {
  SettingsPopup._();

  static Future<void> show(BuildContext context) {
    return showDialog<void>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.45),
      builder: (context) => const _SettingsDialog(),
    );
  }
}

class _SettingsDialog extends StatelessWidget {
  const _SettingsDialog();

  @override
  Widget build(BuildContext context) {
    final settings = AppSettingsScope.of(context);

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
      child: AnimatedBuilder(
        animation: settings,
        builder: (context, _) {
          final strings = AppStrings(settings);
          return ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 360),
            child: Material(
              color: Colors.white,
              borderRadius: BorderRadius.circular(28),
              elevation: 12,
              shadowColor: Colors.black26,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 22),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          Text(
                            strings.settingsTitle,
                            style: const TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.w900,
                              color: AppColors.navy,
                            ),
                          ),
                          Align(
                            alignment: Alignment.centerRight,
                            child: _RoundIconButton(
                              icon: Icons.close_rounded,
                              onTap: () => Navigator.of(context).pop(),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),
                      _ProfileRow(settings: settings, strings: strings),
                      const SizedBox(height: 18),
                      Row(
                        children: [
                          Expanded(
                            child: _ToggleTile(
                              icon: settings.soundEnabled
                                  ? Icons.volume_up_rounded
                                  : Icons.volume_off_rounded,
                              active: settings.soundEnabled,
                              onTap: () => settings.setSoundEnabled(
                                !settings.soundEnabled,
                              ),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: _ToggleTile(
                              icon: settings.hapticsEnabled
                                  ? Icons.vibration_rounded
                                  : Icons.phone_iphone_rounded,
                              active: settings.hapticsEnabled,
                              onTap: () => settings.setHapticsEnabled(
                                !settings.hapticsEnabled,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _MenuRow(
                        icon: Icons.translate_rounded,
                        label: strings.language,
                        onTap: () => _pickLanguage(context, settings, strings),
                      ),
                      const SizedBox(height: 10),
                      _MenuRow(
                        icon: Icons.mail_outline_rounded,
                        label: strings.contactUs,
                        onTap: () => _contact(context, strings),
                      ),
                      const SizedBox(height: 10),
                      _MenuRow(
                        icon: Icons.info_outline_rounded,
                        label: strings.aboutUs,
                        onTap: () => _about(context, strings),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _pickLanguage(
    BuildContext context,
    AppSettings settings,
    AppStrings strings,
  ) async {
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  strings.language,
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 18,
                    color: AppColors.navy,
                  ),
                ),
                const SizedBox(height: 12),
                ListTile(
                  title: Text(strings.english),
                  trailing: settings.localeCode == 'en'
                      ? const Icon(Icons.check_rounded, color: AppColors.cyan)
                      : null,
                  onTap: () async {
                    await settings.setLocaleCode('en');
                    if (context.mounted) Navigator.pop(context);
                  },
                ),
                ListTile(
                  title: Text(strings.urdu),
                  trailing: settings.localeCode == 'ur'
                      ? const Icon(Icons.check_rounded, color: AppColors.cyan)
                      : null,
                  onTap: () async {
                    await settings.setLocaleCode('ur');
                    if (context.mounted) Navigator.pop(context);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _contact(BuildContext context, AppStrings strings) async {
    final uri = Uri(
      scheme: 'mailto',
      path: 'support@arrowescape.app',
      queryParameters: {'subject': strings.contactSubject},
    );
    try {
      final ok = await launchUrl(uri);
      if (!ok && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${strings.contactUs}: support@arrowescape.app')),
        );
      }
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${strings.contactUs}: support@arrowescape.app')),
        );
      }
    }
  }

  Future<void> _about(BuildContext context, AppStrings strings) async {
    await showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(
            strings.aboutUs,
            style: const TextStyle(
              fontWeight: FontWeight.w800,
              color: AppColors.navy,
            ),
          ),
          content: Text(
            '${strings.aboutBody}\n\n${strings.version} 1.0.0',
            style: const TextStyle(color: AppColors.ink, height: 1.4),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(strings.close),
            ),
          ],
        );
      },
    );
  }
}

class _ProfileRow extends StatelessWidget {
  const _ProfileRow({required this.settings, required this.strings});

  final AppSettings settings;
  final AppStrings strings;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        GestureDetector(
          onTap: () => _pickAvatar(context),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: const Color(0xFFD6EBFF),
                child: Text(
                  settings.avatarEmoji,
                  style: const TextStyle(fontSize: 28),
                ),
              ),
              Positioned(
                right: -2,
                bottom: -2,
                child: Container(
                  width: 24,
                  height: 24,
                  decoration: const BoxDecoration(
                    color: AppColors.cyan,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.edit_rounded, size: 14, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: GestureDetector(
            onTap: () => _editName(context),
            child: Container(
              height: 48,
              padding: const EdgeInsets.symmetric(horizontal: 14),
              alignment: Alignment.centerLeft,
              decoration: BoxDecoration(
                color: const Color(0xFFE8F4FF),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Text(
                settings.playerName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 16,
                  color: AppColors.navy,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        _SquareButton(
          icon: Icons.casino_rounded,
          onTap: () => settings.randomizeName(),
        ),
      ],
    );
  }

  Future<void> _editName(BuildContext context) async {
    final controller = TextEditingController(text: settings.playerName);
    final result = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(strings.editName),
          content: TextField(
            controller: controller,
            autofocus: true,
            maxLength: 16,
            decoration: InputDecoration(hintText: strings.nameHint),
            textInputAction: TextInputAction.done,
            onSubmitted: (v) => Navigator.pop(context, v),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(strings.cancel),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, controller.text),
              child: Text(strings.save),
            ),
          ],
        );
      },
    );
    if (result != null) await settings.setPlayerName(result);
  }

  Future<void> _pickAvatar(BuildContext context) async {
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  strings.chooseAvatar,
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 18,
                    color: AppColors.navy,
                  ),
                ),
                const SizedBox(height: 14),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: List.generate(AppSettings.avatarChoices.length, (i) {
                    final selected = i == settings.avatarIndex;
                    return InkWell(
                      onTap: () async {
                        await settings.setAvatarIndex(i);
                        if (context.mounted) Navigator.pop(context);
                      },
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        width: 56,
                        height: 56,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: const Color(0xFFE8F4FF),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: selected ? AppColors.cyan : AppColors.cellLine,
                            width: selected ? 2.5 : 1,
                          ),
                        ),
                        child: Text(
                          AppSettings.avatarChoices[i],
                          style: const TextStyle(fontSize: 28),
                        ),
                      ),
                    );
                  }),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _ToggleTile extends StatelessWidget {
  const _ToggleTile({
    required this.icon,
    required this.active,
    required this.onTap,
  });

  final IconData icon;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Ink(
          height: 72,
          decoration: BoxDecoration(
            color: active ? AppColors.cyan : const Color(0xFFB0BEC5),
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: (active ? AppColors.cyan : Colors.black)
                    .withValues(alpha: 0.2),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Icon(icon, color: Colors.white, size: 34),
        ),
      ),
    );
  }
}

class _MenuRow extends StatelessWidget {
  const _MenuRow({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Ink(
          height: 56,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.cellLine),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.cyan,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                    color: AppColors.navy,
                  ),
                ),
              ),
              const Icon(Icons.chevron_right_rounded, color: AppColors.navy),
            ],
          ),
        ),
      ),
    );
  }
}

class _SquareButton extends StatelessWidget {
  const _SquareButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Ink(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: AppColors.cyan,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(icon, color: Colors.white, size: 26),
        ),
      ),
    );
  }
}

class _RoundIconButton extends StatelessWidget {
  const _RoundIconButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: Ink(
          width: 36,
          height: 36,
          decoration: const BoxDecoration(
            color: Color(0xFFE8F4FF),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: AppColors.navy, size: 20),
        ),
      ),
    );
  }
}
