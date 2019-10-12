//import 'package:Moneymate/classes/Homepage.dart';
import 'package:flutter/material.dart';
import 'package:money_mate/classes/Homepage.dart';

void main() {
  runApp( MaterialApp(
	  onGenerateRoute: (RouteSettings settings) {
		  if (settings.name == '/') {
			  return new MaterialPageRoute<Null>(
				  settings: settings,
				  builder: (_) => new Moneymate(),
				  maintainState: false,
			  );
		  }
		  return null;
	  }
  ));
}

class Moneymate extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Moneymate',
      theme: new ThemeData(
        fontFamily: 'Roboto',
      ),
      home: new Homepage()
    );
  }
}