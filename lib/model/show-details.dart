import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../helper/accessibility.dart';

class ShowDetails {

  ShowDetails({
    @required this.title,
    @required this.startDate,
    @required this.endDate,
    @required this.duration,
    @required this.description,
    @required this.categories,
    this.posterURL,
    this.contentRating
  });

  String title;
  DateTime startDate;
  DateTime endDate;
  int duration; // In minutes
  String description;
  List<String> categories;
  String posterURL;
  String contentRating;

  ShowDetails.fromJson(Map<String, dynamic> json) {
    title = json['title'];
    startDate = DateTime.parse(json['startDate']);
    endDate = DateTime.parse(json['endDate']);
    duration = json['duration'];
    description = json['description'];
    categories = json['categories'] != null ? json['categories'].cast<String>() : [];
    posterURL = json['posterURL'];
    contentRating = json['contentRating'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['title'] = this.title;
    data['startDate'] = this.startDate.toIso8601String();
    data['endDate'] = this.endDate.toIso8601String();
    data['duration'] = this.duration;
    data['description'] = this.description;
    data['categories'] = this.categories;
    data['posterURL'] = this.posterURL;
    data['contentRating'] = this.contentRating;
    return data;
  }

  List<Chip> getCategoriesChips(BuildContext context) {
    List<Chip> chips = [];
    TextStyle textStyle = TextStyle(color: Colors.black);
    if (getAccessibility() != null) {
      chips.add(Chip(
        label: Text('נגישות: ' + getAccessibility(), style: textStyle),
        backgroundColor: Colors.blue.shade50
      ));
    }
    if (contentRating != null) {
      chips.add(Chip(
          label: Text('הגבלת צפייה: ' + contentRating, style: textStyle),
          backgroundColor: Colors.red.shade50
      ));
    }
    chips.addAll((categories ?? []).map((String category) => Chip(
      label: Text(category, style: textStyle),
      backgroundColor: (Theme.of(context).brightness == Brightness.light ? Colors.black : Colors.white).withAlpha(15)
    )).toList());
    return chips;
  }

  String getAccessibility() {
    return Accessibility.getAccessibility(this);
  }

  String getDescription() {
    return Accessibility.getNewDescription(description);
  }
}
