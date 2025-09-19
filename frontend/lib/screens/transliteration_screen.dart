import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
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
  String _target = UiConstants.supportedScripts.first;
  String? _result;
  bool _loading = false;

  Future<void> _transliterateText() async {
    setState(() => _loading = true);
    final client = ApiClient(() => {});
    final resp = await client.postJson('/transliterate/', {
      'source_text': _textController.text,
      'source_script': 'Devanagari',
      'target_script': _target,
    });
    setState(() => _loading = false);
    if (resp.statusCode == 200) {
      final data = jsonDecode(resp.body) as Map<String, dynamic>;
      setState(() => _result = data['transliterated_text'] as String?);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Error transliterating text')));
    }
  }

  Future<void> _pickImageAndTransliterate() async {
    final picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image == null) return;
    final bytes = await image.readAsBytes();
    await _sendImage(bytes, image.name);
  }

  Future<void> _captureAndTransliterate() async {
    final picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.camera);
    if (image == null) return;
    final bytes = await image.readAsBytes();
    await _sendImage(bytes, image.name);
  }

  Future<void> _sendImage(Uint8List bytes, String name) async {
    setState(() => _loading = true);
    final client = ApiClient(() => {});
    final streamResp = await client.postMultipart(
      '/transliterate/image',
      fields: {
        'target_script': _target,
        'source_script': 'Devanagari',
      },
      fileField: 'file',
      fileName: name,
      fileBytes: bytes,
    );
    final resp = await http.Response.fromStream(streamResp);
    setState(() => _loading = false);
    if (resp.statusCode == 200) {
      final data = jsonDecode(resp.body) as Map<String, dynamic>;
      setState(() => _result = data['transliterated_text'] as String?);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Error transliterating image')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('🔧 EDITABLE: Transliteration', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          TextField(
            controller: _textController,
            maxLines: 3,
            decoration: const InputDecoration(labelText: 'Source text'),
          ),
          const SizedBox(height: 8),
          DropdownButton<String>(
            value: _target,
            items: UiConstants.supportedScripts
                .map((s) => DropdownMenuItem<String>(value: s, child: Text(s)))
                .toList(),
            onChanged: (v) => setState(() => _target = v ?? _target),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              ElevatedButton(onPressed: _loading ? null : _transliterateText, child: const Text('Transliterate Text')),
              ElevatedButton(onPressed: _loading ? null : _pickImageAndTransliterate, child: const Text('Pick Image')),
              ElevatedButton(onPressed: _loading ? null : _captureAndTransliterate, child: const Text('Capture Image')),
            ],
          ),
          const SizedBox(height: 16),
          if (_loading) const LinearProgressIndicator(),
          if (_result != null) ...[
            const Divider(),
            const Text('Result:'),
            SelectableText(_result!),
          ]
        ],
      ),
    );
  }
}
