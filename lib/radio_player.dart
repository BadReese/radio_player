/*
 *  radio_player.dart
 *
 *  Created by Ilya Chirkunov <xc@yar.net> on 28.12.2020.
 */

import 'dart:async';
import 'package:flutter/services.dart';

class RadioPlayer {
  static const _methodChannel = MethodChannel('radio_player');
  static const _metadataEvents = EventChannel('radio_player/metadataEvents');
  static const _stateEvents = EventChannel('radio_player/stateEvents');
  static const _defaultArtworkChannel =
      BasicMessageChannel("radio_player/defaultArtwork", BinaryCodec());

  Stream<bool>? _stateStream;
  Stream<List<String>>? _metadataStream;

  /// Configure channel
  Future<void> setMediaItem(String title, String url, [String? image]) async {
    await _methodChannel.invokeMethod('set', [title, url]);
    if (image != null) setArtwork(image);
  }

  /// Set default artwork
  Future<void> setArtwork(String image) async {
    await rootBundle.load(image).then((value) {
      _defaultArtworkChannel.send(value);
    });
  }

  Future<void> play() async {
    await _methodChannel.invokeMethod('play');
  }

  Future<void> pause() async {
    await _methodChannel.invokeMethod('pause');

    setMediaItem(
        'Radio Player', 'https://myradio24.org/2288.m3u', 'assets/cover.jpg');
  }

  /// Get the playback state stream.
  Stream<bool> get stateStream {
    _stateStream ??=
        _stateEvents.receiveBroadcastStream().map<bool>((value) => value);

    return _stateStream!;
  }

  /// Get the metadata stream.
  Stream<List<String>> get metadataStream {
    _metadataStream ??=
        _metadataEvents.receiveBroadcastStream().map((metadata) {
      return metadata.map<String>((value) => value as String).toList();
    });

    return _metadataStream!;
  }
}
