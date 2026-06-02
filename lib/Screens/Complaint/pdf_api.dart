// import 'dart:io';
//
// import 'package:open_file/open_file.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:pdf/widgets.dart';
// import 'package:pdf/pdf.dart';
//
// import '../../Resources/colors.dart';
//
// class PdfApi {
//   static Future<File> generateCenteredText(String text) async {
//     final pdf = Document();
//
//     pdf.addPage(Page(
//       build: (context) => Center(
//         child: Column(
//           children: [
//             Row(
//               children: [
//                 Text(
//                   "Type : ",
//                   style: TextStyle(
//                     fontSize: 15,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//                 Flexible(
//                   child: Text(
//                     "Murder",
//                     style: TextStyle(
//                       fontSize: 15,
//                       // fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//             Row(
//               children: [
//                 Text(
//                   "Description : ",
//                   style: TextStyle(
//                     fontSize: 15,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//                 Flexible(
//                   child: Text(
//                     "Murder is the unlawful killing of another human without justification or valid excuse, especially the unlawful killing of another human with malice aforethought. This state of mind may, depending upon the jurisdiction, distinguish murder from other forms of unlawful homicide, such as manslaughter.",
//                     style: TextStyle(
//                       fontSize: 15,
//                       // fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//             Row(
//               children: [
//                 Text(
//                   "Location : ",
//                   style: TextStyle(
//                     fontSize: 15,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//                 Flexible(
//                   child: Text(
//                     "7.1525,80.0688",
//                     style: TextStyle(
//                       fontSize: 15,
//                       // fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     ));
//
//     return saveDocument(name: 'my_example.pdf', pdf: pdf);
//   }
//
//   static Future<File> saveDocument({
//     required String name,
//     required Document pdf,
//   }) async {
//     final bytes = await pdf.save();
//
//     final dir = await getApplicationDocumentsDirectory();
//     final file = File('${dir.path}/$name');
//
//     await file.writeAsBytes(bytes);
//
//     return file;
//   }
//
//   static Future openFile(File file) async {
//     final url = file.path;
//
//     await OpenFile.open(url);
//   }
// }

import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/services.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart';

import '../../Resources/colors.dart';

// class User {
//   final String name;
//   final int age;
//
//   const User({required this.name, required this.age});
// }

class PdfApi {
  // static Future<File> generateTable(image1) async {
  //   final pdf = Document();
  //
  // //  final headers = ['Name', 'Age'];
  //
  //   // final users = [
  //   //   User(name: 'James', age: 19),
  //   //   User(name: 'Sarah', age: 21),
  //   //   User(name: 'Emma', age: 28),
  //   // ];
  // //  final data = users.map((user) => [user.name, user.age]).toList();
  //
  //   // pdf.addPage(Page(
  //   //   build: (context) => Table.fromTextArray(
  //   //     headers: headers,
  //   //    // data: data,
  //   //   ),
  //   // ));
  //
  //   return saveDocument(name: 'my_example.pdf', pdf: pdf);
  // }

  static Future<File> generateImage(
      address,
      CID,
      City,
      date,
      description,
      district,
      email,
      latitude,
      longitude,
      mobile,
      NIC,
      name,
      poliveNote,
      status,
      type) async {
    final pdf = Document();

    final imageLogo =
        (await rootBundle.load('assets/images/logo.png')).buffer.asUint8List();

    final fontLight =
        Font.ttf(await rootBundle.load('fonts/Poppins-Light.ttf'));
    final fontBold = Font.ttf(await rootBundle.load('fonts/Poppins-Bold.ttf'));

    pdf.addPage(Page(
            pageFormat: PdfPageFormat.a4,
            build: (Context context) {
              return Container(
                width: 210 * PdfPageFormat.mm,
                height: 297 * PdfPageFormat.mm,
                // color: PdfColors.blueAccent100,
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Center(
                        child: Image(
                          MemoryImage(imageLogo),
                          width: 80,
                        ),
                      ),
                      SizedBox(height: 15),
                      Container(
                        child: Center(
                          child: Text(
                            'Online Complaint Summary Report',
                            style: TextStyle(
                              font: fontBold,
                              color: pdfSecondary,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      Container(
                        child: Text(
                          DateFormat('yyyy-MM-dd HH:mm:ss')
                              .format(DateTime.now()),
                          style: TextStyle(
                            fontSize: 15,
                            // fontWeight: FontWeight.bold,
                            color: pdfSecondary,
                            font: fontLight,
                          ),
                        ),

                        //"${DateTime.now()}")
                      ),
                      divider(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            //  color:PdfColors.red,
                            width: 210 * PdfPageFormat.mm / 3,
                            //flex: 2,
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      "CID : ",
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                        color: PdfColors.black,
                                        font: fontBold,
                                      ),
                                    ),
                                    Flexible(
                                      child: Text(
                                        CID.toString(),
                                        style: TextStyle(
                                          fontSize: 15,
                                          // fontWeight: FontWeight.bold,
                                          color: PdfColors.black,
                                          font: fontLight,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    Text(
                                      "District : ",
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                        color: PdfColors.black,
                                        font: fontBold,
                                      ),
                                    ),
                                    Flexible(
                                      child: Text(
                                        district,
                                        style: TextStyle(
                                          fontSize: 15,
                                          // fontWeight: FontWeight.bold,
                                          color: PdfColors.black,
                                          font: fontLight,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    Text(
                                      "City : ",
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                        color: PdfColors.black,
                                        font: fontBold,
                                      ),
                                    ),
                                    Flexible(
                                      child: Text(
                                        City,
                                        style: TextStyle(
                                          fontSize: 15,
                                          // fontWeight: FontWeight.bold,
                                          color: PdfColors.black,
                                          font: fontLight,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          Container(
                            // color:PdfColors.red,
                            width: 210 * PdfPageFormat.mm / 3,
                            // flex: 1,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      "Date : ",
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                        color: PdfColors.black,
                                        font: fontBold,
                                      ),
                                    ),
                                    Flexible(
                                      child: Text(
                                        DateFormat('yyyy-MM-dd').format(
                                            DateTime.parse(
                                                "2022-07-02 06:15:15")),
                                        style: TextStyle(
                                          fontSize: 15,
                                          // fontWeight: FontWeight.bold,
                                          color: PdfColors.black,
                                          font: fontLight,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    Text(
                                      "Time : ",
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                        color: PdfColors.black,
                                        font: fontBold,
                                      ),
                                    ),
                                    Flexible(
                                      child: Text(
                                        DateFormat('hh:mm a').format(
                                            DateTime.parse(
                                                "2022-07-02 18:15:15")),
                                        style: TextStyle(
                                          fontSize: 15,
                                          // fontWeight: FontWeight.bold,
                                          color: PdfColors.black,
                                          font: fontLight,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    Text(
                                      "Status : ",
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                        color: PdfColors.black,
                                        font: fontBold,
                                      ),
                                    ),
                                    Flexible(
                                      child: Text(
                                        status,
                                        style: TextStyle(
                                          fontSize: 15,
                                          // fontWeight: FontWeight.bold,
                                          color: PdfColors.black,
                                          font: fontLight,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 20),
                      Container(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Details of the Complainant',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: PdfColors.black,
                            font: fontBold,
                          ),
                        ),
                      ),
                      SizedBox(height: 8),
                      Column(children: [
                        Row(
                          children: [
                            Text(
                              "Name : ",
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: PdfColors.black,
                                font: fontBold,
                              ),
                            ),
                            Flexible(
                              child: Text(
                                name,
                                style: TextStyle(
                                  fontSize: 15,
                                  // fontWeight: FontWeight.bold,
                                  color: PdfColors.black,
                                  font: fontLight,
                                ),
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Text(
                              "NIC No : ",
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: PdfColors.black,
                                font: fontBold,
                              ),
                            ),
                            Flexible(
                              child: Text(
                                NIC,
                                style: TextStyle(
                                  fontSize: 15,
                                  // fontWeight: FontWeight.bold,
                                  color: PdfColors.black,
                                  font: fontLight,
                                ),
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Text(
                              "Email Address : ",
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: PdfColors.black,
                                font: fontBold,
                              ),
                            ),
                            Flexible(
                              child: Text(
                                email,
                                style: TextStyle(
                                  fontSize: 15,
                                  // fontWeight: FontWeight.bold,
                                  color: PdfColors.black,
                                  font: fontLight,
                                ),
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Text(
                              "Mobile Number : ",
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: PdfColors.black,
                                font: fontBold,
                              ),
                            ),
                            Flexible(
                              child: Text(
                                mobile,
                                style: TextStyle(
                                  fontSize: 15,
                                  // fontWeight: FontWeight.bold,
                                  color: PdfColors.black,
                                  font: fontLight,
                                ),
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Text(
                              "Address : ",
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: PdfColors.black,
                                font: fontBold,
                              ),
                            ),
                            Flexible(
                              child: Text(
                                address,
                                style: TextStyle(
                                  fontSize: 15,
                                  // fontWeight: FontWeight.bold,
                                  color: PdfColors.black,
                                  font: fontLight,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ]),
                      SizedBox(height: 20),
                      Container(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Details of the Complaint',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: PdfColors.black,
                            font: fontBold,
                          ),
                        ),
                      ),
                      SizedBox(height: 8),
                      Column(
                        children: [
                          Row(
                            children: [
                              Text(
                                "Type : ",
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: PdfColors.black,
                                  font: fontBold,
                                ),
                              ),
                              Flexible(
                                child: Text(
                                  type,
                                  style: TextStyle(
                                    fontSize: 15,
                                    // fontWeight: FontWeight.bold,
                                    color: PdfColors.black,
                                    font: fontLight,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              Text(
                                "Description : ",
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: PdfColors.black,
                                  font: fontBold,
                                ),
                              ),
                              Flexible(
                                child: Text(
                                  description,
                                  style: TextStyle(
                                    fontSize: 15,
                                    // fontWeight: FontWeight.bold,
                                    color: PdfColors.black,
                                    font: fontLight,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              Text(
                                "Location : ",
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: PdfColors.black,
                                  font: fontBold,
                                ),
                              ),
                              Flexible(
                                child: Text(
                                  "$latitude , $longitude",
                                  style: TextStyle(
                                    fontSize: 15,
                                    // fontWeight: FontWeight.bold,
                                    color: PdfColors.black,
                                    font: fontLight,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      SizedBox(height: 20),
                      Container(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Comments of the Police',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: PdfColors.black,
                            font: fontBold,
                          ),
                        ),
                      ),
                      SizedBox(height: 8),
                      Flexible(
                        child: Text(
                          poliveNote,
                          style: TextStyle(
                            fontSize: 15,
                            // fontWeight: FontWeight.bold,
                            color: PdfColors.black,
                            font: fontLight,
                          ),
                        ),
                      ),
                    ]),
              );
            })

        // MultiPage(
        //   build: (context) => [
        //     Center(
        //       child: Image(
        //         MemoryImage(imageLogo),
        //         width: 80,
        //       ),
        //     ),
        //     SizedBox(height: 15),
        //     Container(
        //       child: Center(
        //         child: Text(
        //           'Online Complaint Summary Report',
        //           style: TextStyle(
        //             font: fontBold,
        //             color: pdfSecondary,
        //             fontSize: 20,
        //             fontWeight: FontWeight.bold,
        //           ),
        //         ),
        //       ),
        //     ),
        //
        //     buildCustomHeader(),
        //
        //     Column(
        //       children: [
        //         Row(
        //           children: [
        //             Text(
        //               "Name : ",
        //               style: TextStyle(
        //                 fontSize: 15,
        //                 fontWeight: FontWeight.bold,
        //                 color: PdfColors.black,
        //                 font:fontBold ,
        //               ),
        //             ),
        //             Flexible(
        //               child: Text(name,
        //                 style: TextStyle(
        //                   fontSize: 15,
        //                   // fontWeight: FontWeight.bold,
        //                   color: PdfColors.black,
        //                   font:fontLight ,
        //                 ),
        //               ),
        //             ),
        //           ],
        //         ),
        //         Row(
        //           children: [
        //             Text(
        //               "NIC No : ",
        //               style: TextStyle(
        //                 fontSize: 15,
        //                 fontWeight: FontWeight.bold,
        //                 color: PdfColors.black,
        //                 font:fontBold ,
        //               ),
        //             ),
        //             Flexible(
        //               child: Text(
        //                 NIC,
        //                 style: TextStyle(
        //                   fontSize: 15,
        //                   // fontWeight: FontWeight.bold,
        //                   color: PdfColors.black,
        //                   font:fontLight ,
        //                 ),
        //               ),
        //             ),
        //           ],
        //         ),
        //         Row(
        //           children: [
        //             Text(
        //               "Email Address : ",
        //               style: TextStyle(
        //                 fontSize: 15,
        //                 fontWeight: FontWeight.bold,
        //                 color: PdfColors.black,
        //                 font:fontBold ,
        //               ),
        //             ),
        //             Flexible(
        //               child: Text(
        //                 email,
        //                 style: TextStyle(
        //                   fontSize: 15,
        //                   // fontWeight: FontWeight.bold,
        //                   color: PdfColors.black,
        //                   font:fontLight ,
        //                 ),
        //               ),
        //             ),
        //           ],
        //         ),
        //         Row(
        //           children: [
        //             Text(
        //               "Mobile Number : ",
        //               style: TextStyle(
        //                 fontSize: 15,
        //                 fontWeight: FontWeight.bold,
        //                 color: PdfColors.black,
        //                 font:fontBold ,
        //               ),
        //             ),
        //             Flexible(
        //               child: Text(
        //                 mobile,
        //                 style: TextStyle(
        //                   fontSize: 15,
        //                   // fontWeight: FontWeight.bold,
        //                   color: PdfColors.black,
        //                   font:fontLight ,
        //                 ),
        //               ),
        //             ),
        //           ],
        //         ),
        //         Row(
        //           children: [
        //             Text(
        //               "Address : ",
        //               style: TextStyle(
        //                 fontSize: 15,
        //                 fontWeight: FontWeight.bold,
        //                 color: PdfColors.black,
        //                 font:fontBold ,
        //               ),
        //             ),
        //             Flexible(
        //               child: Text(
        //                 address,
        //                 style: TextStyle(
        //                   fontSize: 15,
        //                   // fontWeight: FontWeight.bold,
        //                   color: PdfColors.black,
        //                   font:fontLight ,
        //                 ),
        //               ),
        //             ),
        //           ],
        //         ),
        //       ],
        //     ),
        //   ],
        // ),
        );

    return saveDocument(name: 'SafeMe_CID-$CID.pdf', pdf: pdf);
  }

  static Future<File> saveDocument({
    required String name,
    required Document pdf,
  }) async {
    final bytes = await pdf.save();

    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/$name');

    await file.writeAsBytes(bytes);

    return file;
  }

  static Future openFile(File file) async {
    final url = file.path;

    await OpenFile.open(url);
  }

  static Widget divider() => Padding(
        padding: EdgeInsets.only(left: 8.0, right: 8, bottom: 8),
        child: Divider(),
      );
}
