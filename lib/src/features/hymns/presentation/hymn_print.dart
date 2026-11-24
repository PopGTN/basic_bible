import 'dart:typed_data';

import 'package:flutter/services.dart' show rootBundle;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../data/hymn_layout.dart';
import '../models/hymn.dart';
import '../models/hymnal.dart';

/// Builds a one-hymn PDF and opens the platform print dialog (system print
/// on Android/iOS/desktop, the browser's print on web). Uses the bundled
/// Gentium Plus font, which covers Latin scripts including Spanish; scripts
/// it lacks (e.g. Tamil) print as missing glyphs — a known limitation.
Future<void> printHymn({
  required Hymn hymn,
  required HymnalInfo book,
  required ChorusPlacement placement,
  HymnTextLabels labels = const HymnTextLabels(),
}) {
  return Printing.layoutPdf(
    name: '${hymn.number} ${hymn.title}',
    onLayout: (format) => buildHymnPdf(
      hymn,
      book,
      placement: placement,
      labels: labels,
      format: format,
    ),
  );
}

Future<pw.Font>? _regular;
Future<pw.Font>? _italic;

Future<pw.Font> _font(String path) async =>
    pw.Font.ttf(await rootBundle.load(path));

Future<Uint8List> buildHymnPdf(
  Hymn hymn,
  HymnalInfo book, {
  required ChorusPlacement placement,
  HymnTextLabels labels = const HymnTextLabels(),
  PdfPageFormat format = PdfPageFormat.a4,
}) async {
  final regular = await (_regular ??= _font(
    'assets/fonts/GentiumPlus-Regular.ttf',
  ));
  final italic = await (_italic ??= _font(
    'assets/fonts/GentiumPlus-Italic.ttf',
  ));
  final base = pw.TextStyle(font: regular, fontItalic: italic, fontSize: 13);
  final muted = base.copyWith(fontSize: 9, color: PdfColors.grey700);
  final details = [
    if (hymn.author.isNotEmpty) hymn.author,
    if (hymn.meter.isNotEmpty) hymn.meter,
    if (hymn.tuneName.isNotEmpty) hymn.tuneName,
  ];

  final doc = pw.Document(title: hymn.title, author: hymn.author);
  doc.addPage(
    pw.MultiPage(
      pageFormat: format,
      margin: const pw.EdgeInsets.all(48),
      build: (context) => [
        pw.Text(
          '${hymn.number}. ${hymn.title}',
          style: base.copyWith(fontSize: 18),
        ),
        if (details.isNotEmpty)
          pw.Text(details.join(' · '), style: muted.copyWith(fontSize: 10)),
        for (final note in hymn.notes)
          pw.Text(note, style: muted.copyWith(fontStyle: pw.FontStyle.italic)),
        for (final block in layoutHymn(hymn, placement: placement))
          pw.Padding(
            padding: pw.EdgeInsets.only(
              top: 10,
              left: block.kind == HymnBlockKind.verse ? 0 : 20,
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(switch (block.kind) {
                  HymnBlockKind.verse => '${block.verseNumber}',
                  HymnBlockKind.chorus => labels.chorus,
                  HymnBlockKind.optionalVerse => [
                    labels.optionalVerse,
                    ?block.label,
                  ].join(' — '),
                  HymnBlockKind.alternateChorus =>
                    block.label ?? labels.optionalChorus,
                }, style: muted),
                pw.Text(
                  block.lines.join('\n'),
                  style: block.kind == HymnBlockKind.chorus
                      ? base.copyWith(fontStyle: pw.FontStyle.italic)
                      : block.isOptional
                      ? base.copyWith(color: PdfColors.grey700)
                      : base,
                ),
              ],
            ),
          ),
        pw.SizedBox(height: 18),
        for (final line in hymnCreditLines(hymn, book))
          pw.Text(line, style: muted),
      ],
    ),
  );
  return doc.save();
}
