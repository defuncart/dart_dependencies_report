import 'package:meta/meta.dart';
import 'package:web_scraper/web_scraper.dart';

/// A model representing scraped data of a package hosted on pub.dev
class PubDevScrapedData {
  /// The about text
  final String about;

  /// The license
  final String license;

  /// The score
  final String score;

  /// Constructs a new instance of [PubDevScrapedData]
  ///
  /// All properties are required
  const PubDevScrapedData({
    @required this.about,
    @required this.license,
    @required this.score,
  });

  @override
  String toString() => '{about: $about, license: $license, score: $score}';
}

/// A scraper to extract info from packages hosted on pub.dev
class PubDevScraper {
  final _webScraper = WebScraper('http://pub.dev/packages');

  /// Returns [PubDevScrapedData] for a given [package] name
  Future<PubDevScrapedData> forPackage(String package) async {
    if (await _webScraper.loadWebPage('/$package')) {
      final elements1 = _webScraper.getElement('aside.detail-info-box > h3', []);

      final indexAbout = elements1.indexOf(elements1.firstWhere(
        (element) => element['title'] == 'About',
        orElse: () => null,
      ));
      final indexLicense = elements1.indexOf(elements1.firstWhere(
        (element) => element['title'] == 'License',
        orElse: () => null,
      ));

      if (indexAbout >= 0 && indexLicense >= 0) {
        final elements2 = _webScraper.getElement('aside.detail-info-box > p', []);

        final about = elements2[indexAbout]['title'].trim();
        final license = elements2[indexLicense + 1]['title'].replaceAll('(LICENSE)', '').trim();

        final elements3 = _webScraper.getElement('div.score-box', []);
        final score = elements3.first['title'];

        return PubDevScrapedData(about: about, license: license, score: score);
      } else {
        print('Problem scraping $package from pub.dev');
      }
    }

    return null;
  }
}
