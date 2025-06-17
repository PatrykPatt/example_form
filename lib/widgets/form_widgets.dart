import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class FormWidgets {
  static Widget buildSlider({
    required double value,
    required double min,
    required double max,
    required Function(double) onChanged,
    required AppLocalizations l10n,
  }) {
    return Column(
      children: [
        Slider(
          value: value,
          min: min,
          max: max,
          divisions: max.toInt(),
          label: '${value.round()}',
          onChanged: onChanged,
        ),
        Text(
          l10n.numberOfItems(value.round()),
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 16),
        ),
      ],
    );
  }

  static Widget buildBooleanRadioGroup({
    required bool? value,
    required Function(bool?) onChanged,
    required AppLocalizations l10n,
  }) {
    return Row(
      children: [
        Expanded(
          child: RadioListTile<bool>(
            title: Text(l10n.yes),
            value: true,
            groupValue: value,
            onChanged: onChanged,
          ),
        ),
        Expanded(
          child: RadioListTile<bool>(
            title: Text(l10n.no),
            value: false,
            groupValue: value,
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }

  static Widget buildAwarenessRadioGroup({
    required bool? value,
    required Function(bool?) onChanged,
    required AppLocalizations l10n,
  }) {
    return Row(
      children: [
        Expanded(
          child: RadioListTile<bool>(
            title: Text(l10n.iAmAware),
            value: true,
            groupValue: value,
            onChanged: onChanged,
          ),
        ),
        Expanded(
          child: RadioListTile<bool>(
            title: Text(l10n.iAmNotAware),
            value: false,
            groupValue: value,
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }

  static Widget buildSmokingEffectsList(List<String> effects, String? error) {
    return Card(
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (error != null)
              Text('Error: $error', style: const TextStyle(color: Colors.red)),
            ...effects.map((effect) => Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Text('• $effect', style: const TextStyle(fontSize: 16)),
                )),
          ],
        ),
      ),
    );
  }

  static Widget buildDatePicker({
    required BuildContext context,
    required DateTime? selectedDate,
    required Function(DateTime) onDateSelected,
    required AppLocalizations l10n,
  }) {
    final dateFormat = DateFormat('dd.MM.yyyy');
    final now = DateTime.now();
    final initialDate = selectedDate ?? now.add(const Duration(days: 7));

    return InkWell(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: initialDate,
          firstDate: now,
          lastDate: now.add(const Duration(days: 365 * 2)),
        );

        if (picked != null && context.mounted) {
          onDateSelected(picked);
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              selectedDate == null ? l10n.selectDate : dateFormat.format(selectedDate),
              style: const TextStyle(fontSize: 16),
            ),
            const Icon(Icons.calendar_today),
          ],
        ),
      ),
    );
  }
}