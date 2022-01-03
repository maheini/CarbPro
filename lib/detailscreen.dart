import 'package:flutter/material.dart';
import 'dart:io';
import 'package:permission_handler/permission_handler.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:camera/camera.dart';

class DetailScreen extends StatefulWidget {

  @override
  _DetailScreenState createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  Widget _createImage(int index) {
    return Container(
      padding: EdgeInsets.all(10),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Text('Hallo'),
          Container(
            decoration: BoxDecoration(border: Border.all()),
            child: Center(
              child: Text('hi $_ItemCount'),
            ),
          )
        ],
      ),
    );
  }

  int _ItemCount = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Details'), centerTitle: true,),
      floatingActionButton: FloatingActionButton(onPressed: () {setState(() {_ItemCount++;});}, child: Icon(Icons.add_a_photo),),
      body: GridView.count(
          crossAxisCount: 2,
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          children: List<Widget>.generate(_ItemCount, (index) {
            return _createImage(index);
          })
      ),
    );
  }

  void _AddPicture() async {
    if (Platform.isAndroid) {
      if (await _GetPermssion(Permission.camera)) {

      }
      else {
        showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text('Fehler'),
                content: Text('Die Berechtigung für die Kamera fehlt'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context, 'ok'),
                    child: Text('OK'),
                  ),
                ],
              );
            }
        );
      }
    }
    else {
      print('Plattform wird nicht unterstützt....');
    }
  }

  Future<bool> _GetPermssion(Permission permission) async{
    PermissionStatus status = await permission.status;
    if(status.isGranted){
      return true;
    }
    else if (await permission.request().isGranted){
      return true;
    }
    return false;
  }
}