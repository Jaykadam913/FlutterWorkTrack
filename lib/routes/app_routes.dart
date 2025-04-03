import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_work_track/presentation/cubit/add_edit_employee_cubit.dart';
import 'package:flutter_work_track/presentation/cubit/employee_cubit.dart';
import 'package:flutter_work_track/presentation/views/add_edit_employee.dart';
import 'package:flutter_work_track/presentation/views/employee_list_screen.dart';
import 'package:flutter_work_track/service_locator.dart';

class AppRoutes {
  static const String home = '/';
  static const String addEditEmployee = '/addEditEmployee';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    return buildPage(path: settings.name ?? '/', queryParams: settings.arguments);
  }

  static Route<dynamic> buildPage({
    required String path,
    dynamic queryParams, // Accepts `settings.arguments`
  }) {
    Widget page;

    switch (path) {
      case home:
        page = BlocProvider(
          create: (_) => getIt<EmployeeCubit>()..loadEmployees(),
          child: const EmployeeListScreen(),
        );
        break;

      case addEditEmployee:
        final employee = (queryParams as Map<String, dynamic>?)?['employee']; // Correctly extract arguments
        print('Received arguments: $queryParams'); // Debugging
        page = MultiBlocProvider(
          providers: [
            BlocProvider(
              create: (_) => getIt<AddEditEmployeeCubit>(param1: employee),
            ),
            BlocProvider(
              create: (_) => getIt<EmployeeCubit>()..loadEmployees(),
            ),
          ],
          child: AddEditEmployeeScreen(employee: employee),
        );
        break;

      default:
        page = const Scaffold(
          body: Center(child: Text('Page Not Found')),
        );
    }

    return PageRouteBuilder(
      settings: RouteSettings(name: path, arguments: queryParams), // Ensure arguments are preserved
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionDuration: Duration.zero,
      reverseTransitionDuration: Duration.zero,
    );
  }
}
