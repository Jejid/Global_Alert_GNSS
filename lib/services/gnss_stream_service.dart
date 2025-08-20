// File B: lib/services/gnss_stream_service.dart
// Enhanced GnssStreamService supporting:
//  - existing JSON simulation (assets/alerts_examples.json)
//  - real incoming Globert 20-byte messages
//  - fragmented frames (marker + msgId + seq + total) reassembly
//
// Behavior:
//  - call getAlertStream() to receive alerts as a Stream<AlertMessage>
//  - call handleIncomingRaw(Uint8List raw) when receiving bytes from a native
//    GNSS plugin or simulator that provides raw frames
//
// Note: this file assumes `AlertMessage.fromJson(Map)` exists (like previous
// JSON loader used). It also imports GlobertMessage for parsing assembled
// payloads.

import 'dart:async';
import 'dart:convert';

import 'package:flutter/services.dart';

import '../models/alert_message_model.dart';
import '../protocols/globert/globert_fragmenter.dart';
import '../protocols/globert/globert_message.dart';

class _ReassemblyState {
  final int messageId;
  final int totalFrames;
  final Map<int, Uint8List> chunks = {};
  DateTime firstSeen;

  _ReassemblyState(this.messageId, this.totalFrames)
    : firstSeen = DateTime.now();

  bool get isComplete => chunks.length == totalFrames;

  Uint8List assemble() {
    final totalLen = chunks.values.fold<int>(0, (p, e) => p + e.length);
    final out = Uint8List(totalLen);
    var offset = 0;
    for (var i = 0; i < totalFrames; i++) {
      final c = chunks[i];
      if (c == null)
        throw StateError('missing chunk $i for message $messageId');
      out.setRange(offset, offset + c.length, c);
      offset += c.length;
    }
    return out;
  }
}

class GnssStreamService {
  final Duration interval;
  List<AlertMessage>? _alerts;
  int _currentIndex = 0;

  // Stream controller for publishing alerts (simulation + real)
  final StreamController<AlertMessage> _controller =
      StreamController<AlertMessage>.broadcast();
  bool _simulationStarted = false;

  // Reassembly map: messageId -> state
  final Map<int, _ReassemblyState> _reassembly = {};

  GnssStreamService({this.interval = const Duration(seconds: 5)});

  /// Initialize simulation alerts from assets
  Future<void> init() async {
    final String jsonStr = await rootBundle.loadString(
      'assets/alerts_examples.json',
    );
    final List<dynamic> data = jsonDecode(jsonStr);
    _alerts = data
        .map((e) => AlertMessage.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Returns a broadcast stream of alerts. Starts the simulation (if present)
  /// the first time this method is called.
  Stream<AlertMessage> getAlertStream() {
    if (!_simulationStarted) {
      _startSimulation();
    }
    return _controller.stream;
  }

  void _startSimulation() async {
    _simulationStarted = true;
    if (_alerts == null) {
      await init();
    }
    // emit simulation alerts with the configured interval
    while (_currentIndex < (_alerts?.length ?? 0)) {
      _controller.add(_alerts![_currentIndex]);
      _currentIndex++;
      await Future.delayed(interval);
    }
  }

  /// Reset simulation index to replay
  void reset() {
    _currentIndex = 0;
  }

  /// Dispose controller (call on app shutdown)
  void dispose() {
    _controller.close();
  }

  // ------------------ Handling incoming raw bytes (from plugin) --------------

  /// Public API: call this when the native GNSS layer (or test harness)
  /// provides raw bytes that may be a full 20-byte Globert message or one
  /// of the fragmented frames produced by GlobertFragmenter.fragment(...).
  void handleIncomingRaw(Uint8List raw) {
    if (raw.isEmpty) return;
    // Detection: fragmented frames start with marker 0xAB
    if (raw[0] == GlobertFragmenter.marker) {
      _handleFragment(raw);
    } else if (raw.length == 20) {
      // Direct full MEDIUM payload
      _parseAndPublish(raw);
    } else {
      // Unknown/ignored frame size
      print('Received unknown raw length=${raw.length} — ignoring');
    }
  }

  void _handleFragment(Uint8List frame) {
    if (frame.length < GlobertFragmenter.headerSize) {
      print('Fragment too short — ignoring');
      return;
    }
    final msgId = frame[1];
    final seq = frame[2];
    final total = frame[3];

    final state = _reassembly.putIfAbsent(
      msgId,
      () => _ReassemblyState(msgId, total),
    );
    state.chunks[seq] = frame.sublist(GlobertFragmenter.headerSize);

    // If we've got them all, assemble and parse
    if (state.isComplete) {
      try {
        final assembled = state.assemble();
        _reassembly.remove(msgId);
        _parseAndPublish(assembled);
      } catch (e) {
        print('Error assembling message $msgId: $e');
        _reassembly.remove(msgId);
      }
    } else {
      // cleanup stale entries periodically
      _cleanupReassembly();
    }
  }

  void _cleanupReassembly() {
    final now = DateTime.now();
    final toRemove = <int>[];
    _reassembly.forEach((id, st) {
      if (now.difference(st.firstSeen).inSeconds > 30) {
        toRemove.add(id);
      }
    });
    for (final id in toRemove) {
      _reassembly.remove(id);
    }
  }

  void _parseAndPublish(Uint8List payload) {
    try {
      final msg = GlobertMessage.fromBytes(payload.toList());
      if (!msg.isCrcValid) {
        print('Globert message CRC invalid — ignoring');
        return;
      }
      final alertJson = msg.toAlertJson();
      final alert = AlertMessage.fromJson(Map<String, dynamic>.from(alertJson));
      _controller.add(alert);
    } catch (e) {
      print('Failed parsing Globert payload: $e');
    }
  }
}
