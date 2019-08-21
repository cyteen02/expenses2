import 'package:flutter/material.dart';
import 'package:expenses2/emun/location.dart';
import 'dart:io';

class Receipt{
  DateTime date;
  String description;
  double amount;
  Location location;
  String accountCode;
  Image image;
  File imageFile;

  Receipt()
  {
    description = "";
    accountCode = "";
    amount = 0.0;
  }
}

