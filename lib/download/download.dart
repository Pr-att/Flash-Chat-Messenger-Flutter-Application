import 'dart:developer';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:dio/dio.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:path_provider/path_provider.dart';

class Download {
  static Future<void> saveVideo(String url) async {
    final Dio dio = Dio();
    final Directory appDocDir = await getApplicationDocumentsDirectory();
    final String appDocPath = appDocDir.path;

    try {
      final Response response = await dio.get(url,
          options: Options(responseType: ResponseType.bytes));
      final String fileName =
          '${DateTime.now().microsecondsSinceEpoch.toString()}.mp4';
      final File videoFile = File('$appDocPath/$fileName');
      await videoFile.writeAsBytes(response.data);

      // Save video to gallery
      final result = await ImageGallerySaver.saveFile(videoFile.path);
      if (result['isSuccess']) {
        log('Video saved to gallery: ${result['filePath']}');
      } else {
        log('Failed to save video to gallery: ${result['errorMessage']}');
      }
    } catch (e) {
      log('Error saving video: $e');
    }
  }

  static Future<void> saveImage(String url) async {
    final Dio dio = Dio();
    final Directory appDocDir = await getApplicationDocumentsDirectory();
    final String appDocPath = appDocDir.path;

    try {
      final Response response = await dio.get(url,
          options: Options(responseType: ResponseType.bytes));
      final String fileName =
          '${DateTime.now().microsecondsSinceEpoch.toString()}.png';
      final File imageFile = File('$appDocPath/$fileName');
      await imageFile.writeAsBytes(response.data);

      // Save image to gallery
      final result = await ImageGallerySaver.saveFile(imageFile.path);
      if (result['isSuccess']) {
        log('Image saved to gallery: ${result['filePath']}');
      } else {
        log('Failed to save image to gallery: ${result['errorMessage']}');
      }
    } catch (e) {
      log('Error saving image: $e');
    }
  }

  static Future<void> saveCameraImage(XFile file) async {
    final Directory appDocDir = await getApplicationDocumentsDirectory();
    final String appDocPath = appDocDir.path;
    final String fileName =
        '${DateTime.now().microsecondsSinceEpoch.toString()}.png';
    final File imageFile = File('$appDocPath/$fileName');
    await imageFile.writeAsBytes(await file.readAsBytes());

    // Save image to gallery
    final result = await ImageGallerySaver.saveFile(imageFile.path);
    if (result['isSuccess']) {
      log('Image saved to gallery: ${result['filePath']}');
    } else {
      log('Failed to save image to gallery: ${result['errorMessage']}');
    }
  }
}
