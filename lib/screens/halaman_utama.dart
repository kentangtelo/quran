import 'package:flutter/material.dart';
import 'package:learn_quran_read_sqllite/providers/quran_provider.dart';
import 'package:learn_quran_read_sqllite/screens/quran_page_read.dart';
import 'package:learn_quran_read_sqllite/screens/quran_row_read.dart';
import 'package:provider/provider.dart';

class HalamanUtama extends StatelessWidget {
  const HalamanUtama({super.key});

  @override
  Widget build(BuildContext context) {
    QuranProvider quranProvider = Provider.of<QuranProvider>(context);
    return Scaffold(
      body: SizedBox(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                quranProvider.initTabController(
                  const QuranReadByPageScreenSync(),
                  0,
                  0,
                );
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const QuranPageRead(),
                  ),
                );
              },
              child: const Text('baca halaman'),
            ),
            ElevatedButton(
              onPressed: () {
                quranProvider.initTabRowController(
                  const QuranReadByPageScreenSync(),
                  0,
                );

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const QuranRowRead(),
                  ),
                );
              },
              child: const Text('baca baris'),
            ),
            ElevatedButton(
              onPressed: () {},
              child: const Text('bacaan terakhir'),
            ),
          ],
        ),
      ),
    );
  }
}
