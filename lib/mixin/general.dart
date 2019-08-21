/*----------------------------------------------------------------------------
 *
 * Copyright (C) 2018 Paul Graves and Real Wool Software
 * All Rights Reserved
 * You may not use, distribute and modify this code under any circumstances
 *
 *----------------------------------------------------------------------------*/

import 'package:flutter/material.dart';
import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

abstract class General {

  // This class is intended to be used as a mixin, and should not be
  // extended directly.

  factory General._() => null;

  DateFormat ddmmFormatter = new DateFormat('dd/MM');

  //--------------------------------------------------------------------------//

  bool validateDateString( String dateString )
  {
    debugPrint(">> validateDateString dateString=$dateString");

    List<String> _s = dateString.split("/");
    int _day, _month, _year;


    if ( _s.length > 1 ) {
      _day = int.tryParse(_s[0]);
      _month = int.tryParse(_s[1]);

      if (_s.length == 3) {
        _year = int.tryParse(_s[2]);
        if (_year < 100) _year = 2000 + _year;
      }
      else
        _year = DateTime
            .now()
            .year;
    }

    bool dateValid = ( _day != null && _month != null && _year != null );

    debugPrint(">> _day=$_day _month=$_month _year=$_year dateValid $dateValid");

    return dateValid;
  }

  //--------------------------------------------------------------------------//

  DateTime stringToDate( String dateString ) {
    // Note this assumes the date has already been validated to dd/mm, dd/mm/yy, or dd/mm/yyyy

    debugPrint(">> stringToDate dateString=$dateString");

    List<String> _s = dateString.split("/");
    int _day, _month, _year;

    _day = int.tryParse(_s[0]);
    _month = int.tryParse(_s[1]);

    if (_s.length == 3) {
      _year = int.tryParse(_s[2]);
      if (_year < 100) _year = 2000 + _year;
    }
    else
      _year = DateTime
          .now()
          .year;

    return DateTime.utc(_year, _month, _day);
  }

  //--------------------------------------------------------------------------//

  String dateToStringMmdd(DateTime _dt)
  {
    String _s = "" ;
    if ( _dt != null )
      _s = ddmmFormatter.format(_dt);
    return _s;
  }

  //--------------------------------------------------------------------------//

}