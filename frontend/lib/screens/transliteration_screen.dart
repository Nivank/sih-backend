import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

import '../services/api_client.dart';
import '../state/auth_state.dart';
import '../utils/config.dart';

class TransliterationScreen extends StatefulWidget {
  const TransliterationScreen({super.key});

  @override
  State<TransliterationScreen> createState() => _TransliterationScreenState();
}

class _TransliterationScreenState extends State<TransliterationScreen> {
  final _textController = TextEditingController();
  String _sourceScript = UiConstants.supportedScripts.first; // Source language
  String _targetScript = UiConstants.supportedScripts[1]; // Target language
  String? _result;
  String? _wordMeaning;
  String? _originalText;
  bool _loading = false;
  bool _savingToNotes = false;
  bool _savingToMap = false;

  @override
  void initState() {
    super.initState();
    // Ensure source and target are different
    if (_sourceScript == _targetScript) {
      _targetScript = UiConstants.supportedScripts[1];
    }
  }

  Future<void> _transliterateText() async {
    final text = _textController.text.trim();
    if (text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(UiConstants.enterTextMessage))
      );
      return;
    }

    setState(() => _loading = true);
    final client = ApiClient(() => {});
    try {
      final resp = await client.postJson('/transliterate/', {
        'source_text': text,
        'source_script': _sourceScript,
        'target_script': _targetScript,
      });
      setState(() => _loading = false);
      if (resp.statusCode == 200) {
        final data = jsonDecode(resp.body) as Map<String, dynamic>;
        final result = data['transliterated_text'];
        final wordMeaning = data['word_meaning'];
        if (result != null) {
          setState(() {
            _result = result as String;
            _wordMeaning = wordMeaning as String?;
            _originalText = text;
          });
        } else {
          setState(() => _result = 'No transliteration result received');
        }
      } else {
        print('Error response: ${resp.body}');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('${UiConstants.transliterationErrorMessage} text'))
        );
      }
    } catch (e) {
      setState(() => _loading = false);
      print('Exception during text transliteration: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Network error: $e'))
      );
    }
  }

  Future<void> _pickImageAndTransliterate() async {
    try {
      final picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );
      if (image == null) return;
      
      final bytes = await image.readAsBytes();
      await _sendImage(bytes, image.name);
    } catch (e) {
      print('Error picking image: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error accessing gallery: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _captureAndTransliterate() async {
    try {
      final picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );
      if (image == null) return;
      
      final bytes = await image.readAsBytes();
      await _sendImage(bytes, image.name);
    } catch (e) {
      print('Error capturing image: $e');
      if (mounted) {
        String errorMessage = 'Error accessing camera: $e';
        if (e.toString().contains('camera_access_denied')) {
          errorMessage = 'Camera access denied. Please enable camera permissions in your browser settings.';
        } else if (e.toString().contains('NotAllowedError')) {
          errorMessage = 'Camera access blocked. Please allow camera permissions for this website.';
        }
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
            action: SnackBarAction(
              label: 'Help',
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Row(
                      children: [
                        Icon(Icons.camera_alt, color: Colors.orange),
                        SizedBox(width: 8),
                        Text('Camera Permission Required'),
                      ],
                    ),
                    content: const Text(
                      'Camera access has been denied. To use the camera feature for text recognition, please:\n\n'
                      '1. Refresh the page and allow camera access when prompted\n'
                      '2. Or go to your browser settings\n'
                      '3. Find site permissions\n'
                      '4. Allow camera access for this website',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('OK'),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        );
      }
    }
  }

  Future<void> _sendImage(Uint8List bytes, String name) async {
    setState(() => _loading = true);
    final client = ApiClient(() => {});
    try {
      final streamResp = await client.postMultipart(
        '/transliterate/image',
        fields: {
          'target_script': _targetScript,
          'source_script': _sourceScript,
        },
        fileField: 'file',
        fileName: name,
        fileBytes: bytes,
      );
      final resp = await http.Response.fromStream(streamResp);
      setState(() => _loading = false);
      if (resp.statusCode == 200) {
        final data = jsonDecode(resp.body) as Map<String, dynamic>;
        final result = data['transliterated_text'];
        final extractedText = data['extracted_text']; // OCR extracted text
        final wordMeaning = data['word_meaning'];
        if (result != null) {
          setState(() {
            _result = result as String;
            _wordMeaning = wordMeaning as String?;
            _originalText = extractedText as String? ?? 'Text from image';
            _textController.text = _originalText!; // Set extracted text in input
          });
        } else {
          setState(() => _result = 'No transliteration result received');
        }
      } else {
        final errorData = jsonDecode(resp.body);
        String errorMessage = 'Processing failed';
        if (errorData['detail'] != null) {
          errorMessage = errorData['detail'].toString();
        }
        print('Error response: ${resp.body}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      setState(() => _loading = false);
      print('Exception during image transliteration: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Network error: Unable to process image. Please check your connection and try again.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _copyToClipboard() async {
    if (_result != null) {
      await Clipboard.setData(ClipboardData(text: _result!));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text(UiConstants.textCopiedMessage))
        );
      }
    }
  }

  Future<bool> _requestCameraPermission() async {
    final status = await Permission.camera.request();
    if (status == PermissionStatus.granted) {
      return true;
    } else if (status == PermissionStatus.denied) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Camera permission is required to capture images for transliteration'),
            backgroundColor: Colors.orange,
          ),
        );
      }
      return false;
    } else if (status == PermissionStatus.permanentlyDenied) {
      if (mounted) {
        _showPermissionDialog();
      }
      return false;
    }
    return false;
  }

  void _showPermissionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.camera_alt, color: Colors.orange),
            SizedBox(width: 8),
            Text('Camera Permission Required'),
          ],
        ),
        content: const Text(
          'Camera access has been permanently denied. To use the camera feature for text recognition, please:\n\n'
          '1. Go to your browser settings\n'
          '2. Find site permissions\n'
          '3. Allow camera access for this website\n'
          '4. Refresh the page',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              openAppSettings();
            },
            child: const Text('Open Settings'),
          ),
        ],
      ),
    );
  }

  Future<void> _saveToNotes() async {
    if (_result == null) return;
    
    final auth = context.read<AuthState>();
    if (!auth.isAuthenticated) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(UiConstants.loginRequiredMessage))
      );
      return;
    }

    setState(() => _savingToNotes = true);
    try {
      final client = ApiClient(auth.authHeaders);
      
      // Create note content with transliteration info
      final noteContent = 'Transliteration: $_originalText ($_sourceScript) → $_result ($_targetScript)';
      
      final resp = await client.postJson('/notes/add', {
        'text': noteContent,
        'latitude': 0.0, // Default location for simple notes
        'longitude': 0.0,
      });
      
      if (resp.statusCode == 200) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text(UiConstants.noteSavedMessage))
          );
        }
      } else {
        throw Exception('Failed to save note: ${resp.statusCode}');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving note: $e'))
        );
      }
    } finally {
      if (mounted) setState(() => _savingToNotes = false);
    }
  }

  Future<void> _saveToMapWithLocation() async {
    if (_result == null) return;
    
    final auth = context.read<AuthState>();
    if (!auth.isAuthenticated) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(UiConstants.loginRequiredMessage))
      );
      return;
    }

    setState(() => _savingToMap = true);
    try {
      // Get current location
      final position = await _getCurrentLocation();
      
      final client = ApiClient(auth.authHeaders);
      
      // Create location-based note with transliteration info
      final noteContent = 'Memory: $_originalText ($_sourceScript) → $_result ($_targetScript)';
      
      final resp = await client.postJson('/notes/add', {
        'text': noteContent,
        'latitude': position.latitude,
        'longitude': position.longitude,
      });
      
      if (resp.statusCode == 200) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text(UiConstants.noteSavedToMapMessage))
          );
        }
      } else {
        throw Exception('Failed to save note: ${resp.statusCode}');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving to map: $e'))
        );
      }
    } finally {
      if (mounted) setState(() => _savingToMap = false);
    }
  }

  Future<Position> _getCurrentLocation() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.deniedForever || permission == LocationPermission.denied) {
      throw Exception('Location permission denied');
    }
    return Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
  }

  void _clearText() {
    setState(() {
      _textController.clear();
      _result = null;
      _wordMeaning = null;
      _originalText = null;
    });
  }

  void _swapLanguages() {
    setState(() {
      final temp = _sourceScript;
      _sourceScript = _targetScript;
      _targetScript = temp;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          const Text(
            '🔧 EDITABLE: ${UiConstants.transliterationTitle}',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          
          // Language Selection Section
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '🌍 Language Selection',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 12),
                  
                  // Source Language
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('From:', style: TextStyle(fontWeight: FontWeight.w500)),
                            const SizedBox(height: 4),
                            DropdownButtonFormField<String>(
                              initialValue: _sourceScript,
                              decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              ),
                              items: UiConstants.supportedScripts
                                  .map((s) => DropdownMenuItem<String>(
                                        value: s,
                                        child: Text(s),
                                      ))
                                  .toList(),
                              onChanged: (v) {
                                if (v != null && v != _targetScript) {
                                  setState(() => _sourceScript = v);
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                      
                      // Swap button
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Column(
                          children: [
                            const SizedBox(height: 20),
                            IconButton(
                              onPressed: _swapLanguages,
                              icon: const Icon(Icons.swap_horiz, size: 32),
                              tooltip: 'Swap languages',
                            ),
                          ],
                        ),
                      ),
                      
                      // Target Language
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('To:', style: TextStyle(fontWeight: FontWeight.w500)),
                            const SizedBox(height: 4),
                            DropdownButtonFormField<String>(
                              initialValue: _targetScript,
                              decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              ),
                              items: UiConstants.supportedScripts
                                  .map((s) => DropdownMenuItem<String>(
                                        value: s,
                                        child: Text(s),
                                      ))
                                  .toList(),
                              onChanged: (v) {
                                if (v != null && v != _sourceScript) {
                                  setState(() => _targetScript = v);
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Text Input Section
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text(
                        '✍️ Enter Text',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                      const Spacer(),
                      TextButton.icon(
                        onPressed: _textController.text.isNotEmpty ? _clearText : null,
                        icon: const Icon(Icons.clear, size: 16),
                        label: const Text(UiConstants.clearTextLabel),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  
                  TextField(
                    controller: _textController,
                    maxLines: 4,
                    decoration: InputDecoration(
                      labelText: 'Text in $_sourceScript',
                      hintText: 'Enter text to transliterate...',
                      border: const OutlineInputBorder(),
                      suffixIcon: _textController.text.isNotEmpty
                          ? IconButton(
                              onPressed: _clearText,
                              icon: const Icon(Icons.clear),
                            )
                          : null,
                    ),
                    onChanged: (text) => setState(() {}), // Refresh UI for clear button
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Action Buttons
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      ElevatedButton.icon(
                        onPressed: _loading ? null : _transliterateText,
                        icon: const Icon(Icons.translate),
                        label: const Text(UiConstants.transliterateTextLabel),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).primaryColor,
                          foregroundColor: Colors.white,
                        ),
                      ),
                      OutlinedButton.icon(
                        onPressed: _loading ? null : _pickImageAndTransliterate,
                        icon: const Icon(Icons.photo_library),
                        label: const Text(UiConstants.pickImageLabel),
                      ),
                      OutlinedButton.icon(
                        onPressed: _loading ? null : _captureAndTransliterate,
                        icon: const Icon(Icons.camera_alt),
                        label: const Text(UiConstants.captureImageLabel),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Loading indicator
          if (_loading) 
            const Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 8),
                    Text('Transliterating...'),
                  ],
                ),
              ),
            ),
          
          // Result Section
          if (_result != null) ...[
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Text(
                          '✨ Result',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                        ),
                        const Spacer(),
                        IconButton(
                          onPressed: _copyToClipboard,
                          icon: const Icon(Icons.copy),
                          tooltip: UiConstants.copyResultLabel,
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    
                    // Original text
                    if (_originalText != null) ...[
                      Text(
                        'Original ($_sourceScript):',
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey[300]!),
                        ),
                        child: SelectableText(
                          _originalText!,
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                    
                    // Translated text
                    Text(
                      'Transliterated ($_targetScript):',
                      style: const TextStyle(
                        fontWeight: FontWeight.w500,
                        color: Colors.green,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.green[50],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.green[300]!),
                      ),
                      child: SelectableText(
                        _result!,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    
                    // Word meaning/translation section
                    if (_wordMeaning != null) ...[
                      const SizedBox(height: 16),
                      const Text(
                        'Word Meaning/Translation:',
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          color: Colors.blue,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.blue[50],
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.blue[300]!),
                        ),
                        child: SelectableText(
                          _wordMeaning!,
                          style: const TextStyle(
                            fontSize: 16,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                    ],
                    
                    const SizedBox(height: 16),
                    
                    // Save options
                    const Text(
                      '💾 Save Options',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 8),
                    
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        ElevatedButton.icon(
                          onPressed: _savingToNotes ? null : _saveToNotes,
                          icon: _savingToNotes
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              : const Icon(Icons.notes),
                          label: const Text(UiConstants.saveToNotesLabel),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
                          ),
                        ),
                        ElevatedButton.icon(
                          onPressed: _savingToMap ? null : _saveToMapWithLocation,
                          icon: _savingToMap
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              : const Icon(Icons.location_on),
                          label: const Text(UiConstants.saveToMapLabel),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                          ),
                        ),
                        OutlinedButton.icon(
                          onPressed: _copyToClipboard,
                          icon: const Icon(Icons.copy),
                          label: const Text(UiConstants.copyResultLabel),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
