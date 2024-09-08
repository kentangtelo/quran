import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:learn_quran_read_sqllite/providers/quran_provider.dart';
import 'package:learn_quran_read_sqllite/screens/halaman_utama.dart';
import 'package:path/path.dart';
import 'package:provider/provider.dart';
import 'package:sqflite/sqflite.dart';

void main() async {
  // sqfliteFfiInit();
  // databaseFactory = databaseFactoryFfi;
  WidgetsFlutterBinding.ensureInitialized();

  var databasesPath = await getDatabasesPath();
  var path = join(databasesPath, "qurannew.db");

  var exists = await databaseExists(path);

  if (!exists) {
    try {
      await Directory(dirname(path)).create(recursive: true);
    } catch (_) {}

    ByteData data = await rootBundle.load(join("assets", "qurannew.db"));
    List<int> bytes =
        data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);

    await File(path).writeAsBytes(bytes, flush: true);
  }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => QuranProvider()),
      ],
      child: MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        home: const HalamanUtama(),
      ),
    );
  }
}
