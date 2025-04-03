import 'package:flutter/material.dart';
import 'package:flutter_work_track/routes/app_routes.dart';
import 'package:responsive_framework/responsive_framework.dart';

import 'core/constants/app_constants.dart';
import 'core/constants/app_styles.dart';
import 'core/constants/size_utils.dart';

class WorkTrackApp extends StatelessWidget {
  const WorkTrackApp({super.key});

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context);
    return MaterialApp(
          title: 'Flutter Work Track',
          debugShowCheckedModeBanner: false,
          theme: appTheme,
          scaffoldMessengerKey: scaffoldMessengerKey,
          initialRoute: AppRoutes.home,
          // Start from Home Screen
          onGenerateRoute: AppRoutes.generateRoute, // Handle named routes
          builder: (context, child) {
            return ResponsiveBreakpoints.builder(
              child: ClampingScrollWrapper.builder(context, child!),
              breakpoints: [
                const Breakpoint(start: 0, end: 450, name: MOBILE),
                const Breakpoint(start: 451, end: 800, name: TABLET),
                const Breakpoint(start: 801, end: 1920, name: DESKTOP),
                const Breakpoint(start: 1921, end: double.infinity, name: '4K'),
              ],
            );
          },
    );
  }
}
