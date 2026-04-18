import 'package:flutter/foundation.dart';
import 'package:speech_to_text/speech_recognition_error.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';

enum VoiceState { idle, listening, processing, error }

class VoiceInputService extends ChangeNotifier {
  final SpeechToText _speech = SpeechToText();

  VoiceState state = VoiceState.idle;
  String transcript = '';
  String? errorMessage;
  double level = 0;
  bool _initialized = false;

  Future<bool> _ensureInit() async {
    if (_initialized) return true;
    _initialized = await _speech.initialize(
      onError: (SpeechRecognitionError e) {
        state = VoiceState.error;
        errorMessage = e.errorMsg;
        notifyListeners();
      },
      onStatus: (status) {
        if (status == 'done' || status == 'notListening') {
          if (state == VoiceState.listening) {
            state = VoiceState.idle;
            notifyListeners();
          }
        }
      },
    );
    return _initialized;
  }

  Future<void> start({
    required void Function(String finalText) onFinal,
  }) async {
    final ok = await _ensureInit();
    if (!ok) {
      state = VoiceState.error;
      errorMessage = 'Speech recognition unavailable';
      notifyListeners();
      return;
    }

    transcript = '';
    errorMessage = null;
    state = VoiceState.listening;
    notifyListeners();

    await _speech.listen(
      onResult: (SpeechRecognitionResult r) {
        transcript = r.recognizedWords;
        notifyListeners();
        if (r.finalResult && transcript.isNotEmpty) {
          onFinal(transcript);
        }
      },
      onSoundLevelChange: (l) {
        level = l;
        notifyListeners();
      },
      listenOptions: SpeechListenOptions(
        partialResults: true,
        cancelOnError: true,
      ),
    );
  }

  Future<void> stop() async {
    if (state != VoiceState.listening) return;
    await _speech.stop();
    state = VoiceState.idle;
    notifyListeners();
  }

  Future<void> cancel() async {
    await _speech.cancel();
    state = VoiceState.idle;
    transcript = '';
    notifyListeners();
  }

  @override
  void dispose() {
    _speech.cancel();
    super.dispose();
  }
}
