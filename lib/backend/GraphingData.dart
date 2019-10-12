import 'package:money_mate/backend/DateAmountPair.dart';

class GraphingData{
	List< double> expenses;

	String totalExpenses;
	String totalDebts;
	String totalCredits;

	GraphingData(){
		expenses = new List< double>();
		totalDebts = "";
		totalExpenses = "";
		totalCredits = "";
	}
}