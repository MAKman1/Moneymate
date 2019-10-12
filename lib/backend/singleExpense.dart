class singleExpense{
  String id;
  String amount;
  String tags;
  String description;

  int month;
  int date;
  int year;

  singleExpense( String id, String amount, String tags, String description, int year, int month, int date){
    this.id = id;
    this.amount = amount;
    this.description = description;
    this.tags = tags;

    this.month = month;
    this.year = year;
    this.date = date;
  }
}