import 'package:web_scraper/web_scraper.dart';

import '../configs/constants.dart' as constants;

/// A scraper to extract info from GitHub projects
class GitHubScraper {
  /// Determines the licence for a given project
  static Future<String> licenseForProject(String url) async {
    final _webScraper = WebScraper('$url');
    try {
      if (await _webScraper.loadWebPage('/blob/master/LICENSE')) {
        final regExp = RegExp(r'(<h3 class=\"mt-0 mb-2 h4\">)(.*)(<\/h3>)');
        final matches = regExp.allMatches(_webScraper.getPageContent());
        if (matches.isNotEmpty) {
          return matches.first?.group(2)?.replaceAll('License', '')?.trim();
        }
      }
    } on WebScraperException catch (_) {}

    return constants.unknown;
  }
}
