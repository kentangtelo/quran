// To parse this JSON data, do
//
//     final surahInfo = surahInfoFromJson(jsonString);

import 'dart:convert';

List<SurahInfo> surahInfoFromJson(String str) =>
    List<SurahInfo>.from(json.decode(str).map((x) => SurahInfo.fromJson(x)));

String surahInfoToJson(List<SurahInfo> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class SurahInfo {
  int? index;
  String? name;
  String? ename;
  String? rukus;
  String? start;
  String? tname;
  String? ayas;
  Type? type;
  int? order;
  String? enameEnglish;

  SurahInfo({
    this.index,
    this.name,
    this.ename,
    this.rukus,
    this.start,
    this.tname,
    this.ayas,
    this.type,
    this.order,
    this.enameEnglish,
  });

  factory SurahInfo.fromJson(Map<String, dynamic> json) => SurahInfo(
        index: json["index"],
        name: json["name"],
        ename: json["ename"],
        rukus: json["rukus"],
        start: json["start"],
        tname: json["tname"],
        ayas: json["ayas"],
        type: typeValues.map[json["type"]],
        order: json["order"],
        enameEnglish: json["ename_english"],
      );

  Map<String, dynamic> toJson() => {
        "index": index,
        "name": name,
        "ename": ename,
        "rukus": rukus,
        "start": start,
        "tname": tname,
        "ayas": ayas,
        "type": typeValues.reverse[type],
        "order": order,
        "ename_english": enameEnglish,
      };
}

// ignore: constant_identifier_names
enum Type { MADINAH, MEKKAH }

final typeValues = EnumValues({"Madinah": Type.MADINAH, "Mekkah": Type.MEKKAH});

class EnumValues<T> {
  Map<String, T> map;
  late Map<T, String> reverseMap;

  EnumValues(this.map);

  Map<T, String> get reverse {
    reverseMap = map.map((k, v) => MapEntry(v, k));
    return reverseMap;
  }
}
