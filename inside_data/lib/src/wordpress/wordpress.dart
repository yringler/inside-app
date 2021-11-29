abstract class Wordpress {
  final String wordpressDomain;

  Wordpress({required String wordpressDomain})
      : this.wordpressDomain = ensureHttps(wordpressDomain);

  static String ensureHttps(String url) =>
      url.contains('http') ? url : 'https://$url';
}