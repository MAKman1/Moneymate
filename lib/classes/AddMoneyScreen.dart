import 'dart:async';

import 'package:flutter/material.dart';
import 'package:money_mate/backend/TimePair.dart';
import 'package:money_mate/backend/singleExpense.dart';
import 'package:money_mate/classes/DBHelper.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AddMoneyScreen extends StatefulWidget {
	final TimePair tp;

	AddMoneyScreen({Key key, @required this.tp}) : super(key: key);

	@override
	_AddMoneyScreenState createState() {
		return _AddMoneyScreenState();
	}
}

class _AddMoneyScreenState extends State<AddMoneyScreen> {

	@override
	Widget build(BuildContext context) {
		// Build a Form widget using the _formKey we created above
		return new Scaffold(
			appBar: AppBar(
				title: Text("ADD EXPENSE", style: new TextStyle( fontSize: 18.0),),
			),
			body: new MyCustomForm( tp: widget.tp),
		);
	}
	void saveExpense( String amount, String tag, String description){

	}
}
class MyCustomForm extends StatefulWidget {

	final TimePair tp;

	MyCustomForm({Key key, @required this.tp}) : super(key: key);

	@override
	MyCustomFormState createState() {
		return MyCustomFormState();
	}
}

// Create a corresponding State class. This class will hold the data related to
// the form.
class MyCustomFormState extends State<MyCustomForm> {


	List<String> monthNames = ["JANUARY", "FEBRUARY", "MARCH", "APRIL", "MAY", "JUNE", "JULY", "AUGUST", "SEPTEMBER", "OCTOBER", "NOVEMBER", "DECEMBER"];
	// Create a global key that will uniquely identify the Form widget and allow
	// us to validate the form
	//
	// Note: This is a GlobalKey<FormState>, not a GlobalKey<MyCustomFormState>!
	TimePair tp;
	String currency_code = "";
	final _formKey = GlobalKey<FormState>();
	DBHelper localDb;

	TextEditingController amountController;
	TextEditingController tagController;
	TextEditingController descriptionController;

	int date;

	@override
	void dispose() {
		// Clean up the controller when the Widget is disposed
		amountController.dispose();
		tagController.dispose();
		descriptionController.dispose();
		super.dispose();
	}
	_loadvariable() async {     // load variable
		SharedPreferences prefs = await SharedPreferences.getInstance();
		setState(() {
			currency_code = prefs.getString('currency_prefix').trim();
		});
	}

	@override
	void initState(){
		tp = widget.tp;
		date = DateTime.now().day;

		_loadvariable();

		localDb = new DBHelper();

		amountController = TextEditingController( text: '0.0');
		tagController = TextEditingController();
		descriptionController = TextEditingController( text: '');
	}

	@override
	Widget build(BuildContext context) {

		// Build a Form widget using the _formKey we created above



		return Form(
			autovalidate: true,
				key: _formKey,
				child: new ListView(
					children: <Widget>[
						new Padding(padding: EdgeInsets.all( 10.0),
							child: new FlatButton(
								color: Colors.black54,
								child: new Padding(padding: EdgeInsets.all( 5.0),
									child: new Column(
										children: <Widget>[
											new Text( date.toString() + " " + monthNames[ tp.month - 1] + ", " + tp.year.toString(), style:
											new TextStyle(
												color: Colors.white,
												fontWeight: FontWeight.bold,
												fontSize: 30.0,
											),
											),
											/*
										new Text( "Click to change", style:
											new TextStyle(
												color: Colors.lightBlue,
												fontSize: 12.0,
											),
										),
										*/
										],
									),
								),
								onPressed: _selectDate,
							),
						),
						new Padding(padding: EdgeInsets.fromLTRB( 50.0, 60.0, 50.0, 20.0),
								child: new Card(
									child: new TextFormField(
										controller: amountController,
										style: new TextStyle( color: Colors.green, fontSize: 50.0, fontWeight: FontWeight.bold,),
										keyboardType: TextInputType.number,
										decoration: new InputDecoration( labelText: "Amount (" + currency_code + ")", contentPadding: EdgeInsets.all( 10.0), suffixText: "  " + currency_code,
												labelStyle: new TextStyle( color: Colors.lightBlue,fontSize: 15.0, fontWeight: FontWeight.bold),
												suffixStyle: new TextStyle( color: Colors.grey,fontSize: 30.0, fontWeight: FontWeight.bold)),
										validator: (value) {
											if (value.isEmpty) {
												return 'Please enter an amount';
											}
											else if( value == "0.0"){
												return 'Please enter an amount';
											}
											else if( value.contains( ',', 0)){
												return "Kindly input an amount of format \"123.4\", \"60.0\" etc.";
											}
											else if( value.indexOf( '.', 0) != -1 && value.indexOf( '.', 0) < value.length - 2){
												return "Maximum two decimals allowed (ie: 12.0)";
											}
											else if( value.startsWith( '0', 0) && !value.startsWith( '0.', 0)){
												return "invalid amount, cannot begin with 0";
											}
										},
									),
								)
						),
						new Padding(padding: EdgeInsets.fromLTRB( 30.0, 30.0, 30.0, 10.0),
							child: new TextFormField(
								controller: tagController,
								style: new TextStyle( color: Colors.green, fontSize: 30.0, fontWeight: FontWeight.bold,),
								textAlign: TextAlign.left,
								keyboardType: TextInputType.multiline,
								decoration: new InputDecoration(labelText: "TAG", contentPadding: EdgeInsets.all( 10.0),
										labelStyle: new TextStyle( color: Colors.lightBlue,fontSize: 15.0, fontWeight: FontWeight.bold),
										suffixStyle: new TextStyle( color: Colors.grey,fontSize: 30.0, fontWeight: FontWeight.bold)),
								validator: (value) {
									if (value.isEmpty) {
										return 'Please enter a tag (ie: Food, Groceries etc.)';
									}
								},
							),
						),
						new Padding(padding: EdgeInsets.fromLTRB( 30.0, 10.0, 30.0, 10.0),
							child: new TextFormField(
								controller: descriptionController,
								style: new TextStyle( color: Colors.black, fontSize: 30.0, fontWeight: FontWeight.bold,),
								textAlign: TextAlign.left,
								//initialValue: "",
								keyboardType: TextInputType.multiline,
								decoration: new InputDecoration(labelText: "Description (optional)", contentPadding: EdgeInsets.all( 10.0),
										labelStyle: new TextStyle( color: Colors.grey,fontSize: 15.0, fontWeight: FontWeight.bold),
										suffixStyle: new TextStyle( color: Colors.grey,fontSize: 30.0, fontWeight: FontWeight.bold)),
								validator: (value) {
/*
										if (value.isEmpty) {
											return 'Please enter an amount';
										}
										*/
								},
							),
						),
						new Padding(padding: EdgeInsets.all( 40.0),
							child: new RaisedButton(
									child: new Padding(
										padding: EdgeInsets.fromLTRB( 15.0, 10.0, 17.0, 10.0),
										child: new Row(
											mainAxisAlignment: MainAxisAlignment.center,
											children: <Widget>[
												new Icon( Icons.save, color: Colors.white,),
												new Text("  SAVE EXPENSE", style: new TextStyle( color: Colors.white, fontWeight: FontWeight.bold),),
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
													.showSnackBar(SnackBar(content: Text('Saving expense record')));

											String amount = amountController.text;
											String tag = tagController.text;
											String description = descriptionController.text;
											
											localDb.saveExpense( new singleExpense( "1", amount, tag, description, tp.year, tp.month, date));
											print( amount);
											print( tag);
											print( description);
											Navigator.pop(context);

										}
										else{

										}
									}
							),
						)
					],
				) //
		);

	}
	Future _selectDate() async {
		DateTime picked = await showDatePicker(
				context: context,
				initialDate: new DateTime.now(),
				firstDate: new DateTime(2016),
				lastDate: new DateTime(2019)
		);
		if(picked != null){
			setState(() {
				date = picked.day;
				tp = new TimePair( picked.month, picked.year, false);
			});
		}
	}

}
