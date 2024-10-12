import 'package:flutter/material.dart';

// showing loading circle
void showLoadingCircle(BuildContext context) {
  showDialog(
      context: context,
      builder: (context) => const AlertDialog(
            backgroundColor: Colors.transparent,
            elevation: 0,
            content: Center(
              child: CircularProgressIndicator(),
            ),
          ));
}

// hiding loading circle
void hideLoadingCircle(BuildContext context) {
  Navigator.pop(context);
}
