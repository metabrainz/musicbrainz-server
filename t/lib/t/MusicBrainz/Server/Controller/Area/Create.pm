package t::MusicBrainz::Server::Controller::Area::Create;

use Test::Routine;
use Test::More;
use MusicBrainz::Server::Test qw( capture_edits );

with 't::Mechanize', 't::Context';

=head2 Test description

This test checks whether non-ended areas can be added (which used to ISE, see
MBS-8661) and, by extension, whether basic area adding works.

=cut

test 'MBS-8661: Adding non-ended areas' => sub {
    my $test = shift;
    my $mech = $test->mech;
    my $c = $test->c;

    MusicBrainz::Server::Test->prepare_test_database($c, '+mbs-8661');

    $mech->get_ok('/login');
    $mech->submit_form(with_fields => { username => 'area_editor', password => 'pass' });
    $mech->get_ok('/area/create');
    my @edits = capture_edits {
        $mech->submit_form_ok({
            with_fields => { 'edit-area.name' => 'New Area' },
        },
        'The form returned a 2xx response code')
    } $c;

    is(@edits, 1, 'The edit was entered');

    my $edit = shift(@edits);

    isa_ok($edit, 'MusicBrainz::Server::Edit::Area::Create');

    is_deeply(
        $edit->data,
        {
            begin_date => { year => undef, month => undef, day => undef },
            comment => '',
            end_date => { day => undef, month => undef, year => undef },
            ended => 0,
            iso_3166_1 => [],
            iso_3166_2 => [],
            iso_3166_3 => [],
            name => 'New Area',
            type_id => undef,
        },
        'The edit contains the right data',
    );
};

1;
