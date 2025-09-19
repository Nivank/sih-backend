import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

import '../services/api_client.dart';
import '../state/auth_state.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  Set<Marker> _markers = {};
  CameraPosition _initial = const CameraPosition(target: LatLng(20.5937, 78.9629), zoom: 4.7);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadMarkers());
  }

  Future<void> _loadMarkers() async {
    final auth = context.read<AuthState>();
    if (!auth.isAuthenticated) return;
    final client = ApiClient(auth.authHeaders);
    final resp = await client.get('/notes/');
    if (resp.statusCode == 200) {
      final List list = jsonDecode(resp.body) as List;
      final markers = list.map((e) {
        final m = e as Map<String, dynamic>;
        final lat = (m['latitude'] as num).toDouble();
        final lon = (m['longitude'] as num).toDouble();
        return Marker(
          markerId: MarkerId(m['id'].toString()),
          position: LatLng(lat, lon),
          infoWindow: InfoWindow(title: m['text']?.toString() ?? 'Note'),
        );
      }).toSet();
      if (mounted) setState(() => _markers = markers);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.all(16),
          child: Text('🔧 EDITABLE: Map', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        ),
        Expanded(
          child: GoogleMap(
            initialCameraPosition: _initial,
            markers: _markers,
            myLocationEnabled: false,
          ),
        ),
      ],
    );
  }
}
