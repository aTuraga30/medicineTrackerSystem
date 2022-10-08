// ignore_for_file: avoid_print, unused_local_variable
// ignore_for_file: unnecessary_this
// ignore_for_file: prefer_typing_uninitialized_variables

import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';

void main() => runApp(const MyStemApp());

class MyStemApp extends StatelessWidget {
  const MyStemApp({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Medicine Reminder App',
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);
  @override
  MyHomePageState createState() => MyHomePageState();
}

class MyHomePageState extends State<MyHomePage>
    with SingleTickerProviderStateMixin {
  bool bp = true;
  bool buttonPress = false;
  String formatTimeStamp = "";
  String selectedTime = "";
  String timeString = "";
  String timestamp = "";
  String formatStamp = "";
  String url =
      "https://api.thingspeak.com/channels/1411223/fields/1.json?api_key=3KBN6IR60DDOT2YJ&results=1";
  String postUrl =
      "https://api.thingspeak.com/update?api_key=D0U6OPO92UR8NP45&field1=1";
  var firstNumberHour = "";
  var secondNumberHour = "";
  var firstNumberMinute = "";
  var secondNumberMinute = "";
  var totalHours = "";
  var totalMinutes = "";
  var translatedTimeToString = "";
  var date = "";
  var rest = "";
  var index = 0;
  var value;
  int intFirstNumberHour = 0;
  int intSecondNumberHour = 0;
  int intFirstNumberMinute = 0;
  int intSecondNumberMinute = 0;
  int intTotalHours = 0;
  int intTotalMinutes = 0;
  int translatedTotalHours = 0;
  int counter = 0;
  int count = 0;
  List data = [];
  List<String> values = [];
  late TabController tabController;

  final List<Tab> myTabs = <Tab>[
    const Tab(text: 'REMINDING PAGE'),
    const Tab(text: 'TRACKING PAGE'),
  ];

  @override
  void initState() {
    super.initState();
    this.getJsonData();
    tabController =
        TabController(vsync: this, length: myTabs.length, initialIndex: index);
    timeString = formatDateTime(DateTime.now());
    Timer.periodic(const Duration(seconds: 1), (Timer a) => getTime());
    Timer.periodic(const Duration(seconds: 1), (Timer b) => postData());
    Timer.periodic(const Duration(seconds: 1), (Timer c) => getJsonData());
    Timer.periodic(const Duration(seconds: 1), (Timer d) => formatingStamp2());
    Timer.periodic(const Duration(seconds: 1), (Timer e) => convertTimeToInt());
    Timer.periodic(
        const Duration(seconds: 1), (Timer f) => convertIntTimeToString());
    Timer.periodic(const Duration(seconds: 1), (Timer g) => addTimeToList());
  }

  @override
  void dispose() {
    tabController.dispose();
    super.dispose();
  }

  // Lets the user pick the time
  Future<void> picker() async {
    final TimeOfDay? result =
        await showTimePicker(context: context, initialTime: TimeOfDay.now());
    if (result != null) {
      setState(() {
        selectedTime = result.format(context);
      });
    }
  }

  // Gets the current time, which updates constantly
  void getTime() {
    DateTime timeNow = DateTime.now();
    String formattedTimeNow = formatDateTime(timeNow);
    setState(() {
      timeString = formattedTimeNow;
    });
  }

  // Formats the "DateTime" string
  String formatDateTime(DateTime dateTime) {
    return DateFormat("h:mm a").format(dateTime);
  }

  // "Future" function that constantly gets the JSON values from API
  Future getJsonData() async {
    var response =
        await http.get(Uri.parse(url), headers: {"Accept": "application/json"});
    setState(() {
      var convertDataToJson = json.decode(response.body);
      data = convertDataToJson['feeds'];
      value = data[0]['field1'];
      timestamp = data[0]['created_at'];
    });

    return "Success";
  }

  // Function that prints the statistics of the time...mainly used for dev purposes
  void getStats() {
    print("-------------------------------------------------------");
    print("Selected time is" + selectedTime);
    print("TimeString is: " + timeString);
    print("-------------------------------------------------------");
    print("Value is :" + value);
    print("-------------------------------------------------------");
    print("Timestamp is :" + timestamp);
  }

  void formatingStamp() {
    var timestampParse = DateTime.parse(timestamp);
    formatStamp = DateFormat('MMMM d, y - hh:mm a').format(timestampParse);
    print("Formatted Timestamp is: " + formatStamp);
    // January 18, 2022 - 01:35 PM
    var fsDate = formatStamp[19];
    print("FsDate: " + fsDate);
  }

  // "Future" function which posts the JSON values to API
  Future postData() async {
    void post() async {
      final link = Uri.parse(
          "https://api.thingspeak.com/update?api_key=D0U6OPO92UR8NP45&field1=1");
      final headers = {"Content-Type": "application/json"};
      final response = await http.post(link);
    }

    setState(() {
      if ((selectedTime == timeString) && buttonPress == false) {
        post();
        buttonPress = true;
      } else if (selectedTime != timeString) {
        buttonPress = false;
      }
    });
  }

// ----------------------------------------------------------------------------
  void showTimeStamp() {
    print("Raw TimeStamp is: " + timestamp);
  }

  void formatingStamp2() {
    if (this.mounted) {
      setState(() {
        var timestampParse = DateTime.parse(timestamp);
        formatTimeStamp =
            DateFormat('MMMM d, y - hh:mm a').format(timestampParse);
        print("Value is " + value);
      });
    }
  }

  void convertTimeToInt() {
    firstNumberHour = formatTimeStamp[19];
    secondNumberHour = formatTimeStamp[20];
    firstNumberMinute = formatTimeStamp[22];
    secondNumberMinute = formatTimeStamp[23];
    totalHours = firstNumberHour + secondNumberHour;
    totalMinutes = firstNumberMinute + secondNumberMinute;

    intFirstNumberHour = int.parse(firstNumberHour);
    intSecondNumberHour = int.parse(secondNumberHour);
    intFirstNumberHour = int.parse(firstNumberHour);
    intSecondNumberHour = int.parse(secondNumberMinute);

    intTotalHours = int.parse(totalHours);
    intTotalMinutes = int.parse(totalMinutes);

    translatedTotalHours = intTotalHours + 7;

    if (translatedTotalHours > 12) {
      translatedTotalHours = translatedTotalHours - 12;
    }
  }

  void convertIntTimeToString() {
    translatedTimeToString = translatedTotalHours.toString();
    print("The Translated Time is: " + translatedTimeToString);
    date = formatTimeStamp.substring(0, 18);
    rest = formatTimeStamp.substring(22, 27);
    print("Date is: " + date);
    print("Rest is: " + rest);

    formatTimeStamp = date + " " + translatedTimeToString + ":" + rest;
    print("Updated formatTimeStamp is: " + formatTimeStamp);
  }

  void addTimeToList() {
    print("BP: " + bp.toString());
    if (value == "0" && bp == true) {
      values.add(formatTimeStamp);
      bp = false;
      print(bp);
    } else if (value == "1" && bp == false) {
      bp = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        bottom: TabBar(
          controller: tabController,
          tabs: myTabs,
        ),
      ),
      body: TabBarView(
        controller: tabController,
        children: <Widget>[
          FutureBuilder(
            builder: (context, projectSnap) {
              if (projectSnap.connectionState == ConnectionState.none) {
                return Container();
              }
              return ListView.builder(
                itemCount: data.length,
                itemBuilder: (context, index) {
                  // ignore: avoid_unnecessary_containers
                  return Container(
                    child: Center(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Card(
                            child: Container(
                              child: Text("Value is: " + value),
                              padding: const EdgeInsets.all(20.0),
                            ),
                          ),
                          Column(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(20.0),
                                child: ElevatedButton(
                                  onPressed: picker,
                                  child: const Text("Choose Time to Remind"),
                                ),
                              ),
                              Text(
                                selectedTime,
                                style: const TextStyle(fontSize: 40),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(10),
                                child: Text("Current Time is : " + timeString),
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                  );
                },
              );
            },
            future: getJsonData(),
          ),
          Column(
            children: <Widget>[
              SingleChildScrollView(
                child: Table(
                  border: TableBorder.all(width: 1, color: Colors.black45),
                  children: [
                    const TableRow(
                      children: [
                        TableCell(
                          child: Padding(
                            padding: EdgeInsets.all(20),
                            child: Text("Last Taken At: "),
                          ),
                        ),
                      ],
                    ),
                    for (var val in values)
                      TableRow(
                        children: [
                          TableCell(
                            child: Padding(
                              padding: const EdgeInsets.all(20),
                              child: Row(
                                children: <Widget>[
                                  Text(val),
                                ],
                              ),
                            ),
                          )
                        ],
                      )
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
