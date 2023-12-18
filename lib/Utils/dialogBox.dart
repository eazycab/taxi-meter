import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:taxi_meter/Utils/provider.dart';

class CustomDialogBox {
  // static final TextEditingController textEditingController =
  //     TextEditingController();

  var value = "";

  static dialogBox(BuildContext context, var value) {
    AwesomeDialog(
            context: context,
            dialogType: DialogType.noHeader,
            animType: AnimType.rightSlide,
            title: 'Total Fare',
            // desc: 'Dialog description here.............',
            body: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Text(
                  'Total Fare:',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: MediaQuery.of(context).size.height * 0.02,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                Text(
                  '\$${value.toStringAsFixed(2)}',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: MediaQuery.of(context).size.height * 0.03,
                    fontWeight: FontWeight.bold,
                    // fontStyle: FontWeight.bold
                  ),
                ),
              ],
            ),
            btnOkOnPress: () {})
        .show();
  }
}
