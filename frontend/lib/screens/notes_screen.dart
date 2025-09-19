import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';

import '../services/api_client.dart';
import '../state/auth_state.dart';

class NotesScreen extends StatefulWidget {
  const NotesScreen({super.key});

  @override
  State<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen> {
  final _controller = TextEditingController();
  bool _loading = false;
  List<Map<String, dynamic>> _notes = const [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _fetchNotes());
  }

  Future<void> _fetchNotes() async {
    final auth = context.read<AuthState>();
    final client = ApiClient(auth.authHeaders);
    final resp = await client.get('/notes/');
    if (!mounted) return;
    if (resp.statusCode == 200) {
      final List list = jsonDecode(resp.body) as List;
      setState(() => _notes = list.cast<Map<String, dynamic>>());
    }
  }

  Future<void> _addNote() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    setState(() => _loading = true);
    try {
      final pos = await _getPosition();
      final auth = context.read<AuthState>();
      final client = ApiClient(auth.authHeaders);
      final resp = await client.postJson('/notes/add', {
        'text': text,
        'latitude': pos.latitude,
        'longitude': pos.longitude,
      });
      if (resp.statusCode == 200) {
        _controller.clear();
        await _fetchNotes();
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to add note')));
        }
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<Position> _getPosition() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.deniedForever || permission == LocationPermission.denied) {
      throw Exception('Location permission denied');
    }
    return Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
  }

  @override
  Widget build(BuildContext context) {
    final authed = context.watch<AuthState>().isAuthenticated;
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('🔧 EDITABLE: Notes', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          if (!authed) const Text('Please login to use notes.'),
          if (authed) ...[
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(labelText: 'Note'),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(onPressed: _loading ? null : _addNote, child: const Text('Save')),
              ],
            ),
            const SizedBox(height: 12),
            Expanded(
              child: RefreshIndicator(
                onRefresh: _fetchNotes,
                child: ListView.builder(
                  itemCount: _notes.length,
                  itemBuilder: (context, index) {
                    final n = _notes[index];
                    return ListTile(
                      title: Text(n['text']?.toString() ?? ''),
                      subtitle: Text('(${n['latitude']}, ${n['longitude']})'),
                    );
                  },
                ),
              ),
            )
          ]
        ],
      ),
    );
  }
}
