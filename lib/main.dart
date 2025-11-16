// lib/main.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:intl/date_symbol_data_local.dart';

import 'src/core/nav.dart';
import 'src/state/app_state.dart';

// Auth & flow
import 'src/pages/auth/login_page.dart';
import 'src/pages/auth/signup_page.dart';
import 'src/pages/auth/forgot_password_page.dart';
import 'src/pages/homeflow/home_choice_page.dart';
import 'src/pages/homeflow/create_home_page.dart';
import 'src/pages/homeflow/join_home_page.dart';
import 'src/pages/onboarding/character_select_page.dart';

// Shell / tabs
import 'src/pages/shell/shell.dart';
import 'src/pages/tabs/profile_page.dart';
import 'src/pages/tabs/leaderboard_page.dart';
import 'src/pages/tabs/quests_page.dart';
import 'src/pages/tabs/mart_page.dart';

// BG
import 'src/widgets/poke_background.dart';
import 'src/pages/tabs/manage_quests_page.dart';
import 'src/pages/tabs/mart_page.dart';
import 'src/pages/auth/login_page.dart';

void main() async {
  // This line is good practice to ensure Flutter is ready before doing anything.
  WidgetsFlutterBinding.ensureInitialized();

  // This initializes the date formatting system and fixes the DateFormat error.
  await initializeDateFormatting(null, null);

  runApp(const HouseBuddyMonApp());
}


class HouseBuddyMonApp extends StatelessWidget {
  const HouseBuddyMonApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AppState(),
      child: MaterialApp(
        title: 'HouseBuddy Mon',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          brightness: Brightness.light,
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF7C4DFF), // gamey purple
            brightness: Brightness.light,
          ).copyWith(
            primary: const Color(0xFF7C4DFF),
            secondary: const Color(0xFF00E5FF),
            tertiary: const Color(0xFFFFEA00),
            surface: const Color(0xFFFDFBFF),
          ),
          scaffoldBackgroundColor: Colors.transparent,
          cardTheme: CardThemeData(
            // FIX for withOpacity warning
            color: const Color(0xFFFFFFFF).withAlpha(242), // ~95% opacity
            elevation: 5,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
            margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 0),
          ),
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.transparent,
            foregroundColor: Colors.black87,
            centerTitle: true,
            elevation: 0,
          ),
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            // FIX for withOpacity warning
            fillColor: const Color(0xFFFFFFFF).withAlpha(240), // ~94% opacity
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: Color(0xFF7C4DFF), width: 2),
            ),
          ),
          filledButtonTheme: FilledButtonThemeData(
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFF7C4DFF),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
              textStyle: const TextStyle(fontWeight: FontWeight.w800),
            ),
          ),
        ),
        builder: (context, child) => const PokeBackground(child: SizedBox.expand()).withChild(child),

        // Your initial route is '/login'
        initialRoute: '/login',
        onGenerateRoute: (RouteSettings s) {
          switch (s.name) {
            case '/login':       return fade(const LoginPage());
            case '/signup':      return slideUp(const SignupPage());
            case '/forgot':      return slideUp(const ForgotPasswordPage());
            case '/home-choice': return fadeScale(const HomeChoicePage());
            case '/create-home': return slideUp(const CreateHomePage());
            case '/join-home':   return slideUp(const JoinHomePage());
            case '/pick-mon':    return slideUp(const CharacterSelectPage());
            case '/shell':       return fadeScale(const ShellPage());
          // named routes to tabs if you want to push them directly

          // --- THIS IS THE FIX: REMOVED THE INVALID /profile ROUTE ---
          // case '/profile':     return slideUp(const ProfilePage()); // This line is now removed

            case '/leaderboard': return slideUp(const LeaderboardPage());
            case '/quests':      return slideUp(const QuestsPage());
            case '/mart':        return slideUp(const MartPage());
            case '/manage-quests': return slideUp(const ManageQuestsPage());

            default:
              return fade(Scaffold(body: Center(child: Text('Unknown route ${s.name}'))));
          }
        },
      ),
    );
  }
}

// tiny helper to keep builder one-liner
extension _Child on Widget {
  Widget withChild(Widget? child) => Stack(children: [this, if (child != null) child]);
}
