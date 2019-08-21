import 'package:flutter/material.dart';
import 'package:expenses2/model/settings.dart';
import 'package:expenses2/ui/expenseUI.dart';

void main() async {
  Settings settings = new Settings();

  Widget _homePage = new ExpenseUI(settings);

  runApp(
    new MaterialApp(
      title: "Cash Collection",
      home: _homePage,
      theme: ThemeData(
        primaryColor: Colors.black,
        backgroundColor: Colors.white,
        buttonColor: Colors.amberAccent,
      ),
    ),
  );
}
