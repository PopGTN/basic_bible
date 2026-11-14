use regex::Regex;
use serde::{Deserialize, Serialize};
use serde_json::{json, Value};
use std::collections::HashMap;
use std::ffi::{CStr, CString};
use std::os::raw::c_char;
use std::sync::LazyLock;
use tree_sitter::Parser;

// Compile each regex once at first use rather than on every call to
// clean_inline_text. A USFM Bible has tens of thousands of lines so
// per-call compilation would dominate parse time.
static RE_FOOTNOTE_F:  LazyLock<Regex> = LazyLock::new(|| Regex::new(r"\\f\b[\s\S]*?\\f\*").unwrap());
static RE_FOOTNOTE_FE: LazyLock<Regex> = LazyLock::new(|| Regex::new(r"\\fe\b[\s\S]*?\\fe\*").unwrap());
static RE_FOOTNOTE_X:  LazyLock<Regex> = LazyLock::new(|| Regex::new(r"\\x\b[\s\S]*?\\x\*").unwrap());
static RE_WORD:        LazyLock<Regex> = LazyLock::new(|| Regex::new(r#"\\w\s+([^\\|]+?)(?:\|[^\\]+)?\\w\*"#).unwrap());
static RE_TAG:         LazyLock<Regex> = LazyLock::new(|| Regex::new(r"\\[a-zA-Z0-9+]+(?:\*|\s*)").unwrap());
static RE_ATTR:        LazyLock<Regex> = LazyLock::new(|| Regex::new(r"\|[^\\\s]+").unwrap());
static RE_WHITESPACE:  LazyLock<Regex> = LazyLock::new(|| Regex::new(r"\s+").unwrap());
static RE_WORD_ATTRS:  LazyLock<Regex> = LazyLock::new(|| Regex::new(r#"(\w+)="([^"]*)""#).unwrap());

#[derive(Debug, Deserialize)]
struct ParseRequest {
    files: Vec<SourceFile>,
}

#[derive(Debug, Deserialize)]
struct SourceFile {
    name: String,
    content: String,
}

#[derive(Default)]
struct BookBuilder {
    id: String,
    title: String,
    num: i32,
    toc_labels: Vec<Value>,
    introduction_blocks: Vec<Value>,
    chapters: Vec<ChapterBuilder>,
}

#[derive(Default)]
struct ChapterBuilder {
    number: i32,
    blocks: Vec<Value>,
    verses: Vec<VerseBuilder>,
}

#[derive(Default)]
struct VerseBuilder {
    number: i32,
    /// Raw USFM inline content (markers not yet stripped). Parsed into spans at
    /// JSON-serialisation time so the full marker context is available.
    raw_content: String,
}

#[derive(Serialize)]
struct ParseResponse {
    ok: bool,
    books: Vec<Value>,
    error: Option<String>,
}

#[no_mangle]
pub extern "C" fn basic_bible_parse_usfm_bundle(input: *const c_char) -> *mut c_char {
    // Catch any Rust panic so it never unwinds across the FFI boundary
    // (which is undefined behaviour in a cdylib and kills the host process).
    let result = std::panic::catch_unwind(|| {
        match parse_request_json(input) {
            Ok(request) => match parse_bundle(request) {
                Ok(books) => ParseResponse { ok: true, books, error: None },
                Err(error) => ParseResponse { ok: false, books: Vec::new(), error: Some(error) },
            },
            Err(error) => ParseResponse { ok: false, books: Vec::new(), error: Some(error) },
        }
    });

    let response = result.unwrap_or_else(|_| ParseResponse {
        ok: false,
        books: Vec::new(),
        error: Some("The native USFM parser panicked unexpectedly.".to_string()),
    });

    CString::new(serde_json::to_string(&response).unwrap())
        .unwrap()
        .into_raw()
}

#[no_mangle]
pub extern "C" fn basic_bible_free_string(ptr: *mut c_char) {
    if ptr.is_null() {
        return;
    }
    unsafe {
        drop(CString::from_raw(ptr));
    }
}

fn parse_request_json(input: *const c_char) -> Result<ParseRequest, String> {
    if input.is_null() {
        return Err("The native USFM parser received a null request.".to_string());
    }
    let request_json = unsafe { CStr::from_ptr(input) }
        .to_str()
        .map_err(|_| "The native USFM parser received invalid UTF-8 input.".to_string())?;
    serde_json::from_str::<ParseRequest>(request_json)
        .map_err(|error| format!("Unable to decode USFM parse request: {error}"))
}

fn parse_bundle(request: ParseRequest) -> Result<Vec<Value>, String> {
    let mut books = Vec::new();
    for file in request.files {
        validate_with_tree_sitter(&file.content)?;
        if let Some(book) = parse_file(&file)? {
            books.push(book);
        }
    }
    books.sort_by_key(|book| book["num"].as_i64().unwrap_or(999));
    Ok(books)
}

fn validate_with_tree_sitter(content: &str) -> Result<(), String> {
    let mut parser = Parser::new();
    parser
        .set_language(&tree_sitter_usfm3::language())
        .map_err(|error| format!("Unable to load the USFM 3 grammar: {error}"))?;
    parser
        .parse(content, None)
        .ok_or_else(|| "The USFM parser could not read this document.".to_string())?;
    Ok(())
}

fn parse_file(file: &SourceFile) -> Result<Option<Value>, String> {
    let mut book = BookBuilder::default();
    let mut current_chapter: Option<ChapterBuilder> = None;
    let mut current_verse: Option<VerseBuilder> = None;

    for raw_line in file.content.lines() {
        let line = raw_line.trim_end();
        if line.trim().is_empty() {
            continue;
        }

        if let Some((marker, rest)) = split_marker(line) {
            let (base_marker, level) = split_marker_level(marker);
            match base_marker.as_str() {
                "id" => {
                    let code = rest
                        .split_whitespace()
                        .next()
                        .unwrap_or_default()
                        .to_uppercase();
                    if code.is_empty() {
                        return Err(format!("USFM file {} is missing a book code in \\id.", file.name));
                    }
                    let (book_num, default_title) = book_metadata(&code);
                    book.id = code;
                    book.num = book_num;
                    if book.title.is_empty() {
                        book.title = default_title.to_string();
                    }
                }
                "h" => {
                    let text = clean_inline_text(rest);
                    if !text.is_empty() && book.title.is_empty() {
                        book.title = text.clone();
                    }
                }
                "toc" => {
                    let text = clean_inline_text(rest);
                    if !text.is_empty() {
                        let resolved_level = level.unwrap_or(1);
                        book.toc_labels
                            .push(json!({ "text": text, "level": resolved_level }));
                    }
                }
                "mt" | "mte" => {
                    let text = clean_inline_text(rest);
                    if !text.is_empty() && book.title.is_empty() {
                        book.title = text.clone();
                    }
                    push_heading_block(&mut book, &mut current_chapter, text, level.unwrap_or(1));
                }
                "ms" | "s" | "sr" | "r" => {
                    let text = clean_inline_text(rest);
                    push_heading_block(&mut book, &mut current_chapter, text, level.unwrap_or(1));
                }
                "ip" | "imt" | "imte" | "is" | "iot" | "io" => {
                    let text = clean_inline_text(rest);
                    if !text.is_empty() {
                        book.introduction_blocks.push(document_block(
                            block_kind_introduction(),
                            text,
                            level,
                        ));
                    }
                }
                "c" => {
                    flush_verse_into_chapter(&mut current_chapter, &mut current_verse);
                    flush_chapter_into_book(&mut book, &mut current_chapter);
                    let chapter_number = extract_leading_number(rest).unwrap_or(1);
                    current_chapter = Some(ChapterBuilder {
                        number: chapter_number,
                        ..Default::default()
                    });
                }
                "v" => {
                    current_chapter.get_or_insert_with(|| ChapterBuilder {
                        number: 1,
                        ..Default::default()
                    });
                    flush_verse_into_chapter(&mut current_chapter, &mut current_verse);
                    let (verse_number, verse_text) = split_verse(rest);
                    current_verse = Some(VerseBuilder {
                        number: verse_number,
                        // Store raw USFM content; spans are parsed at serialisation time.
                        raw_content: verse_text.to_string(),
                    });
                }
                "p" | "m" | "mi" | "pi" | "nb" | "pc" | "pm" | "pmc" | "pr" => {
                    let chapter = current_chapter.get_or_insert_with(|| ChapterBuilder {
                        number: 1,
                        ..Default::default()
                    });
                    let text = clean_inline_text(rest);
                    chapter
                        .blocks
                        .push(document_block(block_kind_paragraph(), text, level));
                }
                "q" | "qr" | "qc" | "qm" | "qa" => {
                    let chapter = current_chapter.get_or_insert_with(|| ChapterBuilder {
                        number: 1,
                        ..Default::default()
                    });
                    let text = clean_inline_text(rest);
                    chapter.blocks.push(document_block(
                        block_kind_poetry(),
                        text,
                        level.or(Some(1)),
                    ));
                }
                _ => {
                    // Unknown/inline marker while inside a verse — preserve the
                    // full line (including the leading \marker) in raw_content so
                    // parse_inline_spans can handle it correctly.
                    if let Some(verse) = current_verse.as_mut() {
                        if !verse.raw_content.is_empty() {
                            verse.raw_content.push(' ');
                        }
                        verse.raw_content.push_str(line);
                    }
                }
            }
        } else if let Some(verse) = current_verse.as_mut() {
            // Continuation line with no leading marker.
            if !verse.raw_content.is_empty() {
                verse.raw_content.push(' ');
            }
            verse.raw_content.push_str(line);
        }
    }

    flush_verse_into_chapter(&mut current_chapter, &mut current_verse);
    flush_chapter_into_book(&mut book, &mut current_chapter);

    if book.id.is_empty() {
        return Ok(None);
    }
    if book.title.is_empty() {
        book.title = book.id.clone();
    }

    Ok(Some(json!({
        "id": book.id,
        "title": book.title,
        "num": book.num,
        "tocLabels": book.toc_labels,
        "introductionBlocks": book.introduction_blocks,
        "chapters": book.chapters.into_iter().map(chapter_to_json).collect::<Vec<_>>(),
    })))
}

fn push_heading_block(
    book: &mut BookBuilder,
    current_chapter: &mut Option<ChapterBuilder>,
    text: String,
    level: i32,
) {
    if text.is_empty() {
        return;
    }
    let block = document_block(block_kind_heading(), text, Some(level));
    if let Some(chapter) = current_chapter.as_mut() {
        chapter.blocks.push(block);
    } else {
        book.introduction_blocks.push(block);
    }
}

fn flush_verse_into_chapter(
    current_chapter: &mut Option<ChapterBuilder>,
    current_verse: &mut Option<VerseBuilder>,
) {
    let Some(verse) = current_verse.take() else {
        return;
    };
    let chapter = current_chapter.get_or_insert_with(|| ChapterBuilder {
        number: 1,
        ..Default::default()
    });
    chapter.verses.push(verse);
}

fn flush_chapter_into_book(book: &mut BookBuilder, current_chapter: &mut Option<ChapterBuilder>) {
    if let Some(chapter) = current_chapter.take() {
        if !chapter.verses.is_empty() || !chapter.blocks.is_empty() {
            book.chapters.push(chapter);
        }
    }
}

fn chapter_to_json(chapter: ChapterBuilder) -> Value {
    json!({
        "number": chapter.number,
        "verses": chapter.verses.into_iter().map(|verse| {
            let spans = parse_inline_spans(&verse.raw_content);
            // Plain text fallback (used by search / export when spans are ignored).
            let plain_text = clean_inline_text(&verse.raw_content);
            json!({
                "number": verse.number,
                "text": plain_text,
                "notes": [],
                "references": [],
                "spans": spans,
                "footnotes": [],
                "crossReferences": [],
            })
        }).collect::<Vec<_>>(),
        "blocks": chapter.blocks,
    })
}

fn split_marker(line: &str) -> Option<(String, &str)> {
    let trimmed = line.trim_start();
    if !trimmed.starts_with('\\') {
        return None;
    }
    let tail = &trimmed[1..];
    let marker_len = tail
        .chars()
        .take_while(|ch| ch.is_ascii_alphanumeric() || *ch == '+')
        .count();
    if marker_len == 0 {
        return None;
    }
    let marker = tail[..marker_len].to_string();
    let rest = tail[marker_len..].trim_start();
    Some((marker, rest))
}

fn split_marker_level(marker: String) -> (String, Option<i32>) {
    let split_at = marker
        .find(|ch: char| ch.is_ascii_digit())
        .unwrap_or(marker.len());
    let base = &marker[..split_at];
    let level = marker[split_at..].parse::<i32>().ok();
    let base = if base.starts_with("toc") {
        "toc".to_string()
    } else {
        base.to_string()
    };
    (base, level)
}

fn split_verse(rest: &str) -> (i32, &str) {
    let trimmed = rest.trim_start();
    let number_len = trimmed
        .chars()
        .take_while(|ch| ch.is_ascii_digit() || *ch == '-')
        .count();
    let verse_token = trimmed[..number_len].trim();
    let verse_number = verse_token
        .split('-')
        .next()
        .and_then(|value| value.parse::<i32>().ok())
        .unwrap_or(1);
    let text = trimmed[number_len..].trim_start();
    (verse_number, text)
}

fn extract_leading_number(text: &str) -> Option<i32> {
    let token = text
        .trim_start()
        .chars()
        .take_while(|ch| ch.is_ascii_digit())
        .collect::<String>();
    token.parse::<i32>().ok()
}


/// Parse raw USFM inline content into typed verse spans.
///
/// Marker-to-kind mapping mirrors `BibleVerseSpanKind` in the Dart model:
///   0=normal, 1=wordsOfJesus(\wj), 2=translatorAddition(\add),
///   3=quote(\qt), 5=word(\w), 6=divineNameTag(\nd), 7=properName(\pn/\bk),
///   8=selah(\qs), 10=emphasis(\em), 11=bold(\bd), 12=italic(\it),
///   13=foreignLanguage(\tl), 14=keyword(\k)
fn parse_inline_spans(raw: &str) -> Vec<Value> {
    // Strip footnotes/cross-refs before span parsing.
    let step1 = RE_FOOTNOTE_F.replace_all(raw, "");
    let step2 = RE_FOOTNOTE_FE.replace_all(&step1, "");
    let cleaned = RE_FOOTNOTE_X.replace_all(&step2, "");
    let text = cleaned.as_ref();

    let chars: Vec<char> = text.chars().collect();
    let n = chars.len();
    let mut i = 0;

    let mut spans: Vec<Value> = Vec::new();
    let mut current_kind: i32 = 0; // normal
    // Stack of kinds so nested markers restore the outer kind on close.
    let mut kind_stack: Vec<i32> = Vec::new();
    let mut current_text = String::new();

    // Special state for \w word|attrs\w*
    let mut in_word = false;
    let mut word_text = String::new();
    let mut in_word_attrs = false;
    let mut word_attr_buf = String::new();

    while i < n {
        if chars[i] == '\\' {
            // Locate end of marker name (alphanumeric + '+' allowed).
            let mut j = i + 1;
            while j < n && (chars[j].is_ascii_alphanumeric() || chars[j] == '+') {
                j += 1;
            }
            if j == i + 1 {
                // Lone backslash — treat as literal text.
                if in_word && !in_word_attrs { word_text.push('\\'); }
                else if !in_word { current_text.push('\\'); }
                i += 1;
                continue;
            }
            let is_closing = j < n && chars[j] == '*';
            let marker: String = chars[i + 1..j].iter().collect();
            let base: String = marker
                .trim_end_matches(|c: char| c.is_ascii_digit())
                .to_string();

            if is_closing {
                if in_word && base == "w" {
                    // Close the \w...\w* word span.
                    let word = word_text.trim().to_string();
                    if !word.is_empty() {
                        let mut meta = serde_json::Map::new();
                        for cap in RE_WORD_ATTRS.captures_iter(&word_attr_buf) {
                            if let (Some(k), Some(v)) = (cap.get(1), cap.get(2)) {
                                meta.insert(k.as_str().to_string(), json!(v.as_str()));
                            }
                        }
                        spans.push(json!({
                            "text": word,
                            "kind": 5,
                            "metadata": Value::Object(meta),
                        }));
                    }
                    in_word = false;
                    in_word_attrs = false;
                    word_text.clear();
                    word_attr_buf.clear();
                    current_kind = kind_stack.pop().unwrap_or(0);
                } else {
                    // Close a regular character marker.
                    let t = RE_WHITESPACE
                        .replace_all(current_text.trim(), " ")
                        .to_string();
                    if !t.is_empty() {
                        spans.push(json!({ "text": t, "kind": current_kind, "metadata": {} }));
                    }
                    current_text.clear();
                    current_kind = kind_stack.pop().unwrap_or(0);
                }
                i = j + 1; // skip past '*'
            } else {
                // Opening marker.
                if base == "w" {
                    // Start \w span (special: needs attr parsing).
                    let t = RE_WHITESPACE
                        .replace_all(current_text.trim(), " ")
                        .to_string();
                    if !t.is_empty() {
                        spans.push(json!({ "text": t, "kind": current_kind, "metadata": {} }));
                    }
                    current_text.clear();
                    kind_stack.push(current_kind);
                    in_word = true;
                    in_word_attrs = false;
                    word_text.clear();
                    word_attr_buf.clear();
                } else {
                    let kind = inline_marker_kind(&base);
                    let t = RE_WHITESPACE
                        .replace_all(current_text.trim(), " ")
                        .to_string();
                    if !t.is_empty() {
                        spans.push(json!({ "text": t, "kind": current_kind, "metadata": {} }));
                    }
                    current_text.clear();
                    // Always push so the matching close pops correctly.
                    kind_stack.push(current_kind);
                    if kind >= 0 {
                        current_kind = kind;
                    }
                    // kind < 0 → unknown/transparent: content stays under the
                    // parent kind (we keep current_kind unchanged).
                }
                i = j;
                // Skip the single space that follows an opening marker.
                if i < n && chars[i] == ' ' {
                    i += 1;
                }
            }
        } else if chars[i] == '|' && in_word {
            // Separator between word text and attribute string inside \w.
            in_word_attrs = true;
            i += 1;
        } else if in_word {
            if in_word_attrs {
                word_attr_buf.push(chars[i]);
            } else {
                word_text.push(chars[i]);
            }
            i += 1;
        } else {
            current_text.push(chars[i]);
            i += 1;
        }
    }

    // Flush any remaining accumulated text.
    let t = RE_WHITESPACE
        .replace_all(current_text.trim(), " ")
        .to_string();
    if !t.is_empty() {
        spans.push(json!({ "text": t, "kind": current_kind, "metadata": {} }));
    }

    spans
}

/// Map a USFM base character marker name to a `BibleVerseSpanKind` index.
/// Returns -1 for unknown/transparent markers (content passes through as the
/// current parent span kind).
fn inline_marker_kind(base: &str) -> i32 {
    match base {
        "wj" => 1,        // wordsOfJesus
        "add" => 2,       // translatorAddition
        "qt" => 3,        // quote
        // "w" handled separately → 5 (word)
        "nd" => 6,        // divineNameTag
        "pn" | "bk" => 7, // properName / book name
        "qs" => 8,        // selah
        "em" => 10,       // emphasis
        "bd" => 11,       // bold
        "it" => 12,       // italic
        "tl" => 13,       // foreignLanguage
        "k"  => 14,       // keyword
        _ => -1,          // unknown — transparent to current span
    }
}

fn clean_inline_text(text: &str) -> String {
    let step1 = RE_FOOTNOTE_F.replace_all(text, " ");
    let step2 = RE_FOOTNOTE_FE.replace_all(&step1, " ");
    let without_notes = RE_FOOTNOTE_X.replace_all(&step2, " ");
    let normalized_words = RE_WORD.replace_all(&without_notes, "$1");
    let without_attrs = RE_ATTR.replace_all(&normalized_words, "");
    let without_tags = RE_TAG.replace_all(&without_attrs, " ");
    RE_WHITESPACE.replace_all(without_tags.trim(), " ").to_string()
}

#[cfg(test)]
mod tests {
    use super::{clean_inline_text, parse_inline_spans};

    #[test]
    fn clean_inline_text_strips_footnotes_and_crossrefs_without_panicking() {
        let text = r"\v 1 In the beginning\f + \ft Footnote text.\f* God created.\x + \xt Cross reference.\x*";
        let cleaned = clean_inline_text(text);
        assert_eq!(cleaned, "1 In the beginning God created.");
    }

    #[test]
    fn clean_inline_text_preserves_word_marker_text() {
        let text = r#"\w beginning|lemma="reshiyth"\w* was the start."#;
        let cleaned = clean_inline_text(text);
        assert_eq!(cleaned, "beginning was the start.");
    }

    #[test]
    fn parse_inline_spans_emits_words_of_jesus() {
        let text = r"Come, \wj follow me,\wj* he said.";
        let spans = parse_inline_spans(text);
        assert_eq!(spans.len(), 3);
        assert_eq!(spans[0]["text"], "Come,");
        assert_eq!(spans[0]["kind"], 0); // normal
        assert_eq!(spans[1]["text"], "follow me,");
        assert_eq!(spans[1]["kind"], 1); // wordsOfJesus
        assert_eq!(spans[2]["text"], "he said.");
        assert_eq!(spans[2]["kind"], 0);
    }

    #[test]
    fn parse_inline_spans_word_marker_with_attributes() {
        let text = r#"\w beginning|lemma="reshiyth" strong="H7225"\w* of all things."#;
        let spans = parse_inline_spans(text);
        let word_span = spans.iter().find(|s| s["kind"] == 5).expect("word span");
        assert_eq!(word_span["text"], "beginning");
        assert_eq!(word_span["metadata"]["lemma"], "reshiyth");
        assert_eq!(word_span["metadata"]["strong"], "H7225");
    }

    #[test]
    fn parse_inline_spans_strips_footnotes() {
        let text = r"God created\f + \ft See Gen 1.\f* the heavens.";
        let spans = parse_inline_spans(text);
        let joined: String = spans.iter()
            .filter_map(|s| s["text"].as_str())
            .collect::<Vec<_>>()
            .join(" ");
        assert!(!joined.contains("See Gen"));
        assert!(joined.contains("God created"));
        assert!(joined.contains("the heavens"));
    }
}

fn document_block(kind: i32, text: String, level: Option<i32>) -> Value {
    json!({
        "kind": kind,
        "text": text,
        "level": level,
        "metadata": HashMap::<String, String>::new(),
    })
}

fn block_kind_paragraph() -> i32 {
    0
}

fn block_kind_introduction() -> i32 {
    2
}

fn block_kind_heading() -> i32 {
    3
}

fn block_kind_poetry() -> i32 {
    5
}

fn book_metadata(code: &str) -> (i32, &'static str) {
    match code {
        "GEN" => (1, "Genesis"),
        "EXO" => (2, "Exodus"),
        "LEV" => (3, "Leviticus"),
        "NUM" => (4, "Numbers"),
        "DEU" => (5, "Deuteronomy"),
        "JOS" => (6, "Joshua"),
        "JDG" => (7, "Judges"),
        "RUT" => (8, "Ruth"),
        "1SA" => (9, "1 Samuel"),
        "2SA" => (10, "2 Samuel"),
        "1KI" => (11, "1 Kings"),
        "2KI" => (12, "2 Kings"),
        "1CH" => (13, "1 Chronicles"),
        "2CH" => (14, "2 Chronicles"),
        "EZR" => (15, "Ezra"),
        "NEH" => (16, "Nehemiah"),
        "EST" => (17, "Esther"),
        "JOB" => (18, "Job"),
        "PSA" => (19, "Psalms"),
        "PRO" => (20, "Proverbs"),
        "ECC" => (21, "Ecclesiastes"),
        "SNG" => (22, "Song of Songs"),
        "ISA" => (23, "Isaiah"),
        "JER" => (24, "Jeremiah"),
        "LAM" => (25, "Lamentations"),
        "EZK" => (26, "Ezekiel"),
        "DAN" => (27, "Daniel"),
        "HOS" => (28, "Hosea"),
        "JOL" => (29, "Joel"),
        "AMO" => (30, "Amos"),
        "OBA" => (31, "Obadiah"),
        "JON" => (32, "Jonah"),
        "MIC" => (33, "Micah"),
        "NAM" => (34, "Nahum"),
        "HAB" => (35, "Habakkuk"),
        "ZEP" => (36, "Zephaniah"),
        "HAG" => (37, "Haggai"),
        "ZEC" => (38, "Zechariah"),
        "MAL" => (39, "Malachi"),
        "MAT" => (40, "Matthew"),
        "MRK" => (41, "Mark"),
        "LUK" => (42, "Luke"),
        "JHN" => (43, "John"),
        "ACT" => (44, "Acts"),
        "ROM" => (45, "Romans"),
        "1CO" => (46, "1 Corinthians"),
        "2CO" => (47, "2 Corinthians"),
        "GAL" => (48, "Galatians"),
        "EPH" => (49, "Ephesians"),
        "PHP" => (50, "Philippians"),
        "COL" => (51, "Colossians"),
        "1TH" => (52, "1 Thessalonians"),
        "2TH" => (53, "2 Thessalonians"),
        "1TI" => (54, "1 Timothy"),
        "2TI" => (55, "2 Timothy"),
        "TIT" => (56, "Titus"),
        "PHM" => (57, "Philemon"),
        "HEB" => (58, "Hebrews"),
        "JAS" => (59, "James"),
        "1PE" => (60, "1 Peter"),
        "2PE" => (61, "2 Peter"),
        "1JN" => (62, "1 John"),
        "2JN" => (63, "2 John"),
        "3JN" => (64, "3 John"),
        "JUD" => (65, "Jude"),
        "REV" => (66, "Revelation"),
        _ => (999, "Unknown Book"),
    }
}
