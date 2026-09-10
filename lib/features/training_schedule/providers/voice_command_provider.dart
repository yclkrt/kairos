import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:sporlab/core/services/voice_command_service.dart';

final voiceCommandServiceProvider = Provider<VoiceCommandService>((ref) {
  return VoiceCommandService();
});

final voiceCommandStateProvider =
    StateNotifierProvider<VoiceCommandNotifier, VoiceCommandState>((ref) {
      final service = ref.watch(voiceCommandServiceProvider);
      return VoiceCommandNotifier(service);
    });

class VoiceCommandState {
  final bool isListening;
  final bool isAvailable;
  final String recognizedText;
  final String? errorMessage;

  const VoiceCommandState({
    this.isListening = false,
    this.isAvailable = false,
    this.recognizedText = '',
    this.errorMessage,
  });

  VoiceCommandState copyWith({
    bool? isListening,
    bool? isAvailable,
    String? recognizedText,
    String? errorMessage,
  }) {
    return VoiceCommandState(
      isListening: isListening ?? this.isListening,
      isAvailable: isAvailable ?? this.isAvailable,
      recognizedText: recognizedText ?? this.recognizedText,
      errorMessage: errorMessage,
    );
  }
}

class VoiceCommandNotifier extends StateNotifier<VoiceCommandState> {
  final VoiceCommandService _service;

  VoiceCommandNotifier(this._service) : super(const VoiceCommandState()) {
    _initialize();
  }

  Future<void> _initialize() async {
    final isAvailable = await _service.initialize();
    state = state.copyWith(isAvailable: isAvailable);
  }

  Future<void> startListening() async {
    if (!state.isAvailable) {
      final isAvailable = await _service.initialize();
      state = state.copyWith(isAvailable: isAvailable);
      if (!isAvailable) {
        state = state.copyWith(
          errorMessage: 'Mikrofon izni gerekli. Lütfen izin verin.',
        );
        return;
      }
    }

    state = state.copyWith(
      isListening: true,
      recognizedText: '',
      errorMessage: null,
    );

    await _service.startListening(
      onResult: (result) {
        if (result.finalResult) {
          state = state.copyWith(recognizedText: result.recognizedWords);
        }
      },
      onDone: () {
        state = state.copyWith(isListening: false);
      },
    );
  }

  Future<void> stopListening() async {
    await _service.stopListening();
    state = state.copyWith(isListening: false);
  }

  void clearError() {
    state = state.copyWith(errorMessage: null);
  }

  void clearRecognizedText() {
    state = state.copyWith(recognizedText: '');
  }
}
