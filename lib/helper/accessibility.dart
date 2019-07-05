import '../model/show-details.dart'
;
class Accessibility {

  Map<String, List<String>> accessibilities = {
    'כתוביות ע"פ דרישה': [
      "כ' ע\"פ דרישה",
      "כתוביות ע\"פ דרישה"
    ],
    'כתוביות סמויות': [
      "מלווה בכתוביות סמויות",
      "כתוביות סמויות",
      "כ' סמ'",
      "כ' סמויות"
    ],
    'דיבוב בעברית': [
      "ד' עב'",
      "ד' עב"
    ],
    'כתוביות בעברית': [
      "כתוביות בעברית",
      "כ' עב'/כ' סמ'",
      "כ' עב'",
      "כ' עב"
    ],
    'כתוביות בערבית': [
      "כתוביות בערבית",
      "כ' ער'",
      "כ' ער"
    ],
    'כתוביות בעברית ובערבית': [
      "כתוביות בעברית ובערבית",
      "כ' עב'/ער'",
      "כ' עב/ער"
    ],
    'כתוביות בעברית וברוסית': [
      "כתוביות בעברית וברוסית",
      "כ' עב'/רו'",
      "כ' עב/רו"
    ],
    'שפת הסימנים': [
      "בליווי ש' הסימנים",
      "ש' הסימנים",
      "בליווי שפת הסימנים",
      "שפת הסימנים"
    ],
  };

  static String getAccessibility(ShowDetails show) {
    for (String title in Accessibility().accessibilities.keys) {
      for (String name in Accessibility().accessibilities[title]) {
        if (show.title.contains(name) || show.description.contains(name)) {
          return title;
        }
      }
    }
    return null;
  }

  static String getNewDescription(String description) {
    for (String name in Accessibility().accessibilities.values.expand((x) => x).toList()) {
      description = description.replaceAll('$name.', '');
      description = description.replaceAll(name, '');
    }
    description = description.replaceAll(RegExp('/\s\s+/g'), ' ');
    description = description.replaceAll(RegExp('/..+/g'), '.');
    return description;
  }
}