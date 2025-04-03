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
import 'package:flutter_work_track/presentation/cubit/add_edit_employee_cubit.dart';
import 'package:flutter_work_track/presentation/cubit/add_edit_employee_state.dart';
import 'package:flutter_work_track/presentation/cubit/employee_cubit.dart';
import 'package:flutter_work_track/presentation/widgets/custom_date_picker.dart';
import 'package:flutter_work_track/presentation/widgets/show_position_picker_dialog.dart';
import 'package:flutter_work_track/routes/app_routes.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:responsive_framework/responsive_framework.dart';

class AddEditEmployeeScreen extends StatelessWidget {
  final EmployeeModel? employee;

  const AddEditEmployeeScreen({this.employee, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final addEditEmployeeCubit = context.read<AddEditEmployeeCubit>();
    final employeeCubit = context.read<EmployeeCubit>();

    return Scaffold(
      appBar: _buildAppBar(context, employeeCubit),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: BlocBuilder<AddEditEmployeeCubit, AddEditEmployeeState>(
            builder: (context, state) {
              return ResponsiveRowColumn(
                layout: ResponsiveRowColumnType.COLUMN,
                children: [
                  ResponsiveRowColumnItem(
                    child: _buildTextField(
                      context,
                      state.name,
                      addEditEmployeeCubit,
                    ),
                  ),
                  ResponsiveRowColumnItem(
                    child: _buildPositionPicker(
                      context,
                      state.position,
                      addEditEmployeeCubit,
                    ),
                  ),
                  ResponsiveRowColumnItem(
                    child: _buildDatePickers(
                      state.startDate,
                      state.endDate,
                      addEditEmployeeCubit,
                    ),
                  ),
                  ResponsiveRowColumnItem(child: const Spacer()),
                  ResponsiveRowColumnItem(
                    child: _buildFooterButtons(
                      context,
                      addEditEmployeeCubit,
                      employeeCubit,
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  AppBar _buildAppBar(BuildContext context, EmployeeCubit employeeCubit) {
    return AppBar(
      title: Text(
        employee == null
            ? AppStrings.addEmployeeDetails
            : AppStrings.editEmployeeDetails,
        style: Theme.of(
          context,
        ).textTheme.titleLarge?.copyWith(color: AppColors.whiteTextColor),
      ),
      leadingWidth: 0,
      leading: SizedBox.shrink(),
      actions:
          employee == null
              ? null
              : [_buildDeleteButton(context, employeeCubit)],
    );
  }

  IconButton _buildDeleteButton(
    BuildContext context,
    EmployeeCubit employeeCubit,
  ) {
    return IconButton(
      onPressed: () => _showDeleteDialog(context, employeeCubit),
      icon: Icon(FontAwesomeIcons.trashCan),
    );
  }

  void _showDeleteDialog(BuildContext context, EmployeeCubit employeeCubit) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(AppStrings.deleteEmployee),
          content: Text(
            AppStrings.deleteEmployeeMessage.replaceAll(
              "/employee",
              employee!.name,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(AppStrings.cancelCTATitle, style: TextStyle(color: Colors.black)),
            ),
            TextButton(
              onPressed: () {
                Navigator.pushReplacementNamed(context, AppRoutes.home);
                employeeCubit.deleteEmployee(employee!.id);
                showSnackBar(AppStrings.empDeletedSuccessTitle,snackbarAction: SnackBarAction(
                  label: AppStrings.undoTitle,
                  onPressed: () => employeeCubit.addEmployee(employee!, undoItem: true),
                ));
              },
              child: const Text(AppStrings.deleteCTATitle, style: TextStyle(color: AppColors.primaryBlue)),
            ),
          ],
        );
      },
    );
  }

  Widget _buildTextField(
    BuildContext context,
    String name,
    AddEditEmployeeCubit cubit,
  ) {
    return TextFormField(
      initialValue: name,
      cursorColor: AppColors.primaryBlue,
      autofillHints: [AutofillHints.name],
      onChanged: cubit.updateName,
      decoration: _inputDecoration(
        context,
        AppStrings.employeeName,
        Icons.person_outline,
      ),
    );
  }

  Widget _buildPositionPicker(
    BuildContext context,
    String? selectedPosition,
    AddEditEmployeeCubit cubit,
  ) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 2.h),
      child: GestureDetector(
        onTap:
            () => showPositionPicker(context, (value) {
              cubit.updatePosition(value);
              Navigator.of(context).pop();
            }),
        child: InputDecorator(
          decoration: _inputDecoration(
            context,
            AppStrings.selectPositionTitle,
            Icons.work_outline,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                selectedPosition ?? AppStrings.selectPositionTitle,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color:
                      selectedPosition != null
                          ? AppColors.textAccentColor
                          : AppColors.greyTextAccentColor,
                ),
              ),
              Image.asset(AppImages.dropdownIcon, color: AppColors.primaryBlue),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDatePickers(
    String? startDate,
    String? endDate,
    AddEditEmployeeCubit cubit,
  ) {
    return Row(
      children: [
        CustomDatePicker(
          selectedDate: startDate ?? '',
          onDateChanged: (value){
            if (value == endDate) {
              showSnackBar(AppStrings.startEndDateError);
              return;
            }
            if (endDate!=null && value.toDate().isAfter(endDate.toDate())) {
              showSnackBar(AppStrings.startBeforeDate);
              return;
            }
            cubit.updateStartDate(value);
          },
          hintText: AppStrings.noDateTitle,
        ),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 8),
          child: Icon(
            Icons.arrow_right_alt_outlined,
            color: AppColors.primaryBlue,
          ),
        ),
        CustomDatePicker(
          selectedDate: endDate ?? '',
          onDateChanged: (value){
            if (value == startDate) {
              showSnackBar(AppStrings.startEndDateError);
              return;
            }
            if (startDate!=null && startDate!.toDate().isAfter(value.toDate())) {
              showSnackBar(AppStrings.startBeforeDate);
              return;
            }
            cubit.updateEndDate(value);
          },
          hintText: AppStrings.noDateTitle,
        ),
      ],
    );
  }

  Widget _buildFooterButtons(
    BuildContext context,
    AddEditEmployeeCubit cubit,
    EmployeeCubit employeeCubit,
  ) {
    return Column(
      children: [
        const Divider(),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            _buildButton(
              context,
              AppStrings.cancelCTATitle,
              AppColors.greyCTACancelColor,
              () => Navigator.pop(context),
              textColor: AppColors.primaryBlue,
            ),
            SizedBox(width: kIsWeb ? 2.w : 4.w),
            _buildButton(
              context,
              employee == null
                  ? AppStrings.saveCTATitle
                  : AppStrings.updateCTATitle,
              AppColors.primaryBlue,
              () => _saveEmployee(context, cubit, employeeCubit),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildButton(
    BuildContext context,
    String text,
    Color color,
    VoidCallback onPressed, {
    Color? textColor,
  }) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: kIsWeb?2.h:1.h),
        child: Text(
          text,
          style: Theme.of(context).textTheme.displayMedium?.copyWith(
            color: textColor ?? AppColors.whiteTextColor,
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(
    BuildContext context,
    String hint,
    IconData icon,
  ) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: Padding(
        padding: EdgeInsets.symmetric(horizontal: 1.w),
        child: Icon(icon, color: AppColors.primaryBlue),
      ),
      hintStyle: Theme.of(
        context,
      ).textTheme.bodyLarge?.copyWith(color: AppColors.greyTextAccentColor),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: AppColors.primaryBlue, width: 1.5),
        borderRadius: BorderRadius.circular(10),
      ),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
    );
  }

  void _saveEmployee(
    BuildContext context,
    AddEditEmployeeCubit cubit,
    EmployeeCubit employeeCubit,
  ) {
    final state = cubit.state;

    if (state.name.isEmpty ||
        state.position == null ||
        state.startDate == null ||
        state.endDate == null) {
      showSnackBar(AppStrings.pleaseFillFieldsError);
      return;
    }

    final newEmployee = EmployeeModel(
      id: employee?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      name: state.name,
      position: state.position ?? '',
      dateOfJoining: state.startDate ?? '',
      dateOfLeaveCompany: state.endDate ?? '',
    );

    if (employee != null) {
      employeeCubit.updateEmployee(newEmployee);
      showSnackBar(AppStrings.employeeUpdatedSuccess);
    } else {
      employeeCubit.addEmployee(newEmployee);
      showSnackBar(AppStrings.employeeAddedSuccess);
    }

    Navigator.pushReplacementNamed(context, AppRoutes.home);
  }
}
