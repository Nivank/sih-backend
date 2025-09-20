import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/auth_state.dart';
import 'map_screen_google.dart';
import 'map_screen_openstreetmap.dart';

class MapScreen extends StatefulWidget {
  final Map<String, dynamic>? noteToFocus;
  final VoidCallback? onNoteFocused;
  
  const MapScreen({super.key, this.noteToFocus, this.onNoteFocused});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  String _selectedMapProvider = 'openstreet'; // 'openstreet' or 'google'
  
  // This will be passed to child screens to allow note focusing
  void _focusOnNote(Map<String, dynamic> note) {
    // This will be implemented in child screens
  }
  
  @override
  void initState() {
    super.initState();
    // Handle note focusing from other screens
    if (widget.noteToFocus != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _focusOnNote(widget.noteToFocus!);
        widget.onNoteFocused?.call();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthState>();
    
    return Column(
      children: [
        // Minimal Map Provider Toggle Bar
        Container(
          height: 60,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              const Icon(Icons.map, color: Colors.indigo, size: 20),
              const SizedBox(width: 8),
              const Text(
                'Map Provider:',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => _selectedMapProvider = 'openstreet'),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                            decoration: BoxDecoration(
                              color: _selectedMapProvider == 'openstreet' 
                                  ? Colors.indigo 
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              'OpenStreetMap',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: _selectedMapProvider == 'openstreet' 
                                    ? Colors.white 
                                    : Colors.grey.shade600,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => _selectedMapProvider = 'google'),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                            decoration: BoxDecoration(
                              color: _selectedMapProvider == 'google' 
                                  ? Colors.indigo 
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              'Google Maps',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: _selectedMapProvider == 'google' 
                                    ? Colors.white 
                                    : Colors.grey.shade600,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        
        // Map Implementation - Takes up the remaining space
        Expanded(
          child: _selectedMapProvider == 'openstreet'
              ? MapScreenOpenStreetMap(noteToFocus: widget.noteToFocus)
              : MapScreenGoogleMaps(noteToFocus: widget.noteToFocus),
        ),
      ],
    );
  }
}
