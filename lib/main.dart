import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'smoke_cubit.dart';
import 'smoke_page.dart';
import 'repository/smoke_repository.dart';

void main() => runApp(const SmokeApp());

class SmokeApp extends StatelessWidget {
  const SmokeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('pl'),
        Locale('en'),
      ],
      home: RepositoryProvider(
        create: (_) => SmokeRepository(),
        child: BlocProvider(
          create: (context) => SmokeCubit(context.read<SmokeRepository>()),
          child: const SmokePage(),
        ),
      ),
    );
  }
}
