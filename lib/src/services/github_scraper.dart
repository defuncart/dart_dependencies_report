import 'package:web_scraper/web_scraper.dart';

class GitHubScraper {
  static Future<String> licenseForPackage(String url) async {
    final _webScraper = WebScraper('$url');
    if (await _webScraper.loadWebPage('/blob/master/LICENSE')) {
      final regExp = RegExp(r'(<h3 class=\"mt-0 mb-2 h4\">)(.*)(<\/h3>)');
      final matches = regExp.allMatches(_webScraper.getPageContent());
      final license = matches?.first?.group(2)?.replaceAll('License', '')?.trim();

      return license;
    }

    return 'Unknown';
  }
}
