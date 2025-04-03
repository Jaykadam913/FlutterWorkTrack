import 'package:flutter/material.dart';
import 'package:flutter_work_track/core/constants/app_colors.dart';
import 'package:flutter_work_track/core/constants/app_images.dart';
import 'package:flutter_work_track/core/constants/app_styles.dart';
import 'package:flutter_work_track/core/constants/extensions.dart';
import 'package:flutter_work_track/core/constants/size_utils.dart';
import 'package:flutter_work_track/presentation/widgets/date_dialog_widget.dart';

class CustomDatePicker extends StatelessWidget {
  final String selectedDate;
  final Function(String) onDateChanged;
  final String hintText;

  CustomDatePicker({
    required this.selectedDate,
    required this.onDateChanged,
    required this.hintText,
    super.key,
  });

  PageController pageController = PageController();

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: () async {
          datePickerDialog(context, pageController, selectedDate, (value) {
            onDateChanged(value);
          });
        },
        child: InputDecorator(
          decoration: InputDecoration(
            prefixIcon: Image.asset(
              AppImages.calendarIcon,
              color: AppColors.primaryBlue,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.grey, width: 1.5),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: AppColors.primaryBlue, width: 1.5),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.green, width: 2),
            ),
          ),
          child: Text(
            formatDate(),
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color:
                  selectedDate.isEmpty
                      ? AppColors.greyTextAccentColor
                      : AppColors.textAccentColor,
            ),
          ),
        ),
      ),
    );
  }

  formatDate() {
    DateTime now = DateTime.now();
    if (selectedDate.isNotEmpty) {
      DateTime initialDate = selectedDate.toDate();
      return initialDate.year == now.year &&
              initialDate.month == now.month &&
              initialDate.day == now.day
          ? "Today"
          : selectedDate.toString();
    }
    return hintText;
  }
}
