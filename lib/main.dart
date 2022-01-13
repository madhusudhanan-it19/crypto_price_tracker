import 'dart:async';
import 'dart:convert';

import 'package:crypto_price_tracker/CoinModel.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'CoinCard.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Home(),
    );
  }
}

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {

  Future<List<Coin>> fetchCoin() async {
    coinList = [];
    final response = await http.get(Uri.parse( 'https://api.coingecko.com/api/v3/coins/markets?vs_currency=usd&order=market_cap_desc&per_page=100&page=1&sparkline=false'));

    if(response.statusCode == 200){
      List<dynamic> values = [];
      values = json.decode(response.body);
      if(values.length > 0){
        for(int i =0;i < values.length;i++){
          if(values[i] != null){
            Map<String, dynamic> map = values[i];
            coinList.add(Coin.fromJson(map));
          } 
        }
        setState(() {
        coinList;
      });
      }

      return coinList;
    }
    else{
      throw Exception("Failed to load coins");
    }
  }

@override
  void initState() {
    fetchCoin();
    Timer.periodic(Duration(seconds: 10), (timer) => fetchCoin());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      appBar: AppBar(
        backgroundColor: Colors.grey[300],
        centerTitle: true,
        title: Text(
          "CRYPTOBASE",
          style: TextStyle(
            color: Colors.grey[900],
            fontSize: 25,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: fetchCoin,
        child: ListView.builder(
          scrollDirection: Axis.vertical,
          itemCount: coinList.length,
          itemBuilder: (context, index) {
            return CoinCard(
              name: coinList[index].name,
              symbol: coinList[index].symbol, 
              imageurl: coinList[index].imageurl, 
              price: coinList[index].price.toDouble(), 
              change: coinList[index].change.toDouble(), 
              changePercentage: coinList[index].changePercentage.toDouble(),
              );
          }
          ),
      )
    );
  }
}
