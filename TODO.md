# Fix CreateTask Screen Visibility Issue

## Steps:
- [x] Step 1: Create this TODO.md (current)
- [x] Step 2: Update CustomTextField to use theme colors (onSurface) instead of hardcoded white
- [ ] Step 3: Test in light/dark mode - verify labels and text fields visible in CreateTask screen
- [ ] Step 4: Run `flutter analyze` and hot reload
- [ ] Step 5: Mark complete, run `flutter pub get` if needed, attempt_completion

**Root cause**: CustomTextField hardcoded Colors.white invisible on light theme scaffold background.
**Files**: lib/views/widgets/custom_textfield.dart (updated)
