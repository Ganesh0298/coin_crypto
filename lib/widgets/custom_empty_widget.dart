import 'package:flutter/material.dart';


import '../../utils/app_colors.dart';
import '../../utils/app_styles.dart';
import '../utils/app_images.dart';

class CustomEmptyWidget extends StatelessWidget {
  const CustomEmptyWidget({super.key});

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(AppImages.noDataFoundImage,height:MediaQuery.of(context).size.height*0.12,),
          SizedBox(height: MediaQuery.of(context).size.width*0.02,),
          Text(
            "No data found",
            style: AppStyles.semiBold.copyWith(
              color: ColorResource.textInputColor,
              fontSize: 16,
            ),
          ),
          SizedBox(height: MediaQuery.of(context).size.height * 0.002),
          Text(
            "No records available at the moment",
            style: AppStyles.medium.copyWith(
              color: ColorResource.unselectedLabelColor,
              fontSize: 14,
            ),
          ),
        ],
      ),
    ),
  );
}
