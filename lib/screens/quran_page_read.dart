import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:learn_quran_read_sqllite/services/database_helper.dart';
import 'package:provider/provider.dart';

import '../models/ayah.dart';
import '../providers/quran_provider.dart';

class QuranPageRead extends StatelessWidget {
  const QuranPageRead({super.key});

  @override
  Widget build(BuildContext context) {
    QuranProvider quranProvider = Provider.of<QuranProvider>(context);
    return DefaultTabController(
      length: context.watch<QuranProvider>().surahInfo.length,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
              'Al-Quran - Halaman ${context.watch<QuranProvider>().currentPageIndex + 1}'),
          actions: [
            IconButton(
              onPressed: () async {
                await bottomSheetSearch(context: context);
              },
              icon: const Icon(Icons.search),
            )
          ],
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(48.0),
            child: Directionality(
              textDirection: TextDirection.rtl,
              child: TabBar(
                controller: quranProvider.tabQuranController,
                onTap: (index) async {
                  quranProvider.setTabPageSelectedTab(
                    index: index,
                    pageIndex:
                        await quranProvider.getFirstPageSurah(index: index + 1),
                  );
                },
                tabAlignment: TabAlignment.start,
                isScrollable: true,
                tabs: quranProvider.surahInfo
                    .map(
                      (e) => Directionality(
                        textDirection: TextDirection.ltr,
                        child: Tab(
                          text: ' ${e.index}. ${e.tname}  ',
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
          ),
        ),
        body: Directionality(
          textDirection: TextDirection.rtl,
          child: PageView.builder(
            controller:
                context.watch<QuranProvider>().pageQuranByPageController,
            physics: const AlwaysScrollableScrollPhysics(),
            allowImplicitScrolling: true,
            itemCount: 604,
            itemBuilder: (context, index) {
              return Consumer<QuranProvider>(
                builder: (context, quranProvider, child) {
                  var ayahs = quranProvider.ayahs;
                  Set<int> displayedSurahs = {};
                  return Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.pink, width: 2),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          for (int i = 1; i <= 15; i++) ...[
                            if (ayahs.any((a) => a.lineNumber == i)) ...[
                              Builder(builder: (context) {
                                var lineAyahs = ayahs
                                    .where((a) => a.lineNumber == i)
                                    .toList();
                                var firstAyahInLine = lineAyahs.first;

                                List<Widget> lineWidgets = [];

                                // Check if this is the start of a new surah and hasn't been displayed yet
                                if (firstAyahInLine.ayaNumber == 1 &&
                                    !displayedSurahs
                                        .contains(firstAyahInLine.sura) &&
                                    index > 0) {
                                  displayedSurahs.add(firstAyahInLine.sura);
                                  lineWidgets.add(Image.asset(
                                    'assets/bismillah.png',
                                    height: 50,
                                  ));
                                }

                                lineWidgets
                                    .add(_buildLine(lineAyahs, i, index));

                                return Column(children: lineWidgets);
                              }),
                            ]
                          ]
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildLine(List<Ayah> lineAyahs, int lineNumber, int pageNumber) {
    // log(lineAyahs[lineNumber].lineNumber.toString());

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        textDirection: TextDirection.rtl,
        mainAxisAlignment: pageNumber < 2
            ? MainAxisAlignment.center
            : pageNumber > 599
                ? MainAxisAlignment.center
                : MainAxisAlignment.spaceBetween,
        children: [
          ...lineAyahs.map((ayah) {
            return _buildAyahText(ayah, pageNumber);
          }),
        ],
      ),
    );
  }

  Widget _buildAyahText(Ayah ayah, int pageNumber) {
    return Text(
      ayah.text,
      style: TextStyle(
        fontFamily: ayah.charType == "end" ? 'LPMQ' : 'indopak',
        // fontFamily: "indopak",
        fontSize: pageNumber > 598 ? 25 : 20,
        letterSpacing: 0,
        height: 1.2,
      ),
    );
  }
}

class QuranReadByPageScreenSync implements TickerProvider {
  const QuranReadByPageScreenSync();
  @override
  Ticker createTicker(TickerCallback onTick) => Ticker(onTick);
}

Future<void> bottomSheetSearch({required BuildContext context}) {
  return showModalBottomSheet(
    context: context,
    builder: (context) {
      return Container(
        height: MediaQuery.of(context).size.height / 2,
        margin: const EdgeInsets.symmetric(
          vertical: 40,
          horizontal: 16,
        ),
        child: TextField(
          textInputAction: TextInputAction.done,
          keyboardType: TextInputType.number,
          inputFormatters: [
            RangeInputFormatter(
              min: 1,
              max: 604,
            )
          ],
          onSubmitted: (value) async {
            Provider.of<QuranProvider>(context, listen: false)
                .setTabPageSelectedTab(
              index: await DatabaseHelper()
                  .getNumberSurahFromPage(int.parse(value)),
              pageIndex: int.parse(value),
            );

            // ignore: use_build_context_synchronously
            Navigator.of(context).pop();
          },
        ),
      );
    },
  );
}

class RangeInputFormatter extends TextInputFormatter {
  final int min;
  final int max;

  RangeInputFormatter({required this.min, required this.max});

  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.text.isEmpty) {
      return newValue;
    }

    final int? value = int.tryParse(newValue.text);
    if (value == null || value < min || value > max) {
      return oldValue;
    }
    return newValue;
  }
}
