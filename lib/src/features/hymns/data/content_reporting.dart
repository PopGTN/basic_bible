/// Where rights holders send takedown requests for content the app ships or
/// lists from the official repository. Override at build time with
/// `--dart-define=TAKEDOWN_URL=…` (an https: page or a mailto: address).
///
/// Default: a new issue in the public bible-data repository, which should
/// carry a takedown issue template (`.github/ISSUE_TEMPLATE/takedown.md`).
const kAppTakedownContact = String.fromEnvironment(
  'TAKEDOWN_URL',
  defaultValue:
      'https://github.com/PopGTN/bible-data/issues/new?template=takedown.md',
);

/// Builds a link that opens [contact] with the report pre-filled.
///
/// - `mailto:` addresses get `subject` and `body`.
/// - GitHub "new issue" pages get `title` and `body`.
/// - Any other https page is opened as-is (forms can't be pre-filled).
///
/// Returns null when [contact] is not a usable mailto:/https: link.
Uri? buildContentReportUri(
  String contact, {
  required String subject,
  required String body,
}) {
  final trimmed = contact.trim();
  if (trimmed.isEmpty || trimmed.contains('TODO_')) return null;
  if (!trimmed.contains(':') && trimmed.contains('@')) {
    return buildContentReportUri(
      'mailto:$trimmed',
      subject: subject,
      body: body,
    );
  }
  final uri = Uri.tryParse(trimmed);
  if (uri == null) return null;
  if (uri.scheme == 'mailto') {
    return uri.replace(
      query: _encode({
        ...uri.queryParameters,
        'subject': subject,
        'body': body,
      }),
    );
  }
  if (uri.scheme != 'https') return null;
  if (uri.host == 'github.com' && uri.path.endsWith('/issues/new')) {
    return uri.replace(
      queryParameters: {...uri.queryParameters, 'title': subject, 'body': body},
    );
  }
  return uri;
}

/// mailto: needs %20 for spaces; Uri's queryParameters would emit '+'.
String _encode(Map<String, String> params) => params.entries
    .map((e) => '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}')
    .join('&');

/// The facts a rights holder needs us to identify the content.
String contentReportBody({
  required String bookTitle,
  required String bookId,
  required String source,
  String? publisher,
}) =>
    'Content: $bookTitle\n'
    'Identifier: $bookId\n'
    'Source: $source\n'
    '${publisher == null ? '' : 'Listed publisher: $publisher\n'}'
    '\n'
    'Please describe the work and your rights in it, and how we can '
    'contact you:\n';
