// import 'dart:io';
// import 'package:flutter/foundation.dart';
// import 'package:another_audio_recorder/another_audio_recorder.dart';
// import 'package:path_provider/path_provider.dart';

// class VoiceRecordProvider extends ChangeNotifier {
//   bool isRecording = false;
//   String? recordedFilePath;
//   Duration currentDuration = Duration.zero;
//   AnotherAudioRecorder? _recorder;

//   Future<void> startRecording() async {
//     try {
      
//       if (!await AnotherAudioRecorder.hasPermissions) return;

//       final dir = await getApplicationDocumentsDirectory();
//       final path =
//           '${dir.path}/voice_${DateTime.now().millisecondsSinceEpoch}.aac';

      
//       _recorder = AnotherAudioRecorder(path, audioFormat: AudioFormat.AAC);

      
//       await _recorder!.start();

//       recordedFilePath = path;
//       isRecording = true;
//       currentDuration = Duration.zero;

//       _updateDuration();

//       notifyListeners();
//     } catch (e) {
//       debugPrint("Error starting recording: $e");
//     }
//   }

//   Future<void> _updateDuration() async {
//     while (isRecording) {
//       await Future.delayed(const Duration(seconds: 1));
//       currentDuration += const Duration(seconds: 1);
//       notifyListeners();
//     }
//   }

//   Future<void> stopRecording() async {
//     try {
//       if (!isRecording) return;

//       await _recorder!.stop();
//       isRecording = false;
//       notifyListeners();
//     } catch (e) {
//       debugPrint("Error stopping recording: $e");
//     }
//   }
// }
