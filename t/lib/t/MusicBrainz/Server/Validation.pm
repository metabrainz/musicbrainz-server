package t::MusicBrainz::Server::Validation;
use utf8;
use strict;
use warnings;

use Test::Routine;
use Test::More;
use Test::Warn;

use MusicBrainz::Server::Validation qw(
    is_positive_integer
    is_guid
    trim_in_place
    is_valid_url
    is_valid_isrc
    format_isrc
    is_valid_discid
    is_freedb_id
    is_valid_iswc
    format_iswc
    is_valid_ipi
    format_ipi
    is_valid_isni
    format_isni
    encode_entities
    normalise_strings
    is_valid_barcode
    is_valid_gtin
    is_valid_partial_date
    is_database_row_id
    is_database_bigint_id
    is_database_indexable_string
    has_at_most_oneline_string_length
    is_valid_edit_note
);

test 'Test trim_in_place' => sub {
    my $a = '  ';
    my $b = ' a ';
    my $c = ' a  b  ';
    my $d = ' a  b  c ';
    my $e = undef;

    warning_is {
        trim_in_place($a, $b, $c, $d, $e)
    } 'Uninitialized value passed to trim_in_place';

    is( $a, '' );
    is( $b, 'a' );
    is( $c, 'a b' );
    is( $d, 'a b c' );
    is( $e, '' );
};

test 'Test is_positive_integer' => sub {
    ok(is_positive_integer(1), 'Actual positive integer');
    ok(!is_positive_integer(0), 'Zero');
    ok(!is_positive_integer('123 is a nice number'), 'Number plus letters');
    ok(!is_positive_integer(-1), 'Negative integer');
    ok(!is_positive_integer(undef), 'Passing undef to is_positive_integer');
    ok(!is_positive_integer([1, 2, 3, 4]), 'Passing arrayref to is_positive_integer');
    ok(!is_positive_integer({blah => 'foo', bar => 3}), 'Passing hashref to is_positive_integer');
};

test 'Test is_database_row_id' => sub {
    ok(is_database_row_id(1), '1 is a row id');
    ok(is_database_row_id(2147483647), 'max postgres int is a row id');
    ok(!is_database_row_id(2147483648), '(max postgres int + 1) is not a row id');
    ok(!is_database_row_id(0), 'zero is not a row id');
    ok(!is_database_row_id('123 is a nice number'), 'number plus letters is not a row id');
    ok(!is_database_row_id(-1), 'negative integer is not a row id');
    ok(!is_database_row_id(undef), 'undef is not a row id');
    ok(!is_database_row_id([1, 2, 3, 4]), 'arrayref is not a row id');
    ok(!is_database_row_id({blah => 'foo', bar => 3}), 'hashref is not a row id');
};

test 'Test is_database_bigint_id' => sub {
    ok(is_database_bigint_id(1), '1 is a bigint');
    ok(is_database_bigint_id(2147483647), 'max postgres int is a bigint ID');
    ok(is_database_bigint_id(2147483648), '(max postgres int + 1) is a bigint ID');
    ok(is_database_bigint_id(9223372036854775807), 'max postgres bigint is a bigint ID');
    ok(!is_database_bigint_id(9223372036854775808), '(max postgres bigint + 1) is not a bigint ID');
    ok(!is_database_bigint_id(0), 'zero is not a bigint ID');
    ok(!is_database_bigint_id(-1), 'negative integer is not a bigint ID');
};

test 'Test is_database_indexable_string' => sub {
    ok(is_database_indexable_string(undef), 'undef is an indexable string');
    ok(is_database_indexable_string(''), '"" is an indexable string');
    ok(is_database_indexable_string('0123456789ABCDEF' x 169), '2704 single-byte characters string is an indexable string');
    ok(!is_database_indexable_string(('0123456789ABCDEF' x 169) . '0'), '2705 single-byte characters string is not an indexable string');
    ok(!is_database_indexable_string('𝄞𝄵𝅘𝅥𝅘𝅥𝅮𝅘𝅥𝅮𝅘𝅥𝅮𝄾𝅘𝅥𝄀𝅘𝅥𝅮𝅘𝅥𝅮𝅘𝅥𝅮𝄾𝆑𝅗𝅥𝄂' x 64), '1024 four-byte characters string is not an indexable string');
};

test 'Test has_at_most_oneline_string_length' => sub {
    ok(has_at_most_oneline_string_length(undef), 'undef has under one-line string length');
    ok(has_at_most_oneline_string_length(''), '"" has under one-line string length');
    ok(has_at_most_oneline_string_length('0123456789ABCDEF' x 64), '1024 characters string has one-line string length');
    ok(!has_at_most_oneline_string_length(('0123456789ABCDEF' x 64) . '0'), '1025 characters string has over one-line string length');
};

test 'Test is_guid' => sub {
    my $valid_guid = 'abcdef89-4444-5555-789a-1432abcdef88';
    ok(is_guid($valid_guid), 'Actual GUID');
    ok(!is_guid('abcdef89-4444'), 'Incomplete GUID');
    ok(!is_guid('00000000a0000-0000-0000-000000000000'), 'Incorrect format with correct length');
    ok(!is_guid('00000000-0000-0000-0000-000000000000'), 'All 0s fails');
    ok(!is_guid(undef), 'Passing undef to is_guid');
    ok(!is_guid([1, 2, 3, 4]), 'Passing arrayref to is_guid');
    ok(!is_guid({blah => 'foo', bar => 3}), 'Passing hashref to is_guid');
};

test 'Test is_valid_url' => sub {
    ok(is_valid_url('http://musicbrainz.org/'), 'Valid URL');
    ok(is_valid_url('urn:isbn:0451450523'), 'URN');
    ok(!is_valid_url(' http://musicbrainz.org'), 'Contains a space');
    ok(!is_valid_url('../lol.html'), 'Relative URI');
    ok(!is_valid_url('://lol.org'), 'No scheme');
    ok(!is_valid_url('http://blah/'), 'No period in authority');
};

test 'Test is_valid_isrc' => sub {
    ok(is_valid_isrc('USPR37300012'));
    ok(!is_valid_isrc('USPR373000128'));
    ok(!is_valid_isrc('12PR37300012'));
    ok(!is_valid_isrc(''));
    ok(!is_valid_isrc('123'));
};

test 'Test is_valid_discid' => sub {
    ok(is_valid_discid('D5LsXhbWwpctL4s5xHSTS_SefQw-'));
    ok(!is_valid_discid('aivDFb2Tw6HzN.XdYZFj5zr1Q9EY'));
    ok(!is_valid_discid(''));
    ok(!is_valid_discid('123'));
};

test 'Test is_valid_iswc' => sub {
    ok(is_valid_iswc('T-000.000.001-0'));
    ok(is_valid_iswc('T-000000001-0'));
    ok(is_valid_iswc('T-000000001.0'));
    ok(is_valid_iswc('T0000000010'));
    ok(!is_valid_iswc('T00010'));
    ok(!is_valid_iswc('T-000.000-0'));
    ok(is_valid_iswc('T- 101.914.232-4'));
};

test 'Test format_iswc' => sub {
    is(format_iswc('T-000.000.001-0'), 'T-000.000.001-0');
    is(format_iswc('T-000000001-0'), 'T-000.000.001-0');
    is(format_iswc('T-000000001.0'), 'T-000.000.001-0');
    is(format_iswc('T0000000010'), 'T-000.000.001-0');
    is(format_iswc('T- 101.914.232-4'), 'T-101.914.232-4');
};

test 'Test format_isrc' => sub {
    is(format_isrc('GB-XWZ-08-00015'), 'GBXWZ0800015', 'format_isrc removes hyphens (MBS-6394)');
    is(format_isrc('gbxwz0800015'), 'GBXWZ0800015', 'format_isrc uppercases letters (MBS-6554)');
};

test 'Test is_valid_ipi' => sub {
    ok(is_valid_ipi('00014107338'));
    ok(!is_valid_ipi('00000000000'), 'All-zeros IPI is not valid');
    ok(!is_valid_ipi(''));
    ok(!is_valid_ipi('MusicBrainz::Server::Entity::ArtistIPI=HASH(0x11c9a410)'),
       'Regression test #MBS-5066');
};

test 'Test format_ipi' => sub {
    is(format_ipi('07338'), '00000007338', '5 (or more) character IPI is zero-padded');
    is(format_ipi('274.373.649'), '00274373649');
    is(format_ipi('274 373 649'), '00274373649');
    is(format_ipi('7338'), '7338', 'Too short IPI is returned as-is');
    is(format_ipi('MusicBrainz::Server::Entity::ArtistIPI=HASH(0x11c9a410)'),
       'MusicBrainz::Server::Entity::ArtistIPI=HASH(0x11c9a410)',
       'Regression test #MBS-5066');
};

test 'Test is_valid_isni' => sub {
    ok(is_valid_isni('0000000106750994'));
    ok(is_valid_isni('000000010675099X'));
    ok(!is_valid_isni('000000010675099Y'));
    ok(!is_valid_isni('106750994'));
};

test 'Test format_isni' => sub {
    is(format_isni('000000010675099 X'),
       '000000010675099X',
       'spaces are removed');
};

test 'Test is_freedb_id' => sub {
    ok(is_freedb_id('abcdef12'), 'Valid FreeDB ID');
    ok(is_freedb_id('ABCDEF12'), 'Valid FreeDB ID with uppercase');
    ok(!is_freedb_id('abcqqq12'), 'Invalid FreeDB ID');
};

test 'Test is_valid_barcode' => sub {
    ok(is_valid_barcode('1879246154964195'), 'Valid Barcode');
    ok(!is_valid_barcode('129483615aaa'), 'Invalid Barcode');
};

test 'Test is_valid_gtin' => sub {
    ok(!is_valid_gtin('1234565'), '7-digit barcode with valid check digit has invalid length');
    ok(is_valid_gtin('07642357'), 'GTIN-8 (EAN-8) is valid');
    ok(!is_valid_gtin('07642358'), 'GTIN-8 (EAN-8) has invalid check digit');
    ok(is_valid_gtin('718752155427'), 'GTIN-12 (UPC-A) is valid');
    ok(!is_valid_gtin('718752155428'), 'GTIN-12 (UPC-A) has invalid check digit');
    ok(is_valid_gtin('0666017082523'), '13-digit 0-padded GTIN-12 (UPC-A) is valid');
    ok(is_valid_gtin('4050538793819'), 'GTIN-13 (EAN-13) is valid');
    ok(!is_valid_gtin('4050538793810'), 'GTIN-13 (EAN-13) has invalid check digit');
    ok(is_valid_gtin('00602577318801'), '14-digit 0-padded GTIN-12 (UPC-A) is valid');
    ok(is_valid_gtin('07875354382095'), '14-digit 0-padded GTIN-13 (EAN-13) is valid');
    ok(!is_valid_gtin('02083116542649'), 'GTIN-12 (UPC-A) with 2-digit add-on (UPC-2) is invalid (until MBS-13468)');
    ok(!is_valid_gtin('01501272866800084'), 'GTIN-12 (UPC-A) with 5-digit add-on (UPC-5) is invalid (until MBS-13468)');
    ok(!is_valid_gtin('419091010790904'), 'GTIN-13 (EAN-13) with 2-digit add-on (EAN-2) is invalid (until MBS-13468)');
    ok(!is_valid_gtin('842056520418700004'), 'GTIN-13 (EAN-13) with 5-digit add-on (EAN-5) is invalid (until MBS-13468)');
};

test 'Test is_valid_partial_date' => sub {
    ok(is_valid_partial_date(2014, 10, 16), 'normal complete date');
    ok(is_valid_partial_date(2014, undef, 16), 'incomplete date');
    ok(is_valid_partial_date(undef, undef, undef), 'empty date');

    ok(!is_valid_partial_date('2014a', undef, 16), 'non-number');

    ok(!is_valid_partial_date(undef, 13, undef), 'invalid month');
    ok(!is_valid_partial_date(undef, undef, 32), 'invalid day-of-month');
    ok(!is_valid_partial_date(undef, 6, 31), 'invalid month/day combination');

    ok(is_valid_partial_date(1980, 7, 31), 'last of July');

    subtest 'February 29th (leap years)' => sub {
        my $run = sub { is_valid_partial_date(shift, 2, 29); };

        ok(!$run->(2014), 'regular non-leap year');
        ok($run->(2012), 'regular leap year');
        ok($run->(2000), '2000 was a leap year');
        ok($run->(1600), '1600 was a leap year');
        ok(!$run->(1900), '1900 was no leap year');
        ok($run->(undef), 'unknown year may be a leap year');
    };
};

test 'Test encode_entities' => sub {
    is(encode_entities(q(ãñ><"'&Å)), 'ãñ&gt;&lt;&quot;&#39;&amp;Å');
};

test 'Test normalise_strings' => sub {
    my ($alice, $bob) = normalise_strings('alice', 'bob');
    my $alice2 = normalise_strings('alice');
    is($alice, 'alice');
    is($alice2, 'alice');
    is($bob, 'bob');

    is(normalise_strings(q(")), q('), 'Double quote to single quote');

    is(normalise_strings('`'), q('), 'U+0060 GRAVE ACCENT');
    is(normalise_strings('´'), q('), 'U+00B4 ACUTE ACCENT');
    is(normalise_strings('«'), q('), 'U+00AB LEFT-POINTING DOUBLE ANGLE QUOTATION MARK');
    is(normalise_strings('»'), q('), 'U+00BB RIGHT-POINTING DOUBLE ANGLE QUOTATION MARK');
    is(normalise_strings('ʻ'), q('), 'U+02BB MODIFIER LETTER TURNED COMMA');
    is(normalise_strings('׳'), q('), 'U+05F3 HEBREW PUNCTUATION GERESH');
    is(normalise_strings('״'), q('), 'U+05F4 HEBREW PUNCTUATION GERSHAYIM');
    is(normalise_strings('‘'), q('), 'U+2018 LEFT SINGLE QUOTATION MARK');
    is(normalise_strings('’'), q('), 'U+2019 RIGHT SINGLE QUOTATION MARK');
    is(normalise_strings('‚'), q('), 'U+201A SINGLE LOW-9 QUOTATION MARK');
    is(normalise_strings('‛'), q('), 'U+201B SINGLE HIGH-REVERSED-9 QUOTATION MARK');
    is(normalise_strings('“'), q('), 'U+201C LEFT DOUBLE QUOTATION MARK');
    is(normalise_strings('”'), q('), 'U+201D RIGHT DOUBLE QUOTATION MARK');
    is(normalise_strings('„'), q('), 'U+201E DOUBLE LOW-9 QUOTATION MARK');
    is(normalise_strings('‟'), q('), 'U+201F DOUBLE HIGH-REVERSED-9 QUOTAITON MARK');
    is(normalise_strings('′'), q('), 'U+2032 PRIME');
    is(normalise_strings('″'), q('), 'U+2033 DOUBLE PRIME');
    is(normalise_strings('‹'), q('), 'U+2039 SINGLE LEFT-POINTING ANGLE QUOTATION MARK');
    is(normalise_strings('›'), q('), 'U+203A SINGLE RIGHT-POINTING ANGLE QUOTATION MARK');

    is(normalise_strings('־'), '-', 'U+05BE HEBREW PUNCTUATION MAQAF');
    is(normalise_strings('‐'), '-', 'U+2010 HYPHEN');
    is(normalise_strings('‒'), '-', 'U+2012 FIGURE DASH');
    is(normalise_strings('–'), '-', 'U+2013 EN DASH');
    is(normalise_strings('—'), '-', 'U+2014 EM DASH');
    is(normalise_strings('―'), '-', 'U+2015 HORIZONTAL BAR');
    is(normalise_strings('−'), '-', 'U+2212 MINUS SIGN');

    is(normalise_strings('…'), '...', 'U+2026 HORIZONTAL ELLIPSIS');
    is(normalise_strings('⋯'), '...', 'U+22EF MIDLINE HORIZONTAL ELLIPSIS');

    is(normalise_strings('ı'), 'i', 'U+0131 LATIN SMALL LETTER DOTLESS I -> i');

    is(normalise_strings('ABCDE'), 'abcde', 'ASCII lc');
    is(normalise_strings('ÀÉÎÕÜ'), 'aeiou', 'Latin-1 lc/unaccent');
    is(normalise_strings('ĀĖİŐŮ'), 'aeiou', 'Latin-A lc/unaccent');
    is(normalise_strings('ǍƠȘȚǙ'), 'aostu', 'Latin-B lc/unaccent');
    is(normalise_strings('ẨẸỊỖṤṸẂỶẔ'), 'aeiosuwyz', 'Latin Additional lc/unaccent');
    is(normalise_strings('！＄０５ＡＺｂｙ'), '!$05azby', 'Fullwidth Latin to ASCII');
    is(normalise_strings('｡｢･ｱﾝ'), '。「・アン', 'Halfwidth Katakana/punctuation to fullwidth');

};

test 'Test is_valid_edit_note' => sub {
    ok(!is_valid_edit_note(''), 'Empty edit note is invalid');
    ok(is_valid_edit_note('This is a note!'), 'Standard edit note is valid');
    ok(
        !is_valid_edit_note('a'),
        'Note made of just one ASCII character is invalid',
    );
    ok(
        is_valid_edit_note('‍͏‍͏‍͏‍͏‍͏‍͏‍͏‍͏‍͏‍͏‍͏‍͏‍͏‍͏‍͏‍͏‍͏‍͏‍͏‍͏‍͏‍͏‍͏‍͏‍͏‍͏‍͏‍͏‍͏‍͏‍͏‍͏‍͏‍͏‍͏‍͏‍͏‍͏‍͏‍͏‍͏‍͏‍͏漢'),
        'Note made of just one kanji character is valid',
    );
    ok(
        !is_valid_edit_note("  \t"),
        'Note made of spaces and tabs is invalid',
    );
    ok(
        !is_valid_edit_note("\N{ZERO WIDTH JOINER}\N{COMBINING GRAPHEME JOINER}\N{ZERO WIDTH JOINER}\N{COMBINING GRAPHEME JOINER}\N{ZERO WIDTH JOINER}\N{COMBINING GRAPHEME JOINER}"),
        'Note made of format and join characters is invalid',
    );
    ok(
        is_valid_edit_note("\N{ZERO WIDTH JOINER}\N{COMBINING GRAPHEME JOINER}abc\N{ZERO WIDTH JOINER}\N{COMBINING GRAPHEME JOINER}"),
        'Note made of format and join characters plus text is valid',
    );
};

1;
