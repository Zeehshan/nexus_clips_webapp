import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class SnackBarWidget {
  // TODO
  void showNoInternetBanner({required BuildContext context}) {
    ScaffoldMessenger.of(context).showMaterialBanner(
      const MaterialBanner(
        content: Text('No Internet connection'),
        leading: Icon(Icons.add),
        backgroundColor: Colors.yellow,
        actions: [Text('a')],
      ),
    );
  }

  void showSuccess({required String message}) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      backgroundColor: Colors.green,
      textColor: Colors.white,
    );
  }

  void showInfo({required String message}) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      backgroundColor: Colors.lightBlueAccent,
      textColor: Colors.white,
    );
  }

  void showWarning({required String message}) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      backgroundColor: Colors.brown.shade200,
      textColor: Colors.white,
    );
  }

  void showError({String? error}) {
    Fluttertoast.showToast(
      msg: error ?? 'Something went wrong try again', // TODO
      toastLength: Toast.LENGTH_LONG,
      backgroundColor: Colors.red,
      textColor: Colors.white,
    );
  }

  void cancelToast() {
    Fluttertoast.cancel();
  }
}
