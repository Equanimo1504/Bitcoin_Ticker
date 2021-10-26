import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'coin_data.dart';
import 'package:flutter/cupertino.dart';
import 'dart:io' show Platform;
import 'package:http/http.dart' as http;
import 'dart:convert';

class PriceScreen extends StatefulWidget {
  @override
  _PriceScreenState createState() => _PriceScreenState();
}

class _PriceScreenState extends State<PriceScreen> {
  String selectedValue = 'USD';
  String presentcurrency = 'USD';

  DropdownButton<String> getDropdownButton() {
    List<DropdownMenuItem<String>> dropDownItems = [];

    for (int i = 0; i < currenciesList.length; i++) {
      String currency = currenciesList[i];

      var newItem = DropdownMenuItem(
        child: Text(currency),
        value: currency,
      );
      dropDownItems.add(newItem);
    }

    return DropdownButton<String>(
      value: selectedValue,
      dropdownColor: Colors.green,
      elevation: 100,
      items: dropDownItems,
      onChanged: (value) {
        setState(
          () {
            selectedValue = value;
          },
        );
      },
    );
  }

  CupertinoPicker IOSPicker() {
    List<Text> pickerlist = [];

    for (String item in currenciesList) {
      var listItem = Text(item);
      pickerlist.add(listItem);
    }
    return CupertinoPicker(
      itemExtent: 24,
      onSelectedItemChanged: (selectedIndex) {
        setState(() {
          presentcurrency = currenciesList[selectedIndex];
          getData1();
        });
        print(selectedIndex);
      },
      children: pickerlist,
    );
  }

  Widget getPicker() {
    if (Platform.isIOS) {
      return IOSPicker();
    } else if (Platform.isAndroid) {
      return getDropdownButton();
    }
  }

  Future getdata() async {
    http.Response response = await http.get(
        'https://rest.coinapi.io/v1/exchangerate/BTC/$presentcurrency?apikey=B4E1F520-A3F4-4B66-AFF2-FFC62C7DC87D');
    print(response.statusCode);

    return jsonDecode(response.body)['rate'];
  }

  String btcPriceInUsd = 'Calculating...';
  void getData1() async {
    double v = await getdata();
    print(v);
    setState(() {
      btcPriceInUsd = v.toStringAsFixed(2);
    });
  }

  @override
  void initState() {
    getData1();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(child: Text('🤑 Coin Ticker')),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Padding(
            padding: EdgeInsets.fromLTRB(18.0, 18.0, 18.0, 0),
            child: Card(
              color: Colors.lightBlueAccent,
              elevation: 5.0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 15.0, horizontal: 28.0),
                child: Text(
                  '1 BTC = $btcPriceInUsd $presentcurrency',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 20.0,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
          Container(
            height: 150.0,
            alignment: Alignment.center,
            padding: EdgeInsets.only(bottom: 30.0),
            color: Colors.lightBlue,
            child: IOSPicker(),
          ),
        ],
      ),
    );
  }
}
