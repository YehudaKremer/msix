import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:html' as html;
import 'package:path/path.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PAGE_TITLE',
      home: Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(60),
          child: Row(
            children: [
              Column(
                children: [
                  Container(
                    height: 210,
                    width: 210,
                    child: Image(image: AssetImage('logo.png')),
                  ),
                ],
              ),
              Container(width: 30),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'APP_NAME',
                    style: TextStyle(
                      fontSize: 32,
                      color: Colors.blue,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                  Container(height: 25),
                  Text(
                    'Version APP_VERSION',
                    style: subTitleStyle,
                  ),
                  Container(height: 45),
                  MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: ElevatedButton(
                        style: ButtonStyle(
                            elevation: MaterialStateProperty.all(0)),
                        child: const Padding(
                          padding: EdgeInsets.fromLTRB(40, 6, 40, 6),
                          child: Text(
                            'Install',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                        onPressed: () async {
                          final text = await Dio().get('APP_INSTALLER_LINK');
                          print('text.data: ${text.data}');
                          final bytes = utf8.encode(text.data);
                          final blob = html.Blob([bytes]);
                          final url = html.Url.createObjectUrlFromBlob(blob);
                          final anchor = html.document.createElement('a')
                              as html.AnchorElement
                            ..href = url
                            ..style.display = 'none'
                            ..download = basename('APP_INSTALLER_LINK');
                          html.document.body!.children.add(anchor);
                          anchor.click();

                          html.document.body!.children.remove(anchor);
                          html.Url.revokeObjectUrl(url);
                        }),
                  ),
                  Container(height: 15),
                  GestureDetector(
                      child: MouseRegion(
                        cursor: SystemMouseCursors.click,
                        child: Text(
                          'Troubleshoot installation',
                          style: TextStyle(
                            color: Colors.blue,
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                      ),
                      onTap: () async {
                        await launch(
                            'https://go.microsoft.com/fwlink/?linkid=870616');
                      }),
                  Container(height: 30),
                  Text(
                    'Application Information',
                    style: subTitleStyle,
                  ),
                  Container(height: 25),
                  Row(
                    children: [
                      SizedBox(
                        width: 260,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Version',
                              style: detailStyle,
                            ),
                            Container(height: 25),
                            Text(
                              'Required Operating System',
                              style: detailStyle,
                            ),
                            Container(height: 25),
                            Text(
                              'Architectures',
                              style: detailStyle,
                            ),
                            Container(height: 25),
                            Text(
                              'Publisher',
                              style: detailStyle,
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('APP_VERSION'),
                          Container(height: 25),
                          const Text('REQUIRED_OS_VERSION'),
                          Container(height: 25),
                          const Text('ARCHITECTURE'),
                          Container(height: 25),
                          const Text('PUBLISHER_NAME'),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

var subTitleStyle = const TextStyle(
  fontSize: 18,
  color: Color.fromARGB(255, 77, 77, 77),
  fontWeight: FontWeight.normal,
);

var detailStyle = const TextStyle(
  fontSize: 15,
  color: Color.fromARGB(255, 124, 124, 124),
  fontWeight: FontWeight.bold,
);
