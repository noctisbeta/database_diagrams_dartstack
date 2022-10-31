// import 'package:dartz/dartz.dart';

// /// Delta time manager.
// class DeltaTimeManager {
//   /// Target fps.
//   static const targetFps = 60;

//   /// Target frametime.
//   static const targetFrameTime = 1 / targetFps;

//   final Stopwatch _stopwatch = Stopwatch();

//   Future<void> runWithDeltaTime<T>(void Function() callback, T accumulator) async {
//     if(_stopwatch.)
  
//     _stopwatch.start();
// // 
//     callback();

//     final double frameTime = _stopwatch.elapsedMilliseconds / 1000;
//     final double delta = frameTime / targetFrameTime;

//     _stopwatch.reset();

//     await Future<void>.delayed(Duration(milliseconds: (targetFrameTime - frameTime).round()));

//     runWithDeltaTime(callback, accumulator);
//   }
// }
