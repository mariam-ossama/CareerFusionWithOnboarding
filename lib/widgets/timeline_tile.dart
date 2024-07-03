import 'package:career_fusion/constants.dart';
import 'package:flutter/material.dart';
import 'package:timeline_tile/timeline_tile.dart';
import 'package:career_fusion/widgets/event_card.dart';
import 'package:career_fusion/models/timeline_item.dart';

class CustomTimelineTile extends StatelessWidget {
  final bool isFirst;
  final bool isLast;
  final bool isPast;
  final Widget eventCard;
  final VoidCallback onDelete;
  final VoidCallback onEdit;
  final Function(bool?) onCheckboxChanged; // Accept index
  final TimelineItem item;
  final int? index; // New parameter for index

  CustomTimelineTile({
    required this.isFirst,
    required this.isLast,
    required this.isPast,
    required this.eventCard,
    required this.onDelete,
    required this.onEdit,
    required this.onCheckboxChanged,
    required this.item,
    this.index, // Initialize index
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 200,
      child: TimelineTile(
        isFirst: isFirst,
        isLast: isLast,
        hasIndicator: isPast,
        beforeLineStyle: LineStyle(
          color: isPast
              ? mainAppColor
              : secondColor,
        ),
        indicatorStyle: IndicatorStyle(
          width: 40,
          color: isPast
              ? mainAppColor
              : secondColor,
          iconStyle: IconStyle(
            iconData: Icons.done,
            color: isPast ? Colors.white : const Color.fromARGB(255, 142, 142, 246),
          ),
        ),
        endChild: EventCard(
          isPast: isPast,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              eventCard,
              Flexible(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    IconButton(onPressed: onEdit, icon: Icon(Icons.edit, color: Colors.white)),
                    IconButton(onPressed: onDelete, icon: Icon(Icons.delete, color: Colors.white)),
                    Checkbox(
                      value: item.isChecked,
                      onChanged: (newValue) {
                        // Pass index along with the new checkbox value
                        onCheckboxChanged(newValue);
                      },
                      activeColor: Colors.white,
                      checkColor: mainAppColor,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
