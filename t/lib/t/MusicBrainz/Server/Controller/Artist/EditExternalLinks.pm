package t::MusicBrainz::Server::Controller::Artist::EditExternalLinks;

use utf8;

use Test::Deep qw( cmp_deeply ignore );
use Test::Routine;
use Test::More;
use MusicBrainz::Server::Test qw( capture_edits );

with 't::Mechanize', 't::Context';

=head2 Test description

This test checks whether external links are correctly added, removed and
modified when editing artists, and whether editing other parts of the artist
data does not enter link edits.

=cut

test 'Test editing external links for an artist' => sub {

    my $test = shift;
    my $mech = $test->mech;

    prepare_test($test);

    my @edits = capture_edits {
        $mech->post_ok(
            '/artist/acd58926-4243-40bb-a2e5-c7464b3ce577/edit', {
                'edit-artist.name' => 'Faye Wong',
                'edit-artist.sort_name' => 'Faye Wong',
                'edit-artist.url.0.relationship_id' => '1',
                'edit-artist.url.0.link_type_id' => '179',
                'edit-artist.url.0.text' => 'http://musicbrainz.org/',
                'edit-artist.url.1.link_type_id' => '179',
                'edit-artist.url.1.text' => 'http://microsoft.com',
                'edit-artist.url.2.relationship_id' => '2',
                'edit-artist.url.2.link_type_id' => '283',
                'edit-artist.url.2.removed' => '1',
                'edit-artist.make_votable' => '1'
            });
    } $test->c;

    is(@edits, 3, 'Three edits were entered');

    isa_ok(
        $edits[0],
        'MusicBrainz::Server::Edit::Relationship::Edit',
        'The first edit',
    );
    isa_ok(
        $edits[1],
        'MusicBrainz::Server::Edit::Relationship::Create',
        'The second edit',
    );
    isa_ok(
        $edits[2],
        'MusicBrainz::Server::Edit::Relationship::Delete',
        'The third edit',
    );

    cmp_deeply($edits[0]->data, {
        'type1' => 'url',
        'link' => {
            'link_type' => {
                'long_link_phrase' => 'has a Wikipedia page at',
                'link_phrase' => 'Wikipedia',
                'name' => 'wikipedia',
                'id' => 179,
                'reverse_link_phrase' => 'Wikipedia page for'
            },
            'ended' => '0',
            'entity1' => {
                'name' => 'http://zh-yue.wikipedia.org/wiki/%E7%8E%8B%E8%8F%B2',
                'id' => 3,
                'gid' => '25d6b63a-12dc-41c9-858a-2f42ae610a7d'
            },
            'end_date' => {
                'month' => undef,
                'day' => undef,
                'year' => undef
            },
            'entity0' => {
                'name' => 'Faye Wong',
                'id' => 100,
                'gid' => 'acd58926-4243-40bb-a2e5-c7464b3ce577'
            },
            'begin_date' => {
                'month' => undef,
                'day' => undef,
                'year' => undef
            },
            'attributes' => [],
        },
        'relationship_id' => 1,
        'type0' => 'artist',
        'new' => {
            'entity1' => {
                'name' => 'http://musicbrainz.org/',
                'id' => 1,
                'gid' => '9201840b-d810-4e0f-bb75-c791205f5b24'
            }
        },
        'old' => {
            'entity1' => {
                'name' => 'http://zh-yue.wikipedia.org/wiki/%E7%8E%8B%E8%8F%B2',
                'id' => 3,
                'gid' => '25d6b63a-12dc-41c9-858a-2f42ae610a7d'
            }
        },
        'entity0_credit' => '',
        'entity1_credit' => '',
        'edit_version' => 2,
    }, 'The first edit contains the right data');

    cmp_deeply($edits[1]->data, {
        'link_type' => {
            'long_link_phrase' => 'has a Wikipedia page at',
            'link_phrase' => 'Wikipedia',
            'name' => 'wikipedia',
            'id' => 179,
            'reverse_link_phrase' => 'Wikipedia page for'
        },
        'type1' => 'url',
        'entity1' => {
            'name' => 'http://microsoft.com/',
            'id' => 6,
            'gid' => ignore()
        },
        'ended' => 0,
        'entity0' => {
            'name' => 'Faye Wong',
            'id' => 100,
            'gid' => 'acd58926-4243-40bb-a2e5-c7464b3ce577'
        },
        'type0' => 'artist',
        'edit_version' => 2,
    }, 'The second edit contains the right data');

    cmp_deeply($edits[2]->data, {
        'relationship' => {
            'link' => {
                'end_date' => {
                    'month' => undef,
                    'day' => undef,
                    'year' => undef
                },
                'begin_date' => {
                    'month' => undef,
                    'day' => undef,
                    'year' => undef
                },
                ended => 0,
                'type' => {
                    'entity0_type' => 'artist',
                    'long_link_phrase' => 'has an Allmusic page at',
                    'entity1_type' => 'url',
                    'id' => 283
                },
                'attributes' => [],
            },
            'entity1' => {
                'name' => 'https://www.allmusic.com/artist/faye-wong-mn0000515659',
                'id' => 4,
                'gid' => '7bd45cc7-6189-4712-35e1-cdf3632cf1a9'
            },
            'entity0' => {
                'name' => 'Faye Wong',
                'id' => 100,
                'gid' => 'acd58926-4243-40bb-a2e5-c7464b3ce577'
            },
            'id' => 2
        },
        'edit_version' => 2,
    }, 'The third edit contains the right data');
};

test 'MBS-7282: Test editing artist does not create link edits' => sub {
    my $test = shift;
    my $mech = $test->mech;

    prepare_test($test);

    my @edits = capture_edits {
        $mech->post_ok(
            '/artist/acd58926-4243-40bb-a2e5-c7464b3ce577/edit', {
                'edit-artist.name' => 'Faye Wong!!!',
                'edit-artist.sort_name' => 'Faye Wong!!!',
                'edit-artist.url.0.relationship_id' => '1',
                'edit-artist.url.0.link_type_id' => '283',
                'edit-artist.url.0.text' => 'https://www.allmusic.com/artist/faye-wong-mn0000515659',
                'edit-artist.make_votable' => '1',
            });
    } $test->c;

    is(scalar @edits, 1, 'Only one edit is entered');

    isa_ok(
        $edits[0],
        'MusicBrainz::Server::Edit::Artist::Edit',
        'The only entered edit',
    );
};

test 'MBS-8322: Check URL relationship dates are not removed if not specified' => sub {
    my $test = shift;
    my ($c, $mech) = ($test->c, $test->mech);

    MusicBrainz::Server::Test->prepare_test_database($c);

    $mech->get_ok('/login');
    $mech->submit_form( with_fields => { username => 'new_editor', password => 'password' } );

    my @edits = capture_edits {
        $mech->post_ok('/artist/e2a083a9-9942-4d6e-b4d2-8397320b95f7/edit', {
            'edit-artist.name' => 'Test Alias',
            'edit-artist.sort_name' => 'Kate Bush',
            'edit-artist.url.0.relationship_id' => '1',
            'edit-artist.url.0.link_type_id' => '183',
            'edit-artist.url.0.text' => 'http://musicbrainz.org/',
        });
    } $c;

    is(@edits, 0, 'No edits were entered');
};

sub prepare_test {
    my $test = shift;

    MusicBrainz::Server::Test->prepare_test_database($test->c, '+edit');
    MusicBrainz::Server::Test->prepare_test_database($test->c, '+url');

    $test->mech->get('/login');
    $test->mech->submit_form(
        with_fields => { username => 'new_editor', password => 'password' }
    );
}

1;
