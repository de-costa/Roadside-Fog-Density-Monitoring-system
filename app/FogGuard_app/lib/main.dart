import 'package:flutter/material.dart';
import 'dart:async';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    }
  } catch (e, st) {
    debugPrint('Firebase initialization failed: $e');
    debugPrint('$st');
  }

  runApp(const FogGuardApp());
}

class FogGuardApp extends StatelessWidget {
  const FogGuardApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'FogGuard',
      theme: ThemeData.dark(),
      home: const SplashScreen(),
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    Timer(const Duration(seconds: 3), () {
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const RouteScreen()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF0A1F44),
              Color(0xFF0D2A5E),
              Color(0xFF061530),
            ],
          ),
        ),
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _SplashIcon(),
              SizedBox(height: 40),
              Text(
                "FogGuard",
                style: TextStyle(
                  fontSize: 40,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 10),
              Text(
                "Smart Fog Monitoring",
                style: TextStyle(fontSize: 18, color: Colors.cyanAccent),
              ),
              SizedBox(height: 40),
              CircularProgressIndicator(color: Colors.cyanAccent),
            ],
          ),
        ),
      ),
    );
  }
}

class _SplashIcon extends StatelessWidget {
  const _SplashIcon();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(50),
        gradient: LinearGradient(
          colors: [
            Color(0xFF0A1F44),
            Color(0xFF0D2A5E),
            Color(0xFF061530),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.cyanAccent.withAlpha((0.6 * 255).toInt()),
            blurRadius: 30,
            spreadRadius: 5,
          ),
        ],
      ),
      child: const Icon(
        Icons.wifi_tethering,
        size: 90,
        color: Colors.cyanAccent,
      ),
    );
  }
}

class RouteScreen extends StatelessWidget {
  const RouteScreen({super.key});

  Widget buildRouteCard(BuildContext context, String title) {
    return GestureDetector(
      onTap: () {
        if (title == "Colombo → Jaffna") {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => NodeListScreen(routeName: title),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Coming soon")),
          );
        }
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 10),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: const Color(0xFF112A5C),
          borderRadius: BorderRadius.circular(15),
        ),
        child: const Row(
          children: [
            Icon(Icons.route, color: Colors.cyanAccent),
            SizedBox(width: 15),
            Expanded(
              child: Text(
                "placeholder",
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
            Icon(Icons.arrow_forward_ios, color: Colors.white, size: 16),
          ],
        ),
      ),
    );
  }

  Widget buildRealRouteCard(BuildContext context, String title) {
    return GestureDetector(
      onTap: () {
        if (title == "Colombo → Jaffna") {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => NodeListScreen(routeName: title),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Coming soon")),
          );
        }
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 10),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: const Color(0xFF112A5C),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Row(
          children: [
            const Icon(Icons.route, color: Colors.cyanAccent),
            const SizedBox(width: 15),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
            const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 16),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A1F44),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0A1F44),
        title: const Text("Welcome"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 20),
            const Text(
              "Choose Your Route",
              style: TextStyle(fontSize: 24, color: Colors.white),
            ),
            const SizedBox(height: 25),
            buildRealRouteCard(context, "Colombo → Jaffna"),
            buildRealRouteCard(context, "Kandy → Nuwara Eliya"),
            buildRealRouteCard(context, "Colombo → Kandy"),
            buildRealRouteCard(context, "Badulla → Ella"),
          ],
        ),
      ),
    );
  }
}

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

int parseFogLevel(dynamic value) {
  if (value == null) return 1;
  if (value is int) return value;
  if (value is double) return value.toInt();
  return int.tryParse(value.toString()) ?? 1;
}

double parseHumidity(dynamic value) {
  if (value == null) return 0.0;
  if (value is int) return value.toDouble();
  if (value is double) return value;
  return double.tryParse(value.toString()) ?? 0.0;
}

DateTime parseDate(dynamic value) {
  if (value == null) return DateTime.now();
  return DateTime.tryParse(value.toString()) ?? DateTime.now();
}

Color fogColor(int level) {
  if (level == 1) return Colors.green;
  if (level == 2) return Colors.yellow;
  if (level == 3) return Colors.red;
  return Colors.grey;
}

String fogText(int level) {
  if (level == 1) return "LOW";
  if (level == 2) return "MEDIUM";
  if (level == 3) return "HIGH";
  return "UNKNOWN";
}

class NodeDetailScreen extends StatefulWidget {
  final FogNode node;

  const NodeDetailScreen({super.key, required this.node});

  @override
  State<NodeDetailScreen> createState() => _NodeDetailScreenState();
}

class _NodeDetailScreenState extends State<NodeDetailScreen> {
  late FogNode currentNode;
  DatabaseReference? _nodeRef;
  StreamSubscription<DatabaseEvent>? _subscription;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    currentNode = widget.node;
    _nodeRef = FirebaseDatabase.instanceFor(
      app: Firebase.app(),
      databaseURL: DefaultFirebaseOptions.currentPlatform.databaseURL,
    ).ref('fog_nodes/${widget.node.id}');
    fetchNodeData();
  }

  void fetchNodeData() {
    if (_nodeRef == null) {
      setState(() => isLoading = false);
      return;
    }

    _subscription?.cancel();
    _subscription = _nodeRef!.onValue.listen((event) {
      final data = event.snapshot.value;

      if (data != null && data is Map<dynamic, dynamic>) {
        setState(() {
          currentNode = FogNode(
            id: currentNode.id,
            name: (data['name'] ?? currentNode.name).toString(),
            fogLevel: parseFogLevel(data['fogLevel']),
            humidity: parseHumidity(data['humidity']),
            location: (data['location'] ?? currentNode.location).toString(),
            warning: (data['warning'] ?? currentNode.warning).toString(),
            lastUpdated: parseDate(data['lastUpdated']),
          );
          isLoading = false;
        });
      } else {
        setState(() => isLoading = false);
      }
    }, onError: (error) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error fetching node data: $error")),
      );
    });
  }

  void refreshData() {
    setState(() => isLoading = true);
    fetchNodeData();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  Widget _buildInfoCard(IconData icon, String title, String value, Color? valueColor) {
    return Card(
      color: const Color(0xFF112A5C),
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Icon(icon, color: Colors.cyanAccent, size: 28),
        title: Text(
          title,
          style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500),
        ),
        subtitle: Text(
          value,
          style: TextStyle(
            color: valueColor ?? Colors.white70,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A1F44),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0A1F44),
        title: Text(currentNode.name),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: refreshData,
          ),
        ],
      ),
      body: isLoading
          ? const Center(
        child: CircularProgressIndicator(color: Colors.cyanAccent),
      )
          : ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _buildInfoCard(Icons.location_on, "Location", currentNode.location, null),
          _buildInfoCard(Icons.cloud, "Fog Level", "${fogText(currentNode.fogLevel)} (${currentNode.fogLevel})", fogColor(currentNode.fogLevel)),
          _buildInfoCard(Icons.water_drop, "Humidity", "${currentNode.humidity.toStringAsFixed(1)}%", null),
          _buildInfoCard(Icons.warning_amber, "Warning", currentNode.warning, Colors.cyanAccent),
          _buildInfoCard(Icons.access_time, "Last Updated", currentNode.lastUpdated.toString(), Colors.grey),
        ],
      ),
    );
  }
}

class NodeListScreen extends StatefulWidget {
  final String routeName;

  const NodeListScreen({super.key, required this.routeName});

  @override
  State<NodeListScreen> createState() => _NodeListScreenState();
}

class _NodeListScreenState extends State<NodeListScreen> {
  List<FogNode> nodes = [];
  DatabaseReference? _databaseRef;
  StreamSubscription<DatabaseEvent>? _subscription;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _databaseRef = FirebaseDatabase.instanceFor(
      app: Firebase.app(),
      databaseURL: DefaultFirebaseOptions.currentPlatform.databaseURL,
    ).ref('fog_nodes');
    fetchData();
  }

  Future<void> fetchData() async {
    if (_databaseRef == null) {
      setState(() => isLoading = false);
      return;
    }

    setState(() => isLoading = true);

    try {
      final snapshot = await _databaseRef!.get();
      handleSnapshot(snapshot);
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching data: $e')),
      );
    }

    _subscription?.cancel();
    _subscription = _databaseRef!.onValue.listen((event) {
      handleSnapshot(event.snapshot);
    }, onError: (error) {
      setState(() => isLoading = false);
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
            id: entry.key.toString(),
            name: (nodeData['name'] ?? entry.key).toString(),
            fogLevel: parseFogLevel(nodeData['fogLevel']),
            humidity: parseHumidity(nodeData['humidity']),
            location: (nodeData['location'] ?? 'Unknown').toString(),
            warning: (nodeData['warning'] ?? 'No warning').toString(),
            lastUpdated: parseDate(nodeData['lastUpdated']),
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

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  Widget buildNodeCard(FogNode node) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => NodeDetailScreen(node: node),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 10),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: const Color(0xFF112A5C),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Row(
          children: [
            Icon(Icons.location_on, color: fogColor(node.fogLevel)),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    node.name,
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    "Humidity: ${node.humidity.toStringAsFixed(1)}%",
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ],
              ),
            ),
            Text(
              fogText(node.fogLevel),
              style: TextStyle(
                color: fogColor(node.fogLevel),
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
      backgroundColor: const Color(0xFF0A1F44),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0A1F44),
        title: Text(widget.routeName),
        centerTitle: true,
      ),
      body: isLoading
          ? const Center(
        child: CircularProgressIndicator(color: Colors.cyanAccent),
      )
          : RefreshIndicator(
        onRefresh: fetchData,
        child: nodes.isEmpty
            ? ListView(
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.height - 100,
              child: const Center(
                child: Text(
                  "No Data Available",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        )
            : Padding(
          padding: const EdgeInsets.all(20),
          child: ListView(
            children: nodes.map(buildNodeCard).toList(),
          ),
        ),
      ),
    );
  }
}