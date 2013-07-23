package t::MusicBrainz::Server::Data::MediumCDTOC;
use Test::Routine;
use Test::Moose;
use Test::More;

use MusicBrainz::Server::Data::MediumCDTOC;

use MusicBrainz::Server::Context;
use MusicBrainz::Server::Test qw( capture_edits );

with 't::Context';

test all => sub {
my $test = shift;
my $c = $test->c;

    $c->sql->do(<<'EOSQL');
INSERT INTO editor (id, name, password, privs, email, website, bio, member_since,
        email_confirm_date, last_login_date, edits_accepted, edits_rejected,
        auto_edits_accepted, edits_failed, ha1)
    VALUES (1, 'new_editor', '{CLEARTEXT}password', 1+8+32, 'test@email.com', 'http://test.website',
        'biography', '1989-07-23', '2005-10-20', '2013-04-05', 12, 2, 59, 9, 'aa550c5b01407ef1f3f0d16daf9ec3c8'),
         (2, 'Alice', '{CLEARTEXT}secret1', 0, 'alice@example.com', 'http://example.com',
        'second biography', '2007-07-23', '2007-10-20', now(), 11, 3, 41, 8, 'e7f46e4f25ae38fcc952ef2b7edf0de9'),
         (3, 'kuno', '{CLEARTEXT}byld', 0, 'kuno@example.com', 'http://frob.nl',
        'donation check test user', '2010-03-25', '2010-03-25', now(), 0, 0, 0, 0, '00863261763ed5029ea051f87c4bbec3'),
         (4, 'ModBot', '{CLEARTEXT}mb', 0, '', 'http://musicbrainz.org/doc/ModBot',
         'See the above link for more information.', NULL, NULL, NULL, 2, 1, 99951, 3560, '9bcacf185adc9268d460694f78615c33');
EOSQL
    MusicBrainz::Server::Test->prepare_test_database($test->c, '+medium-cdtoc');

    my @edits = capture_edits {
        $c->model('MediumCDTOC')->insert({medium => 1, cdtoc => 1});
    } $c;

    is(@edits, 1, 'created 1 edit');
    isa_ok($edits[0], 'MusicBrainz::Server::Edit::Medium::SetTrackLengths', 'is a "Set Track Lengths" edit');
    is($edits[0]->editor_id, 4, 'ModBot is editor')
};

1;
