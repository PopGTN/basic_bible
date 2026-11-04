import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:basic_bible/src/features/settings/application/view_models/reader_font_view_models.dart';
import 'package:basic_bible/src/features/settings/data/device_font_scanner.dart';
import 'package:basic_bible/src/features/settings/data/reader_font_loader.dart';
import 'package:basic_bible/src/features/settings/data/reader_font_repository.dart';
import 'package:basic_bible/src/features/settings/models/reader_font.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:shared_preferences/shared_preferences.dart';

/// Smallest byte string that passes the font signature check.
Uint8List fakeTtf() => Uint8List.fromList([0, 1, 0, 0, ...List.filled(16, 0)]);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory tempDir;
  late List<String> registered;
  late SharedPreferences prefs;

  setUp(() async {
    tempDir = Directory.systemTemp.createTempSync('reader_font_test');
    registered = [];
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
  });

  tearDown(() => tempDir.deleteSync(recursive: true));

  ReaderFontRepository repo({
    List<String> assets = const [],
    List<String>? deviceDirs,
    bool failRegister = false,
  }) {
    return ReaderFontRepository(
      prefs,
      registrar: (family, files) async {
        if (failRegister) throw Exception('bad font');
        registered.add(family);
      },
      fontsDirectory: () async => tempDir,
      assetKeys: () async => assets,
      deviceFontDirectories: deviceDirs ?? const [],
    );
  }

  group('device font grouping', () {
    test('groups style variants into one family and sorts by name', () {
      final fonts = DeviceFontScanner.groupFiles({
        '/f/NotoSerif-Regular.ttf': 100,
        '/f/NotoSerif-BoldItalic.ttf': 120,
        '/f/Roboto-Regular.ttf': 50,
        '/f/Arial.ttf': 10,
      });
      expect(fonts.map((f) => f.name), ['Arial', 'Noto Serif', 'Roboto']);
      final noto = fonts.singleWhere((f) => f.name == 'Noto Serif');
      expect(noto.paths, hasLength(2));
      expect(noto.sizeBytes, 220);
      expect(noto.id, 'device:NotoSerif');
    });

    test('variable fonts join their family', () {
      expect(DeviceFontScanner.familyStem('NotoSerif[wght]'), 'NotoSerif');
      expect(
        DeviceFontScanner.familyStem('NotoSerif-Italic[wdth,wght]'),
        'NotoSerif',
      );
    });

    test('scans directories recursively for ttf/otf only', () async {
      final nested = Directory(p.join(tempDir.path, 'truetype', 'dejavu'))
        ..createSync(recursive: true);
      File(p.join(nested.path, 'DejaVuSans.ttf')).writeAsBytesSync([1]);
      File(p.join(nested.path, 'DejaVuSans-Bold.ttf')).writeAsBytesSync([1]);
      File(p.join(tempDir.path, 'readme.txt')).writeAsStringSync('x');
      File(p.join(tempDir.path, 'Big.ttc')).writeAsBytesSync([1]);

      final fonts = await repo(deviceDirs: [tempDir.path]).scanner.fonts();
      expect(fonts.map((f) => f.name), ['Deja Vu Sans']);
      expect(fonts.single.paths, hasLength(2));
    });
  });

  group('bundled fonts', () {
    test('only fonts whose files exist are offered', () async {
      final fonts = await repo(
        assets: [
          'assets/fonts/GentiumPlus-Regular.ttf',
          'assets/fonts/GentiumPlus-Italic.ttf',
          'assets/fonts/README.md',
        ],
      ).bundledFonts();
      expect(fonts.map((f) => f.name), ['Gentium Plus']);
      expect(fonts.single.paths, hasLength(2));
    });

    test('none offered until the font files are added', () async {
      expect(await repo().bundledFonts(), isEmpty);
    });
  });

  group('import', () {
    test('stores the file, registers it, and remembers it', () async {
      final repository = repo();
      final font = await repository.importFont(
        fileName: 'My_Font.ttf',
        bytes: fakeTtf(),
      );

      expect(font.name, 'My Font');
      expect(registered, [font.family]);
      expect(File(font.paths.single).existsSync(), isTrue);
      expect(repository.importedFonts().single.id, font.id);
    });

    test('rejects non-font data and wrong extensions', () async {
      final repository = repo();
      await expectLater(
        repository.importFont(fileName: 'notes.txt', bytes: fakeTtf()),
        throwsA(isA<InvalidFontFileException>()),
      );
      await expectLater(
        repository.importFont(
          fileName: 'fake.ttf',
          bytes: Uint8List.fromList(List.filled(40, 7)),
        ),
        throwsA(isA<InvalidFontFileException>()),
      );
      expect(repository.importedFonts(), isEmpty);
    });

    test('a font the engine refuses is not stored', () async {
      final repository = repo(failRegister: true);
      await expectLater(
        repository.importFont(fileName: 'x.otf', bytes: fakeTtf()),
        throwsA(isA<InvalidFontFileException>()),
      );
      expect(tempDir.listSync(), isEmpty);
    });

    test('deleting removes the file and resets the selection', () async {
      final repository = repo();
      final font = await repository.importFont(
        fileName: 'a.ttf',
        bytes: fakeTtf(),
      );
      await repository.saveSelected(font);

      await repository.deleteImported(font);

      expect(File(font.paths.single).existsSync(), isFalse);
      expect(repository.importedFonts(), isEmpty);
      expect(repository.selected.isDefault, isTrue);
    });
  });

  group('selection persistence', () {
    test('selected font survives a restart and is reloaded', () async {
      final first = repo();
      final font = await first.importFont(fileName: 'a.ttf', bytes: fakeTtf());
      await first.saveSelected(font);

      registered.clear();
      final restarted = repo(); // new instance = fresh process
      final restored = await restarted.restore();

      expect(restored.id, font.id);
      expect(registered, [font.family]);
    });

    test('falls back to the default when the font file vanished', () async {
      final repository = repo();
      final font = await repository.importFont(
        fileName: 'a.ttf',
        bytes: fakeTtf(),
      );
      await repository.saveSelected(font);
      File(font.paths.single).deleteSync();

      final restored = await repo().restore();

      expect(restored.isDefault, isTrue);
      expect(repo().selected.isDefault, isTrue);
    });

    test('default is stored as no override', () async {
      final repository = repo();
      expect(repository.selected.isDefault, isTrue);
      expect(repository.selected.family, isNull);
    });
  });

  group('loading', () {
    test('concurrent loads of one family hit the engine once', () async {
      final file = File(p.join(tempDir.path, 'Shared-Regular.ttf'))
        ..writeAsBytesSync(fakeTtf());
      final font = ReaderFont(
        id: 'device:Shared',
        name: 'Shared',
        source: ReaderFontSource.device,
        family: 'device:Shared',
        paths: [file.path],
      );
      final repository = repo();

      final results = await Future.wait([
        repository.loader.ensureLoaded(font),
        repository.loader.ensureLoaded(font),
        repository.loader.ensureLoaded(font),
      ]);

      expect(results, [true, true, true]);
      expect(registered, ['device:Shared']);
      expect(repository.loader.isLoaded(font), isTrue);
    });
  });

  group('previews', () {
    ReaderFont deviceFont(String name, {int size = 10}) {
      final file = File(p.join(tempDir.path, '$name-Regular.ttf'))
        ..writeAsBytesSync(fakeTtf());
      return ReaderFont(
        id: 'device:$name',
        name: name,
        source: ReaderFontSource.device,
        family: 'device:$name',
        paths: [file.path],
        sizeBytes: size,
      );
    }

    test('rows that scrolled away before their turn are skipped', () async {
      final repository = repo();
      final a = deviceFont('A');
      final b = deviceFont('B');

      final results = await Future.wait([
        repository.loader.loadForPreview(a, stillWanted: () => true),
        repository.loader.loadForPreview(b, stillWanted: () => false),
      ]);

      expect(results, [true, false]);
      expect(registered, ['device:A']);
    });

    test('requests made together load as one batch', () async {
      final repository = repo();
      final fonts = [for (var i = 0; i < 5; i++) deviceFont('Batch$i')];

      final results = await Future.wait([
        for (final font in fonts)
          repository.loader.loadForPreview(font, stillWanted: () => true),
      ]);

      expect(results, everyElement(isTrue));
      expect(registered, unorderedEquals([for (final f in fonts) f.family]));
      for (final font in fonts) {
        expect(repository.loader.hasPreview(font), isTrue);
        // Single-file families are fully usable once previewed.
        expect(repository.loader.isLoaded(font), isTrue);
      }
    });

    test('previews register only the regular face of a family', () async {
      final repository = repo();
      final paths = [
        for (final style in ['Bold', 'Regular', 'Italic'])
          (File(
            p.join(tempDir.path, 'Multi-$style.ttf'),
          )..writeAsBytesSync(fakeTtf())).path,
      ];
      final font = ReaderFont(
        id: 'device:Multi',
        name: 'Multi',
        source: ReaderFontSource.device,
        family: 'device:Multi',
        paths: paths,
        sizeBytes: 30,
      );

      expect(
        await repository.loader.loadForPreview(font, stillWanted: () => true),
        isTrue,
      );
      expect(registered, ['device:Multi']);
      expect(repository.loader.hasPreview(font), isTrue);
      expect(repository.loader.isLoaded(font), isFalse);

      // Selecting it still loads the remaining faces.
      expect(await repository.loader.ensureLoaded(font), isTrue);
      expect(repository.loader.isLoaded(font), isTrue);
    });

    test('previewPath prefers the regular face, then the plainest name', () {
      expect(
        ReaderFontLoader.previewPath([
          '/f/Lora-Bold.ttf',
          '/f/Lora-Regular.ttf',
        ]),
        '/f/Lora-Regular.ttf',
      );
      expect(
        ReaderFontLoader.previewPath(['/f/Lato-BoldItalic.ttf', '/f/Lato.ttf']),
        '/f/Lato.ttf',
      );
    });

    test('fonts over the size limit are not previewed', () {
      final repository = repo();
      final huge = deviceFont(
        'Huge',
        size: ReaderFontLoader.previewSizeLimitBytes + 1,
      );
      expect(repository.loader.canPreview(huge), isFalse);
      expect(repository.loader.canPreview(ReaderFont.systemDefault), isFalse);
    });

    test('previews stop once the memory budget is used', () async {
      final repository = repo();
      final limit = ReaderFontLoader.previewSizeLimitBytes;
      final count = ReaderFontLoader.previewBudgetBytes ~/ limit;
      for (var i = 0; i < count; i++) {
        expect(
          await repository.loader.loadForPreview(
            deviceFont('F$i', size: limit),
            stillWanted: () => true,
          ),
          isTrue,
        );
      }
      final over = deviceFont('Over', size: limit);
      expect(repository.loader.canPreview(over), isFalse);
      expect(
        await repository.loader.loadForPreview(over, stillWanted: () => true),
        isFalse,
      );
    });
  });

  group('controller', () {
    test('select loads, persists, and updates state', () async {
      final repository = repo();
      final font = await repository.importFont(
        fileName: 'a.ttf',
        bytes: fakeTtf(),
      );
      final controller = ReaderFontController(repository);
      addTearDown(controller.dispose);

      expect(await controller.select(font), isTrue);

      expect(controller.state.selected, font);
      expect(repository.selected.id, font.id);
    });

    test('selecting an unloadable font keeps the old one', () async {
      final controller = ReaderFontController(repo());
      addTearDown(controller.dispose);
      const missing = ReaderFont(
        id: 'device:Gone',
        name: 'Gone',
        source: ReaderFontSource.device,
        family: 'device:Gone',
        paths: ['/no/such/file.ttf'],
      );

      expect(await controller.select(missing), isFalse);

      expect(controller.state.selected.isDefault, isTrue);
      expect(controller.state.error?.kind, ReaderFontErrorKind.loadFailed);
      expect(controller.state.error?.fontName, 'Gone');
    });

    test('import reports a readable error for bad files', () async {
      final controller = ReaderFontController(repo());
      addTearDown(controller.dispose);

      final result = await controller.import(
        fileName: 'photo.png',
        bytes: Uint8List(40),
      );

      expect(result, isNull);
      expect(controller.state.error?.kind, ReaderFontErrorKind.unsupportedType);
      expect(controller.state.busy, isFalse);
    });

    test('a slow earlier selection cannot override a newer one', () async {
      final slowFile = File(p.join(tempDir.path, 'Slow-Regular.ttf'))
        ..writeAsBytesSync(fakeTtf());
      final fastFile = File(p.join(tempDir.path, 'Fast-Regular.ttf'))
        ..writeAsBytesSync(fakeTtf());
      final slowGate = Completer<void>();
      final repository = ReaderFontRepository(
        prefs,
        registrar: (family, files) async {
          if (family == 'device:Slow') await slowGate.future;
        },
        deviceFontDirectories: const [],
      );
      ReaderFont font(String name, File file) => ReaderFont(
        id: 'device:$name',
        name: name,
        source: ReaderFontSource.device,
        family: 'device:$name',
        paths: [file.path],
      );
      final slow = font('Slow', slowFile);
      final fast = font('Fast', fastFile);
      final controller = ReaderFontController(repository);
      addTearDown(controller.dispose);

      final slowSelect = controller.select(slow);
      await controller.select(fast);
      slowGate.complete();
      await slowSelect;

      expect(controller.state.selected, fast);
      expect(repository.selected.id, fast.id);
      expect(controller.state.busy, isFalse);
    });
  });
}
