import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_work_track/core/constants/app_colors.dart';
import 'package:flutter_work_track/core/constants/size_utils.dart';
import 'package:flutter_work_track/data/models/employee_model.dart';
import 'package:flutter_work_track/routes/app_routes.dart';

class EmployeeCard extends StatefulWidget {
  final EmployeeModel employee;
  final VoidCallback onDelete;
  final bool isEmployed;

  const EmployeeCard({
    required this.employee,
    required this.onDelete,
    required this.isEmployed,
    super.key,
  });

  @override
  State<EmployeeCard> createState() => _EmployeeCardState();
}

class _EmployeeCardState extends State<EmployeeCard> {
  bool isDismissed = false;

  @override
  Widget build(BuildContext context) {
    if (isDismissed) return SizedBox.shrink();
    return GestureDetector(
        onTap: () {
          Navigator.pushNamed(context, AppRoutes.addEditEmployee,
              arguments: {"employee": widget.employee});
        },
        child: Slidable(
          key: ValueKey(widget.employee.id),
          endActionPane: ActionPane(
            motion: const DrawerMotion(), // Smooth slide animation
            children: [
              SlidableAction(
                onPressed: (context) => widget.onDelete(),
                backgroundColor: AppColors.redBackgroundColor,
                foregroundColor: AppColors.whiteTextColor,
                icon: Icons.delete_forever_outlined,
              ),
            ],
          ),
          child: SizedBox(
            width: double.infinity,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: kIsWeb?1.5.w:4.w, vertical: kIsWeb?1.w:2.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.employee.name,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: AppColors.textAccentColor,
                          fontSize: 16,
                        ),
                  ),
                  SizedBox(height: 1.h),
                  Text(
                    widget.employee.position,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: AppColors.greyTextAccentColor,
                          fontSize: 14,
                        ),
                  ),
                  SizedBox(height: 1.h),
                  Text(
                    widget.isEmployed
                        ? 'From ${widget.employee.dateOfJoining}'
                        : '${widget.employee.dateOfJoining} - ${widget.employee.dateOfLeaveCompany}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.greyTextAccentColor,
                          fontSize: 12,
                        ),
                  ),
                ],
              ),
            ),
          ),
        ));
  }
}
