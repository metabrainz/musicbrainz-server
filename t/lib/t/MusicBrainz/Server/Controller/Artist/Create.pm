package t::MusicBrainz::Server::Controller::Artist::Create;
use utf8;
use Test::Routine;
use Test::More;
use MusicBrainz::Server::Test qw( capture_edits html_ok );

with 't::Mechanize', 't::Context';

use aliased 'MusicBrainz::Server::Entity::PartialDate';

=head2 Test description

This test checks that the artist create form works properly with both complete
and minimal data, plus some edge cases.

=cut

my $artist_page_regexp = qr{/artist/([a-f0-9]{8}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{12})};

test 'Test creating artist with most fields' => sub {
    my $test = shift;
    my $mech = $test->mech;

    prepare_test($test);

    $mech->get_ok('/artist/create');
    html_ok($mech->content);

    my @edits = capture_edits {
        $mech->submit_form_ok({
            with_fields => {
                'edit-artist.name' => 'controller artist',
                'edit-artist.sort_name' => 'artist, controller',
                'edit-artist.type_id' => 1,
                'edit-artist.area_id' => 222,
                'edit-artist.gender_id' => 2,
                'edit-artist.period.begin_date.year' => 1990,
                'edit-artist.period.begin_date.month' => 1,
                'edit-artist.period.begin_date.day' => 2,
                'edit-artist.begin_area_id' => 222,
                'edit-artist.period.end_date.year' => 2003,
                'edit-artist.period.end_date.month' => 4,
                'edit-artist.period.end_date.day' => 15,
                'edit-artist.end_area_id' => 222,
                'edit-artist.comment' => 'artist created in controller_artist.t',
            },
        },
        'The form returned a 2xx response code')
    } $test->c;

    ok(
        $mech->uri =~ $artist_page_regexp,
        'The user is redirected to the artist page after entering the edit',
    );

    is(@edits, 1, 'The edit was entered');

    my $edit = shift(@edits);

    isa_ok($edit, 'MusicBrainz::Server::Edit::Artist::Create');
    is_deeply(
        $edit->data,
        {
            name => 'controller artist',
            sort_name => 'artist, controller',
            type_id => 1,
            area_id => 222,
            gender_id => 2,
            comment => 'artist created in controller_artist.t',
            begin_date => {
                year => 1990,
                month => 1,
                day => 2
            },
            begin_area_id => 222,
            end_date => {
                year => 2003,
                month => 4,
                day => 15
            },
            end_area_id => 222,
            ended => 1,
            ipi_codes => [],
            isni_codes => [],
        },
        'The edit contains the right data',
    );


    # Test display of edit data
    $mech->get_ok('/edit/' . $edit->id, 'Fetched the edit page');
    html_ok($mech->content);
    $mech->content_contains(
        'controller artist',
        'The edit page contains the artist name',
    );
    $mech->content_contains(
        'artist, controller',
        'The edit page contains the artist sort name',
    );
    $mech->content_contains(
        'Person',
        'The edit page contains the artist type',
    );
    $mech->content_contains(
        'United States',
        'The edit page contains the area',
    );
    $mech->content_contains(
        'Female',
        'The edit page contains the artist gender',
    );
    $mech->content_contains(
        'artist created in controller_artist.t',
        'The edit page contains the disambiguation',
    );
    $mech->content_contains(
        '1990-01-02',
        'The edit page contains the artist begin date',
    );
    $mech->content_contains(
        '2003-04-15',
        'The edit page contains the artist end date',
    );
};

test 'Test creating artists with only the minimal amount of fields' => sub {
    my $test = shift;
    my $mech = $test->mech;

    prepare_test($test);

    $mech->get_ok('/artist/create');
    html_ok($mech->content);

    my @edits = capture_edits {
        $mech->submit_form_ok({
            with_fields => {
                'edit-artist.name' => 'Alice Artist',
                'edit-artist.sort_name' => 'Artist, Alice',
            },
        },
        'The form returned a 2xx response code')
    } $test->c;

    ok(
        $mech->uri =~ $artist_page_regexp,
        'The user is redirected to the artist page after entering the edit',
    );

    is(@edits, 1, 'The edit was entered');

    my $edit = shift(@edits);

    isa_ok($edit, 'MusicBrainz::Server::Edit::Artist::Create');

    is(
        $edit->data->{name},
        'Alice Artist',
        'The edit data contains the right name',
    );
    is(
        $edit->data->{sort_name},
        'Artist, Alice',
        'The edit data contains the right sort name',
    );
    is($edit->data->{type_id}, undef, 'The edit data has no type ID');
    is($edit->data->{area_id}, undef, 'The edit data has no area');
    is(
        $edit->data->{begin_area_id},
        undef,
        'The edit data has no begin area',
    );
    is($edit->data->{end_area_id}, undef, 'The edit data has no end area');
    is($edit->data->{gender_id}, undef, 'The edit data has no gender');
    is(
        $edit->data->{comment},
        '',
        'The edit data has an empty disambiguation',
    );
    ok(
        PartialDate->new($edit->data->{begin_date})->is_empty,
        'The edit data has an empty begin date'
    );
    ok(
        PartialDate->new($edit->data->{end_date})->is_empty,
        'The edit data has an empty end date'
    );

    # Test display of edit data
    $mech->get_ok('/edit/' . $edit->id, 'Fetched the edit page');
    html_ok($mech->content);
    $mech->content_contains(
        'Alice Artist',
        'The edit page contains the artist name',
    );
    $mech->content_contains(
        'Artist, Alice',
        'The edit page contains the artist sort name',
    );
};

test 'MBS-10976: No ISE if only invalid characters are submitted' => sub {
    my $test = shift;
    my $mech = $test->mech;

    prepare_test($test);

    $mech->get_ok('/artist/create');

    my $invalid = "\x{200B}\x{00AD}\x{FEFF}";

    my @edits = capture_edits {
        $mech->submit_form_ok({
            with_fields => {
                'edit-artist.name' => $invalid,
                'edit-artist.sort_name' => $invalid,
            },
        },
        'The form returned a 2xx response code')
    } $test->c;

    ok(
        $mech->uri =~ qr{/artist/create$},
        'The add artist page is shown again',
    );

    is(@edits, 0, 'No edit was entered');

    $mech->content_contains(
        'The characters you’ve entered are invalid or not allowed.',
        'contains error for invalid characters',
    );
};

test 'MBS-10976: Private use characters U+E000..U+F8FF are allowed' => sub {
    my $test = shift;
    my $mech = $test->mech;

    prepare_test($test);

    $mech->get_ok('/artist/create');

    my $klingon = "\x{F8D3}\x{F8D4}\x{F8D5}";
    my $other_private_use = "\x{E000}\x{F8FF}";

    my @edits = capture_edits {
        $mech->submit_form_ok({
            with_fields => {
                'edit-artist.name' => $klingon,
                'edit-artist.sort_name' => $other_private_use,
            },
        },
        'The form returned a 2xx response code')
    } $test->c;

    ok(
        $mech->uri =~ $artist_page_regexp,
        'The user is redirected to the artist page after entering the edit',
    );

    is(@edits, 1, 'The edit was entered');

    my $edit = shift(@edits);

    is(
        $edit->data->{name},
        $klingon,
        'The edit data contains the right name',
    );
    is(
        $edit->data->{sort_name},
        $other_private_use,
        'The edit data contains the right sort name',
    );
};

sub prepare_test {
    my $test = shift;

    MusicBrainz::Server::Test->prepare_test_database(
        $test->c,
        '+controller_artist',
    );

    $test->mech->get('/login');
    $test->mech->submit_form(
        with_fields => { username => 'new_editor', password => 'password' }
    );
}

1;
