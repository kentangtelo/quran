import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:learn_quran_read_sqllite/models/surah_info_model.dart';
import 'package:scrollview_observer/scrollview_observer.dart';

import '../models/ayah.dart';
import '../services/database_helper.dart';

class QuranProvider extends ChangeNotifier {
  // int nomerSurat = 598;
  // int nomerSurat = 106;
  // int nomerSurat = 604;

  final DatabaseHelper _databaseHelper = DatabaseHelper();
  List<Ayah> _ayahs = [];
  List<Ayah> get ayahs => _ayahs;

  List<AyatPerRow> _ayahPerRow = [];
  List<AyatPerRow> get ayahPerRow => _ayahPerRow;

  List<SurahInfo> _surahInfo = [];
  List<SurahInfo> get surahInfo => _surahInfo;

  int nomerSurat = 1;

  TabController? _tabQuranController;
  TabController? get tabQuranController => _tabQuranController;

  PageController? _pageQuranByPageController;
  PageController? get pageQuranByPageController => _pageQuranByPageController;

  int _selectedSurahByPageTab = 0;
  int get selectedSurahByPageTab => _selectedSurahByPageTab;

  int _currentPageIndex = 0;
  int get currentPageIndex => _currentPageIndex;

  int _currentTabRowIndex = 0;
  int get currentTabRowIndex => _currentTabRowIndex;

  TabController? _tabQuranRowController;
  TabController? get tabQuranRowController => _tabQuranRowController;

  final Map<int, ListObserverController> scrollControllers = {};
  final Map<int, List<GlobalKey>> _keys = {};

  int _searchedTabIndex = 0;
  int get searchedTabIndex => _searchedTabIndex;

  int _searchedAyatIndex = 0;
  int get searchedAyatIndex => _searchedAyatIndex;

  QuranProvider() {
    loadQuranPage(nomerSurat);
    getSurahInfo();
  }

  void initTabController(
    TickerProvider vynsc,
    int initTabIndex,
    int intPageIndex,
  ) async {
    if (_tabQuranController != null) {
      _tabQuranController!.dispose();
    }

    _tabQuranController = TabController(
      initialIndex: initTabIndex,
      length: 114,
      vsync: vynsc,
    );

    _selectedSurahByPageTab = initTabIndex;
    _currentPageIndex = intPageIndex;
    loadQuranPage(_currentPageIndex + 1);
    notifyListeners();

    _pageQuranByPageController = PageController(
      initialPage: intPageIndex,
      keepPage: true,
    );

    _pageQuranByPageController!.addListener(() {
      _currentPageIndex = _pageQuranByPageController!.page!.toInt().round();
      notifyListeners();
      loadQuranPage(_currentPageIndex + 1).whenComplete(() {
        setTabPageSelectedTab(
          index: tabQuranController!.index,
          pageIndex: -1,
        );
      });

      notifyListeners();
    });
  }

  void setTabPageSelectedTab({
    required int index,
    required int pageIndex,
  }) async {
    _selectedSurahByPageTab = index;

    notifyListeners();

    if (pageIndex != -1) {
      _currentPageIndex = pageIndex - 1;
      pageQuranByPageController!.jumpToPage(pageIndex - 1);
    }

    if (pageIndex != -1) {
      _selectedSurahByPageTab = index;
      notifyListeners();
    } else {
      _selectedSurahByPageTab = _ayahs[0].sura - 1;
      notifyListeners();
    }

    log('_selectedSurahByPageTab $_selectedSurahByPageTab');

    tabQuranController!.animateTo(_selectedSurahByPageTab);
  }

  Future<void> loadQuranPage(int pageNumber) async {
    final List<Map<String, dynamic>> maps =
        await _databaseHelper.getQuranPage(pageNumber);
    _ayahs = maps.map((map) => Ayah.fromMap(map)).toList();
    notifyListeners();
  }

  Future<void> getQuranBySurah(int surahNumber) async {
    var maps = await _databaseHelper.getQuranSurah(surahNumber);
    log(maps.toString());
  }

  Future<void> getSurahInfo() async {
    var data = await _databaseHelper.getAllSurahInfo();

    if (_surahInfo.isEmpty) {
      for (var i = 0; i < data.length; i++) {
        _surahInfo.add(SurahInfo.fromJson(data[i]));
      }
    }

    log(surahInfo.length.toString());
    notifyListeners();
  }

  Future<int> getFirstPageSurah({required int index}) async {
    var firstPage = await _databaseHelper.getFirstPageOfSurah(index);

    log('firstPage $firstPage');

    return firstPage;
  }

  void initTabRowController(
    TickerProvider vynsc,
    int initTabIndex,
  ) async {
    if (_tabQuranRowController != null) {
      _tabQuranRowController!.dispose();
    }

    _tabQuranRowController = TabController(
      initialIndex: initTabIndex,
      length: 114,
      vsync: vynsc,
    );

    _currentTabRowIndex = initTabIndex;
    notifyListeners();

    getSurahAyat(surahNumber: initTabIndex + 1);

    _tabQuranRowController!.addListener(() {
      setTabRowPageSelectedTab(index: _tabQuranRowController!.index);
    });
  }

  void setTabRowPageSelectedTab({
    required int index,
  }) {
    getSurahAyat(surahNumber: index + 1);
    _currentTabRowIndex = index;
    log("_currentTabRowIndex $_currentTabRowIndex");
    notifyListeners();

    _tabQuranRowController!.animateTo(index);
  }

  Future<void> getSurahAyat({required int surahNumber}) async {
    final List<Map<String, dynamic>> maps = await _databaseHelper.getSurahAyat(
      surahNumber: surahNumber,
    );
    _ayahPerRow = maps.map((e) => AyatPerRow.fromJson(e)).toList();

    notifyListeners();
  }

  ListObserverController getScrollController(int tabIndex) {
    if (!scrollControllers.containsKey(tabIndex)) {
      scrollControllers[tabIndex] = ListObserverController(
        controller: ScrollController(),
      );
    }
    log("getScrollController ${scrollControllers[tabIndex]!.controller!.hasClients}");
    return scrollControllers[tabIndex]!;
  }

  GlobalKey getKey(int tabIndex, int index) {
    if (!_keys.containsKey(tabIndex)) {
      _keys[tabIndex] = List.generate(
        _ayahPerRow.length,
        (index) => GlobalKey(),
      );
    }
    return _keys[tabIndex]![index];
  }

  void setSearchedTabIndex(int index) {
    _searchedTabIndex = index;
    notifyListeners();
  }

  void setSearchedAyatIndex(int index) {
    _searchedAyatIndex = index;
    notifyListeners();
  }

  Future<void> goToSearchedAyat() async {
    log("goToSearchedAyat _searchedTabIndex $_searchedTabIndex");
    log("goToSearchedAyat _searchedAyatIndex $_searchedAyatIndex");
    log("goToSearchedAyat _currentTabRowIndex $_currentTabRowIndex");

    setTabRowPageSelectedTab(index: _searchedTabIndex - 1);
    await Future.delayed(const Duration(milliseconds: 1000));
    scrollControllers[_currentTabRowIndex]!
        .jumpTo(index: _searchedAyatIndex - 1);
  }
}
