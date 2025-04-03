import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_work_track/core/constants/app_colors.dart';
import 'package:flutter_work_track/core/constants/app_constants.dart';
import 'package:flutter_work_track/core/constants/app_images.dart';
import 'package:flutter_work_track/core/constants/app_strings.dart';
import 'package:flutter_work_track/core/constants/extensions.dart';
import 'package:flutter_work_track/core/constants/size_utils.dart';
import 'package:flutter_work_track/data/models/employee_model.dart';
import 'package:flutter_work_track/presentation/cubit/employee_cubit.dart';
import 'package:flutter_work_track/presentation/cubit/employee_state.dart';
import 'package:flutter_work_track/presentation/widgets/employee_card.dart';
import 'package:flutter_work_track/routes/app_routes.dart';
import 'package:google_fonts/google_fonts.dart';

class EmployeeListScreen extends StatefulWidget {
  const EmployeeListScreen({super.key});

  @override
  State<EmployeeListScreen> createState() => _EmployeeListScreenState();
}

class _EmployeeListScreenState extends State<EmployeeListScreen> {
  late EmployeeCubit employeeCubit;

  void _navigateToAddEmployee() {
    Navigator.pushNamed(context, AppRoutes.addEditEmployee);
  }

  @override
  Widget build(BuildContext context) {
    employeeCubit = context.watch<EmployeeCubit>();
    return Scaffold(
      appBar: AppBar(
        title: Text(AppStrings.employeeListTitle,
            style: GoogleFonts.roboto(fontSize: 18, fontWeight: FontWeight.w500)),
        leading: SizedBox.shrink(),
        leadingWidth: 0,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToAddEmployee,
        backgroundColor: AppColors.primaryBlue,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: SafeArea(
        child: BlocConsumer<EmployeeCubit, EmployeeState>(
          bloc:  employeeCubit..loadEmployees(),
          listener: (context, state) {},
          builder: (context, state) {
            if (state is EmployeeLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is EmployeeLoaded) {
              final employees = state.employees;
              final DateTime currentDate = DateTime.now().toDateOnly();

              final currentEmployees = employees
                  .where((e) =>
              e.dateOfLeaveCompany.isEmpty ||
                  e.dateOfLeaveCompany.toDate().isAfter(currentDate) ||
                  e.dateOfLeaveCompany.toDate().isAtSameMomentAs(currentDate))
                  .toList();

              final previousEmployees = employees
                  .where((e) =>
              e.dateOfLeaveCompany.isNotEmpty &&
                  e.dateOfLeaveCompany.toDate().isBefore(currentDate))
                  .toList();

              return Column(
                children: [
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.only(bottom: 20),
                      children: [
                        if (currentEmployees.isNotEmpty) ...[
                          _buildSectionTitle(AppStrings.currentEmployTitle),
                          _buildEmployeeList(currentEmployees, isEmployed: true),
                        ],
                        if (previousEmployees.isNotEmpty) ...[
                          _buildSectionTitle(AppStrings.previousEmployTitle),
                          _buildEmployeeList(previousEmployees),
                        ],
                      ],
                    ),
                  ),
                  Container(
                    color: Colors.grey.shade300,
                    width: double.infinity,
                    padding: EdgeInsets.all(kIsWeb ? 2.w : 4.w),
                    child: Text(
                      AppStrings.swipeLeftDeleteTitle,
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(color: AppColors.greyTextAccentColor),
                    ),
                  ),
                ],
              );
            } else {
              return Center(
                child: Image.asset(
                  AppImages.noDataFoundIcon,
                  width: 100.w,
                  height: 100.h,
                ),
              );
            }
          },
        ),
      ),
    );
  }

  Widget _buildEmployeeList(List<EmployeeModel> employees, {bool isEmployed = false}) {
    return ListView.separated(
      separatorBuilder: (_, __) => const Divider(thickness: 0.3),
      shrinkWrap: true,
      padding: const EdgeInsets.only(bottom: 10),
      physics: const NeverScrollableScrollPhysics(),
      itemCount: employees.length,
      itemBuilder: (context, index) {
        final employee = employees[index];
        return EmployeeCard(
          employee: employee,
          isEmployed: isEmployed,
          onDelete: () => _confirmDeleteEmployee(context, employee),
        );
      },
    );
  }

  Widget _buildSectionTitle(String title) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(15),
      color: Colors.grey.shade300,
      child: Text(
        title,
        style: Theme.of(
          context,
        ).textTheme.titleMedium?.copyWith(color: AppColors.primaryBlue),
      ),
    );
  }

  Future<void> _confirmDeleteEmployee(BuildContext context, EmployeeModel employee) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(AppStrings.deleteEmployee),
        content: Text(AppStrings.deleteEmployeeMessage.replaceAll('/employee', employee.name)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text(AppStrings.cancelCTATitle, style: TextStyle(color: Colors.black))),
          TextButton(
            onPressed: () {
              Navigator.pop(context, true);
              employeeCubit.deleteEmployee(employee.id);
              showSnackBar(AppStrings.empDeletedSuccessTitle,snackbarAction: SnackBarAction(
                label: AppStrings.undoTitle,
                onPressed: () => employeeCubit.addEmployee(employee, undoItem: true),
              ));
            },
            child: const Text(AppStrings.deleteCTATitle, style: TextStyle(color: AppColors.primaryBlue)),
          ),
        ],
      ),
    );
    if (result == true) {
      employeeCubit.deleteEmployee(employee.id);
    }
  }
}