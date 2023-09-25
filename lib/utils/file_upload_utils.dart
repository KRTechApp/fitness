import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:crossfit_gym_trainer/utils/static_data.dart';
import 'package:path/path.dart' as path_lib;
import 'package:video_compress/video_compress.dart' as compress;

class FileUploadUtils {
  Future<String> uploadImage({required String folderName, required File fileImage}) async {
    final extension = path_lib.extension(fileImage.path);
    String fileName = "${StaticData.fileName}_${DateTime.now().microsecondsSinceEpoch}$extension";
    Reference reference = FirebaseStorage.instance.ref(folderName).child(fileName);

    File? compressedImage;

    if (extension != ".png") {
      final targetPath =
          "${fileImage.absolute.path.replaceAll(path_lib.basename(fileImage.absolute.path), "")}temp.jpg";
      debugPrint(targetPath);
      compressedImage = (await FlutterImageCompress.compressAndGetFile(
        fileImage.absolute.path,
        targetPath,
        quality: 34,
        rotate: 0,
      ));
    }

    TaskSnapshot uploading = await reference.putFile(compressedImage ?? fileImage);

    return uploading.ref.getDownloadURL();
  }

  Future<String> uploadAndUpdateImage(
      {required String folderName, required File fileImage, required String oldUrl}) async {
    final extension = path_lib.extension(fileImage.path);
    String fileName = "${StaticData.fileName}_${DateTime.now().microsecondsSinceEpoch}$extension";
    Reference reference = FirebaseStorage.instance.ref(folderName).child(fileName);

    File? compressedImage;

    if (extension != ".png") {
      final targetPath =
          "${fileImage.absolute.path.replaceAll(path_lib.basename(fileImage.absolute.path), "")}temp.jpg";
      debugPrint(targetPath);
      compressedImage = (await FlutterImageCompress.compressAndGetFile(
        fileImage.absolute.path,
        targetPath,
        quality: 34,
        rotate: 0,
      ));
    }
    if (oldUrl.isNotEmpty && !oldUrl.startsWith("assets/default_data/default_image/")) {
      await FirebaseStorage.instance.refFromURL(oldUrl).delete();
    }
    TaskSnapshot uploading = await reference.putFile(compressedImage ?? fileImage);

    return uploading.ref.getDownloadURL();
  }

  Future<String> uploadVideo({required String folderName, required File fileVideo}) async {
    final extension = path_lib.extension(fileVideo.path);
    String fileName = "${StaticData.fileName}_${DateTime.now().microsecondsSinceEpoch}$extension";
    Reference reference = FirebaseStorage.instance.ref(folderName).child(fileName);

    final targetPath =
        "${fileVideo.absolute.path.replaceAll(path_lib.basename(fileVideo.absolute.path), "")}temp$extension";

    final compress.MediaInfo? info = await compress.VideoCompress.compressVideo(
      fileVideo.path,
      quality: compress.VideoQuality.MediumQuality,
      deleteOrigin: false,
      includeAudio: true,
    );

    debugPrint(targetPath);
    if (info != null && info.path != null) {
      fileVideo = File(info.path!);
    }

    TaskSnapshot uploading = await reference.putFile(fileVideo);

    return uploading.ref.getDownloadURL();
  }

  Future<String> uploadAndUpdateVideo(
      {required String folderName, required File fileVideo, required String oldUrl}) async {
    final extension = path_lib.extension(fileVideo.path);
    String fileName = "${StaticData.fileName}_${DateTime.now().microsecondsSinceEpoch}$extension";
    Reference reference = FirebaseStorage.instance.ref(folderName).child(fileName);

    final targetPath =
        "${fileVideo.absolute.path.replaceAll(path_lib.basename(fileVideo.absolute.path), "")}temp$extension";

    final compress.MediaInfo? info = await compress.VideoCompress.compressVideo(
      fileVideo.path,
      quality: compress.VideoQuality.MediumQuality,
      deleteOrigin: false,
      includeAudio: true,
    );

    debugPrint(targetPath);
    if (info != null && info.path != null) {
      fileVideo = File(info.path!);
    }
    if (oldUrl.isNotEmpty) {
      await FirebaseStorage.instance.refFromURL(oldUrl).delete();
    }

    TaskSnapshot uploading = await reference.putFile(fileVideo);

    return uploading.ref.getDownloadURL();
  }

  Future<String> uploadDocument({required String folderName, required File fileDoc}) async {
    final extension = path_lib.extension(fileDoc.path);
    String fileName = "${StaticData.fileName}_${DateTime.now().microsecondsSinceEpoch}$extension";
    Reference reference = FirebaseStorage.instance.ref(folderName).child(fileName);

    TaskSnapshot uploading = await reference.putFile(fileDoc);
    return uploading.ref.getDownloadURL();
  }

  Future<String> uploadAndUpdateDocument(
      {required String folderName, required File fileDoc, required String oldUrl}) async {
    final extension = path_lib.extension(fileDoc.path);
    String fileName = "${StaticData.fileName}_${DateTime.now().microsecondsSinceEpoch}$extension";
    Reference reference = FirebaseStorage.instance.ref(folderName).child(fileName);
    if (oldUrl.isNotEmpty) {
      await FirebaseStorage.instance.refFromURL(oldUrl).delete();
    }

    TaskSnapshot uploading = await reference.putFile(fileDoc);
    return uploading.ref.getDownloadURL();
  }

  Future<void> removeSingleFile({required String? url}) async {
    if (url == null || url.isEmpty || url.startsWith("assets/default_data/default_image/")) {
      return;
    }
    await FirebaseStorage.instance.refFromURL(url).delete();
  }

  Future<void> removeMultipleFile({required List<String?> urlList}) async {
    for (int i = 0; i < urlList.length; i++) {
      if (urlList[i] == null || urlList[i]!.isEmpty) {
        continue;
      }
      await FirebaseStorage.instance.refFromURL(urlList[i]!).delete();
    }
  }
}
