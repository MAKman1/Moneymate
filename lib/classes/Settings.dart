import 'dart:async';
import 'package:flutter/material.dart';
import 'package:money_mate/backend/singleDebt.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Settings extends StatefulWidget {

  Settings({Key key}) : super(key: key);

  @override
  _SettingsState createState() {
    return _SettingsState();
  }
}

class _SettingsState extends State<Settings> {

  @override
  Widget build(BuildContext context) {
    // Build a Form widget using the _formKey we created above
    return new Scaffold(
      appBar: AppBar(
        title: Text("SETTINGS", style: new TextStyle( fontSize: 18.0),),
      ),
      body: new _MyCustomForm(),
    );
  }
  void saveExpense( String amount, String tag, String description){

  }
}
class _MyCustomForm extends StatefulWidget {


  _MyCustomForm({Key key}) : super(key: key);

  @override
  _MyCustomFormState createState() {
    return _MyCustomFormState();
  }
}

// Create a corresponding State class. This class will hold the data related to
// the form.
class _MyCustomFormState extends State<_MyCustomForm> {
  // Create a global key that will uniquely identify the Form widget and allow
  // us to validate the form
  //
  // Note: This is a GlobalKey<FormState>, not a GlobalKey<MyCustomFormState>!

  final _formKey = GlobalKey<FormState>();

  TextEditingController amountController;


  @override
  void dispose() {
    // Clean up the controller when the Widget is disposed
    amountController.dispose();
    super.dispose();
  }
  @override
  void initState(){

    amountController = TextEditingController( text: '');
    _loadvariable();
  }

  _loadvariable() async {     // load variable
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      amountController.text = prefs.getString('currency_prefix').trim();
    });
  }
  _savevariable() async {     // load variable
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      String currency_prefix = amountController.text.trim();
      prefs.setString('currency_prefix', currency_prefix);
    });
  }

  @override
  Widget build(BuildContext context) {

    // Build a Form widget using the _formKey we created above

    return Form(
        autovalidate: true,
        key: _formKey,
        child: new ListView(
          children: <Widget>[
            new Padding(padding: EdgeInsets.fromLTRB( 50.0, 60.0, 50.0, 20.0),
                child: new Card(
                  child: new TextFormField(
                    controller: amountController,
                    style: new TextStyle( color: Colors.green, fontSize: 50.0, fontWeight: FontWeight.bold,),
                    keyboardType: TextInputType.text,
                    decoration: new InputDecoration( labelText: "CURRENCY PREFIX", contentPadding: EdgeInsets.all( 10.0),
                        labelStyle: new TextStyle( color: Colors.lightBlue,fontSize: 15.0, fontWeight: FontWeight.bold)),
                    validator: (value) {
                      if (value.isEmpty) {
                        return 'Please enter a currency';
                      }
                      else if( value.length > 3) {
                        return 'currency code cannot be more than 3 characters long';
                      }
                    },
                  ),
                )
            ),
            new Padding(padding: EdgeInsets.all( 40.0),
              child: new RaisedButton(
                  child: new Padding(
                    padding: EdgeInsets.fromLTRB( 15.0, 10.0, 17.0, 10.0),
                    child: new Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        new Icon( Icons.save, color: Colors.white,),
                        new Text("  SAVE SETTINGS", style: new TextStyle( color: Colors.white, fontWeight: FontWeight.bold),),
                      ],
                    ),
                  ),
                  elevation: 8.0,
                  splashColor: Colors.blueGrey,
                  color: Colors.lightBlue,
                  shape: new RoundedRectangleBorder( borderRadius: new BorderRadius.circular(50.0)),
                  onPressed:(){
                    if (_formKey.currentState.validate()) {
                      // If the form is valid, we want to show a Snackbar
                      Scaffold.of(context)
                          .showSnackBar(SnackBar(content: Text('Saving settings')));
                      _savevariable();
                    }
                  }
              ),
            ),
          ],
        ) //
    );

  }
}
