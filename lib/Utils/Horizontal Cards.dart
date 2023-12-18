import 'package:flutter/material.dart';

Widget cardBar(BuildContext context, String title, String description) {
  double height = MediaQuery.of(context).size.height;
  double width = MediaQuery.of(context).size.width;
  return SizedBox(
    // height: height * 0.102,
    height: height * 0.126,
    width: width * 0.9,
    child: Card(
      elevation: 3,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(height * 0.023),
      ),
      child: Padding(
        padding: EdgeInsets.all(height * 0.02),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: height * 0.03,
              ),
            ),
            Flexible(
              child: Text(
                description,
                style: TextStyle(
                  fontSize: height * 0.03,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

Widget cardImageBar(BuildContext context, String image) {
  double height = MediaQuery.of(context).size.height;
  double width = MediaQuery.of(context).size.width;
  return Card(
    elevation: 3,
    color: Colors.transparent,
    //shadowColor: Colors.transparent,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(height * 0.023),
    ),
    child: Container(
      height: height * 0.09,
      //  width: width * 0.448,
      width: width * 0.92,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(20)),
        gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomRight,
            colors: [Color(0xFF71BAA8), Color(0xFF7EC249)]),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: width * 0.12,
            child: Center(
              child: Text('gg'),
            ),
          ),
        ],
      ),
    ),
  );
}
