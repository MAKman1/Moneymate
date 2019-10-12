import 'dart:async';

import 'package:flutter/material.dart';
import 'package:money_mate/backend/TimePair.dart';
import 'package:money_mate/backend/singleDebt.dart';
import 'package:money_mate/classes/AddDebtScreen.dart';
import 'package:money_mate/classes/DBHelper.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AllDebtsView extends StatefulWidget{

  AllDebtsView({Key key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _AllDebtsViewState();
}

class _AllDebtsViewState extends State<AllDebtsView>{


  Future< List< singleDebt>> allexpenses;
  String currency_code = "";
  int token = 0;

  TimePair tp;

  List<String> monthNamesAll = ["JAN", "FEB", "MAR", "APR", "MAY", "JUN", "JUL", "AUG", "SEP", "OCT", "NOV", "DEC"];


  @override
  initState() {
    super.initState();
    tp = new TimePair( new DateTime.now().month , new DateTime.now().year, true);
    forceFullyChangeMonth();
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
  didUpdateWidget(AllDebtsView old) {
    super.didUpdateWidget(old);
    // in case the steam instance changed, subscribe to the new one

  }

  @override
  dispose() {
    print( "debtPage disposed");
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
                        forceFullyChangeMonth();
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

    return new Scaffold(
      appBar: AppBar(
        title: Text("VIEW ALL DEBTS/ CREDIT", style: new TextStyle( fontSize: 18.0),),
      ),
      body: new Container(
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
      ),
    );
  }

  void forceFullyChangeMonth () async{
    getDebts();
  }
  void getDebts() async{
    DBHelper localDb = DBHelper();
    //localDb.saveExpense( new singleExpense( "1", "500", "free", "data", 2018, 9, 3));
    //localDb.saveDebt( new singleDebt( "1", "500", "money saad", 1, "saad", 2018, 9, 4));
    setState(() {
      allexpenses = localDb.getAllDebts();
      token++;
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
                      forceFullyChangeMonth();
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