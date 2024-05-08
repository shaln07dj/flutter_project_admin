import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class LoadingWidget extends StatelessWidget {
  final String? loadingText;

  const LoadingWidget({super.key, this.loadingText});

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return ScreenUtilInit(
      designSize: Size(screenWidth, screenHeight),
      builder: (BuildContext context, Widget? child) {
        return Center(
          child: Container(
            width: 600.w,
            alignment: Alignment.center,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                LoadingAnimationWidget.staggeredDotsWave(
                  color: const Color(0xFF0E5EB6),
                  size: 50,
                ),
                if (loadingText != null)
                  Padding(
                    padding: EdgeInsets.all(ScreenUtil().setWidth(8.0)),
                    child: Center(
                      child: Text(
                        loadingText!,
                        maxLines: 2,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 18.sp,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
