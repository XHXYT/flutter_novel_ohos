// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class EmptyBuild extends StatelessWidget {
  EmptyBuild({super.key, this.text, this.width = 240});
  final String? text;
  final String str = "没有找到对应资源！";
  late double width;
  @override
  Widget build(BuildContext context) {
    return Center(
        child: SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SvgPicture.asset(
            'assets/svg/empty.svg',
            width: width,
          ),
          Text(text ?? str,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w300))
        ],
      ),
    ));
  }
}
