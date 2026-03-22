import 'package:flutter/material.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(FogGuardApp());
}

class FogGuardApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'FogGuard',
      theme: ThemeData.dark(),
      home: SplashScreen(),
    );
  }
}

//
// ================= SPLASH SCREEN =================
//

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {

  @override
  void initState() {
    super.initState();

    Timer(Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => RouteScreen()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF0A1F44),
              Color(0xFF0D2A5E),
              Color(0xFF061530),
            ],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [

              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.cyanAccent.withOpacity(0.6),
                      blurRadius: 30,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: Icon(Icons.wifi_tethering,
                    size: 90, color: Colors.cyanAccent),
              ),

              SizedBox(height: 40),

              Text("FogGuard",
                  style: TextStyle(
                      fontSize: 40,
                      color: Colors.white,
                      fontWeight: FontWeight.bold)),

              SizedBox(height: 10),

              Text("Smart Fog Monitoring",
                  style: TextStyle(fontSize: 18, color: Colors.cyanAccent)),

              SizedBox(height: 40),

              CircularProgressIndicator(color: Colors.cyanAccent),
            ],
          ),
        ),
      ),
    );
  }
}

//
// ================= ROUTE SCREEN =================
//

class RouteScreen extends StatelessWidget {

  Widget buildRouteCard(BuildContext context, String title) {
    return GestureDetector(
      onTap: () {
        if (title == "Colombo → Jaffna") {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => NodeListScreen(routeName: title),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Coming soon")),
          );
        }
      },
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 10),
        padding: EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Color(0xFF112A5C),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Row(
          children: [
            Icon(Icons.route, color: Colors.cyanAccent),
            SizedBox(width: 15),
            Expanded(
              child: Text(title,
                  style: TextStyle(color: Colors.white, fontSize: 16)),
            ),
            Icon(Icons.arrow_forward_ios, color: Colors.white, size: 16),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF0A1F44),
      appBar: AppBar(
        backgroundColor: Color(0xFF0A1F44),
        title: Text("Welcome"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            SizedBox(height: 20),
            Text("Choose Your Route",
                style: TextStyle(fontSize: 24, color: Colors.white)),
            SizedBox(height: 25),
            buildRouteCard(context, "Colombo → Jaffna"),
            buildRouteCard(context, "Kandy → Nuwara Eliya"),
            buildRouteCard(context, "Colombo → Kandy"),
            buildRouteCard(context, "Badulla → Ella"),
          ],
        ),
      ),
    );
  }
}

//
// ================= DATA MODEL =================
//

class FogNode {
  String name;
  int fogLevel;
  double humidity;

  FogNode({
    required this.name,
    required this.fogLevel,
    required this.humidity,
  });
}

//
// ================= NODE LIST SCREEN =================
//

class NodeListScreen extends StatefulWidget {
  final String routeName;

  NodeListScreen({required this.routeName});

  @override
  _NodeListScreenState createState() => _NodeListScreenState();
}

class _NodeListScreenState extends State<NodeListScreen> {

  List<FogNode> nodes = [];

  @override
  void initState() {
    super.initState();
    fetchData();

    // Auto refresh every 10 seconds
    Timer.periodic(Duration(seconds: 10), (timer) {
      fetchData();
    });
  }

  Future<void> fetchData() async {
    final url = "https://api.thingspeak.com/channels/3307018/feeds/last.json";

    try {
      final response = await http.get(Uri.parse(url));
      final data = jsonDecode(response.body);

      setState(() {
        nodes = [
          FogNode(
            name: "Kurunegala",
            fogLevel: int.parse(data["field1"] ?? "0"),
            humidity: double.parse(data["field2"] ?? "0"),
          ),
          FogNode(
            name: "Anuradhapura",
            fogLevel: int.parse(data["field1"] ?? "0"),
            humidity: double.parse(data["field2"] ?? "0"),
          ),
          FogNode(
            name: "Vavuniya",
            fogLevel: int.parse(data["field1"] ?? "0"),
            humidity: double.parse(data["field2"] ?? "0"),
          ),
          FogNode(
            name: "Jaffna",
            fogLevel: int.parse(data["field1"] ?? "0"),
            humidity: double.parse(data["field2"] ?? "0"),
          ),
        ];
      });
    } catch (e) {
      print("Error fetching data");
    }
  }

  Color getColor(int level) {
    if (level == 0) return Colors.green;
    if (level == 1) return Colors.yellow;
    return Colors.red;
  }

  String getText(int level) {
    if (level == 0) return "LOW";
    if (level == 1) return "MEDIUM";
    return "HIGH";
  }

  Widget buildNodeCard(FogNode node) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10),
      padding: EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Color(0xFF112A5C),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [

          Icon(Icons.location_on, color: getColor(node.fogLevel)),

          SizedBox(width: 15),

          Expanded(
            child: Text(
              node.name,
              style: TextStyle(color: Colors.white),
            ),
          ),

          Text(
            getText(node.fogLevel),
            style: TextStyle(
              color: getColor(node.fogLevel),
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF0A1F44),
      appBar: AppBar(
        backgroundColor: Color(0xFF0A1F44),
        title: Text(widget.routeName),
        centerTitle: true,
      ),
      body: nodes.isEmpty
          ? Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: nodes.map((node) => buildNodeCard(node)).toList(),
        ),
      ),
    );
  }
}