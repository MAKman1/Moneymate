import 'dart:async';

import 'package:flutter/material.dart';
import 'package:money_mate/backend/DateAmountPair.dart';
import 'package:money_mate/backend/GraphingData.dart';
import 'package:money_mate/backend/TimePair.dart';
import 'package:money_mate/backend/singleDebt.dart';
import 'package:money_mate/backend/singleExpense.dart';
import 'package:money_mate/classes/AddDebtScreen.dart';
import 'package:money_mate/classes/AddMoneyScreen.dart';
import 'package:money_mate/classes/DBHelper.dart';
import 'package:money_mate/classes/Homepage.dart';
import 'package:money_mate/classes/Settings.dart';
import 'package:money_mate/classes/AllDebtsView.dart';
import 'package:fcharts/fcharts.dart';
import 'package:shared_preferences/shared_preferences.dart';


class HomepageState extends State<Homepage> {


	@override
  Widget build(BuildContext context) {


      return MaterialApp(
        title: 'Moneymate',
        home: new MyTabbedPage(title: 'Moneymate'),
      );
    }

}
class MyTabbedPage extends StatefulWidget {

	final String title;


	const MyTabbedPage({ Key key ,  this.title}) : super(key: key);
	@override
	_MyTabbedPageState createState() => new _MyTabbedPageState();
}

enum MyWidgetTabs { tab1, tab2 , tab3}

class _MyTabbedPageState extends State<MyTabbedPage> with SingleTickerProviderStateMixin<MyTabbedPage>{

	final changeNotifier = new StreamController.broadcast();

	List<String> monthNamesAll = ["JANUARY", "FEBRUARY", "MARCH", "APRIL", "MAY", "JUNE", "JULY", "AUGUST", "SEPTEMBER", "OCTOBER", "NOVEMBER", "DECEMBER"];
	int _month;
	int _year;
	String monthName = "";


	final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
	TabController _tabController;
	MyWidgetTabs _selectedTab;

  _fixCurrencyCode() async {     // load variable
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if( prefs.getString('currency_prefix') == null || prefs.getString('currency_prefix') == ""){
      prefs.setString('currency_prefix', "USD");
      changeMonthInView( _month, _year, true);
    }
  }

	@override
	void initState() {
		super.initState();

    _fixCurrencyCode();

		_month = new DateTime.now().month;
		_year = new DateTime.now().year;
		changeMonthInView( _month, _year, true);
		new Future.delayed(const Duration(milliseconds: 500), () {
			//print( "updated");
			changeMonthInView( _month, _year, false);
		});


		_tabController = new TabController(
				vsync: this, initialIndex: 1, length: MyWidgetTabs.values.length);
		_tabController.addListener( _handleTabSelection);

		_selectedTab = MyWidgetTabs.tab2;

	}

	@override
	void dispose() {
		print( "tab disposed");
		_tabController.dispose();
		changeNotifier.close();
		super.dispose();
	}

	void _handleTabSelection() {
		setState(() {
			_selectedTab = MyWidgetTabs.values[_tabController.index];
			});
		changeMonthInView( _month, _year, true);
	}

	Widget _buildTopTab(BuildContext context, MyWidgetTabs tab) {
		switch (tab) {
			case MyWidgetTabs.tab1:
				return new expensesPage(shouldTriggerChange: changeNotifier.stream);
				break;

			case MyWidgetTabs.tab2:
				return new dashboard(shouldTriggerChange: changeNotifier.stream);
				break;

			case MyWidgetTabs.tab3:
				return new debtPage(shouldTriggerChange: changeNotifier.stream);
				break;
		}
	}

	@override
	Widget build(BuildContext context) {

		//print("Build - main");
		monthName = monthNamesAll[ _month - 1];
		changeMonthInView( _month, _year, true);
		//getData();


		//Expenses tab page of the thing

		Widget bottomMonthWidget =
		new Container(
			height: 35.0,
			decoration: new BoxDecoration(
				boxShadow: [
					BoxShadow(
						color: Colors.grey,
						blurRadius: 6.0, // has the effect of softening the shadow
						spreadRadius: 5.0, // has the effect of extending the shadow
						offset: Offset(0.0, -0.0),
					)
				],
				color: Colors.black87,
			),
			child: new Dismissible(
				resizeDuration: new Duration(milliseconds:100),
				movementDuration: new Duration(milliseconds:50),
				//background: new Text( "loading"),
				//crossAxisEndOffset: 0.5,
				dismissThresholds: const <DismissDirection, double>{ DismissDirection.startToEnd: 0.2, DismissDirection.endToStart: 0.2},
				direction: (_month == DateTime.now().month && _year == DateTime.now().year
						? DismissDirection.startToEnd
						: DismissDirection.horizontal),
				onDismissed: ( direction) {
					print( "direction is: " + direction.toString());
					if( direction == DismissDirection.endToStart){
						if( _month == 12){
							setState(() {
								_year++;
								_month = 1;
							});
						}
						else{
							setState(() {
								_month++;
							});
						}
					}
					else if( direction == DismissDirection.startToEnd){
						if( _month == 1){
							setState(() {
								_year--;
								_month = 12;
							});
						}
						else{
							setState(() {
								_month--;
							});
						}
					}
					else if( direction == DismissDirection.horizontal){
						//print( "direction");
						Scaffold.of(context).showSnackBar(SnackBar(content: Text("Swipe to right")));
					}
				},
				key: new ValueKey( _month),
				child: new Row(
					mainAxisSize: MainAxisSize.min,
					mainAxisAlignment: MainAxisAlignment.center,
					children: <Widget>[
						new GestureDetector(
								key: new ValueKey( 9999),
								onTap: ((){
									if( _month == 1){
										setState(() {
											_year--;
											_month = 12;
										});
									}
									else{
										setState(() {
											_month--;
										});
									}
								}),
								child: new Container(
									height: 35.0,
									child: new Row(
										mainAxisAlignment: MainAxisAlignment.start,
										crossAxisAlignment: CrossAxisAlignment.center,
										mainAxisSize: MainAxisSize.max,
										children: <Widget>[
											Icon( Icons.chevron_left, color: Colors.lightBlue, size: 17.0,),
											Icon( Icons.chevron_left, color: Colors.lightBlue, size: 17.0,),
											Icon( Icons.chevron_left, color: Colors.lightBlue, size: 17.0,),
											Icon( Icons.chevron_left, color: Colors.lightBlue, size: 17.0,),
											Icon( Icons.chevron_left, color: Colors.lightBlue, size: 17.0,)
										],
									),
								)
						),
						new Padding(padding: new EdgeInsets.all(5.0)),
						new Column(
							mainAxisSize: MainAxisSize.min,
							mainAxisAlignment: MainAxisAlignment.center,
							//crossAxisAlignment: CrossAxisAlignment.center,
							children: [
								Text("$monthName" + " " + "$_year", style:
								new TextStyle(
									color: Colors.white,
									fontFamily: 'Roboto',
									fontSize: 18.0,
									fontWeight: FontWeight.bold,
								),
								),
							],
						),
						new Padding(padding: new EdgeInsets.all(5.0)),
						( _month != DateTime.now().month || _year != DateTime.now().year)
								?
						new GestureDetector(
								key: new ValueKey( 1111),
								onTap: ((){
									if( _month == 12){
										setState(() {
											_year++;
											_month = 1;
										});
									}
									else{
										setState(() {
											_month++;
										});
									}
								}),
								child: new Container(
									height: 35.0,
									child: new Row(
										mainAxisAlignment: MainAxisAlignment.end,
										crossAxisAlignment: CrossAxisAlignment.center,
										mainAxisSize: MainAxisSize.min,
										children: <Widget>[
											Icon( Icons.chevron_right, color: Colors.lightBlue, size: 17.0,),
											Icon( Icons.chevron_right, color: Colors.lightBlue, size: 17.0,),
											Icon( Icons.chevron_right, color: Colors.lightBlue, size: 17.0,),
											Icon( Icons.chevron_right, color: Colors.lightBlue, size: 17.0,),
											Icon( Icons.chevron_right, color: Colors.lightBlue, size: 17.0,)
										],
									),
								)
						)
								:
						new Row(
							mainAxisAlignment: MainAxisAlignment.end,
							crossAxisAlignment: CrossAxisAlignment.center,
							mainAxisSize: MainAxisSize.min,
							children: <Widget>[
								Icon( Icons.chevron_right, color: new Color.fromRGBO(5, 5, 5, 0.0), size: 17.0,),
								Icon( Icons.chevron_right, color: new Color.fromRGBO(5, 5, 5, 0.0), size: 17.0,),
								Icon( Icons.chevron_right, color: new Color.fromRGBO(5, 5, 5, 0.0), size: 17.0,),
								Icon( Icons.chevron_right, color: new Color.fromRGBO(5, 5, 5, 0.0), size: 17.0,),
								Icon( Icons.chevron_right, color: new Color.fromRGBO(5, 5, 5, 0.0), size: 17.0,)
							],
						)
					],
				),
			),
		);
		//The side menu bar widget
		Widget sideMenuDrawer = new Drawer(
				child: new ListView(
					children: <Widget>[
            UserAccountsDrawerHeader(
              accountName: new Text('Moneymate', style: new TextStyle( color: Colors.white, fontSize: 25.0, fontWeight: FontWeight.bold,),),
              currentAccountPicture:
              Image.asset( 'icons/main_icon.png'),
              decoration: BoxDecoration(color: Colors.blueAccent),
            ),
						new Padding(padding: EdgeInsets.all(30.0)),
						new ListTile(
							title: new Text('VIEW ALL DEBTS/ CREDITS', style: new TextStyle( color: Colors.blue, fontSize: 15.0, fontWeight: FontWeight.bold,),),
							onTap: () {
								Navigator.push(
									context,
									MaterialPageRoute(builder: (context) => AllDebtsView())
								);
							},
						),
            new ListTile(
              title: new Text('SET BUDGETS', style: new TextStyle( color: Colors.blue, fontSize: 15.0, fontWeight: FontWeight.bold,),),
              onTap: () {

                /*
                Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => AllDebtsView())
                );
                */
              },
            ),
            new Divider(),
            new Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                new ListTile(
                  title: new Text('SETTINGS', style: new TextStyle( color: Colors.black45, fontSize: 13.0, fontWeight: FontWeight.bold,),),
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => Settings())
                    );
                  },
                ),
              ],
            ),
					],
				)
		);


		//The top appBar (header)
		Widget topAppBar = new AppBar(
			bottom: TabBar(
				controller: _tabController,
				tabs: [
					new Tab(
							key: new ValueKey<MyWidgetTabs>(MyWidgetTabs.tab1),
							text: "EXPENSES",
					),
					new Tab(
						key: new ValueKey<MyWidgetTabs>(MyWidgetTabs.tab1),
						icon: new Icon(Icons.home, color: Colors.white,),
					),
					new Tab(
						key: new ValueKey<MyWidgetTabs>(MyWidgetTabs.tab1),
						text: "DEBTS",
					),
				],
				indicatorColor: (Colors.white),
			),
			title: new Row(
				//mainAxisAlignment: MainAxisAlignment.center,
				children: <Widget>[
					new Text( "MoneyMate", style: new TextStyle( color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20.0)),
				],
			),
			backgroundColor: (Colors.lightBlue),
		);


		//The tab layout in the middle
		Widget centerTabLayout = new TabBarView(
			controller: _tabController,
			children: [
			_buildTopTab(context, MyWidgetTabs.tab1),
			_buildTopTab(context, MyWidgetTabs.tab2),
			_buildTopTab(context, MyWidgetTabs.tab3),
				/*
				new expensesPage( shouldTriggerChange: changeNotifier.stream),
				new dashboard(shouldTriggerChange: changeNotifier.stream),
				new debtPage( shouldTriggerChange: changeNotifier.stream),
				*/
			],
		);


		return new Scaffold(
			key: _scaffoldKey,
			drawer: sideMenuDrawer,
			appBar: topAppBar,
			body: centerTabLayout,
			bottomNavigationBar: bottomMonthWidget,
		);
		/*
		return new GestureDetector(
			onHorizontalDragDown: ( temp) {
				print( temp.toString());
				new Future.delayed(const Duration(milliseconds: 100), () {
					//print( "updated");
					changeMonthInView( _month, _year, false);
					new Future.delayed(const Duration(milliseconds: 200), () {
						//print( "updated");
						changeMonthInView( _month, _year, false);
						new Future.delayed(const Duration(milliseconds: 800), () {
							//print( "updated");
							changeMonthInView( _month, _year, true);
							//build( context);
						});
					});
				});
			},
			child: Scaffold(
				key: _scaffoldKey,
				drawer: sideMenuDrawer,
				appBar: topAppBar,
				body: centerTabLayout,
				bottomNavigationBar: bottomMonthWidget,
			),
		);
		*/


	}
	changeMonthInView( int month, int year, bool important){
		changeNotifier.sink.add( new TimePair( month, year, important));
	}
}




class expensesPage extends StatefulWidget{

	final Stream shouldTriggerChange;

	expensesPage({@required this.shouldTriggerChange});

	@override
	State<StatefulWidget> createState() => _expensePageState();
}

class _expensePageState extends State<expensesPage>{


  Future< List< singleExpense>> allexpenses;
  TimePair tp;
  String currency_code = "";

  StreamSubscription streamSubscription;
  List<String> monthNamesAll = ["JAN", "FEB", "MAR", "APR", "MAY", "JUN", "JUL", "AUG", "SEP", "OCT", "NOV", "DEC"];


  @override
  initState() {
	  super.initState();
	  streamSubscription = widget.shouldTriggerChange.listen(( data) => changeMonth( data));
	  _loadvariable();
	  print( "init");
  }
  _loadvariable() async {     // load variable
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      currency_code = prefs.getString('currency_prefix').trim();
    });
  }
  @override
  didUpdateWidget(expensesPage old) {
	  super.didUpdateWidget(old);
	  // in case the steam instance changed, subscribe to the new one
	  if (widget.shouldTriggerChange != old.shouldTriggerChange) {
		  streamSubscription.cancel();
		  streamSubscription = widget.shouldTriggerChange.listen(( data) => changeMonth( data));
		  print( "updated");
	  }
  }

  @override
  dispose() {
	  print( "expensePage disposed");
	  streamSubscription.cancel();
	  super.dispose();
  }

  @override
  Widget build(BuildContext context) {
	  Widget addExpenseButton = new Container(
			  height: MediaQuery.of(context).size.height,
			  child: new Column(
				  children: <Widget>[
					  new Row(
						  mainAxisAlignment: MainAxisAlignment.center,
						  crossAxisAlignment: CrossAxisAlignment.center,
						  children: <Widget>[
							  new RaisedButton(
									  child: new Padding(
										  padding: EdgeInsets.fromLTRB( 15.0, 10.0, 17.0, 10.0),
										  child: new Row(
											  mainAxisAlignment: MainAxisAlignment.center,
											  children: <Widget>[
												  new Icon( Icons.add_circle_outline, color: Colors.white,),
												  new Text("  ADD EXPENSE", style: new TextStyle( color: Colors.white, fontWeight: FontWeight.bold),),
											  ],
										  ),
									  ),
									  elevation: 8.0,
									  splashColor: Colors.blueGrey,
									  color: Colors.lightBlue,
									  shape: new RoundedRectangleBorder( borderRadius: new BorderRadius.circular(50.0)),
									  onPressed:(){
										  Navigator.push(
											  context,
											  MaterialPageRoute(builder: (context) => AddMoneyScreen( tp: this.tp)),
										  ).then(( value){
											  print( "came backk");
											  forceFullyChangeMonth( tp);
										  });
									  }
							  ),
						  ],
					  ),
					  new Padding(padding: EdgeInsets.all( 5.0)),
				  ],
				  mainAxisAlignment: MainAxisAlignment.end,
				  crossAxisAlignment: CrossAxisAlignment.center,
			  )
	  );


        return new Container(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          //color: Colors.black,
          child: new FutureBuilder< List< singleExpense>>(
            future: allexpenses,
            builder: (context, snapshot){
              if(snapshot.hasData){
              	if( snapshot.data.length > 0){
              		return new Stack(
						children: <Widget>[
							new Column(
							children: <Widget>[
							new Expanded(
							child: new ListView.builder(
							itemCount: snapshot.data.length,
									itemBuilder: (BuildContext ctx, int indexTab) {
										return new GestureDetector(
												onTap: (){
													_showLongPressPopUp( snapshot.data[ indexTab].id, snapshot.data[ indexTab].tags, snapshot.data[ indexTab].amount);
												},
												child: new Card(
														margin: EdgeInsets.fromLTRB( 10.0, 5.0, 10.0, 0.0),
														child: new SizedBox(
															width: double.infinity,
															child: new Row(
																//mainAxisSize: MainAxisSize.max,
																mainAxisAlignment: MainAxisAlignment.spaceAround,
																children: <Widget>[
																	new Card(
																			margin: EdgeInsets.fromLTRB( 5.0, 5.0, 30.0, 5.0),
																			color: Colors.green,
																			child: new Padding(
																				padding: new EdgeInsets.fromLTRB( 10.0, 5.0, 10.0, 5.0),
																				child: new Column(
																						mainAxisAlignment: MainAxisAlignment.start,
																						crossAxisAlignment: CrossAxisAlignment.center,
																						children: [
																							Text( snapshot.data[ indexTab].date.toString(), style: new TextStyle(
																								color: Colors.white,
																								fontSize: 30.0,
																								fontWeight: FontWeight.bold,
																							),
																							),
																							Text( monthNamesAll[ snapshot.data[ indexTab].month-1], style: new TextStyle(
																								color: Colors.white,
																							),
																							),
																						]
																				),
																			)
																	),
																	new Expanded(
																		//fit: FlexFit.tight,
																		child: new Column(
																			mainAxisAlignment: MainAxisAlignment.center,
																			crossAxisAlignment: CrossAxisAlignment.start,
																			children: <Widget>[
																				Text( snapshot.data[ indexTab].tags.toUpperCase(), style: new TextStyle(
																					color: Colors.green,
																					fontWeight: FontWeight.bold,
																					fontSize: 20.0,
																				),
																				),
																				Text( snapshot.data[ indexTab].description, style: new TextStyle(
																					color: Colors.black26,
																					fontWeight: FontWeight.bold,
																				),
																				),
																			],
																		),
																	),
																	new Container(
																		height: 30.0,
																		width: 1.0,
																		color: Colors.black26,
																		margin: const EdgeInsets.only(left: 5.0, right: 7.0),
																	),
																	new Padding(
																		padding: EdgeInsets.fromLTRB( 10.0, 5.0, 10.0, 5.0),
																		child: new Column(
																				mainAxisAlignment: MainAxisAlignment.center,
																				crossAxisAlignment: CrossAxisAlignment.center,
																				children: [
																					Text( snapshot.data[ indexTab].amount, style: new TextStyle(
																							color: Colors.blue,
																							fontSize: 25.0,
																							fontWeight: FontWeight.bold
																					),
																					),
																					Text( currency_code, style: new TextStyle(
																						fontWeight: FontWeight.bold,
																						color: Colors.black38,
																					),
																					),
																				]
																		),
																	),
																],
															),
														)
												),
										);
										}
									)
								)
							],
						),
						addExpenseButton,
						],
					);
				}
				else{
              		return new Stack(
						children: <Widget>[
							addExpenseButton,
							new Container(alignment: AlignmentDirectional.center,child: new Text( "No expense record", style: new TextStyle( color: Colors.grey),),)
						],
					);
				}
              } /*else if( snapshot.hasData == false){
				  return new Stack(
					  children: <Widget>[
						  addExpenseButton,
						  new Container(alignment: AlignmentDirectional.center,child: new Text( "No expense record", style: new TextStyle( color: Colors.grey),),)
					  ],
				  );
              }
              */
              return new Container(alignment: AlignmentDirectional.center,child: new CircularProgressIndicator(), color: Colors.white,);
            }
          ),
        );
  }
  void changeMonth ( TimePair temp) async{
	  if( tp == null || temp.important || (tp.month != temp.month || tp.year != temp.year)){
		  getExpenses( temp.month, temp.year);
		  tp = temp;
	  }
  }
  void forceFullyChangeMonth ( TimePair temp) async{
	  getExpenses( temp.month, temp.year);
  }
  void getExpenses( int month, int year) async{
	  DBHelper localDb = DBHelper();
	  //localDb.saveExpense( new singleExpense( "1", "500", "free", "data", 2018, 9, 3));
	  //localDb.saveDebt( new singleDebt( "1", "500", "money saad", 1, "saad", 2018, 9, 4));
	  setState(() {
		  allexpenses = localDb.getExpenses( month, year);
	  });
	  //return allData;
  }
  Future<Null> _showLongPressPopUp( String id, String tag, String amount) async {
	  DBHelper localdb = DBHelper();
	  switch (await showDialog<String>(
			  context: context,
			  builder: (BuildContext context) {
				  return new SimpleDialog(
					  title: new Row(
						  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
						  children: <Widget>[
							  new Card(
								  color: Colors.lightBlue,
								  child: new Padding( padding: EdgeInsets.all( 10.0), child: new Text( tag.toUpperCase() + " ~ " +
										  amount.toUpperCase() + " " + currency_code, style: new TextStyle( color: Colors.white, fontWeight: FontWeight.bold,
										  fontSize: 20.0))),
							  )
						  ],
					  ),
					  children: <Widget>[
						  new SimpleDialogOption(
								  onPressed: () {
									  localdb.deleteExpense( id).whenComplete((){
										  forceFullyChangeMonth( tp);
									  });
									  Navigator.pop( context);
								  },//Navigator.pop(context, Department.treasury); },
								  child: new Row(
									  mainAxisAlignment: MainAxisAlignment.center,
									  children: <Widget>[
										  new Text( "Delete", style: new TextStyle( color: Colors.black54, fontWeight: FontWeight.bold,
												  fontSize: 15.0),)
									  ],
								  )
						  ),
					  ],
				  );
			  }
	  )) {
	  }
  }
}
class debtPage extends StatefulWidget{

	final Stream shouldTriggerChange;

	debtPage({@required this.shouldTriggerChange});

	@override
	State<StatefulWidget> createState() => _debtPageState();
}

class _debtPageState extends State<debtPage>{


	Future< List< singleDebt>> allexpenses;
	TimePair tp;
	String currency_code = "";

	StreamSubscription streamSubscription;
	List<String> monthNamesAll = ["JAN", "FEB", "MAR", "APR", "MAY", "JUN", "JUL", "AUG", "SEP", "OCT", "NOV", "DEC"];


	@override
	initState() {
		super.initState();
		streamSubscription = widget.shouldTriggerChange.listen(( data) => changeMonth( data));
		_loadvariable();
		print( "init debt");
	}
  _loadvariable() async {     // load variable
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      currency_code = prefs.getString('currency_prefix').trim();
    });
  }
	@override
	didUpdateWidget(debtPage old) {
		super.didUpdateWidget(old);
		// in case the steam instance changed, subscribe to the new one
		if (widget.shouldTriggerChange != old.shouldTriggerChange) {
			streamSubscription.cancel();
			streamSubscription = widget.shouldTriggerChange.listen(( data) => changeMonth( data));
			//print( "updated");
		}
	}

	@override
	dispose() {
		print( "debtPage disposed");
		streamSubscription.cancel();
		super.dispose();
	}

	@override
	Widget build(BuildContext context) {
		Widget addDebtButton = new Container(
				height: MediaQuery.of(context).size.height,
				child: new Column(
					children: <Widget>[
						new Row(
							mainAxisAlignment: MainAxisAlignment.center,
							crossAxisAlignment: CrossAxisAlignment.center,
							children: <Widget>[
								new RaisedButton(
										child: new Padding(
											padding: EdgeInsets.fromLTRB( 15.0, 10.0, 17.0, 10.0),
											child: new Row(
												mainAxisAlignment: MainAxisAlignment.center,
												children: <Widget>[
													new Icon( Icons.add_circle_outline, color: Colors.white,),
													new Text("  ADD DEBT/ CREDIT", style: new TextStyle( color: Colors.white, fontWeight: FontWeight.bold),),
												],
											),
										),
										elevation: 8.0,
										splashColor: Colors.blueGrey,
										color: Colors.lightBlue,
										shape: new RoundedRectangleBorder( borderRadius: new BorderRadius.circular(50.0)),
										onPressed:(){
											Navigator.push(
												context,
												MaterialPageRoute(builder: (context) => AddDebtScreen( tp: this.tp)),
											).then(( value){
												print( "came backk");
												forceFullyChangeMonth( tp);
											});
										}
								),
							],
						),
						new Padding(padding: EdgeInsets.all( 5.0)),
					],
					mainAxisAlignment: MainAxisAlignment.end,
					crossAxisAlignment: CrossAxisAlignment.center,
				)
		);


		return new Container(
			height: MediaQuery.of(context).size.height,
			width: MediaQuery.of(context).size.width,
			//color: Colors.black,
			child: new FutureBuilder< List< singleDebt>>(
					future: allexpenses,
					builder: (context, snapshot){
						if(snapshot.hasData){
							if( snapshot.data.length > 0){
								return new Stack(
									children: <Widget>[
										new Column(
											children: <Widget>[
												new Expanded(
														child: new ListView.builder(
																itemCount: snapshot.data.length,
																itemBuilder: (BuildContext ctx, int indexTab) {
																	if( snapshot.data[ indexTab].mine == 1){
																		return new GestureDetector(
																				onTap: (){
																					_showLongPressPopUp( snapshot.data[ indexTab].id, snapshot.data[ indexTab].tofro, snapshot.data[ indexTab].amount);
																				},
																				child: new Card(
																						margin: EdgeInsets.fromLTRB( 10.0, 5.0, 10.0, 0.0),
																						child: new SizedBox(
																							width: double.infinity,
																							child: new Row(
																								//mainAxisSize: MainAxisSize.max,
																								mainAxisAlignment: MainAxisAlignment.spaceAround,
																								children: <Widget>[
																									new Card(
																											margin: EdgeInsets.fromLTRB( 5.0, 5.0, 30.0, 5.0),
																											color: Colors.green,
																											child: new Padding(
																												padding: new EdgeInsets.fromLTRB( 10.0, 5.0, 10.0, 5.0),
																												child: new Column(
																														mainAxisAlignment: MainAxisAlignment.start,
																														crossAxisAlignment: CrossAxisAlignment.center,
																														children: [
																															Text( snapshot.data[ indexTab].date.toString(), style: new TextStyle(
																																color: Colors.white,
																																fontSize: 30.0,
																																fontWeight: FontWeight.bold,
																															),
																															),
																															Text( monthNamesAll[ snapshot.data[ indexTab].month-1], style: new TextStyle(
																																color: Colors.white,
																															),
																															),
																														]
																												),
																											)
																									),
																									new Expanded(
																										//fit: FlexFit.tight,
																										child: new Column(
																											mainAxisAlignment: MainAxisAlignment.center,
																											crossAxisAlignment: CrossAxisAlignment.start,
																											children: <Widget>[
																												Text( snapshot.data[ indexTab].tofro.toUpperCase(), style: new TextStyle(
																													color: Colors.green,
																													fontWeight: FontWeight.bold,
																													fontSize: 20.0,
																												),
																												),
																												Text( snapshot.data[ indexTab].description, style: new TextStyle(
																													color: Colors.black26,
																													fontWeight: FontWeight.bold,
																												),
																												),
																											],
																										),
																									),
																									new Container(
																										height: 30.0,
																										width: 1.0,
																										color: Colors.black26,
																										margin: const EdgeInsets.only(left: 5.0, right: 7.0),
																									),
																									new Padding(
																										padding: EdgeInsets.fromLTRB( 10.0, 5.0, 10.0, 5.0),
																										child: new Column(
																												mainAxisAlignment: MainAxisAlignment.center,
																												crossAxisAlignment: CrossAxisAlignment.center,
																												children: [
																													Text( snapshot.data[ indexTab].amount, style: new TextStyle(
																															color: Colors.blue,
																															fontSize: 25.0,
																															fontWeight: FontWeight.bold
																													),
																													),
																													Text( currency_code, style: new TextStyle(
																														fontWeight: FontWeight.bold,
																														color: Colors.black38,
																													),
																													),
																												]
																										),
																									),
																								],
																							),
																						)
																				),
																		);
																	}
																	else {
																		return new GestureDetector(
																			onTap: () {
																				_showLongPressPopUp( snapshot.data[ indexTab].id, snapshot.data[ indexTab].tofro, snapshot.data[ indexTab].amount);
																			},
																			child: new Card(
																					margin: EdgeInsets
																							.fromLTRB(
																							10.0,
																							5.0,
																							10.0,
																							0.0),
																					child: new SizedBox(
																						width: double
																								.infinity,
																						child: new Row(
																							//mainAxisSize: MainAxisSize.max,
																							mainAxisAlignment: MainAxisAlignment
																									.spaceAround,
																							children: <
																									Widget>[
																								new Card(
																										margin: EdgeInsets
																												.fromLTRB(
																												5.0,
																												5.0,
																												30.0,
																												5.0),
																										color: Colors
																												.red,
																										child: new Padding(
																											padding: new EdgeInsets
																													.fromLTRB(
																													10.0,
																													5.0,
																													10.0,
																													5.0),
																											child: new Column(
																													mainAxisAlignment: MainAxisAlignment
																															.start,
																													crossAxisAlignment: CrossAxisAlignment
																															.center,
																													children: [
																														Text(
																															snapshot
																																	.data[ indexTab]
																																	.date
																																	.toString(),
																															style: new TextStyle(
																																color: Colors
																																		.white,
																																fontSize: 30.0,
																																fontWeight: FontWeight
																																		.bold,
																															),
																														),
																														Text(
																															monthNamesAll[ snapshot
																																	.data[ indexTab]
																																	.month -
																																	1],
																															style: new TextStyle(
																																color: Colors
																																		.white,
																															),
																														),
																													]
																											),
																										)
																								),
																								new Expanded(
																									//fit: FlexFit.tight,
																									child: new Column(
																										mainAxisAlignment: MainAxisAlignment
																												.center,
																										crossAxisAlignment: CrossAxisAlignment
																												.start,
																										children: <
																												Widget>[
																											Text(
																												"PAY TO: " +
																														snapshot
																																.data[ indexTab]
																																.tofro
																																.toUpperCase(),
																												style: new TextStyle(
																													color: Colors
																															.red,
																													fontWeight: FontWeight
																															.bold,
																													fontSize: 20.0,
																												),
																											),
																											Text(
																												snapshot
																														.data[ indexTab]
																														.description,
																												style: new TextStyle(
																													color: Colors
																															.black26,
																													fontWeight: FontWeight
																															.bold,
																												),
																											),
																										],
																									),
																								),
																								new Container(
																									height: 30.0,
																									width: 1.0,
																									color: Colors
																											.black26,
																									margin: const EdgeInsets
																											.only(
																											left: 5.0,
																											right: 7.0),
																								),
																								new Padding(
																									padding: EdgeInsets
																											.fromLTRB(
																											10.0,
																											5.0,
																											10.0,
																											5.0),
																									child: new Column(
																											mainAxisAlignment: MainAxisAlignment
																													.center,
																											crossAxisAlignment: CrossAxisAlignment
																													.center,
																											children: [
																												Text(
																													snapshot
																															.data[ indexTab]
																															.amount,
																													style: new TextStyle(
																															color: Colors
																																	.brown,
																															fontSize: 25.0,
																															fontWeight: FontWeight
																																	.bold
																													),
																												),
																												Text(
																													currency_code,
																													style: new TextStyle(
																														fontWeight: FontWeight
																																.bold,
																														color: Colors
																																.black38,
																													),
																												),
																											]
																									),
																								),
																							],
																						),
																					)
																			),
																		);
																	}

																}
														)
												),
											],
										),
										addDebtButton,
									],
								);
							}
							else{
								return new Stack(
									children: <Widget>[
										addDebtButton,
										new Container(alignment: AlignmentDirectional.center,child: new Text( "No debt record", style: new TextStyle( color: Colors.grey),),)
									],
								);
							}
						} /*else if( snapshot.hasData == false){
							return new Stack(
								children: <Widget>[
									addDebtButton,
									new Container(alignment: AlignmentDirectional.center,child: new Text( "No debt record", style: new TextStyle( color: Colors.grey),),)
								],
							);
						}
						*/
						return new Container(alignment: AlignmentDirectional.center,child: new CircularProgressIndicator(), color: Colors.white,);
					}
			),
		);
	}
	void changeMonth ( TimePair temp) async{
		if( tp == null || temp.important || (tp.month != temp.month || tp.year != temp.year)){
			getDebts( temp.month, temp.year);
			tp = temp;
		}
	}
	void forceFullyChangeMonth ( TimePair temp) async{
		getDebts( temp.month, temp.year);
	}
	void getDebts( int month, int year) async{
		DBHelper localDb = DBHelper();
		//localDb.saveExpense( new singleExpense( "1", "500", "free", "data", 2018, 9, 3));
		//localDb.saveDebt( new singleDebt( "1", "500", "money saad", 1, "saad", 2018, 9, 4));
		setState(() {
			allexpenses = localDb.getDebts( month, year);
		});
		//return allData;
	}
	Future<Null> _showLongPressPopUp( String id, String tag, String amount) async {
		DBHelper localdb = DBHelper();
		switch (await showDialog<String>(
				context: context,
				builder: (BuildContext context) {
					return new SimpleDialog(
						title: new Row(
							mainAxisAlignment: MainAxisAlignment.spaceEvenly,
							children: <Widget>[
								new Card(
									color: Colors.lightBlue,
									child: new Padding( padding: EdgeInsets.all( 10.0), child: new Text( tag.toUpperCase() + " ~ " +
												amount.toUpperCase() + " " + currency_code, style: new TextStyle( color: Colors.white, fontWeight: FontWeight.bold,
												fontSize: 20.0))),
								)
							],
						),
						children: <Widget>[
							new SimpleDialogOption(
								onPressed: () {
									localdb.deleteDebt( id).whenComplete((){
										forceFullyChangeMonth( tp);
									});
									Navigator.pop( context);
								},//Navigator.pop(context, Department.treasury); },
								child: new Row(
									mainAxisAlignment: MainAxisAlignment.center,
									children: <Widget>[
										new Text( "Delete", style: new TextStyle( color: Colors.black54, fontWeight: FontWeight.bold,
											fontSize: 15.0),)
									],
								)
							),
						],
					);
				}
		)) {
		}
	}
}
class dashboard extends StatefulWidget{

	final Stream shouldTriggerChange;

	dashboard({@required this.shouldTriggerChange});

	@override
	State<StatefulWidget> createState() => _dashboardState();
}

class _dashboardState extends State<dashboard> {


	Future< GraphingData> allexpenses;
	TimePair tp;
  String currency_code = "";

	StreamSubscription streamSubscription;


	@override
	initState() {
		super.initState();
		changeMonth( new TimePair( DateTime.now().month, DateTime.now().year, false));
		_loadvariable();
		streamSubscription = widget.shouldTriggerChange.listen(( data) => changeMonth( data));
	}
  _loadvariable() async {     // load variable
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      currency_code = prefs.getString('currency_prefix').trim();
    });
  }
	@override
	didUpdateWidget(dashboard old) {
		super.didUpdateWidget(old);
		// in case the steam instance changed, subscribe to the new one
		if (widget.shouldTriggerChange != old.shouldTriggerChange) {
			streamSubscription.cancel();
			streamSubscription = widget.shouldTriggerChange.listen(( data) => changeMonth( data));
			//print( "updated");
		}
	}

	@override
	dispose() {
		print( "dashboard disposed");
		streamSubscription.cancel();
		super.dispose();
	}

	@override
	Widget build(BuildContext context) {
		print( "rebuilt dashboard!!!!!");
		Widget addExpenseButton = new RaisedButton(
				child: new Padding(
					padding: EdgeInsets.fromLTRB( 15.0, 10.0, 17.0, 10.0),
					child: new Row(
						mainAxisAlignment: MainAxisAlignment.center,
						children: <Widget>[
							new Icon( Icons.add_circle_outline, color: Colors.white,),
							new Text("  ADD EXPENSE", style: new TextStyle( color: Colors.white, fontWeight: FontWeight.bold),),
						],
					),
				),
				elevation: 8.0,
				splashColor: Colors.blueGrey,
				color: Colors.lightBlue,
				shape: new RoundedRectangleBorder( borderRadius: new BorderRadius.circular(50.0)),
				onPressed:(){
					Navigator.push(
						context,
						MaterialPageRoute(builder: (context) => AddMoneyScreen( tp: this.tp)),
					).then(( value){
						print( "came backk");
						forceFullyChangeMonth( tp);
					});
				}
		);
		Widget addDebtButton = new RaisedButton(
				child: new Padding(
					padding: EdgeInsets.fromLTRB( 15.0, 10.0, 17.0, 10.0),
					child: new Row(
						mainAxisAlignment: MainAxisAlignment.center,
						children: <Widget>[
							new Icon( Icons.add_circle_outline, color: Colors.white,),
							new Text("  ADD DEBT/ CREDIT", style: new TextStyle( color: Colors.white, fontWeight: FontWeight.bold),),
						],
					),
				),
				elevation: 8.0,
				splashColor: Colors.blueGrey,
				color: Colors.blue,
				shape: new RoundedRectangleBorder( borderRadius: new BorderRadius.circular(50.0)),
				onPressed:(){
					Navigator.push(
						context,
						MaterialPageRoute(builder: (context) => AddDebtScreen( tp: this.tp)),
					).then(( value){
						print( "came backk");
						forceFullyChangeMonth( tp);
					});
				}
		);

		return new Container(
			height: MediaQuery.of(context).size.height,
			width: MediaQuery.of(context).size.width,
			//color: Colors.black,
			child: new FutureBuilder< GraphingData>(
					future: allexpenses,
					builder: (context, snapshot){
						if(snapshot.hasData){
							return new ListView(
								shrinkWrap: true,
								children: <Widget>[
									new Column(
										children: <Widget>[
											( snapshot.data.totalExpenses != "0.0" ?
												new Container(
													height: 150.0,
													width: MediaQuery.of(context).size.width,
													child: new AmountLineChart( snapshot.data.expenses),//MoneyExpensesChart(),
												)
												:
											new Container(
												height: 150.0,
												width: MediaQuery.of(context).size.width,
												child: null
											)
											),
											new Text( "TOTAL EXPENSES (" + currency_code + ")", style: new TextStyle( color: Colors.black54, fontSize: 15.0, fontWeight: FontWeight.bold),),
											new Text( snapshot.data.totalExpenses.toString(), style: new TextStyle( color: Colors.lightBlue, fontSize: 50.0, fontWeight: FontWeight.bold),),
											new Padding(
												padding: EdgeInsets.fromLTRB( 20.0, 40.0, 20.0, 20.0),
												child: new Card(
													child: new Container(
															width: MediaQuery.of(context).size.width,
															child: new Row(
																mainAxisSize: MainAxisSize.max,
																mainAxisAlignment: MainAxisAlignment.spaceEvenly,
																crossAxisAlignment: CrossAxisAlignment.center,
																children: <Widget>[
																	new Expanded(
																		child: new Card(
																			color: Colors.green,
																			child: new Column(
																				children: <Widget>[
																					new Text( "TOTAL CREDIT (" + currency_code + ")", style: new TextStyle( color: Colors.yellow, fontWeight: FontWeight.bold, fontSize: 15.0),),
																					new Text( snapshot.data.totalDebts.toString(), style: new TextStyle( color: Colors.white, fontWeight: FontWeight.bold, fontSize: 30.0),),
																				],
																			),
																		),
																	),
																	new Expanded(
																		child: new Card(
																			color: Colors.red,
																			child: new Column(
																				children: <Widget>[
																					new Text( "TOTAL DEBT (" + currency_code + ")", style: new TextStyle( color: Colors.yellow, fontWeight: FontWeight.bold, fontSize: 15.0),),
																					new Text( snapshot.data.totalCredits.toString(), style: new TextStyle( color: Colors.white, fontWeight: FontWeight.bold, fontSize: 30.0),),
																				],
																			),
																		),
																	),
																],
															)
													),
												),
											),
											new Padding(
												padding: EdgeInsets.fromLTRB( 70.0, 20.0, 70.0, 10.0),
												child: addExpenseButton,
											),
											new Padding(
												padding: EdgeInsets.fromLTRB( 70.0, 10.0, 70.0, 10.0),
												child: addDebtButton,
											),
										],
									)
								],
							);
						}
						return new Container(alignment: AlignmentDirectional.center,child: new CircularProgressIndicator(), color: Colors.white,);
					}
			),
		);
	}
	void changeMonth ( TimePair temp) async{
		if( tp == null || temp.important || (tp.month != temp.month || tp.year != temp.year)){
			getDebts( temp.month, temp.year);
			tp = temp;
		}
	}
	void forceFullyChangeMonth ( TimePair temp) async{
		getDebts( temp.month, temp.year);
	}
	void getDebts( int month, int year) async{
		DBHelper localDb = DBHelper();
		//localDb.saveExpense( new singleExpense( "1", "500", "TRIP TO IZMIR IZMIR", "data", 2018, 10, 4));
		//localDb.saveDebt( new singleDebt( "1", "500", "money saad", 1, "MUHAMMAD ARHAM KHAN", 2018, 10, 4));
		setState(() {
			allexpenses = localDb.getDetailedData( month, year);
			//print( "mujhe anday wala burger!!!!!");
		});
		//return allData;
	}
}

class AmountLineChart extends StatelessWidget {

	List< double> allData;

	AmountLineChart( this.allData);

	@override
	Widget build(BuildContext context) {

		return new AspectRatio(
			aspectRatio: 3.0,
			child: new LineChart(
				lines: [
					new Sparkline(
						data: allData,
						stroke: new PaintOptions.stroke(
							color: Colors.black26,
							strokeWidth: 4.0,
						),
					),
				],
			),
		);

	}
}