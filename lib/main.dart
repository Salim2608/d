import 'package:darlink/constants/app_theme_data.dart';
import 'package:darlink/constants/database_url.dart';
import 'package:darlink/editable_client_profile_page.dart';
import 'package:darlink/layout/home_layout.dart';
import 'package:darlink/modules/admin/admin_dashboard.dart';
import 'package:darlink/modules/admin/event_data.dart';
import 'package:darlink/modules/authentication/forget_password.dart';
import 'package:darlink/modules/authentication/login_screen.dart';
import 'package:darlink/modules/authentication/register_screen.dart';
import 'package:darlink/modules/intro_screens/splash_screen.dart';
import 'package:darlink/modules/navigation/event_screen.dart';
import 'package:darlink/modules/chat_screen.dart';
import 'package:darlink/modules/navigation/message_screen.dart';
import 'package:darlink/modules/transaction_screen.dart';
import 'package:darlink/modules/upload/property_upload.dart';
import 'package:darlink/shared/cubit/app_cubit.dart';
import 'package:darlink/shared/cubit/app_state.dart';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'modules/authentication/verify_user_change_password.dart';

Future<void> main() async {
  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('isLoggedIn') ?? false;
  }

  WidgetsFlutterBinding.ensureInitialized();
  // await MongoDatabase.connect();
  bool loggedIn = await isLoggedIn();
  runApp(DarLinkApp(isLoggedIn: loggedIn));
}

class DarLinkApp extends StatelessWidget {
  final bool isLoggedIn;
  const DarLinkApp({required this.isLoggedIn});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AppCubit(), // Provide your cubit here
      child: BlocBuilder<AppCubit, AppCubitState>(
        builder: (context, state) {
          return MaterialApp(
            key: UniqueKey(),
            title: 'Darlink',
            debugShowCheckedModeBanner: false,
            theme: AppThemeData.lightTheme,
            darkTheme: AppThemeData.darkTheme,
            themeMode: ThemeMode.light,
            home: EmailVerificationScreen(
            ),
            //home: SplashScreen(isLoggedIn: isLoggedIn),
          );
        },
      ),
    );
  }
}
