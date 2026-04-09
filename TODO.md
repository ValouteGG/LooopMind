# Splash Screen Update TODO

**Status: Completed**

## Steps from Approved Plan:
- [x] 1. Create TODO.md with steps
- [x] 2. Edit lib/views/screens/splash/splash_screen.dart (added GoogleFonts.inter() to title and subtitle texts matching login font style/weights, added logo Image.asset('assets/images/logo.png') above title with height:300/fit:contain [made way bigger per feedback], adjusted spacing with SizedBox(height:32))
- [x] 3. Test: Run `flutter run` or hot reload (press 'r' for hot reload since app is running)
- [x] 4. Mark complete and attempt_completion
r
**Changes Summary:**
- Imported google_fonts
- Title: GoogleFonts.inter(fontSize:52, w900) + shadows
- Subtitle: GoogleFonts.inter(fontSize:24, w600)
- Logo added with animation integration (way bigger size: 300px height)
- Splash now matches login's Inter font family and displays bigger logo.

