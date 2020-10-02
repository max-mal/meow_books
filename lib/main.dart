
import 'package:catcher/catcher.dart';
import 'package:catcher/handlers/console_handler.dart';
import 'package:catcher/model/catcher_options.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/screens/loadingScreen.dart';


void main() async {

  CatcherOptions debugOptions =
  CatcherOptions(SilentReportMode(), [ConsoleHandler()]);

  CatcherOptions releaseOptions = CatcherOptions(SilentReportMode(), [
    ConsoleHandler()
  ]);

  Catcher(new MaterialApp(
      title: 'SunnaBook',
      home: new LoadingScreen()
  ), debugConfig: debugOptions, releaseConfig: releaseOptions);

}

