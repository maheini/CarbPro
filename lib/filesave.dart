import 'dart:io';
import 'package:flutter/material.dart';

import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:permission_handler/permission_handler.dart';


//comment

//Comment2

class FileSaver extends StatefulWidget {
  const FileSaver({Key? key}) : super(key: key);

  @override
  _FileSaverState createState() => _FileSaverState();
}

class _FileSaverState extends State<FileSaver> {

  bool loading = false;

  Future<bool> SaveFile(String url, String FileName) async{
    try{
      if(Platform.isAndroid){
        print('Android');
        if(await RequestPermission(Permission.storage)){
          print('Speicher ok');
          Directory? dir = await getExternalStorageDirectory();
          print(dir?.path);
        }



        if (await RequestPermission(Permission.camera)){
          print('Kamera ok');
        }
        else {
          print('Keine Berechtigung...');
        }
      }
      else{

      }
    }
    catch(e) {

    }

    return false;
  }

  Future<bool> RequestPermission(Permission permission) async{
    if(await permission.isGranted) {
      return true;
    }
    else{
      PermissionStatus result = await permission.request();
      if(result.isGranted) {
        return true;
      }
      else {
        return false;
      }
    }
  }

  DownloadFile() async{
    setState(() {
      loading = true;
    });


    bool downloaded = await SaveFile('https://www.youtube.com/watch?v=3gNd1Ma-gss', 'video.mp4');

    setState(() {
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Test'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () => SaveFile('url', 'path'),
          child: Text('Berechtigung erfragen'),
        ),
      ),
    );
    SaveFile('url', 'FileName');
    return Container();
  }
}
