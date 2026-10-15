import 'package:flutter/material.dart';

import '../../utils/app_colors.dart';
import '../../utils/app_styles.dart';
import '../utils/app_images.dart';


class CustomErrorWidget extends StatelessWidget {
  const CustomErrorWidget({super.key});

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(AppImages.failureImage,height:MediaQuery.of(context).size.height*0.12,),
          SizedBox(height: MediaQuery.of(context).size.width*0.02,),
          Text(
            "Something went wrong",
            style: AppStyles.semiBold.copyWith(
              color: ColorResource.textInputColor,
              fontSize: 18,
            ),
          ),
          SizedBox(height: MediaQuery.of(context).size.height * 0.005),
          Text(
            "Please try again later",
            style: AppStyles.medium.copyWith(
              color: ColorResource.unselectedLabelColor,
              fontSize: 15,
            ),
          ),
        ],
      ),
    ),
  );
}
