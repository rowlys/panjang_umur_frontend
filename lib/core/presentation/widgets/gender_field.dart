import 'package:flutter/material.dart';

import '../../models/user.dart';

class GenderField extends FormField<Gender> {
  GenderField({
    super.key,
    super.initialValue,
    super.validator,
    super.enabled,
    required ValueChanged<Gender> onChanged,
  }) : super(
          builder: (field) => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SegmentedButton<Gender>(
                segments: const [
                  ButtonSegment(value: Gender.male, label: Text('Male'), icon: Icon(Icons.male)),
                  ButtonSegment(value: Gender.female, label: Text('Female'), icon: Icon(Icons.female)),
                ],
                selected: {?field.value},
                emptySelectionAllowed: true,
                onSelectionChanged: field.widget.enabled
                    ? (selection) {
                        if (selection.isEmpty) return;
                        field.didChange(selection.first);
                        onChanged(selection.first);
                      }
                    : null,
              ),
              if (field.hasError)
                Padding(
                  padding: const EdgeInsets.only(top: 8, left: 12),
                  child: Text(
                    field.errorText!,
                    style: Theme.of(field.context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(field.context).colorScheme.error,
                        ),
                  ),
                ),
            ],
          ),
        );
}
