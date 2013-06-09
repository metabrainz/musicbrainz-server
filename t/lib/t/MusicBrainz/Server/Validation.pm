package t::MusicBrainz::Server::Validation;
use Test::Routine;
use Test::More;
use Test::Warn;

use MusicBrainz::Server::Validation qw( is_positive_integer is_guid trim_in_place is_valid_url is_valid_isrc is_valid_discid is_freedb_id is_valid_iswc format_iswc is_valid_ipi format_ipi is_valid_isni format_isni encode_entities normalise_strings is_valid_barcode is_valid_ean );

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
    ok(is_positive_integer(1), "Actual positive integer");
    ok(!is_positive_integer(-1), "Negative integer");
    ok(!is_positive_integer(undef), "Passing undef to is_positive_integer");
    ok(!is_positive_integer([1, 2, 3, 4]), "Passing arrayref to is_positive_integer");
    ok(!is_positive_integer({blah => 'foo', bar => 3}), "Passing hashref to is_positive_integer");
};

test 'Test is_guid' => sub {
    my $valid_guid = 'abcdef89-4444-5555-789a-1432abcdef88';
    ok(is_guid($valid_guid), "Actual GUID");
    ok(!is_guid('abcdef89-4444'), "Incomplete GUID");
    ok(!is_guid('00000000a0000-0000-0000-000000000000'), "Incorrect format with correct length");
    ok(!is_guid('00000000-0000-0000-0000-000000000000'), "All 0s fails");
    ok(!is_guid(undef), "Passing undef to is_guid");
    ok(!is_guid([1, 2, 3, 4]), "Passing arrayref to is_guid");
    ok(!is_guid({blah => 'foo', bar => 3}), "Passing hashref to is_guid");
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

test 'Test is_valid_ipi' => sub {
    ok(is_valid_ipi('00014107338'));
    ok(!is_valid_ipi(''));
    ok(!is_valid_ipi('MusicBrainz::Server::Entity::ArtistIPI=HASH(0x11c9a410)'),
       'Regression test #MBS-5066');
};

test 'Test format_ipi' => sub {
    is(format_ipi('014107338'), '00014107338');
    is(format_ipi('274.373.649'), '00274373649');
    is(format_ipi('274 373 649'), '00274373649');
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

test 'Test is_freedb_id' => sub {
    ok(is_freedb_id('abcdef12'), "Valid FreeDB ID");
    ok(is_freedb_id('ABCDEF12'), "Valid FreeDB ID with uppercase");
    ok(!is_freedb_id('abcqqq12'), "Invalid FreeDB ID");
};

test 'Test is_valid_barcode' => sub {
    ok(is_valid_barcode('1879246154964195'), "Valid Barcode");
    ok(!is_valid_barcode('129483615aaa'), "Invalid Barcode");
};

test 'Test is_valid_ean' => sub {
    ok(!is_valid_ean('1234567'), "Invalid EAN (7 chars)");
    ok(is_valid_ean('96385074'), "Valid EAN (8 chars)");
    ok(!is_valid_ean('96385076'), "Invalid EAN (8 chars)");
    ok(is_valid_ean('123456789999'), "Valid UPC (12 chars)");
    ok(!is_valid_ean('123456789997'), "Invalid UPC (12 chars)");
    ok(is_valid_ean('5901234123457'), "Valid EAN (13 chars)");
    ok(!is_valid_ean('5901234123459'), "Invalid EAN (13 chars)");
    ok(is_valid_ean('12345678901231'), "Valid GTIN (14 chars)");
    ok(!is_valid_ean('12345678901234'), "Invalid GTIN (14 chars)");
    ok(is_valid_ean('12345678912345675'), "Valid (17 chars)");
    ok(!is_valid_ean('12345678912345677'), "Invalid (17 chars)");
    ok(is_valid_ean('123456789123456789'), "Valid SSCC (18 chars)");
    ok(!is_valid_ean('123456789123456787'), "Invalid SSCC (18 chars)");
};

test 'Test encode_entities' => sub {
    is(encode_entities('ãñ><"\'&Å'), 'ãñ&gt;&lt;&quot;&#39;&amp;Å');
};

test 'Test normalise_strings' => sub {
    my ($alice, $bob) = normalise_strings ('alice', 'bob');
    my $alice2 = normalise_strings ('alice');
    is ($alice, 'alice');
    is ($alice2, 'alice');
    is ($bob, 'bob');
};

1;
