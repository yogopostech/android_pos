import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:yogo_pos/app/services/controller/config_controller.dart';
import 'package:yogo_pos/app/utils/static_colors.dart';

// ====================================================================
// SWITCH-STYLE THEME TOGGLE - Compact with Sun/Moon Icons
// Looks like a traditional switch but with better design
// ====================================================================

/// Option 1: Classic Switch Style with Icons (Recommended) ⭐
class SwitchStyleThemeToggle extends StatelessWidget {
  const SwitchStyleThemeToggle({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ConfigController>(
      builder: (controller) => GestureDetector(
        onTap: () {
          controller.toggleTheme();
          controller.update();
        },
        child: AnimatedContainer(
          duration: Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          width: 50,
          height: 30,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            gradient: LinearGradient(
              colors: controller.isLightTheme
                  ? [
                      Theme.of(context).cardColor.withAlpha(200),
                      Theme.of(context).cardColor
                    ]
                  : [
                      StaticColors.cartColor.withAlpha(200),
                      StaticColors.cartColor
                    ],
            ),
            boxShadow: [
              BoxShadow(
                color: controller.isLightTheme
                    ? Theme.of(context).cardColor.withAlpha(100)
                    : StaticColors.cartColor.withAlpha(100),
                blurRadius: 8,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Stack(
            children: [
              // Background icons
              Positioned(
                left: 6,
                top: 7,
                child: AnimatedOpacity(
                  duration: Duration(milliseconds: 200),
                  opacity: controller.isLightTheme ? 0.3 : 1.0,
                  child: Icon(
                    Icons.nightlight_round,
                    size: 14,
                    color: Colors.white,
                  ),
                ),
              ),
              Positioned(
                right: 6,
                top: 7,
                child: AnimatedOpacity(
                  duration: Duration(milliseconds: 200),
                  opacity: controller.isLightTheme ? 1.0 : 0.3,
                  child: Icon(
                    Icons.wb_sunny,
                    size: 14,
                    color: Colors.white,
                  ),
                ),
              ),
              // Sliding thumb
              AnimatedPositioned(
                duration: Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                left: controller.isLightTheme ? 22 : 2,
                top: 2,
                child: Container(
                  width: 26,
                  height: 26,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha(51),
                        blurRadius: 4,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Icon(
                    controller.isLightTheme
                        ? Icons.wb_sunny
                        : Icons.nightlight_round,
                    size: 14,
                    color: controller.isLightTheme
                        ? Color(0xFFFFA500)
                        : Color(0xFF4C1D95),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Option 2: Minimal Switch Style
class MinimalSwitchThemeToggle extends StatelessWidget {
  const MinimalSwitchThemeToggle({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ConfigController>(
      builder: (controller) => GestureDetector(
        onTap: () {
          controller.toggleTheme();
          controller.update();
        },
        child: AnimatedContainer(
          duration: Duration(milliseconds: 250),
          curve: Curves.easeInOut,
          width: 50,
          height: 30,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            color:
                controller.isLightTheme ? Color(0xFFFFA500) : Color(0xFF4C1D95),
            boxShadow: [
              BoxShadow(
                color: controller.isLightTheme
                    ? Colors.orange.withAlpha(76)
                    : Colors.indigo.withAlpha(76),
                blurRadius: 6,
                offset: Offset(0, 2),
              ),
            ],
          ),
          padding: EdgeInsets.all(3),
          child: AnimatedAlign(
            duration: Duration(milliseconds: 250),
            curve: Curves.easeInOut,
            alignment: controller.isLightTheme
                ? Alignment.centerRight
                : Alignment.centerLeft,
            child: Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
              ),
              child: AnimatedSwitcher(
                duration: Duration(milliseconds: 200),
                transitionBuilder: (child, animation) {
                  return ScaleTransition(
                    scale: animation,
                    child: child,
                  );
                },
                child: Icon(
                  controller.isLightTheme
                      ? Icons.wb_sunny
                      : Icons.nightlight_round,
                  key: ValueKey(controller.isLightTheme),
                  size: 14,
                  color: controller.isLightTheme
                      ? Color(0xFFFFA500)
                      : Color(0xFF4C1D95),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Option 3: iOS Style Switch with Icons
class IOSSwitchThemeToggle extends StatelessWidget {
  const IOSSwitchThemeToggle({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ConfigController>(
      builder: (controller) => GestureDetector(
        onTap: () {
          controller.toggleTheme();
          controller.update();
        },
        child: AnimatedContainer(
          duration: Duration(milliseconds: 300),
          width: 50,
          height: 30,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            color: controller.isLightTheme
                ? Color(0xFFFFA500)
                : Color(0xFF34C759).withAlpha(76),
            border: Border.all(
              color: controller.isLightTheme
                  ? Colors.transparent
                  : Color(0xFF4C1D95),
              width: 1.5,
            ),
          ),
          child: AnimatedPadding(
            duration: Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            padding: controller.isLightTheme
                ? EdgeInsets.only(left: 22)
                : EdgeInsets.only(right: 22),
            child: Container(
              width: 26,
              height: 26,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(40),
                    blurRadius: 3,
                    offset: Offset(0, 1),
                  ),
                ],
              ),
              child: AnimatedSwitcher(
                duration: Duration(milliseconds: 250),
                child: Icon(
                  controller.isLightTheme
                      ? Icons.wb_sunny
                      : Icons.nightlight_round,
                  key: ValueKey(controller.isLightTheme),
                  size: 14,
                  color: controller.isLightTheme
                      ? Color(0xFFFFA500)
                      : Color(0xFF4C1D95),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Option 4: Material Style Switch
class MaterialSwitchThemeToggle extends StatelessWidget {
  const MaterialSwitchThemeToggle({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ConfigController>(
      builder: (controller) => GestureDetector(
        onTap: () {
          controller.toggleTheme();
          controller.update();
        },
        child: AnimatedContainer(
          duration: Duration(milliseconds: 300),
          width: 50,
          height: 30,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            color: controller.isLightTheme
                ? Colors.orange.shade100
                : Colors.indigo.shade900,
          ),
          child: Stack(
            children: [
              // Track icons
              Positioned(
                left: 8,
                top: 8,
                child: Icon(
                  Icons.nightlight_round,
                  size: 12,
                  color: controller.isLightTheme
                      ? Colors.grey.shade400
                      : Colors.white70,
                ),
              ),
              Positioned(
                right: 8,
                top: 8,
                child: Icon(
                  Icons.wb_sunny,
                  size: 12,
                  color: controller.isLightTheme
                      ? Colors.orange.shade700
                      : Colors.grey.shade600,
                ),
              ),
              // Thumb
              AnimatedPositioned(
                duration: Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                left: controller.isLightTheme ? 20 : 0,
                child: Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: controller.isLightTheme
                          ? [Color(0xFFFFD93D), Color(0xFFFFA500)]
                          : [Color(0xFF667EEA), Color(0xFF764BA2)],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha(76),
                        blurRadius: 4,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Icon(
                    controller.isLightTheme
                        ? Icons.wb_sunny
                        : Icons.nightlight_round,
                    size: 16,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Option 5: Gradient Track Switch (Most Beautiful) 🌟
class GradientSwitchThemeToggle extends StatelessWidget {
  const GradientSwitchThemeToggle({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ConfigController>(
      builder: (controller) => GestureDetector(
        onTap: () {
          controller.toggleTheme();
          controller.update();
        },
        child: Container(
          width: 50,
          height: 30,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: controller.isLightTheme
                  ? [
                      Color(0xFF667EEA).withAlpha(76),
                      Color(0xFFFFA500),
                    ]
                  : [
                      Color(0xFF1E3A8A),
                      Color(0xFF667EEA).withAlpha(76),
                    ],
            ),
            boxShadow: [
              BoxShadow(
                color: controller.isLightTheme
                    ? Colors.orange.withAlpha(76)
                    : Colors.indigo.withAlpha(76),
                blurRadius: 8,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Stack(
            children: [
              // Background icons
              AnimatedPositioned(
                duration: Duration(milliseconds: 300),
                left: controller.isLightTheme ? 8 : 4,
                top: 8,
                child: AnimatedOpacity(
                  duration: Duration(milliseconds: 200),
                  opacity: controller.isLightTheme ? 0.5 : 1.0,
                  child: Icon(
                    Icons.nightlight_round,
                    size: 12,
                    color: Colors.white,
                  ),
                ),
              ),
              AnimatedPositioned(
                duration: Duration(milliseconds: 300),
                // right: controller ? 4 : 8,
                top: 8,
                child: AnimatedOpacity(
                  duration: Duration(milliseconds: 200),
                  opacity: controller.isLightTheme ? 1.0 : 0.5,
                  child: Icon(
                    Icons.wb_sunny,
                    size: 12,
                    color: Colors.white,
                  ),
                ),
              ),
              // Thumb with icon
              AnimatedPositioned(
                duration: Duration(milliseconds: 350),
                curve: Curves.easeInOutCubic,
                left: controller.isLightTheme ? 22 : 2,
                top: 2,
                child: Container(
                  width: 26,
                  height: 26,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: controller.isLightTheme
                          ? [Color(0xFFFFE57F), Colors.white]
                          : [Colors.white, Color(0xFFE3F2FD)],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha(76),
                        blurRadius: 6,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: AnimatedSwitcher(
                    duration: Duration(milliseconds: 300),
                    transitionBuilder: (child, animation) {
                      return RotationTransition(
                        turns: animation,
                        child: FadeTransition(
                          opacity: animation,
                          child: child,
                        ),
                      );
                    },
                    child: Icon(
                      controller.isLightTheme
                          ? Icons.wb_sunny
                          : Icons.nightlight_round,
                      key: ValueKey(controller.isLightTheme),
                      size: 14,
                      color: controller.isLightTheme
                          ? Color(0xFFFFA500)
                          : Color(0xFF4C1D95),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ====================================================================
// DEMO PAGE
// ====================================================================
class SwitchStyleThemeToggleDemo extends StatelessWidget {
  const SwitchStyleThemeToggleDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Switch-Style Theme Toggles')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          spacing: 30,
          children: [
            _buildOption(
                'Option 1: Classic Switch ⭐', SwitchStyleThemeToggle()),
            _buildOption(
                'Option 2: Minimal Switch', MinimalSwitchThemeToggle()),
            _buildOption('Option 3: iOS Style Switch', IOSSwitchThemeToggle()),
            _buildOption(
                'Option 4: Material Switch', MaterialSwitchThemeToggle()),
            _buildOption(
                'Option 5: Gradient Switch 🌟', GradientSwitchThemeToggle()),
          ],
        ),
      ),
    );
  }

  Widget _buildOption(String title, Widget toggle) {
    return Column(
      children: [
        Text(
          title,
          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
        ),
        SizedBox(height: 12),
        toggle,
      ],
    );
  }
}

// ====================================================================
// USAGE - SIMPLE REPLACEMENT
// ====================================================================
/*

REPLACE YOUR CURRENT CODE:

GetBuilder<ConfigController>(
  builder: (context) => Transform.scale(
    scale: 0.8,
    child: Switch(
      value: ConfigController.to.isLightTheme,
      onChanged: (_) {
        ConfigController.to.toggleTheme();
        context.update();
      },
    ),
  ),
)

WITH ONE OF THESE:

1. SwitchStyleThemeToggle()        // ⭐ RECOMMENDED - Classic switch look
2. GradientSwitchThemeToggle()     // 🌟 Most beautiful
3. MinimalSwitchThemeToggle()      // Clean and simple
4. IOSSwitchThemeToggle()          // iOS style
5. MaterialSwitchThemeToggle()     // Material design

*/
