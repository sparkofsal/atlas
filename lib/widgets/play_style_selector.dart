import 'package:flutter/material.dart';
import '../models/play_style.dart';

class PlayStyleSelector extends StatelessWidget {
  final PlayStyle selectedStyle;
  final ValueChanged<PlayStyle> onSelected;
  final bool sayingsUnlocked;

  const PlayStyleSelector({
    super.key,
    required this.selectedStyle,
    required this.onSelected,
    required this.sayingsUnlocked,
  });

  @override
  Widget build(BuildContext context) {
    final styles = PlayStyle.values;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: styles.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 1.35,
      ),
      itemBuilder: (context, index) {
        final style = styles[index];
        final selected = style == selectedStyle;
        final locked = style == PlayStyle.exploreSayings && !sayingsUnlocked;

        return InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: locked ? null : () => onSelected(style),
          child: Card(
            color: selected
                ? Colors.indigo.withOpacity(0.10)
                : null,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: BorderSide(
                color: selected ? Colors.indigo : Colors.transparent,
                width: 1.5,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    style.emoji,
                    style: const TextStyle(fontSize: 24),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    style.title,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 6),
                  Expanded(
                    child: Text(
                      locked
                          ? 'Unlock sayings at Level 2'
                          : style.subtitle,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                  if (selected)
                    Text(
                      'Active',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.indigo,
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}