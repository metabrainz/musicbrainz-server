package t::MusicBrainz::Server::Validation;
use Test::Routine;
use Test::More;

use MusicBrainz::Server::Validation qw( is_valid_iswc format_iswc is_valid_ipi format_ipi );

test 'Test TrimInPlace' => sub {
    my $a = '  ';
    my $b = ' a ';
    my $c = ' a  b  ';
    my $d = ' a  b  c ';

    MusicBrainz::Server::Validation::TrimInPlace($a, $b, $c, $d);

    is( $a, '' );
    is( $b, 'a' );
    is( $c, 'a b' );
    is( $d, 'a b c' );
};

test 'Test is_positive_integer' => sub {
    ok(MusicBrainz::Server::Validation::is_positive_integer(1), "Actual positive integer");
    ok(!MusicBrainz::Server::Validation::is_positive_integer(-1), "Negative integer");
    ok(!MusicBrainz::Server::Validation::is_positive_integer(undef), "Passing undef to is_positive_integer");
    ok(!MusicBrainz::Server::Validation::is_positive_integer([1, 2, 3, 4]), "Passing arrayref to is_positive_integer");
    ok(!MusicBrainz::Server::Validation::is_positive_integer({blah => 'foo', bar => 3}), "Passing hashref to is_positive_integer");
};

test 'Test IsGUID' => sub {
    my $valid_guid = 'abcdef89-4444-5555-789a-1432abcdef88';
    ok(MusicBrainz::Server::Validation::IsGUID($valid_guid), "Actual GUID");
    ok(!MusicBrainz::Server::Validation::IsGUID('abcdef89-4444'), "Incomplete GUID");
    ok(!MusicBrainz::Server::Validation::IsGUID('00000000a0000-0000-0000-000000000000'), "Incorrect format with correct length");
    ok(!MusicBrainz::Server::Validation::IsGUID('00000000-0000-0000-0000-000000000000'), "All 0s fails");
    ok(!MusicBrainz::Server::Validation::IsGUID(undef), "Passing undef to IsGUID");
    ok(!MusicBrainz::Server::Validation::IsGUID([1, 2, 3, 4]), "Passing arrayref to IsGUID");
    ok(!MusicBrainz::Server::Validation::IsGUID({blah => 'foo', bar => 3}), "Passing hashref to IsGUID");

    ok(MusicBrainz::Server::Validation::is_guid($valid_guid), "Test is_guid alias");
};

test 'Test IsValidURL/is_valid_url' => sub {
    ok(MusicBrainz::Server::Validation->IsValidURL('http://musicbrainz.org/'), 'Valid URL');
    ok(MusicBrainz::Server::Validation->IsValidURL('urn:isbn:0451450523'), 'URN');
    ok(!MusicBrainz::Server::Validation->IsValidURL(' http://musicbrainz.org'), 'Contains a space');
    ok(!MusicBrainz::Server::Validation->IsValidURL('../lol.html'), 'Relative URI');
    ok(!MusicBrainz::Server::Validation->IsValidURL('://lol.org'), 'No scheme');
    ok(!MusicBrainz::Server::Validation->IsValidURL('http://blah/'), 'No period in authority');

    ok(MusicBrainz::Server::Validation::is_valid_url('http://musicbrainz.org/'), 'Valid URL');
    ok(MusicBrainz::Server::Validation::is_valid_url('urn:isbn:0451450523'), 'URN');
    ok(!MusicBrainz::Server::Validation::is_valid_url(' http://musicbrainz.org'), 'Contains a space');
    ok(!MusicBrainz::Server::Validation::is_valid_url('../lol.html'), 'Relative URI');
    ok(!MusicBrainz::Server::Validation::is_valid_url('://lol.org'), 'No scheme');
    ok(!MusicBrainz::Server::Validation::is_valid_url('http://blah/'), 'No period in authority');
};

test 'Test is_valid_isrc' => sub {
    ok(MusicBrainz::Server::Validation::is_valid_isrc('USPR37300012'));
    ok(!MusicBrainz::Server::Validation::is_valid_isrc('12PR37300012'));
    ok(!MusicBrainz::Server::Validation::is_valid_isrc(''));
    ok(!MusicBrainz::Server::Validation::is_valid_isrc('123'));
};

test 'Test is_valid_discid' => sub {
    ok(MusicBrainz::Server::Validation::is_valid_discid('D5LsXhbWwpctL4s5xHSTS_SefQw-'));
    ok(!MusicBrainz::Server::Validation::is_valid_discid('aivDFb2Tw6HzN.XdYZFj5zr1Q9EY'));
    ok(!MusicBrainz::Server::Validation::is_valid_discid(''));
    ok(!MusicBrainz::Server::Validation::is_valid_discid('123'));
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
};

test 'Test format_ipi' => sub {
    is(format_ipi('014107338'), '00014107338');
};

test 'Test is_freedb_id' => sub {
    ok(MusicBrainz::Server::Validation::is_freedb_id('abcdef12'), "Valid FreeDB ID");
    ok(MusicBrainz::Server::Validation::is_freedb_id('ABCDEF12'), "Valid FreeDB ID with uppercase");
    ok(!MusicBrainz::Server::Validation::is_freedb_id('abcqqq12'), "Invalid FreeDB ID");
};

test 'Test IsValidBarcode' => sub {
    ok(MusicBrainz::Server::Validation::IsValidBarcode('1879246154964195'), "Valid Barcode");
    ok(!MusicBrainz::Server::Validation::IsValidBarcode('129483615aaa'), "Invalid Barcode");
};

test 'Test IsValidEAN' => sub {
    ok(!MusicBrainz::Server::Validation::IsValidEAN('1234567'), "Invalid EAN (7 chars)");
    ok(MusicBrainz::Server::Validation::IsValidEAN('96385074'), "Valid EAN (8 chars)");
    ok(!MusicBrainz::Server::Validation::IsValidEAN('96385076'), "Invalid EAN (8 chars)");
    ok(MusicBrainz::Server::Validation::IsValidEAN('123456789999'), "Valid UPC (12 chars)");
    ok(!MusicBrainz::Server::Validation::IsValidEAN('123456789997'), "Invalid UPC (12 chars)");
    ok(MusicBrainz::Server::Validation::IsValidEAN('5901234123457'), "Valid EAN (13 chars)");
    ok(!MusicBrainz::Server::Validation::IsValidEAN('5901234123459'), "Invalid EAN (13 chars)");
    ok(MusicBrainz::Server::Validation::IsValidEAN('12345678901231'), "Valid GTIN (14 chars)");
    ok(!MusicBrainz::Server::Validation::IsValidEAN('12345678901234'), "Invalid GTIN (14 chars)");
    ok(MusicBrainz::Server::Validation::IsValidEAN('12345678912345675'), "Valid (17 chars)");
    ok(!MusicBrainz::Server::Validation::IsValidEAN('12345678912345677'), "Invalid (17 chars)");
    ok(MusicBrainz::Server::Validation::IsValidEAN('123456789123456789'), "Valid SSCC (18 chars)");
    ok(!MusicBrainz::Server::Validation::IsValidEAN('123456789123456787'), "Invalid SSCC (18 chars)");
};

test 'Test encode_entities' => sub {
    is(MusicBrainz::Server::Validation::encode_entities('ãñ><"\'&Å'), 'ãñ&gt;&lt;&quot;&#39;&amp;Å');
};

test 'Test normalise_strings' => sub {
    my ($alice, $bob) = MusicBrainz::Server::Validation::normalise_strings ('alice', 'bob');
    my $alice2 = MusicBrainz::Server::Validation::normalise_strings ('alice');
    is ($alice, 'alice');
    is ($alice2, 'alice');
    is ($bob, 'bob');
};

1;
