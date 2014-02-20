package t::MusicBrainz::Server::Controller::Artist::EditExternalLinks;
use Test::Routine;
use Test::More;
use MusicBrainz::Server::Test qw( capture_edits html_ok );

with 't::Mechanize', 't::Context';

test all => sub {

my $test = shift;
my $mech = $test->mech;
my $c    = $test->c;

MusicBrainz::Server::Test->prepare_test_database($c, '+edit');
MusicBrainz::Server::Test->prepare_test_database($c, '+url');

$mech->get_ok('/login');
$mech->submit_form( with_fields => { username => 'new_editor', password => 'password' } );

my @edits = capture_edits {
    $mech->get_ok();

    $mech->post_ok(
        '/artist/acd58926-4243-40bb-a2e5-c7464b3ce577/edit', {
            'edit-artist.name' => 'Faye Wong',
            'edit-artist.sort_name' => 'Faye Wong',
            'edit-artist.url.0.relationship_id' => '1',
            'edit-artist.url.0.link_type_id' => '1',
            'edit-artist.url.0.text' => 'http://musicbrainz.org/',
            'edit-artist.url.1.link_type_id' => '1',
            'edit-artist.url.1.text' => 'http://microsoft.com',
            'edit-artist.url.2.relationship_id' => '2',
            'edit-artist.url.2.link_type_id' => '2',
            'edit-artist.url.2.removed' => '1',
        });
} $c;

isa_ok($edits[0], 'MusicBrainz::Server::Edit::Relationship::Edit');
isa_ok($edits[1], 'MusicBrainz::Server::Edit::Relationship::Create');
isa_ok($edits[2], 'MusicBrainz::Server::Edit::Relationship::Delete');

is_deeply($edits[0]->data, {
    'type1' => 'url',
    'link' => {
        'link_type' => {
            'long_link_phrase' => 'wikipedia',
            'link_phrase' => 'wikipedia',
            'name' => 'wikipedia',
            'id' => 1,
            'reverse_link_phrase' => 'wikipedia'
        },
        'ended' => '0',
        'entity1' => {
            'name' => 'http://zh-yue.wikipedia.org/wiki/%E7%8E%8B%E8%8F%B2',
            'id' => 3
        },
        'end_date' => {
            'month' => undef,
            'day' => undef,
            'year' => undef
        },
        'entity0' => {
            'name' => 'Faye Wong',
            'id' => 100
        },
        'begin_date' => {
            'month' => undef,
            'day' => undef,
            'year' => undef
        },
        'attributes' => []
    },
    'relationship_id' => 1,
    'type0' => 'artist',
    'new' => {
        'entity1' => {
            'name' => 'http://musicbrainz.org/',
            'id' => 1
        }
    },
    'old' => {
        'entity1' => {
            'name' => 'http://zh-yue.wikipedia.org/wiki/%E7%8E%8B%E8%8F%B2',
            'id' => 3
        }
    }
});

is_deeply($edits[1]->data, {
    'link_type' => {
        'long_link_phrase' => 'wikipedia',
        'link_phrase' => 'wikipedia',
        'name' => 'wikipedia',
        'id' => 1,
        'reverse_link_phrase' => 'wikipedia'
    },
    'type1' => 'url',
    'entity1' => {
        'name' => 'http://microsoft.com/',
        'id' => 5
    },
    'ended' => 0,
    'entity0' => {
        'name' => 'Faye Wong',
        'id' => 100
    },
    'type0' => 'artist'
});

is_deeply($edits[2]->data, {
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
        'type' => {
            'entity0_type' => 'artist',
            'long_link_phrase' => 'allmusic',
            'entity1_type' => 'url',
            'id' => 2
        },
        'attributes' => []
        },
        'entity1' => {
            'name' => 'http://www.allmusic.com/artist/faye-wong-mn0000515659',
            'id' => 4
        },
        'entity0' => {
            'name' => 'Faye Wong',
            'id' => 100
        },
        'id' => 2
    }
});


# Editing the artist name should not enter relationship edits (MBS-7282)

@edits = capture_edits {
    $mech->get_ok();

    $mech->post_ok(
        '/artist/acd58926-4243-40bb-a2e5-c7464b3ce577/edit', {
            'edit-artist.name' => 'Faye Wong!!!',
            'edit-artist.sort_name' => 'Faye Wong!!!',
            'edit-artist.url.0.relationship_id' => '1',
            'edit-artist.url.0.link_type_id' => '1',
            'edit-artist.url.0.text' => 'http://zh-yue.wikipedia.org/wiki/王菲',
            'edit-artist.as_auto_editor' => '1',
        });
} $c;

is(scalar @edits, 1, 'only one edit is entered');
isa_ok($edits[0], 'MusicBrainz::Server::Edit::Artist::Edit');

};

1;
