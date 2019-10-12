class singleDebt{
  String id;
  String amount;
  int mine;
  String tofro;
  String description;

  int month;
  int date;
  int year;

  singleDebt( String id, String amount, String description, int mine, String tofro, int year, int month, int date){
    this.id = id;
    this.amount = amount;
    this.mine = mine;
    this.description = description;
    this.tofro = tofro;

    this.month = month;
    this.year = year;
    this.date = date;
  }
}