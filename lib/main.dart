import 'package:darlink/constants/app_theme_data.dart';
import 'package:darlink/constants/database_url.dart';
import 'package:darlink/layout/home_layout.dart';
import 'package:darlink/modules/authentication/login_screen.dart';
import 'package:darlink/modules/authentication/register_screen.dart';
import 'package:darlink/modules/intro_screens/splash_screen.dart';
import 'package:darlink/modules/transaction_screen.dart';
import 'package:darlink/modules/upload/property_upload.dart';
import 'package:darlink/shared/cubit/app_cubit.dart';
import 'package:darlink/shared/cubit/app_state.dart';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'modules/upload/announce_event_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // await MongoDatabase.connect();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AppCubit(),
      child: const DarLinkApp(),
    );
  }
}

class DarLinkApp extends StatelessWidget {
  const DarLinkApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppCubit, AppCubitState>(
      buildWhen: (previous, current) => true,
      builder: (context, state) {
        print("App rebuilt with state: ${state.runtimeType}");

        return MaterialApp(
          key: UniqueKey(),
          title: 'Darlink',
          debugShowCheckedModeBanner: false,
          theme: AppThemeData.lightTheme,
          darkTheme: AppThemeData.darkTheme,
          themeMode: ThemeMode.light, // Using light for now
          home:HomeLayout(),
        );
      },
    );
  }
}
