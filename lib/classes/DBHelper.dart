import 'dart:async';
import 'dart:io' as io;
import 'package:money_mate/backend/DateAmountPair.dart';
import 'package:money_mate/backend/GraphingData.dart';
import 'package:money_mate/backend/singleDebt.dart';
import 'package:money_mate/backend/singleExpense.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';

class DBHelper{

  static Database _db;

  Future<Database> get db async {
    if(_db != null)
      return _db;
    _db = await initDb();
    return _db;
  }

  //Creating a database with name test.dn in your directory
  initDb() async {
    io.Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, "moneyData.db");
    var theDb = await openDatabase(path, version: 1, onCreate: _onCreate);
    return theDb;
  }

  // Creating a table name Employee with fields
  void _onCreate(Database db, int version) async {
    // When creating the db, create the table
    await db.execute(
        "CREATE TABLE expenseRecord(id INTEGER PRIMARY KEY, amount TEXT, tags TEXT, description TEXT, month INTEGER, days INTEGER, year INTEGER)");
    await db.execute(
        "CREATE TABLE debtRecord(id INTEGER PRIMARY KEY, amount TEXT, mine INTEGER, tofro TEXT, description TEXT, month INTEGER, days INTEGER, year INTEGER)");
    print("Created tables");
  }

  Future< List< singleDebt>> getDebts( int month, int year) async {
	  var dbClient = await db;
	  List<Map> debtList = await dbClient.rawQuery('SELECT * FROM debtRecord WHERE month=' + month.toString() + " AND year=" + year.toString() + " Order BY days DESC");

	  List<singleDebt> debts = new List();

	  for (int i = 0; i < debtList.length; i++) {
		  debts.add( new singleDebt( debtList[i]["id"].toString(), debtList[i]["amount"], debtList[i]["description"], debtList[i]["mine"], debtList[i]["tofro"], debtList[i]["year"], debtList[i]["month"], debtList[i]["days"]));
	  }

	  print("debt count: " + debts.length.toString());

	  return debts;
  }
  Future< List< singleDebt>> getAllDebts() async {
    var dbClient = await db;
    List<Map> debtList = await dbClient.rawQuery('SELECT * FROM debtRecord Order BY days, month DESC');

    List< singleDebt> debts = new List();

    for (int i = 0; i < debtList.length; i++) {
      debts.add( new singleDebt( debtList[i]["id"].toString(), debtList[i]["amount"], debtList[i]["description"], debtList[i]["mine"], debtList[i]["tofro"], debtList[i]["year"], debtList[i]["month"], debtList[i]["days"]));
    }

    //print("debt count: " + debts.length.toString());

    return debts;
  }
  Future< List< singleExpense>> getExpenses( int month, int year) async {
	  var dbClient = await db;
	  List<Map> expenseList = await dbClient.rawQuery('SELECT * FROM expenseRecord WHERE month=' + month.toString() + " AND year=" + year.toString() + " Order BY days DESC");

	  List<singleExpense> expenses = new List();

	  for (int i = 0; i < expenseList.length; i++) {
		  expenses.add(new singleExpense(expenseList[i]["id"].toString(), expenseList[i]["amount"], expenseList[i]["tags"], expenseList[i]["description"], expenseList[i]["year"], expenseList[i]["month"], expenseList[i]["days"]));
	  }

	  print("expense count: " + expenses.length.toString());


	  return expenses;
  }

  // Retrieving expenses from Expenses Tables
  Future< GraphingData> getDetailedData( int month, int year) async {
    var dbClient = await db;
    GraphingData tempData = new GraphingData();
    double totalExpenses = 0.0;
    double totalDebt = 0.0;
    double totalCredit = 0.0;

    for( int i = 1; i < 32; i++) {
    	//print( "current i: " + i.toString());
		double expenses = 0.0;
		double debt = 0.0;
		double credit = 0.0;

		List<Map> expenseList = await dbClient.rawQuery(
				"SELECT * FROM expenseRecord WHERE days=" + i.toString() +
						" AND month=" + month.toString() + " AND year=" +
						year.toString());
		List<Map> debtList = await dbClient.rawQuery(
				"SELECT * FROM debtRecord WHERE days=" + i.toString() +
						" AND month=" + month.toString() + " AND year="+
						year.toString() + " AND mine = 1");
		List<Map> creditList = await dbClient.rawQuery(
				"SELECT * FROM debtRecord WHERE days=" + i.toString() +
						" AND month=" + month.toString() + " AND year="+
						year.toString() + " AND mine = 0");

		for (int a = 0; a < expenseList.length; a++) {
			expenses = expenses + double.parse(expenseList[a]["amount"]);
			//print( "the sum is: " + expenses.toString());
		}
		for (int b = 0; b < debtList.length; b++) {
			debt = debt + double.parse(debtList[b]["amount"]);
		}
		for (int c = 0; c < creditList.length; c++) {
			credit = credit + double.parse(creditList[c]["amount"]);
		}
		tempData.expenses.add( expenses);

		totalExpenses = totalExpenses + expenses;
		totalDebt = totalDebt + debt;
		totalCredit = totalCredit + credit;
	}

		tempData.totalExpenses = totalExpenses.abs().toStringAsFixed(1);
    tempData.totalDebts = totalDebt.abs().toStringAsFixed(1);
    tempData.totalCredits = totalCredit.abs().toStringAsFixed(1);
    return tempData;
  }

  void saveExpense(singleExpense newExpense) async {
    var dbClient = await db;
    await dbClient.transaction((txn) async {
      return await txn.rawInsert(
          "INSERT INTO expenseRecord(amount, tags, description, month, days, year ) VALUES( "+
              "\"" +
              newExpense.amount +
              "\"" +
              "," +
              "\"" +
              newExpense.tags +
              "\"" +
              "," +
              "\"" +
              newExpense.description +
              "\"" +
              ", " +
              newExpense.month.toString() +
              ", " +
              newExpense.date.toString() +
              ", " +
              newExpense.year.toString() +
              ")");
    });
  }
  void saveDebt(singleDebt newDebt) async {
	  var dbClient = await db;
	  await dbClient.transaction((txn) async {
		  return await txn.rawInsert(
				  "INSERT INTO debtRecord(amount, mine, tofro, description, month, days, year ) VALUES( "+
						  "\"" +
						  newDebt.amount +
						  "\"" +
						  ", " +
						  newDebt.mine.toString() +
						  ", " +
						  "\"" +
						  newDebt.tofro +
						  "\", " +
						  "\"" +
						  newDebt.description +
						  "\"" +
						  ", " +
						  newDebt.month.toString() +
						  ", " +
						  newDebt.date.toString() +
						  ", " +
						  newDebt.year.toString() +
						  ")");
	  });
  }
  Future<Null> deleteDebt( String recordId) async {
	  var dbClient = await db;
    List<Map> theDebt = await dbClient.rawQuery("SELECT * FROM debtRecord WHERE id=" + recordId);
    if( theDebt != null && theDebt[0]["mine"] == 0){
      print( "Ye boi!!!");
      saveExpense( new singleExpense( "0", theDebt[0]["amount"], "TO: " + theDebt[0]["tofro"], "Debt cleared: " + theDebt[0]["description"], new DateTime.now().year, new DateTime.now().month, new DateTime.now().day));
    }
	  await dbClient.transaction((txn) async {
      return await txn.rawDelete( "DELETE FROM debtRecord WHERE id = " + recordId);
	  });
  }
  Future<Null> deleteExpense( String recordId) async {
	  var dbClient = await db;
	  await dbClient.transaction((txn) async {
		  return await txn.rawDelete( "DELETE FROM expenseRecord WHERE id = " + recordId);
	  });
  }


}