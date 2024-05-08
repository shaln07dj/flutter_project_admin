import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:pauzible_app/Helper/Constants/colors.dart';
import 'package:pauzible_app/Helper/Constants/constant.dart';
import 'package:pauzible_app/widgets/helper_widgets/text_widget.dart';

class Footer extends StatelessWidget {
  Future<String> getVersionNumber() async {
    try {
      PackageInfo packageInfo = await PackageInfo.fromPlatform();
      return packageInfo.version;
    } catch (e) {
      debugPrint('Error fetching version number: $e');
      return 'Unknown';
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return FutureBuilder<String>(
      future: getVersionNumber(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        }

        if (snapshot.hasError) {
          return const Text('Error fetching version number');
        }

        String versionNumber = snapshot.data!;

        return Container(
          padding: EdgeInsets.all(screenWidth * 0.004),
          color: Color(seedColor),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    TextWidget(
                      displayText: 'version $versionNumber',
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      fontColor: Colors.white,
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextWidget(
                      displayText: footerCopywriteText,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      fontColor: Colors.white,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
