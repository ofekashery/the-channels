import 'model/show.dart';

class Utilities {

  static bool filterUnnecessaryInformation(List<Show> shows, String newShowTitle) => shows.length == 0 || !((shows.last.title.contains("נשוב לשדר") || shows.last.title.contains("שידורינו יתחדשו"))
      && (newShowTitle.contains("נשוב לשדר") || newShowTitle.contains("שידורינו יתחדשו")));

}