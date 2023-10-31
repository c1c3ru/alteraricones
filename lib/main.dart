import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String appName = 'My App';
  File? customAppIcon;

  @override
  void initState() {
    super.initState();
    loadAppName();
    loadCustomAppIcon();
  }

  void loadAppName() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey('appName')) {
      setState(() {
        appName = prefs.getString('appName')!;
      });
    }
  }

  void loadCustomAppIcon() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey('customAppIconPath')) {
      String imagePath = prefs.getString('customAppIconPath')!;
      setState(() {
        customAppIcon = File(imagePath);
      });
    }
  }

  void pickCustomAppIcon() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      final appDir = await getApplicationDocumentsDirectory();
      final customIconFile = File('${appDir.path}/custom_app_icon.png');

      // Crie um novo File a partir do caminho do XFile
      final newFile = File(pickedFile.path);

      await newFile.copy(customIconFile.path);

      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setString('customAppIconPath', customIconFile.path);

      setState(() {
        customAppIcon = customIconFile;
      });
    }
  }



  void resetCustomAppIcon() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove('customAppIconPath');

    final appDir = await getApplicationDocumentsDirectory();
    final defaultIconPath = 'assets/app_icon.png';
    final defaultIconFile = File('${appDir.path}/default_app_icon.png');

    await defaultIconFile.create();
    final defaultIconData = File(defaultIconPath).readAsBytesSync();
    defaultIconFile.writeAsBytes(defaultIconData);

    setState(() {
      customAppIcon = defaultIconFile;
    });
  }

  void setAppName(String newName) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('appName', newName);
    setState(() {
      appName = newName;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(appName),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            if (customAppIcon != null)
              CircleAvatar(
                backgroundImage: FileImage(customAppIcon!),
                radius: 50,
              ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: pickCustomAppIcon,
              child: Text('Escolher Ícone Personalizado'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: resetCustomAppIcon,
              child: Text('Restaurar Ícone Padrão'),
            ),
            const SizedBox(height: 20),
            TextField(
              decoration: InputDecoration(labelText: 'Nome do Aplicativo'),
              onSubmitted: setAppName,
            ),
          ],
        ),
      ),
    );
  }
}
