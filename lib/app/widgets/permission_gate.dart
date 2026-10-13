import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:yogo_pos/app/services/base/permission_service.dart';
import 'package:yogo_pos/app/utils/static_colors.dart';

class PermissionGate extends StatefulWidget {
  final Widget child;

  const PermissionGate({super.key, required this.child});

  @override
  State<PermissionGate> createState() => _PermissionGateState();
}

class _PermissionGateState extends State<PermissionGate>
    with WidgetsBindingObserver {
  List<AppPermissionStatus>? _statuses; // null = still checking
  bool _needsSettings = false;
  bool _busy = false;

  bool get _allRequiredGranted =>
      _statuses != null &&
      _statuses!.every((s) => s.granted || !s.item.isRequired);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _check();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Coming back from the system settings screen.
    if (state == AppLifecycleState.resumed && !_allRequiredGranted) _check();
  }

  Future<void> _check() async {
    final statuses = await PermissionService.statuses();
    final needsSettings = await PermissionService.needsAppSettings();
    if (!mounted) return;
    setState(() {
      _statuses = statuses;
      _needsSettings = needsSettings;
    });
  }

  Future<void> _requestAll() async {
    if (_busy) return;
    setState(() => _busy = true);
    await PermissionService.request();
    if (!mounted) return;
    setState(() => _busy = false);
    await _check();
  }

  Future<void> _requestOne(AppPermission item) async {
    if (_busy) return;
    setState(() => _busy = true);
    await PermissionService.requestOne(item);
    if (!mounted) return;
    setState(() => _busy = false);
    await _check();
  }

  @override
  Widget build(BuildContext context) {
    if (_allRequiredGranted) return widget.child;

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final statuses = _statuses;

    return Directionality(
      textDirection: TextDirection.ltr,
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        body: SafeArea(
          child: statuses == null
              ? const Center(child: CircularProgressIndicator())
              : Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 32,
                    ),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 560),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _header(theme, isDark),
                          const SizedBox(height: 28),
                          for (final status in statuses) ...[
                            _PermissionTile(
                              status: status,
                              busy: _busy,
                              onAllow: () => _requestOne(status.item),
                            ),
                            const SizedBox(height: 12),
                          ],
                          const SizedBox(height: 12),
                          _primaryButton(),
                          const SizedBox(height: 10),
                          TextButton(
                            onPressed: _busy ? null : _check,
                            child: Text(
                              'Check again',
                              style: theme.textTheme.labelLarge?.copyWith(
                                color: theme.hintColor,
                              ),
                            ),
                          ),
                          if (_needsSettings) ...[
                            const SizedBox(height: 4),
                            Text(
                              'Settings → Apps → YOGO POS → Permissions',
                              textAlign: TextAlign.center,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.hintColor,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
        ),
      ),
    );
  }

  Widget _header(ThemeData theme, bool isDark) {
    return Column(
      children: [
        SvgPicture.asset(
          'assets/images/splash/yogo_logo.svg',
          width: 130,
          colorFilter: ColorFilter.mode(
            isDark ? Colors.white : Colors.black,
            BlendMode.srcIn,
          ),
        ),
        const SizedBox(height: 28),
        Text(
          'Before you start',
          textAlign: TextAlign.center,
          style: theme.textTheme.headlineSmall,
        ),
        const SizedBox(height: 8),
        Text(
          _needsSettings
              ? 'These were turned off. Open app settings to allow them, then '
                    'come back to this screen.'
              : 'This app needs the access below to reach your printers '
                    'and devices on the network.',
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyMedium?.copyWith(color: theme.hintColor),
        ),
      ],
    );
  }

  Widget _primaryButton() {
    final label = _busy
        ? 'Please wait…'
        : _needsSettings
        ? 'Open app settings'
        : 'Allow all';

    return SizedBox(
      height: 54,
      child: ElevatedButton(
        onPressed: _busy
            ? null
            : () => _needsSettings
                  ? PermissionService.openSettings()
                  : _requestAll(),
        style: ElevatedButton.styleFrom(
          backgroundColor: StaticColors.blueColor,
          foregroundColor: Colors.white,
          disabledBackgroundColor: StaticColors.blueColor.withAlpha(120),
          disabledForegroundColor: Colors.white70,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: Text(
          label,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}

class _PermissionTile extends StatelessWidget {
  final AppPermissionStatus status;
  final bool busy;
  final VoidCallback onAllow;

  const _PermissionTile({
    required this.status,
    required this.busy,
    required this.onAllow,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final granted = status.granted;
    final accent = granted ? StaticColors.greenColor : StaticColors.blueColor;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: granted
              ? accent.withAlpha(90)
              : theme.dividerColor.withAlpha(90),
        ),
        color: granted ? accent.withAlpha(20) : Colors.transparent,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: accent.withAlpha(32),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              granted ? Icons.check_rounded : status.item.icon,
              color: accent,
              size: 22,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        status.item.label,
                        style: theme.textTheme.titleSmall,
                      ),
                    ),
                    const SizedBox(width: 8),
                    if (!status.item.isRequired)
                      _chip(theme, 'Optional', theme.hintColor),
                    if (status.permanentlyDenied && !granted)
                      _chip(theme, 'Blocked', StaticColors.redColor),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  status.item.reason,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.hintColor,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          if (granted)
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Text(
                'Allowed',
                style: theme.textTheme.labelSmall?.copyWith(color: accent),
              ),
            )
          else
            TextButton(
              onPressed: busy ? null : onAllow,
              style: TextButton.styleFrom(
                foregroundColor: StaticColors.blueColor,
                padding: const EdgeInsets.symmetric(horizontal: 12),
              ),
              child: Text(status.permanentlyDenied ? 'Settings' : 'Allow'),
            ),
        ],
      ),
    );
  }

  Widget _chip(ThemeData theme, String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withAlpha(30),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: theme.textTheme.labelSmall?.copyWith(color: color),
      ),
    );
  }
}
