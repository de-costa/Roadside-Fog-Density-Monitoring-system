import 'package:flutter/material.dart';
import 'dart:async';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
    }
  } catch (e, st) {
    debugPrint('Firebase initialization failed: $e');
    debugPrint('$st');
  }

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
      if (!mounted) return;
      debugPrint('Splash timeout: navigating to RouteScreen');
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
                      color: Colors.cyanAccent.withAlpha((0.6 * 255).toInt()),
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
  final String id;
  final String name;
  final int fogLevel;
  final double humidity;
  final String location;
  final String warning;
  final DateTime lastUpdated;

  FogNode({
    required this.id,
    required this.name,
    required this.fogLevel,
    required this.humidity,
    required this.location,
    required this.warning,
    required this.lastUpdated,
  });
}

//
// ================= NODE DETAIL SCREEN =================
//

class NodeDetailScreen extends StatefulWidget {
  final FogNode node;

  NodeDetailScreen({required this.node});

  @override
  _NodeDetailScreenState createState() => _NodeDetailScreenState();
}

class _NodeDetailScreenState extends State<NodeDetailScreen> {
  late FogNode currentNode;
  DatabaseReference? _nodeRef;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    currentNode = widget.node;
    _nodeRef = FirebaseDatabase.instanceFor(
      app: Firebase.app(),
      databaseURL: DefaultFirebaseOptions.currentPlatform.databaseURL,
    ).ref('fog_nodes/${widget.node.id}');
    debugPrint('NodeDetailScreen initState ref: fog_nodes/${widget.node.id}');
    fetchNodeData();
  }

  void fetchNodeData() {
    if (_nodeRef == null) {
      debugPrint('NodeDetailScreen fetchNodeData: _nodeRef is null');
      setState(() {
        isLoading = false;
      });
      return;
    }

    debugPrint('NodeDetailScreen fetchNodeData from ${_nodeRef!.path}');

    _nodeRef!.onValue.listen((event) {
      final data = event.snapshot.value;
      debugPrint('NodeDetailScreen event value: $data');
      if (data != null && data is Map<dynamic, dynamic>) {
        setState(() {
          currentNode = FogNode(
            id: currentNode.id,
            name: data['name'] ?? currentNode.name,
            fogLevel: data['fogLevel'] ?? currentNode.fogLevel,
            humidity: (data['humidity'] ?? currentNode.humidity).toDouble(),
            location: data['location'] ?? currentNode.location,
            warning: data['warning'] ?? currentNode.warning,
            lastUpdated: DateTime.tryParse(data['lastUpdated'] ?? '') ?? currentNode.lastUpdated,
          );
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
      }
    }, onError: (error) {
      setState(() {
        isLoading = false;
      });
      debugPrint('NodeDetailScreen fetch error: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error fetching node data: $error")),
      );
    });
  }

  void refreshData() {
    setState(() {
      isLoading = true;
    });
    fetchNodeData();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF0A1F44),
      appBar: AppBar(
        backgroundColor: Color(0xFF0A1F44),
        title: Text(currentNode.name),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: refreshData,
          ),
        ],
      ),
      body: isLoading
          ? Center(
              child: CircularProgressIndicator(color: Colors.cyanAccent),
            )
          : Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 20),
                  Text("Location: ${currentNode.location}",
                      style: TextStyle(color: Colors.white, fontSize: 18)),
                  SizedBox(height: 20),
                  Row(
                    children: [
                      Text("Fog Level: ",
                          style: TextStyle(color: Colors.white, fontSize: 18)),
                      Text(getText(currentNode.fogLevel),
                          style: TextStyle(
                              color: getColor(currentNode.fogLevel),
                              fontSize: 18,
                              fontWeight: FontWeight.bold)),
                    ],
                  ),
                  SizedBox(height: 20),
                  Text("Humidity: ${currentNode.humidity.toStringAsFixed(1)}%",
                      style: TextStyle(color: Colors.white, fontSize: 18)),
                  SizedBox(height: 20),
                  Text("Warning: ${currentNode.warning}",
                      style: TextStyle(color: Colors.cyanAccent, fontSize: 18)),
                  SizedBox(height: 20),
                  Text("Last Updated: ${currentNode.lastUpdated.toString()}",
                      style: TextStyle(color: Colors.grey, fontSize: 14)),
                ],
              ),
            ),
    );
  }
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
  DatabaseReference? _databaseRef;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _databaseRef = FirebaseDatabase.instanceFor(
      app: Firebase.app(),
      databaseURL: DefaultFirebaseOptions.currentPlatform.databaseURL,
    ).ref('fog_nodes');
    debugPrint('NodeListScreen initState db ref: fog_nodes');
    fetchData();
  }

  Future<void> fetchData() async {
    if (_databaseRef == null) {
      debugPrint('NodeListScreen fetchData: _databaseRef is null');
      setState(() {
        isLoading = false;
      });
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final snapshot = await _databaseRef!.get();
      handleSnapshot(snapshot);
    } catch (e, st) {
      debugPrint('NodeListScreen fetchData get failure: $e\n$st');
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching data: $e')),
      );
    }

    _databaseRef!.onValue.listen((event) {
      debugPrint('NodeListScreen onValue event received');
      handleSnapshot(event.snapshot);
    }, onError: (error) {
      debugPrint('NodeListScreen onValue error: $error');
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching data: $error')),
      );
    });
  }

  void handleSnapshot(DataSnapshot snapshot) {
    final data = snapshot.value;
    if (data != null && data is Map<dynamic, dynamic>) {
      setState(() {
        nodes = data.entries.map((entry) {
          final nodeData = entry.value as Map<dynamic, dynamic>;
          return FogNode(
            id: entry.key,
            name: nodeData['name'] ?? entry.key,
            fogLevel: nodeData['fogLevel'] ?? 0,
            humidity: (nodeData['humidity'] ?? 0).toDouble(),
            location: nodeData['location'] ?? 'Unknown',
            warning: nodeData['warning'] ?? 'No warning',
            lastUpdated: DateTime.tryParse(nodeData['lastUpdated'] ?? '') ?? DateTime.now(),
          );
        }).toList();
        isLoading = false;
      });
    } else {
      setState(() {
        nodes = [];
        isLoading = false;
      });
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
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => NodeDetailScreen(node: node),
          ),
        );
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

            Icon(Icons.location_on, color: getColor(node.fogLevel)),

            SizedBox(width: 15),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(node.name,
                      style: TextStyle(color: Colors.white, fontSize: 16)),

                  SizedBox(height: 5),

                  Text("Humidity: ${node.humidity}%",
                      style: TextStyle(color: Colors.grey, fontSize: 12)),
                ],
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
      body: isLoading
          ? Center(
              child: CircularProgressIndicator(color: Colors.cyanAccent),
            )
          : RefreshIndicator(
              onRefresh: () async {
                // Refresh data
                await fetchData();
              },
              child: nodes.isEmpty
                  ? ListView(
                      children: [
                        SizedBox(
                          height: MediaQuery.of(context).size.height - 100,
                          child: Center(
                            child: Text("No Data Available",
                                style: TextStyle(color: Colors.white)),
                          ),
                        ),
                      ],
                    )
                  : Padding(
                      padding: const EdgeInsets.all(20),
                      child: ListView(
                        children: nodes.map((node) => buildNodeCard(node)).toList(),
                      ),
                    ),
            ),
    );
  }
}
