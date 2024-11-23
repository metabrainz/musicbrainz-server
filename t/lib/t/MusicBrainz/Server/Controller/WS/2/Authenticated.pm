package t::MusicBrainz::Server::Controller::WS::2::Authenticated;
use utf8;
use strict;
use warnings;

use HTTP::Status qw( :constants );
use Test::Routine;
use Test::More;
use Test::XML::SemanticCompare qw( is_xml_same );

with 't::Mechanize', 't::Context';

use MusicBrainz::Server::Test qw( xml_ok schema_validator xml_post );
use MusicBrainz::Server::Test ws_test => {
    version => 2,
};

test all => sub {

my $test = shift;
my $c = $test->c;
my $v2 = schema_validator;
my $mech = $test->mech;
$mech->default_header('Accept' => 'application/xml');

MusicBrainz::Server::Test->prepare_test_database($c, '+webservice');
MusicBrainz::Server::Test->prepare_test_database($c, <<~'SQL');
    SELECT setval('tag_id_seq', (SELECT MAX(id) FROM tag));
    INSERT INTO editor (id, name, password, ha1)
        VALUES (1, 'new_editor', '{CLEARTEXT}password', 'e1dd8fee8ee728b0ddc8027d3a3db478')
    SQL

my $content = '<?xml version="1.0" encoding="UTF-8"?>
<metadata xmlns="http://musicbrainz.org/ns/mmd-2.0#">
    <artist-list>
        <artist id="802673f0-9b88-4e8a-bb5c-dd01d68b086f">
            <user-tag-list>
                <user-tag><name>hello project</name></user-tag>
                <user-tag><name>jpop</name></user-tag>
            </user-tag-list>
        </artist>
        <artist id="472bc127-8861-45e8-bc9e-31e8dd32de7a">
            <user-tag-list>
                <user-tag><name>dubstep</name></user-tag>
                <user-tag><name>uk</name></user-tag>
            </user-tag-list>
        </artist>
    </artist-list>
    <recording-list>
        <recording id="162630d9-36d2-4a8d-ade1-1c77440b34e7">
            <user-tag-list>
                <user-tag><name>country schlager thrash gabber</name></user-tag>
            </user-tag-list>
        </recording>
    </recording-list>
</metadata>';

$mech->request(xml_post('/ws/2/tag?client=post.t-0.0.2', $content));
is ($mech->status, HTTP_UNAUTHORIZED, 'Tags rejected without authentication');
$mech->content_contains('You are not authorized');

$mech->credentials('localhost:80', 'musicbrainz.org', 'new_editor', 'password');

$mech->request(xml_post('/ws/2/tag?client=post.t-0.0.2', $content));
xml_ok ($mech->content);

my $xp = XML::XPath->new( xml => $mech->content );
is ($xp->find('//message/text')->string_value, 'OK', 'POST request got "OK" response');

_compare_tags ($c, 'Artist', '802673f0-9b88-4e8a-bb5c-dd01d68b086f',
               {'jpop' => 1, 'hello project' => 1});
_compare_tags ($c, 'Artist', '472bc127-8861-45e8-bc9e-31e8dd32de7a',
               {'dubstep' => 1, 'uk' => 1});
_compare_tags ($c, 'Recording', '162630d9-36d2-4a8d-ade1-1c77440b34e7',
               {'country schlager thrash gabber' => 1});

$mech->get_ok('/ws/2/tag?id=802673f0-9b88-4e8a-bb5c-dd01d68b086f&entity=artist');
&$v2 ($mech->content, 'Validate user tag lookup for artist');

$mech->content_contains('hello project');
$mech->content_contains('jpop');

# Test vote attributes
$content = '<?xml version="1.0" encoding="UTF-8"?>
<metadata xmlns="http://musicbrainz.org/ns/mmd-2.0#">
    <artist-list>
        <artist id="802673f0-9b88-4e8a-bb5c-dd01d68b086f">
            <user-tag-list>
                <user-tag vote="upvote"><name>h!p</name></user-tag>
                <user-tag vote="downvote"><name>asdfjkl;</name></user-tag>
                <user-tag vote="withdraw"><name>hello project</name></user-tag>
            </user-tag-list>
        </artist>
    </artist-list>
</metadata>';

$mech->request(xml_post('/ws/2/tag?client=post.t-0.0.2', $content));
xml_ok ($mech->content);

$xp = XML::XPath->new(xml => $mech->content);
is($xp->find('//message/text')->string_value, 'OK', 'POST request got "OK" response');

_compare_tags($c, 'Artist', '802673f0-9b88-4e8a-bb5c-dd01d68b086f', {'h!p' => 1, 'jpop' => 1, 'asdfjkl;' => -1});

$mech->get_ok('/ws/2/tag?id=802673f0-9b88-4e8a-bb5c-dd01d68b086f&entity=artist');
&$v2($mech->content, 'Validate user tag lookup for artist');

$mech->content_contains('h!p');
$mech->content_contains('jpop');

$mech->request(xml_post('/ws/2/tag?client=post.t-0.0.2', 'garbage'));
xml_ok ($mech->content);

$xp = XML::XPath->new(xml => $mech->content);
is($xp->find('//error/text')->string_value, 'Invalid XML.', 'POST request got "Invalid XML." response');

$content = '<?xml version="1.0" encoding="UTF-8"?>
<metadata xmlns="http://musicbrainz.org/ns/mmd-2.0#">
    <artist-list>
        <artist id="802673f0-9b88-4e8a-bb5c-dd01d68b086f">
            <user-rating>80</user-rating>
        </artist>
    </artist-list>
    <recording-list>
        <recording id="162630d9-36d2-4a8d-ade1-1c77440b34e7">
            <user-rating>40</user-rating>
        </recording>
    </recording-list>
</metadata>';

$mech->request(xml_post('/ws/2/rating?client=post.t-0.0.2', $content));
xml_ok ($mech->content);

$xp = XML::XPath->new( xml => $mech->content );
is ($xp->find('//message/text')->string_value, 'OK', 'POST request got "OK" response');

$mech->get_ok('/ws/2/rating?id=802673f0-9b88-4e8a-bb5c-dd01d68b086f&entity=artist');
&$v2 ($mech->content, 'Validate user rating lookup for artist');

my $expected = '<?xml version="1.0" encoding="UTF-8"?>
<metadata xmlns="http://musicbrainz.org/ns/mmd-2.0#">
    <user-rating>80</user-rating>
</metadata>';

my $diff = XML::SemanticDiff->new;
is($diff->compare($expected, $expected), 0, 'result ok');

};

sub _compare_tags
{
    my ($c, $model, $gid, $expected, $desc) = @_;

    my $tag_names = join q(, ), sort keys %$expected;
    $desc = "$model has tags ($tag_names)";

    my $entity = $c->model($model)->get_by_gid($gid);
    my @user_tags = $c->model($model)->tags->find_user_tags(1, $entity->id);

    my %tags = map { $_->tag->name => ($_->is_upvote ? 1 : -1) } grep { $_->tag } @user_tags;
    is_deeply(\%tags, $expected, $desc);
}

test 'OAuth bearer' => sub {
    my $test = shift;
    my $c = $test->c;
    my $mech = $test->mech;

    MusicBrainz::Server::Test->prepare_test_database($c, '+webservice');
    MusicBrainz::Server::Test->prepare_test_database($c, '+oauth');

    $mech->get('/ws/2/rating?id=802673f0-9b88-4e8a-bb5c-dd01d68b086f&entity=artist');
    is($mech->status, HTTP_UNAUTHORIZED, 'Rejected without authentication');

    $mech->get('/ws/2/rating?id=802673f0-9b88-4e8a-bb5c-dd01d68b086f&entity=artist&access_token=7Fjfp0ZBr1KtDRbnfVdmIw');
    is($mech->status, HTTP_UNAUTHORIZED, 'Rejected with insufficent scope of the authentication');

    $mech->get_ok('/ws/2/rating?id=802673f0-9b88-4e8a-bb5c-dd01d68b086f&entity=artist&access_token=Nlaa7v15QHm9g8rUOmT3dQ');

    $mech->delete_header('Authorization');
    $mech->add_header('Authorization', 'Bearer 7Fjfp0ZBr1KtDRbnfVdmIw');
    $mech->get('/ws/2/rating?id=802673f0-9b88-4e8a-bb5c-dd01d68b086f&entity=artist');
    is($mech->status, HTTP_UNAUTHORIZED, 'Rejected with insufficent scope of the authentication');

    $mech->delete_header('Authorization');
    $mech->add_header('Authorization', 'Bearer Nlaa7v15QHm9g8rUOmT3dQ');
    $mech->get_ok('/ws/2/rating?id=802673f0-9b88-4e8a-bb5c-dd01d68b086f&entity=artist');
};

test 'Authorization header must be correctly encoded' => sub {
    my $test = shift;
    my $c = $test->c;
    my $mech = $test->mech;

    MusicBrainz::Server::Test->prepare_test_database($c, '+webservice');

    # This is not valid UTF-8, so it should immediately 400 without even trying
    # to parse this header.
    $mech->delete_header('Authorization');
    $mech->add_header('Authorization', pack('H*', 'df27'));

    $mech->get('/ws/2/rating?id=802673f0-9b88-4e8a-bb5c-dd01d68b086f&entity=artist');
    is($mech->status, HTTP_BAD_REQUEST);
};

test 'Same tag can be submitted to multiple entities (MBS-8470)' => sub {
    my $test = shift;
    my $c = $test->c;
    my $mech = $test->mech;

    MusicBrainz::Server::Test->prepare_test_database($c, '+webservice');
    MusicBrainz::Server::Test->prepare_test_database($c, <<~'SQL');
        SELECT setval('tag_id_seq', (SELECT MAX(id) FROM tag));
        INSERT INTO editor (id, name, password, ha1)
            VALUES (1, 'new_editor', '{CLEARTEXT}password', 'e1dd8fee8ee728b0ddc8027d3a3db478')
        SQL

    my $content = <<'EOXML';
<?xml version="1.0" encoding="UTF-8"?>
<metadata xmlns="http://musicbrainz.org/ns/mmd-2.0#">
    <recording-list>
        <recording id="cbd9e885-b160-4c3c-9b87-468914839d45">
            <user-tag-list>
                <user-tag><name>foo-tag</name></user-tag>
            </user-tag-list>
        </recording>
        <recording id="18c16c80-421d-476f-893c-0b02f964bd86">
            <user-tag-list>
                <user-tag><name>foo-tag</name></user-tag>
            </user-tag-list>
        </recording>
    </recording-list>
</metadata>
EOXML

    $mech->default_header('Accept' => 'application/xml');
    $mech->credentials('localhost:80', 'musicbrainz.org', 'new_editor', 'password');
    $mech->request(xml_post('/ws/2/tag?client=post.t-0.0.2', $content));

    _compare_tags($c, 'Recording', 'cbd9e885-b160-4c3c-9b87-468914839d45', { 'foo-tag' => 1 });
    _compare_tags($c, 'Recording', '18c16c80-421d-476f-893c-0b02f964bd86', { 'foo-tag' => 1 });
};

test 'Tags are lowercased and trimmed by the server (MBS-8462)' => sub {
    my $test = shift;
    my $c = $test->c;
    my $mech = $test->mech;

    MusicBrainz::Server::Test->prepare_test_database($c, '+edit_recording');
    MusicBrainz::Server::Test->prepare_test_database($c, <<~'SQL');
        SELECT setval('tag_id_seq', (SELECT MAX(id) FROM tag));
        INSERT INTO editor (id, name, password, ha1)
            VALUES (1, 'new_editor', '{CLEARTEXT}password', 'e1dd8fee8ee728b0ddc8027d3a3db478')
        SQL

    my $content = <<'EOXML';
<?xml version="1.0" encoding="UTF-8"?>
<metadata xmlns="http://musicbrainz.org/ns/mmd-2.0#">
    <recording-list>
        <recording id="581556f0-755f-11de-8a39-0800200c9a66">
            <user-tag-list>
                <user-tag><name> OMG </name></user-tag>
            </user-tag-list>
        </recording>
    </recording-list>
</metadata>
EOXML

    $mech->default_header('Accept' => 'application/xml');
    $mech->credentials('localhost:80', 'musicbrainz.org', 'new_editor', 'password');
    $mech->request(xml_post('/ws/2/tag?client=post.t-0.0.2', $content));

    _compare_tags($c, 'Recording', '581556f0-755f-11de-8a39-0800200c9a66', { 'omg' => 1 });
};

test 'Empty tag names are disallowed' => sub {
    my $test = shift;
    my $c = $test->c;
    my $mech = $test->mech;

    MusicBrainz::Server::Test->prepare_test_database($c, '+edit_recording');
    MusicBrainz::Server::Test->prepare_test_database($c, <<~'SQL');
        SELECT setval('tag_id_seq', (SELECT MAX(id) FROM tag));
        INSERT INTO editor (id, name, password, ha1)
            VALUES (1, 'new_editor', '{CLEARTEXT}password', 'e1dd8fee8ee728b0ddc8027d3a3db478')
        SQL

    my $content = <<~'EOXML';
        <?xml version="1.0" encoding="UTF-8"?>
        <metadata xmlns="http://musicbrainz.org/ns/mmd-2.0#">
            <recording-list>
                <recording id="581556f0-755f-11de-8a39-0800200c9a66">
                    <user-tag-list>
                        <user-tag><name>TAG_NAME</name></user-tag>
                    </user-tag-list>
                </recording>
            </recording-list>
        </metadata>
        EOXML

    my $error_message = <<~'EOXML';
        <?xml version="1.0"?>
        <error>
            <text>The tag name cannot be empty.</text>
            <text>For usage, please see: https://musicbrainz.org/development/mmd</text>
        </error>
        EOXML

    $mech->default_header('Accept' => 'application/xml');
    $mech->credentials('localhost:80', 'musicbrainz.org', 'new_editor', 'password');

    $mech->request(xml_post('/ws/2/tag?client=post.t-0.0.2', $content =~ s/TAG_NAME//r));
    is($mech->status, HTTP_BAD_REQUEST);
    is_xml_same($mech->content, $error_message);

    $mech->request(xml_post('/ws/2/tag?client=post.t-0.0.2', $content =~ s/TAG_NAME/ /r));
    is($mech->status, HTTP_BAD_REQUEST);
    is_xml_same($mech->content, $error_message);
};

1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2011 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
