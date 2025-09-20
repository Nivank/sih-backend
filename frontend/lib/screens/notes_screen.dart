import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';

import '../services/api_client.dart';
import '../state/auth_state.dart';
import '../utils/config.dart';
import 'photo_note_screen.dart';

class NotesScreen extends StatefulWidget {
  final Function(Map<String, dynamic>)? onViewOnMap;
  
  const NotesScreen({super.key, this.onViewOnMap});

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
    if (!auth.isAuthenticated) {
      print('Not authenticated - cannot fetch notes');
      return;
    }
    
    try {
      final client = ApiClient(auth.authHeaders);
      final resp = await client.get('/notes/');
      if (!mounted) return;
      
      print('Notes fetch response: ${resp.statusCode}');
      print('Response body: ${resp.body}');
      
      if (resp.statusCode == 200) {
        final List list = jsonDecode(resp.body) as List;
        setState(() => _notes = list.cast<Map<String, dynamic>>());
      } else if (resp.statusCode == 401) {
        print('Authentication failed - clearing token');
        // Clear invalid token
        await auth.logout();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Session expired. Please login again.'))
          );
        }
      } else {
        print('Failed to fetch notes: ${resp.statusCode} - ${resp.body}');
      }
    } catch (e) {
      print('Error fetching notes: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Network error: $e'))
        );
      }
    }
  }

  Future<void> _addNote() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    
    final auth = context.read<AuthState>();
    if (!auth.isAuthenticated) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please login first'))
        );
      }
      return;
    }
    
    setState(() => _loading = true);
    try {
      final pos = await _getPosition();
      final client = ApiClient(auth.authHeaders);
      final resp = await client.postJson('/notes/add', {
        'text': text,
        'latitude': pos.latitude,
        'longitude': pos.longitude,
      });
      
      print('Add note response: ${resp.statusCode}');
      print('Response body: ${resp.body}');
      
      if (resp.statusCode == 200) {
        _controller.clear();
        await _fetchNotes();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Note added successfully'))
          );
        }
      } else if (resp.statusCode == 401) {
        print('Authentication failed during note add');
        await auth.logout();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Session expired. Please login again.'))
          );
        }
      } else {
        print('Failed to add note: ${resp.statusCode} - ${resp.body}');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text(UiConstants.noteAddFailedMessage)));
        }
      }
    } catch (e) {
      print('Error adding note: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'))
        );
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

  Future<void> _addLocationToNote(int? noteId) async {
    if (noteId == null) return;
    
    final auth = context.read<AuthState>();
    if (!auth.isAuthenticated) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please login first'))
      );
      return;
    }

    try {
      final position = await _getPosition();
      final client = ApiClient(auth.authHeaders);
      
      // You would need an API endpoint to update note location
      // For now, we'll show a message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Location captured: ${position.latitude.toStringAsFixed(4)}, ${position.longitude.toStringAsFixed(4)}'
          ),
        ),
      );
      
      // TODO: Implement API call to update note with location
      // final resp = await client.postJson('/notes/$noteId/update-location', {
      //   'latitude': position.latitude,
      //   'longitude': position.longitude,
      // });
      
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error getting location: $e'))
      );
    }
  }

  void _showFullSizePhoto(Map<String, dynamic> note) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppBar(
              title: const Text('Photo'),
              backgroundColor: Colors.transparent,
              foregroundColor: Colors.black,
              elevation: 0,
              leading: IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
            Expanded(
              child: Image.network(
                '${AppConfig.apiBaseUrl}/notes/${note['id']}/photo',
                headers: context.read<AuthState>().authHeaders(),
                fit: BoxFit.contain,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return const Center(child: CircularProgressIndicator());
                },
                errorBuilder: (context, error, stackTrace) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.broken_image, size: 48, color: Colors.grey),
                        Text('Photo not available'),
                      ],
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                note['text']?.toString() ?? '',
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authed = context.watch<AuthState>().isAuthenticated;
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('🔧 EDITABLE: ${UiConstants.notesTitle}', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          if (!authed) const Text(UiConstants.loginRequiredMessage),
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
                ElevatedButton(
                  onPressed: _loading ? null : _addNote, 
                  child: const Text(UiConstants.saveNoteLabel)
                ),
              ],
            ),
            const SizedBox(height: 12),
            
            // Photo note button
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => PhotoNoteScreen(
                        onNoteCreated: _fetchNotes,
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.camera_alt),
                label: const Text('📸 Create Photo Note'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  side: BorderSide(color: Colors.blue[300]!),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: RefreshIndicator(
                onRefresh: _fetchNotes,
                child: ListView.builder(
                  itemCount: _notes.length,
                  itemBuilder: (context, index) {
                    final n = _notes[index];
                    final noteText = n['text']?.toString() ?? '';
                    final hasLocation = n['latitude'] != null && n['longitude'] != null &&
                                       n['latitude'] != 0.0 && n['longitude'] != 0.0;
                    final hasPhoto = n['has_photo'] == true;
                    final isTransliteration = noteText.contains('Transliteration:') || noteText.contains('Memory:');
                    
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Photo section
                          if (hasPhoto) ...[
                            Container(
                              width: double.infinity,
                              height: 200,
                              decoration: BoxDecoration(
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(12),
                                  topRight: Radius.circular(12),
                                ),
                                color: Colors.grey[200],
                              ),
                              child: ClipRRect(
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(12),
                                  topRight: Radius.circular(12),
                                ),
                                child: Image.network(
                                  '${AppConfig.apiBaseUrl}/notes/${n['id']}/photo',
                                  fit: BoxFit.cover,
                                  headers: context.read<AuthState>().authHeaders(),
                                  loadingBuilder: (context, child, loadingProgress) {
                                    if (loadingProgress == null) return child;
                                    return Center(
                                      child: CircularProgressIndicator(
                                        value: loadingProgress.expectedTotalBytes != null
                                            ? loadingProgress.cumulativeBytesLoaded /
                                                loadingProgress.expectedTotalBytes!
                                            : null,
                                      ),
                                    );
                                  },
                                  errorBuilder: (context, error, stackTrace) {
                                    return const Center(
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(Icons.broken_image, size: 48, color: Colors.grey),
                                          Text('Photo not available', style: TextStyle(color: Colors.grey)),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                          ],
                          
                          // Content section
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Note header with icon
                                Row(
                                  children: [
                                    CircleAvatar(
                                      radius: 16,
                                      backgroundColor: hasPhoto
                                          ? Colors.purple
                                          : isTransliteration 
                                              ? Colors.orange 
                                              : hasLocation 
                                                  ? Colors.green 
                                                  : Colors.blue,
                                      child: Icon(
                                        hasPhoto
                                            ? Icons.photo_camera
                                            : isTransliteration 
                                                ? Icons.translate 
                                                : hasLocation 
                                                    ? Icons.location_on 
                                                    : Icons.note,
                                        color: Colors.white,
                                        size: 16,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        hasPhoto ? '📸 Photo Note' : 'Text Note',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.grey[700],
                                        ),
                                      ),
                                    ),
                                    // Action menu
                                    PopupMenuButton(
                                      itemBuilder: (context) => [
                                        if (hasLocation) ...[
                                          const PopupMenuItem(
                                            value: 'view_map',
                                            child: Row(
                                              children: [
                                                Icon(Icons.map, size: 16),
                                                SizedBox(width: 8),
                                                Text('View on Map'),
                                              ],
                                            ),
                                          ),
                                          const PopupMenuItem(
                                            value: 'copy_location',
                                            child: Row(
                                              children: [
                                                Icon(Icons.copy, size: 16),
                                                SizedBox(width: 8),
                                                Text('Copy Location'),
                                              ],
                                            ),
                                          ),
                                        ],
                                        if (hasPhoto)
                                          const PopupMenuItem(
                                            value: 'view_photo',
                                            child: Row(
                                              children: [
                                                Icon(Icons.fullscreen, size: 16),
                                                SizedBox(width: 8),
                                                Text('View Full Size'),
                                              ],
                                            ),
                                          ),
                                      ],
                                      onSelected: (value) {
                                        if (value == 'view_map') {
                                          if (widget.onViewOnMap != null) {
                                            widget.onViewOnMap!(n);
                                          } else {
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              const SnackBar(
                                                content: Text('Go to Map tab to view this location'),
                                              ),
                                            );
                                          }
                                        } else if (value == 'copy_location') {
                                          Clipboard.setData(
                                            ClipboardData(
                                              text: 'Lat: ${n['latitude']}, Lng: ${n['longitude']}',
                                            ),
                                          );
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            const SnackBar(
                                              content: Text('Location copied to clipboard'),
                                            ),
                                          );
                                        } else if (value == 'view_photo') {
                                          _showFullSizePhoto(n);
                                        }
                                      },
                                    ),
                                  ],
                                ),
                                
                                const SizedBox(height: 12),
                                
                                // Note text
                                Text(
                                  noteText,
                                  style: const TextStyle(fontSize: 16),
                                ),
                                
                                const SizedBox(height: 8),
                                
                                // Note metadata
                                Wrap(
                                  spacing: 16,
                                  runSpacing: 4,
                                  children: [
                                    if (hasLocation) ...[
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Icon(
                                            Icons.my_location,
                                            size: 14,
                                            color: Colors.grey,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            'Lat: ${(n['latitude'] as double).toStringAsFixed(4)}, Lng: ${(n['longitude'] as double).toStringAsFixed(4)}',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey[600],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                    if (n['created_at']?.toString().isNotEmpty == true) ...[
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Icon(
                                            Icons.access_time,
                                            size: 14,
                                            color: Colors.grey,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            n['created_at'].toString().split('T')[0],
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey[600],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
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
