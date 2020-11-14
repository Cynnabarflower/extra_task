import 'dart:async';

import 'package:flutter/material.dart';

class AppTheme {

  ThemeData themeData;

  AppTheme(this.themeData);

  // ignore: non_constant_identifier_names
  static final AppTheme DARK_THEME = AppTheme(ThemeData.dark().copyWith(

    textTheme: ThemeData.light().textTheme.apply(
      bodyColor: Colors.grey.shade300,
      displayColor: Colors.grey.shade300,
      decorationColor: Colors.grey.shade300,
      fontFamily: 'Consolas'
    ),
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: Colors.transparent,
        ),
      ),
    backgroundColor: Colors.black,
    iconTheme: ThemeData.light().iconTheme.copyWith(
      color: Colors.grey.shade300
    )
  ));

  // ignore: non_constant_identifier_names
  static final AppTheme LIGHT_THEME = AppTheme(ThemeData.light().copyWith(
    backgroundColor: Colors.lightBlue,
    indicatorColor: Colors.white,
    textTheme: ThemeData.light().textTheme.apply(
      bodyColor: Colors.lightBlue,
      displayColor: Colors.lightBlue,
      decorationColor: Colors.lightBlue,
      fontFamily: 'Consolas'
    ),
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: Colors.transparent,
        ),
      ),
      iconTheme: ThemeData.light().iconTheme.copyWith(
          color: Colors.lightBlue
      ),
    )
  );
}

class ThemeBloc {
  // ignore: close_sinks
  final _themeStreamController = StreamController<AppTheme>();
  ///Change subject call method
  get changeTheTheme => _themeStreamController.sink.add;
  ///Subject data
  get themeData => _themeStreamController.stream;
}

final bloc = ThemeBloc();


void applyTheme(bool light) {
  if (!light) {
    bloc.changeTheTheme(AppTheme.DARK_THEME);
  } else {
    bloc.changeTheTheme(AppTheme.LIGHT_THEME);
  }
}