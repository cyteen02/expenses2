import 'package:expenses2/model/receipt.dart';

class ExpenseClaim {
  DateTime claimDate;
  String accountName;
  String accountNumber;

  List<Receipt> receipts = new List<Receipt>();

  double get total {
    double t = 0 ;
    receipts.forEach( (r) => t = t + r.amount );
    return t;
  }
}
