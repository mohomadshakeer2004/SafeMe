import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';

/// Date/time picker that dismisses EasyLoading first — avoids overlay layout crashes.
class SafeDateField extends StatelessWidget {
  const SafeDateField({
    super.key,
    required this.name,
    required this.labelText,
    required this.labelStyle,
    required this.focusColor,
    this.initialValue,
    this.validator,
    this.onChanged,
    this.includeTime = false,
    this.firstDate,
    this.lastDate,
  });

  final String name;
  final String labelText;
  final TextStyle labelStyle;
  final Color focusColor;
  final DateTime? initialValue;
  final String? Function(DateTime?)? validator;
  final ValueChanged<DateTime?>? onChanged;
  final bool includeTime;
  final DateTime? firstDate;
  final DateTime? lastDate;

  Future<DateTime?> _pick(BuildContext context, DateTime? current) async {
    EasyLoading.dismiss();
    FocusManager.instance.primaryFocus?.unfocus();

    final now = DateTime.now();
    final initial = current ?? now;

    final pickedDate = await showDatePicker(
      context: context,
      useRootNavigator: true,
      initialDate: initial,
      firstDate: firstDate ?? now.subtract(const Duration(days: 365)),
      lastDate: lastDate ?? now.add(const Duration(days: 365)),
    );
    if (pickedDate == null) return null;

    if (!includeTime) {
      return DateTime(pickedDate.year, pickedDate.month, pickedDate.day);
    }

    if (!context.mounted) return null;
    final pickedTime = await showTimePicker(
      context: context,
      useRootNavigator: true,
      initialTime: TimeOfDay.fromDateTime(initial),
    );
    if (pickedTime == null) return null;

    return DateTime(
      pickedDate.year,
      pickedDate.month,
      pickedDate.day,
      pickedTime.hour,
      pickedTime.minute,
    );
  }

  @override
  Widget build(BuildContext context) {
    return FormBuilderField<DateTime>(
      name: name,
      initialValue: initialValue,
      validator: validator,
      builder: (field) {
        return InkWell(
          onTap: () async {
            final value = await _pick(context, field.value);
            if (value == null) return;
            field.didChange(value);
            onChanged?.call(value);
          },
          child: InputDecorator(
            decoration: InputDecoration(
              labelText: labelText,
              labelStyle: labelStyle,
              contentPadding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
              border: const OutlineInputBorder(),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: focusColor),
              ),
              suffixIcon: const Icon(Icons.date_range),
              errorText: field.errorText,
            ),
            child: Text(
              field.value != null
                  ? DateFormat(
                      includeTime ? 'yyyy-MM-dd HH:mm' : 'yyyy-MM-dd',
                    ).format(field.value!)
                  : '',
            ),
          ),
        );
      },
    );
  }
}
