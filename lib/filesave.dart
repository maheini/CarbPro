import 'package:flutter/material.dart';
import 'databasecommunicator.dart';


// class FileSaver extends StatefulWidget {
//   FileSaver({Key? key}) : super(key: key);
//
//   final DatabaseCommunicator db = DatabaseCommunicator();
//
//   @override
//   _FileSaverState createState() => _FileSaverState();
// }
// class _FileSaverState extends State<FileSaver> {
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Test'),
//       ),
//       body: Center(
//         child: Column(
//           children: [
//             ElevatedButton(
//                 onPressed: () => widget.db.addItem('Itemname'),
//                 child: const Text('Eintrag erstellen'),
//             ),
//             ElevatedButton(
//               onPressed: () => widget.db.getItems().then((List<Map>  result) => print(result)),
//               child: const Text('Eintrag abrufen'),
//             ),
//           ],
//         )
//       ),
//     );
//   }
// }
