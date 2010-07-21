use utf8;
use strict;
use Test::More;
use XML::XPath;
use XML::SemanticDiff;
use Catalyst::Test 'MusicBrainz::Server';
use MusicBrainz::Server::Test qw( xml_ok v2_schema_validator );
use MusicBrainz::WWW::Mechanize;
use HTTP::Request;

my $c = MusicBrainz::Server::Test->create_test_context;
my $v2 = v2_schema_validator;
my $mech = MusicBrainz::WWW::Mechanize->new(catalyst_app => 'MusicBrainz::Server');
my $diff = XML::SemanticDiff->new;

sub _raw_post
{
    my ($url, $content) = @_;

    # $mech->post_ok seems intent on destroying the POST body by trying to
    # encode it as "application/x-www-form-urlencoded".  So create a request
    # by hand, to make sure the body is submitted verbatim.
    my $request = HTTP::Request->new (
        POST => $url,
        HTTP::Headers->new ('Content-Type' => 'application/xml; charset=UTF-8',
                            'Content-Length', length ($content)),
        );

    $request->content ($content);

    return $request;
}

sub _compare_tags
{
    my ($model, $gid, $expected, $desc) = @_;

    $expected = [ sort (@$expected) ];
    $desc = "$model has tags (".join (', ', @$expected).")";

    my $entity = $c->model($model)->get_by_gid ($gid);
    my @user_tags = $c->model($model)->tags->find_user_tags(1, $entity->id);

    my @tags = sort (map { $_->tag->name } grep { $_->tag } @user_tags );
    
    is_deeply (\@tags, $expected, $desc);
}

my $content = '<?xml version="1.0" encoding="UTF-8"?>
<metadata xmlns="http://musicbrainz.org/ns/mmd-2.0#">
    <artist-list>
        <artist id="a16d1433-ba89-4f72-a47b-a370add0bb55">
            <user-tag-list>
                <user-tag><name>kpop</name></user-tag>
                <user-tag><name>female</name></user-tag>
                <user-tag><name>korean</name></user-tag>
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
        <recording id="eb818aa4-d472-4d2b-b1a9-7fe5f1c7d26e">
            <user-tag-list>
                <user-tag><name>country schlager thrash gabber</name></user-tag>
            </user-tag-list>
        </recording>
    </recording-list>
</metadata>';

$mech->request (_raw_post ('/ws/2/tag?client=post.t-0.0.2', $content));
is ($mech->status, 401, 'Tags rejected without authentication');
$mech->content_contains ('Authorization required');

$mech->credentials ('localhost:80', 'webservice', 'new_editor', 'password');

$mech->request (_raw_post ('/ws/2/tag?client=post.t-0.0.2', $content));
xml_ok ($mech->content);

my $xp = XML::XPath->new( xml => $mech->content );
is ($xp->find('//message/text')->string_value, 'OK', 'POST request got "OK" response');

_compare_tags ('Artist', 'a16d1433-ba89-4f72-a47b-a370add0bb55',
               [ 'female', 'kpop', 'korean', 'jpop' ]);
_compare_tags ('Artist', '472bc127-8861-45e8-bc9e-31e8dd32de7a',
               [ 'dubstep', 'uk' ]);
_compare_tags ('Recording', 'eb818aa4-d472-4d2b-b1a9-7fe5f1c7d26e',
               [ 'country schlager thrash gabber' ]);


$mech->get_ok ('/ws/2/tag?id=a16d1433-ba89-4f72-a47b-a370add0bb55&entity=artist');
&$v2 ($mech->content, "Validate user tag lookup for artist");

$mech->content_contains ('female');
$mech->content_contains ('jpop');
$mech->content_contains ('kpop');
$mech->content_contains ('korean');


$content = '<?xml version="1.0" encoding="UTF-8"?>
<metadata xmlns="http://musicbrainz.org/ns/mmd-2.0#">
    <artist-list>
        <artist id="a16d1433-ba89-4f72-a47b-a370add0bb55">
            <user-rating>80</user-rating>
        </artist>
    </artist-list>
    <recording-list>
        <recording id="eb818aa4-d472-4d2b-b1a9-7fe5f1c7d26e">
            <user-rating>40</user-rating>
        </recording>
    </recording-list>
</metadata>';

$mech->request (_raw_post ('/ws/2/rating?client=post.t-0.0.2', $content));
xml_ok ($mech->content);

my $xp = XML::XPath->new( xml => $mech->content );
is ($xp->find('//message/text')->string_value, 'OK', 'POST request got "OK" response');

$mech->get_ok ('/ws/2/rating?id=a16d1433-ba89-4f72-a47b-a370add0bb55&entity=artist');
&$v2 ($mech->content, "Validate user rating lookup for artist");

my $expected = '<?xml version="1.0" encoding="UTF-8"?>
<metadata xmlns="http://musicbrainz.org/ns/mmd-2.0#">
    <user-rating>80</user-rating>
</metadata>';

is ($diff->compare ($expected, $mech->content), 0, 'result ok');

done_testing;
