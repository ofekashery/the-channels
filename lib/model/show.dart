import 'package:flutter/foundation.dart';

class Show {

  Show({
    @required this.key,
    @required this.title,
    @required this.startDate,
    @required this.endDate,
    this.categories
  });

  String key;
  String title;
  DateTime startDate;
  DateTime endDate;
  List<String> categories;

  String getStartTime() => '${pad(startDate.hour)}:${pad(startDate.minute)}';

  String pad(int num) => num < 10 ? '0$num' : '$num';

  Show.fromJson(Map<String, dynamic> json) {
    key = json['key'];
    title = json['title'];
    startDate = DateTime.parse(json['startDate']);
    endDate = json['endDate'] != null ? DateTime.parse(json['endDate']) : null;
    categories = (json['categories'] ?? []).map((item) => item.toString()).toList().cast<String>();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['key'] = this.key;
    data['title'] = this.title;
    data['startDate'] = this.startDate.toIso8601String();
    data['endDate'] = this.endDate != null ? this.endDate.toIso8601String() : null;
    data['categories'] = this.categories ?? [];
    return data;
  }
}
