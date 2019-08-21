import 'package:flutter/material.dart';

import 'dart:io';
import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:sprintf/sprintf.dart';
import 'package:image_picker/image_picker.dart';

import 'package:expenses2/model/settings.dart';
import 'package:expenses2/model/expenseClaim.dart';
import 'package:expenses2/model/receipt.dart';

import 'package:expenses2/mixin/general.dart';

import 'package:expenses2/emun/location.dart';

class ExpenseUI extends StatefulWidget {

  Settings settings;
  String navigationMessage;

  ExpenseUI(this.settings);

  ExpenseUI.withNavigationMessage(settings, navigationMessage);

  @override
  State createState() {
    debugPrint(">> ExpenseUI createState settings=$settings navigationMessage=$navigationMessage");
    return new ExpenseUIState(settings, navigationMessage);
  }
}

//--------------------------------------------------------------------------//

class ExpenseUIState extends State<ExpenseUI> with General {

  Settings settings;
  String navigationMessage;

  ExpenseUIState(this.settings, this.navigationMessage);

  GlobalKey<FormState> _formKey;

  final _scaffoldKey = GlobalKey<ScaffoldState>();

  ExpenseClaim expenseClaim = new ExpenseClaim();
  Receipt newReceipt = new Receipt();

  String _locationSelected ;
  File _receiptImageFileSelected;
  Image _receiptImageSelected;

  DateFormat ddmmFormatter = new DateFormat('dd/MM');

  //--------------------------------------------------------------------------//

  @override
  void initState() {
    super.initState();

    debugPrint(">> ExpenseUIState initState settings=$settings");

    _formKey = new GlobalKey<FormState>();

    initializeDateFormatting("en_GB", null).then((_) {debugPrint("date formatting initialised");});

    debugPrint(">> ExpenseUIState end of initState");
  }

  //--------------------------------------------------------------------------//

  @override
  void dispose() {
    // Stop listening to text changes

    super.dispose();
  }

  //--------------------------------------------------------------------------//

  @override
  Widget build(BuildContext context) {
    debugPrint(">> ExpenseUiState build");

    Scaffold _scaffold = Scaffold(
        key: _scaffoldKey,
        appBar: new AppBar(
          backgroundColor: Colors.amberAccent,
          title: new Text("Expense"),
        ),
        body: new Column( children: [ new Expanded( child: new Container(
            alignment: Alignment.topCenter,
            child: new ListView(
                children: <Widget>[

                  addReceiptSection(),

                  new Divider( color: Colors.black),

                  listReceiptsSection(),

                  new Divider( color: Colors.black),

                  totalSection(),
//
//                  actionButtons(),
                ]
            ))
        )]
    ));

    return _scaffold;
  }

  //--------------------------------------------------------------------------//

  Widget addReceiptSection() {

    debugPrint(">> addReceiptSection");

    List<Widget> widgetList = new List<Widget>();

    Widget dateWidget = new TextFormField(
        key: new Key("EditDate"),
        style: TextStyle( fontSize: 10),
        decoration: new InputDecoration(
          contentPadding: EdgeInsets.all(8.0),//here your padding
          fillColor: Colors.grey,
          border: new OutlineInputBorder(
              borderRadius: new BorderRadius.circular(2.0),
              borderSide: new BorderSide()
          ),
          hintStyle: TextStyle( fontSize: 10),
          hintText: "Date",
        ),
        initialValue: dateToStringMmdd(newReceipt.date),
        textCapitalization: TextCapitalization.words,
        validator: (val) {
          if (val == null) return 'Date is required';
          if (!validateDateString(val)) return 'Date format dd/mm or dd/mm/yy';
          return null;
        },
        onSaved: ( (val) {

          debugPrint('>> In Date onSaved val $val');
          newReceipt.date = stringToDate(val);}
        )
    );

    List<DropdownMenuItem<String>> _locationList = Locations.list
        .map<DropdownMenuItem<String>> (
          (String value ) => DropdownMenuItem<String> (
            value: value,
              child: Text(value, style: TextStyle(fontSize: 8),)
          )
        ).toList();

    Widget locationWidget = new DropdownButton(
        hint: Text('Site'),
        value: _locationSelected,
        onChanged: ((String newValue) {
          setState( () { _locationSelected = newValue;});
        }),
        items: _locationList
    );

    Widget locationWidgetOld1 = new TextFormField(
        key: new Key("Location"),
        style: TextStyle( fontSize: 10),
        decoration: new InputDecoration(
          contentPadding: EdgeInsets.all(8.0),//here your padding
          fillColor: Colors.grey,
          border: new OutlineInputBorder(
              borderRadius: new BorderRadius.circular(2.0),
              borderSide: new BorderSide()
          ),
          hintStyle: TextStyle( fontSize: 10),
          hintText: "Location",
        ),
        initialValue: '',
        textCapitalization: TextCapitalization.words,
        validator: (val) => val.isEmpty ? 'Location is required' : null,
        onSaved: ( (val) {
          debugPrint('>> In Location onSaved val $val');
//          newReceipt.location = val;
          }
        )
    );

    Widget amountWidget = new TextFormField(
        key: new Key("Amount"),
        style: TextStyle( fontSize: 10),
        keyboardType: TextInputType.numberWithOptions(
          signed: false, decimal: false),
        inputFormatters: [WhitelistingTextInputFormatter.digitsOnly],
        decoration: new InputDecoration(
          contentPadding: EdgeInsets.all(8.0),
          fillColor: Colors.grey,
          border: new OutlineInputBorder(
              borderRadius: new BorderRadius.circular(2.0),
              borderSide: new BorderSide()
          ),
          hintStyle: TextStyle( fontSize: 10),
          hintText: "Amount",
        ),
        initialValue: newReceipt.amount.toString(),
        textCapitalization: TextCapitalization.words,
        validator: (val) => val.isEmpty ? 'Amount is required' : null,
        onSaved: ( (val) {
          debugPrint('>> In amount name onSaved val $val');
          newReceipt.amount = double.tryParse(val);}
        )
    );

    Widget codeWidget = new TextFormField(
        key: new Key("Code"),
        style: TextStyle( fontSize: 10),
        keyboardType: TextInputType.numberWithOptions(
            signed: false, decimal: false),
        inputFormatters: [WhitelistingTextInputFormatter.digitsOnly],
        decoration: new InputDecoration(
          contentPadding: EdgeInsets.all(8.0),
          fillColor: Colors.grey,
          border: new OutlineInputBorder(
              borderRadius: new BorderRadius.circular(2.0),
              borderSide: new BorderSide()
          ),
          hintStyle: TextStyle( fontSize: 10),
          hintText: "Code",
        ),
        initialValue: '',
        textCapitalization: TextCapitalization.words,
        validator: (val) => val.isEmpty ? 'Code is required' : null,
        onSaved: ( (val) {
          debugPrint('>> In Code name onSaved val $val');
          newReceipt.accountCode = val;}
        )
    );

    Widget descriptionWidget = new TextFormField(
        key: new Key("Description0"),
        style: TextStyle( fontSize: 10),
        decoration: new InputDecoration(
          contentPadding: EdgeInsets.all(8.0),//here your padding
          fillColor: Colors.grey,
          border: new OutlineInputBorder(
              borderRadius: new BorderRadius.circular(2.0),
              borderSide: new BorderSide()
              ),
          hintStyle: TextStyle( fontSize: 10),
          hintText: "Description",
//          labelText: "Description",
//          icon: new Icon(Icons.person),
        ),
        initialValue: newReceipt.description,
        textCapitalization: TextCapitalization.words,
        validator: (val) => val.isEmpty ? 'Description is required' : null,
        onSaved: ( (val) {
          debugPrint('>> In Description name onSaved val $val');
          newReceipt.description = val;}
        )
    );
    Image _img;
    if ( _receiptImageSelected == null )
      _img = Image.asset('images/camera.png', width: 100, height: 50);
    else
      _img = Image.file(_receiptImageFileSelected);

    Widget receiptImageWidget = new Container(
      height: 100,
        width: 100,
      child: FlatButton(
      onPressed: getImage,
      child: _img
    ));

    Widget buttonRow = new Row (
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          new RaisedButton(
            child: new Text('Add'),
            shape: new RoundedRectangleBorder(
                borderRadius: new BorderRadius.circular(30)),
            onPressed: () => _addNewReceipt(),
          ),
        ],
      );


    widgetList.add(
      new Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          new Expanded(
            child: new Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget> [
              // column 1
                new Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                    new Expanded( child: new Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget> [
                        dateWidget,
                        locationWidget
                      ],
                    )),
                    new Expanded( child: new Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget> [
                        amountWidget,
                        codeWidget
                      ],
                    )),
                   ]
                ),
                new Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget> [
                      Expanded( child:
                      descriptionWidget
                    ),
////                    new Expanded( child: new Text('Description') )
//                    Text('Description')
                  ]
               ),
              ]
            )
          ),
//          new Expanded( child: new Placeholder( fallbackHeight: 100, fallbackWidth: 75,) )
          new Expanded(child: receiptImageWidget)
        ],
    ));

    widgetList.add(buttonRow);




    Widget receiptSection = new SafeArea(
        top: false,
        bottom: false,
        child: new Form(
            key: _formKey,
            autovalidate: false,
            child: new SingleChildScrollView(
                key: Key('ListViewKey'),
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: new Column(
                    children: widgetList
                )
            )
        )
    );


//    return
//        new Row(
//      children: <Widget>[ new Expanded( child: descriptionWidget),
//      new Expanded( child: descriptionWidget)
//      ],
//    );

    return receiptSection;
  }

  //--------------------------------------------------------------------------//

  Future getImage() async {
    var _image = await ImagePicker.pickImage(source: ImageSource.camera);

    setState(() {
      _receiptImageFileSelected = _image;
      _receiptImageSelected = Image.file(_image);
    });
  }

  //--------------------------------------------------------------------------//

  void _addNewReceipt() {
    debugPrint('>> Add new receipt');

    FormState form = _formKey.currentState;

    if ( form.validate() ) {
      form.save();

      newReceipt.location = Locations.fromText(_locationSelected);
      newReceipt.image = _receiptImageSelected;
      newReceipt.imageFile = _receiptImageFileSelected;

      debugPrint('>> newReceipt.description ${newReceipt.description}');

      Receipt r = new Receipt();
      r.date = newReceipt.date;
      r.amount = newReceipt.amount;
      r.location = newReceipt.location;
      r.accountCode = newReceipt.accountCode;
      r.description = newReceipt.description;
      r.image = newReceipt.image;
      r.imageFile = newReceipt.imageFile;
      expenseClaim.receipts.add(r);

      setState(() {});
    }
  }

  //--------------------------------------------------------------------------//

  Widget listReceiptsSection() {

    debugPrint('>> listReceiptsSection length ${expenseClaim.receipts.length}');

    List<Widget> widgetList = new List<Widget>();

    widgetList.add(
        new Text( 'Expense Claim' )
    );

    Widget _buildExpensesRow( int _rowNum ) {
      debugPrint('>> _buildExpensesRow _rowNum $_rowNum description ${expenseClaim.receipts[_rowNum].description}');


      debugPrint("expenseClaim.receipts[_rowNum].date ${expenseClaim.receipts[_rowNum].date}");
//      String _d = ddmmFormatter.format(expenseClaim.receipts[_rowNum].date);
      String _d = dateToStringMmdd(expenseClaim.receipts[_rowNum].date);
      String _a = sprintf("£%.2f", [ expenseClaim.receipts[_rowNum].amount ]);


//      title: new Row(
//          children: <Widget>[
//            new Expanded(child: new Text(product.name)),
//            new Checkbox(value: product.isCheck, onChanged: (bool value) {
//              setState(() {
//                product.isCheck = value;
//              });
//            })
//          ],

      return ListTile(
        onLongPress: () { editReceipt(_rowNum); },
        title: new Row(
          children: <Widget> [
            new Expanded( child: new Text( _d + " : " + _a )),
            new Container(
                width:40,
                height: 60,
                child: new Image.file( expenseClaim.receipts[_rowNum].imageFile)),
        ]),
        subtitle: Text( expenseClaim.receipts[_rowNum].description),
        trailing: Icon(Icons.clear),
      );
    }

    if ( expenseClaim.receipts.length > 0 ) {
      widgetList.add(
          ListView.builder(
              scrollDirection: Axis.vertical,
              shrinkWrap: true,
              itemCount: expenseClaim.receipts.length,
              itemBuilder: (BuildContext context, int r) {
                return _buildExpensesRow(r);
              })
      );
    };

    return new Container(
      child: new SingleChildScrollView(
        key: Key('ExpenseListKey'),
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: new Column(
            children: widgetList
        )
      )
    );
  }

  //--------------------------------------------------------------------------//

  void editReceipt( int rowNum )
  {
    debugPrint(">> editReceipt $rowNum");

    newReceipt.amount = expenseClaim.receipts[rowNum].amount;
    newReceipt.date = expenseClaim.receipts[rowNum].date;
    newReceipt.location = expenseClaim.receipts[rowNum].location;
    newReceipt.accountCode = expenseClaim.receipts[rowNum].accountCode;
    newReceipt.description = expenseClaim.receipts[rowNum].description;
    newReceipt.image = expenseClaim.receipts[rowNum].image;
    newReceipt.imageFile = expenseClaim.receipts[rowNum].imageFile;

    _locationSelected = Locations.text(newReceipt.location);
    _receiptImageSelected = newReceipt.image;
    _receiptImageFileSelected = newReceipt.imageFile;

    setState(() {});

  }

  //--------------------------------------------------------------------------//

  Widget totalSection() {

    List<Widget> widgetList = new List<Widget>();

    widgetList.add(
        new Text( 'Total: £${expenseClaim.total}' )
    );

    Widget buttonRow = new Row (
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        new RaisedButton(
          child: new Text('Submit'),
          shape: new RoundedRectangleBorder(
              borderRadius: new BorderRadius.circular(30)),
          onPressed: () => _submitExpenses(),
        ),
        new RaisedButton(
          child: new Text('Clear'),
          shape: new RoundedRectangleBorder(
              borderRadius: new BorderRadius.circular(30)),
          onPressed: () => _clearExpenses(),
        ),
      ],
    );

    widgetList.add(buttonRow);

    return new Column(
        children: widgetList
    );

  }
  //--------------------------------------------------------------------------//

  void _submitExpenses() {
    debugPrint('>> _submitExpenses');
  }

  //--------------------------------------------------------------------------//

  void _clearExpenses() {
    debugPrint('>> _clearExpenses');
  }

  //--------------------------------------------------------------------------//

  Widget actionButtons() {

    debugPrint('>> actionButtons');

    Container receiptSection = new Container();

    return receiptSection;
  }
}
//--------------------------------------------------------------------------//


