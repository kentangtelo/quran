import 'dart:convert';

class Ayah {
  final int pageNumber;
  final int lineNumber;
  final int ayaNumber;
  final String text;
  final String charType;
  final int sura;

  Ayah(
      {required this.pageNumber,
      required this.lineNumber,
      required this.ayaNumber,
      required this.text,
      required this.charType,
      required this.sura});

  factory Ayah.fromMap(Map<String, dynamic> map) {
    return Ayah(
      pageNumber: map['page_number'],
      lineNumber: map['line_number'],
      ayaNumber: map['aya'],
      // text: map['text_madani'],
      text: map['text_indopak'],
      charType: map['char_type'],
      sura: map['sura'],
    );
  }
}

// To parse this JSON data, do
//
//     final ayatPerRow = ayatPerRowFromJson(jsonString);

List<AyatPerRow> ayatPerRowFromJson(String str) =>
    List<AyatPerRow>.from(json.decode(str).map((x) => AyatPerRow.fromJson(x)));

String ayatPerRowToJson(List<AyatPerRow> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class AyatPerRow {
  String ayat;
  String latin;
  String translate;

  AyatPerRow({
    required this.ayat,
    required this.latin,
    required this.translate,
  });

  factory AyatPerRow.fromJson(Map<String, dynamic> json) => AyatPerRow(
        ayat: json["ayat"],
        latin: json["latin"],
        translate: json["translate"],
      );

  Map<String, dynamic> toJson() => {
        "ayat": ayat,
        "latin": latin,
        "translate": translate,
      };
}
