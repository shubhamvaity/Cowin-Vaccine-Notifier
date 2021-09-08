// import "package:flutter/material.dart";

// class NotifyFormChange extends StatefulWidget {
//   NotifyFormChange();
//   @override
//   _NotifyFormChangeState createState() => _NotifyFormChangeState();
// }

// class _NotifyFormChangeState extends State<NotifyFormChange> {
//   @override
//   Widget build(BuildContext context) {
//     final _n1 = FocusNode();
//     final _n2 = FocusNode();
//     return Column(
//       children: [
//         Padding(
//           padding: const EdgeInsets.only(top: 20, left: 10, right: 10),
//           child: TextFormField(
//             autofocus: false,
//             textInputAction: TextInputAction.next,
//             enableInteractiveSelection: false,
//             onFieldSubmitted: (_) {
//               FocusScope.of(context).requestFocus(new FocusNode());
//             },
//             decoration: InputDecoration(
//                 labelText: 'PIN Code',
//                 labelStyle: null,
//                 // suffixText: "suffixText" ?? '',
//                 border: OutlineInputBorder(
//                   borderSide: BorderSide(color: Colors.black, width: 2),
//                 ),
//                 hintText: '',
//                 floatingLabelBehavior: FloatingLabelBehavior.always),
//             maxLength: 6,
//             keyboardType: TextInputType.number,
//             style: TextStyle(fontSize: 20),
//             controller: myController1,
//             inputFormatters: [FilteringTextInputFormatter.digitsOnly],
//           ),
//         ),
//         Padding(
//           padding: const EdgeInsets.all(8.0),
//           child: DropdownButtonFormField(
//             focusNode: _n1,
//             decoration: InputDecoration(
//                 labelText: 'Vaccine Type',
//                 labelStyle: null,
//                 // suffixText: "suffixText" ?? '',
//                 border: OutlineInputBorder(
//                   borderSide: BorderSide(color: Colors.black, width: 2),
//                 ),
//                 hintText: '',
//                 floatingLabelBehavior: FloatingLabelBehavior.always),
//             items: ["COVISHIELD", "COVAXIN", "SPUTNIK V"]
//                 .map((label) => DropdownMenuItem(
//                       child: Text(label.toString()),
//                       value: label,
//                     ))
//                 .toList(),
//             onChanged: (value) {
//               vaccineIp = value;
//               FocusScope.of(context).requestFocus(new FocusNode());
//               print(vaccineIp);
//             },
//           ),
//         ),
//         Padding(
//           padding: const EdgeInsets.all(8.0),
//           child: DropdownButtonFormField(
//             focusNode: _n2,
//             decoration: InputDecoration(
//                 labelText: 'Dose No.',
//                 labelStyle: null,
//                 // suffixText: "suffixText" ?? '',
//                 border: OutlineInputBorder(
//                   borderSide: BorderSide(color: Colors.black, width: 2),
//                 ),
//                 hintText: '',
//                 floatingLabelBehavior: FloatingLabelBehavior.always),
//             items: ["1", "2"]
//                 .map((label) => DropdownMenuItem(
//                       child: Text(label.toString()),
//                       value: label,
//                     ))
//                 .toList(),
//             onChanged: (value) {
//               FocusScope.of(context).requestFocus(new FocusNode());
//               doseIp = value;

//               print(doseIp.toString());
//             },
//           ),
//         ),
//         Padding(
//           padding: const EdgeInsets.all(8.0),
//           child: SwitchListTile(
//             // activeTrackColor: Colors.blueAccent,
//             tileColor: Colors.amberAccent,
//             title: const Text(
//               'Create Alert',
//               style: TextStyle(
//                   fontSize: 20,
//                   color: Colors.black,
//                   fontWeight: FontWeight.bold),
//             ),
//             value: _enabled,
//             onChanged: (value) {
//               if (myController1.text != null &&
//                   vaccineIp != null &&
//                   doseIp != null) {
//                 alert[0] = myController1.text;
//                 alert[1] = vaccineIp;
//                 alert[2] = doseIp;
//               }
//               onClickEnable();
//             },
//             secondary: const Icon(Icons.assignment_turned_in_outlined),
//           ),
//         )
//       ],
//     );
//   }
// }
