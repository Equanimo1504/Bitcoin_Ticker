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

const String url =
    'https://api.nomics.com/v1/currencies/ticker?key=4854640d26529f07e322a9335f0be00a3ad0716b&ids';

class _PriceScreenState extends State<PriceScreen> {
  String selectedValue = 'USD';
  String presentcurrency = 'USD';
  bool iswaiting = false;

  Map<String, String> coinValues = {};

  Future coinPrices() async {
    try {
      for (String item in cryptoList) {
        iswaiting = true;
        http.Response response =
            await http.get('$url=$item&convert=$selectedValue');
        iswaiting = false;
        setState(() {
          String x = jsonDecode(response.body)[0]['price'];
          double d = double.parse(x);
          String a = d.toStringAsFixed(2);
          coinValues[item] = a;
        });
      }
    } catch (e) {
      print(e);
    }
    return coinValues;
  }

  Map<String, String> coinValues2 = {};

  void getDATA() async {
    coinValues2 = await coinPrices();
    // setState(() {
    coinValues2 = coinValues;
    // });
    print(coinValues['BTC']);
    print(coinValues2['BTC']);
  }

  Future getdata() async {
    http.Response response =
        await http.get('$url=BTC&convert=$selectedValue&per-page=100&page=1');
    print(response.statusCode);

    return jsonDecode(response.body)[0]['price'];
  }

  String btcPriceInUsd = "Calculating...";
  void getData1() async {
    String v = await getdata();
    print(v);
    double n = double.parse(v);

    setState(() {
      btcPriceInUsd = n.toStringAsFixed(2);
      // btcPriceInUsd.toString();
    });
  }

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
      dropdownColor: Colors.black,
      isDense: false,
      isExpanded: false,
      borderRadius: BorderRadius.circular(12),
      elevation: 100,
      menuMaxHeight: 259,
      items: dropDownItems,
      onChanged: (value) {
        selectedValue = value;
        setState(
          () {
            selectedValue = value;
            btcPriceInUsd = 'Calculating...';
          },
        );
        getDATA();
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

  @override
  void initState() {
    getDATA();
    super.initState();
  }

  Column makeCards() {
    List<Widget> children = [];
    for (String item in cryptoList) {
      String coin = item;
      String value = iswaiting ? "Calculating.." : coinValues[item];
      children
          .add(NewCard(value: value, coin: coin, selectedValue: selectedValue));
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: children,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(child: Text('Crypto Tracker')),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          makeCards(),
          Container(
            height: 150.0,
            alignment: Alignment.center,
            padding: EdgeInsets.only(bottom: 30.0),
            color: Colors.indigo[900],
            child: getDropdownButton(),
          ),
        ],
      ),
    );
  }
}

class NewCard extends StatelessWidget {
  const NewCard({
    Key key,
    @required this.value,
    @required this.coin,
    @required this.selectedValue,
  }) : super(key: key);

  final String value;
  final String selectedValue;
  final String coin;

  @override
  Widget build(BuildContext context) {
    return Padding(
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
            '1 $coin = $value $selectedValue',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 20.0,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
