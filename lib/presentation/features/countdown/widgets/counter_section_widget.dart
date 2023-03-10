import 'package:flutter/material.dart';
import 'package:launch_tracker_app/presentation/common/theme/app_colors.dart';
import 'package:launch_tracker_app/presentation/common/theme/text_styles.dart';
import 'package:launch_tracker_app/presentation/common/widgets/loader_widget.dart';

class CounterSection extends StatelessWidget {
  const CounterSection({
    super.key,
    required this.name,
    required this.counterValue,
  });

  final String name;
  final ValueNotifier<int?> counterValue;

  @override
  Widget build(BuildContext context) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 15),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ValueListenableBuilder(
            valueListenable: counterValue,
            builder: (context, counter, widget) => counter != null
                ? Text(
                    counter.toString(),
                    style: TextStyles.whiteRegular80,
                  )
                : const Loader(),
          ),
          const SizedBox(height: 10),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5),
              border: Border.all(color: AppColors.white),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            child: Text(
              name.toUpperCase(),
              style: TextStyles.whiteRegular20,
            ),
          )
        ],
      ),
    );
}
