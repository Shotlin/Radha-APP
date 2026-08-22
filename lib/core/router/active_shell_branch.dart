import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Index of the Scan branch within the shell's `branches` list in
/// app_router.dart — a named constant so screens reacting to
/// [activeShellBranchProvider] don't hardcode a magic number.
const int kScanBranchIndex = 1;

/// Mirrors `StatefulNavigationShell.currentIndex` (see root_shell.dart) into
/// a listenable provider.
///
/// `StatefulNavigationShell.of(context)` is a plain, non-reactive ancestor
/// lookup (`context.findAncestorStateOfType`, not an InheritedWidget), so a
/// screen deep inside one branch's Navigator has no built-in way to learn
/// when a *different* branch becomes active. That gap matters because the
/// shell is an `IndexedStack`: switching tabs never disposes the previous
/// tab's screen, so a camera-owning screen (e.g. ScanScreen) keeps running
/// — including its camera — after the user has navigated away from it.
/// That live-but-invisible camera can then collide with a second camera
/// session opened elsewhere (Android allows only one open session per
/// physical camera per process), surfacing as an unexplained camera error
/// on the second screen.
///
/// RootShell writes this provider (post-frame, to avoid mutating provider
/// state during another widget's build) whenever the active branch
/// changes; camera-owning screens read it to stop their camera the moment
/// their tab stops being visible, and restart it when it becomes visible
/// again.
final activeShellBranchProvider = StateProvider<int>((ref) => 0);
