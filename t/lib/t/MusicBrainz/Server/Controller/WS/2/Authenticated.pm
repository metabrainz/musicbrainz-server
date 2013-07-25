package t::MusicBrainz::Server::Controller::WS::2::Authenticated;
use Test::Routine;
use Test::More;
use MusicBrainz::Server::Test qw( html_ok );

with 't::Mechanize', 't::Context';

use utf8;
use XML::SemanticDiff;
use XML::XPath;

use MusicBrainz::Server::Test qw( xml_ok schema_validator xml_post );
use MusicBrainz::Server::Test ws_test => {
    version => 2
};

test all => sub {

my $test = shift;
my $c = $test->c;
my $v2 = schema_validator;
my $mech = $test->mech;
$mech->default_header ("Accept" => "application/xml");

MusicBrainz::Server::Test->prepare_test_database($c, '+webservice');
MusicBrainz::Server::Test->prepare_test_database($c, <<'EOSQL');
SELECT setval('tag_id_seq', (SELECT MAX(id) FROM tag));
INSERT INTO editor (id, name, password, ha1) VALUES (1, 'new_editor', '{CLEARTEXT}password', 'e1dd8fee8ee728b0ddc8027d3a3db478')
EOSQL

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

$mech->request (xml_post ('/ws/2/tag?client=post.t-0.0.2', $content));
is ($mech->status, 401, 'Tags rejected without authentication');
$mech->content_contains ('Authorization required');

$mech->credentials ('localhost:80', 'musicbrainz.org', 'new_editor', 'password');

$mech->request (xml_post ('/ws/2/tag?client=post.t-0.0.2', $content));
xml_ok ($mech->content);

my $xp = XML::XPath->new( xml => $mech->content );
is ($xp->find('//message/text')->string_value, 'OK', 'POST request got "OK" response');

_compare_tags ($c, 'Artist', '802673f0-9b88-4e8a-bb5c-dd01d68b086f',
               [ 'jpop', 'hello project' ]);
_compare_tags ($c, 'Artist', '472bc127-8861-45e8-bc9e-31e8dd32de7a',
               [ 'dubstep', 'uk' ]);
_compare_tags ($c, 'Recording', '162630d9-36d2-4a8d-ade1-1c77440b34e7',
               [ 'country schlager thrash gabber' ]);

$mech->get_ok ('/ws/2/tag?id=802673f0-9b88-4e8a-bb5c-dd01d68b086f&entity=artist');
&$v2 ($mech->content, "Validate user tag lookup for artist");

$mech->content_contains ('hello project');
$mech->content_contains ('jpop');


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

$mech->request (xml_post ('/ws/2/rating?client=post.t-0.0.2', $content));
xml_ok ($mech->content);

$xp = XML::XPath->new( xml => $mech->content );
is ($xp->find('//message/text')->string_value, 'OK', 'POST request got "OK" response');

$mech->get_ok ('/ws/2/rating?id=802673f0-9b88-4e8a-bb5c-dd01d68b086f&entity=artist');
&$v2 ($mech->content, "Validate user rating lookup for artist");

my $expected = '<?xml version="1.0" encoding="UTF-8"?>
<metadata xmlns="http://musicbrainz.org/ns/mmd-2.0#">
    <user-rating>80</user-rating>
</metadata>';

my $diff = XML::SemanticDiff->new;
is($diff->compare ($expected, $expected), 0, 'result ok');

};

sub _compare_tags
{
    my ($c, $model, $gid, $expected, $desc) = @_;

    $expected = [ sort (@$expected) ];
    $desc = "$model has tags (".join (', ', @$expected).")";

    my $entity = $c->model($model)->get_by_gid ($gid);
    my @user_tags = $c->model($model)->tags->find_user_tags(1, $entity->id);

    my @tags = sort (map { $_->tag->name } grep { $_->tag } @user_tags );

    is_deeply (\@tags, $expected, $desc);
}

test 'OAuth bearer' => sub {
    my $test = shift;
    my $c = $test->c;
    my $mech = $test->mech;

    MusicBrainz::Server::Test->prepare_test_database($c, '+webservice');
    MusicBrainz::Server::Test->prepare_test_database($c, '+oauth');

    my $token = '';

    $mech->get("/ws/2/rating?id=802673f0-9b88-4e8a-bb5c-dd01d68b086f&entity=artist");
    is($mech->status, 401, 'Rejected without authentication');

    $mech->get("/ws/2/rating?id=802673f0-9b88-4e8a-bb5c-dd01d68b086f&entity=artist&access_token=7Fjfp0ZBr1KtDRbnfVdmIw");
    is($mech->status, 401, 'Rejected with insufficent scope of the authentication');

    $mech->get_ok("/ws/2/rating?id=802673f0-9b88-4e8a-bb5c-dd01d68b086f&entity=artist&access_token=Nlaa7v15QHm9g8rUOmT3dQ");

    $mech->delete_header('Authorization');
    $mech->add_header('Authorization', 'Bearer 7Fjfp0ZBr1KtDRbnfVdmIw');
    $mech->get("/ws/2/rating?id=802673f0-9b88-4e8a-bb5c-dd01d68b086f&entity=artist");
    is($mech->status, 401, 'Rejected with insufficent scope of the authentication');

    $mech->delete_header('Authorization');
    $mech->add_header('Authorization', 'Bearer Nlaa7v15QHm9g8rUOmT3dQ');
    $mech->get_ok("/ws/2/rating?id=802673f0-9b88-4e8a-bb5c-dd01d68b086f&entity=artist");
};

test 'Authorization header must be correctly encoded' => sub {
    my $test = shift;
    my $c = $test->c;
    my $mech = $test->mech;

    MusicBrainz::Server::Test->prepare_test_database($c, '+webservice');

    # This is not valid UTF-8, so it should immediately 400 without even trying
    # to parse this header.
    $mech->delete_header('Authorization');
    $mech->add_header('Authorization', pack("H*", "df27"));

    $mech->get("/ws/2/rating?id=802673f0-9b88-4e8a-bb5c-dd01d68b086f&entity=artist");
    is($mech->status, 400);
};

1;

