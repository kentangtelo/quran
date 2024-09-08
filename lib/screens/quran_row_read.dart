import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:learn_quran_read_sqllite/providers/quran_provider.dart';
import 'package:learn_quran_read_sqllite/screens/quran_page_read.dart';
import 'package:learn_quran_read_sqllite/services/database_helper.dart';
import 'package:provider/provider.dart';
import 'package:scrollview_observer/scrollview_observer.dart';

class QuranRowRead extends StatelessWidget {
  const QuranRowRead({super.key});

  @override
  Widget build(BuildContext context) {
    QuranProvider quranProvider = Provider.of<QuranProvider>(context);

    return DefaultTabController(
      length: context.watch<QuranProvider>().surahInfo.length,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'Al-Quran - Surat ${context.watch<QuranProvider>().surahInfo[context.watch<QuranProvider>().currentTabRowIndex].tname}',
            style: const TextStyle(
              fontSize: 16,
            ),
          ),
          actions: [
            IconButton(
              onPressed: () async {
                await searchAyatBottomSheet(
                  context: context,
                );
              },
              icon: const Icon(Icons.search),
            )
          ],
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(48.0),
            child: Directionality(
              textDirection: TextDirection.rtl,
              child: TabBar(
                controller: quranProvider.tabQuranRowController,
                onTap: (index) async {
                  quranProvider.setTabRowPageSelectedTab(
                    index: index,
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
          child: TabBarView(
            controller: quranProvider.tabQuranRowController,
            children: List.generate(
              114,
              (index) {
                return NotificationListener(
                  onNotification: (notificationInfo) {
                    if (notificationInfo is OverscrollIndicatorNotification) {
                      notificationInfo.disallowIndicator();
                    }
                    return true;
                  },
                  child: ListViewObserver(
                    controller: quranProvider
                        .getScrollController(quranProvider.currentTabRowIndex),
                    child: ListView.separated(
                      controller: quranProvider
                          .getScrollController(quranProvider.currentTabRowIndex)
                          .controller,
                      itemCount:
                          context.watch<QuranProvider>().ayahPerRow.length,
                      separatorBuilder: (context, index) => const Divider(
                        height: 0,
                        color: Colors.black,
                      ),
                      itemBuilder: (context, index) {
                        return Listener(
                          onPointerDown: (_) async {
                            log('index = $index');
                          },
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            color: Colors.white,
                            child: Directionality(
                              textDirection: TextDirection.ltr,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Directionality(
                                    textDirection: TextDirection.rtl,
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        Expanded(
                                          child: Text.rich(
                                            textAlign: TextAlign.justify,
                                            TextSpan(
                                              children: [
                                                TextSpan(
                                                  text:
                                                      '${context.watch<QuranProvider>().ayahPerRow[index].ayat} ',
                                                  style: const TextStyle(
                                                    fontFamily: 'LPMQ',
                                                    // fontFamily: "indopak",
                                                    fontSize: 30,
                                                    letterSpacing: 0,
                                                    height: 1.6,
                                                  ),
                                                ),
                                                TextSpan(
                                                  text: "${index + 1}",
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 10),
                                      ],
                                    ),
                                  ),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const SizedBox(height: 12),
                                          Text(
                                            context
                                                .watch<QuranProvider>()
                                                .ayahPerRow[index]
                                                .latin,
                                          ),
                                        ],
                                      ),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const SizedBox(height: 4),
                                          Text(
                                            context
                                                .watch<QuranProvider>()
                                                .ayahPerRow[index]
                                                .translate,
                                            textAlign: TextAlign.left,
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 12),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

Future<void> searchAyatBottomSheet({
  required BuildContext context,
}) async {
  return showModalBottomSheet(
    context: context,
    builder: (context) {
      return Container(
        height: MediaQuery.of(context).size.height / 2,
        margin: const EdgeInsets.symmetric(
          vertical: 40,
          horizontal: 16,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            TextField(
              textInputAction: TextInputAction.next,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText:
                    "Nomer Surat 1 - ${context.watch<QuranProvider>().surahInfo.length}",
              ),
              inputFormatters: [
                RangeInputFormatter(
                  min: 1,
                  max: context.watch<QuranProvider>().surahInfo.length,
                )
              ],
              onChanged: (value) async {
                Provider.of<QuranProvider>(context, listen: false)
                    .setSearchedTabIndex(
                  int.parse(value),
                );
              },
            ),
            TextField(
              textInputAction: TextInputAction.done,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                hintText: "Nomer Ayat",
              ),
              // inputFormatters: [
              //   RangeInputFormatter(
              //     min: 1,
              //     max: context.watch<QuranProvider>().ayahPerRow.length,
              //   )
              // ],
              onChanged: (value) async {
                Provider.of<QuranProvider>(context, listen: false)
                    .setSearchedAyatIndex(
                  int.parse(value),
                );
              },
            ),
            ElevatedButton(
              onPressed: () async {
                await Provider.of<QuranProvider>(context, listen: false)
                    .goToSearchedAyat();
              },
              child: const Text("Cari"),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("Kembali"),
            ),
          ],
        ),
      );
    },
  );
}
