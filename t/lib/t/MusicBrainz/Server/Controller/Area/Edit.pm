package t::MusicBrainz::Server::Controller::Area::Edit;

use Test::Routine;
use Test::More;
use MusicBrainz::Server::Test qw( capture_edits );

with 't::Mechanize', 't::Context';

=head2 Test description

This test checks whether non-ended areas can be edited (which used to ISE, see
MBS-8661) and, by extension, whether basic area editing works.

=cut

test 'MBS-8661: Editing non-ended areas' => sub {
    my $test = shift;
    my $mech = $test->mech;
    my $c = $test->c;

    MusicBrainz::Server::Test->prepare_test_database($c, '+mbs-8661');

    $mech->get_ok('/login');
    $mech->submit_form(with_fields => { username => 'area_editor', password => 'pass' });
    $mech->get_ok('/area/29a709d8-0320-493e-8d0c-f2c386662b7f/edit');
    my @edits = capture_edits {
        $mech->submit_form_ok({
            with_fields => { 'edit-area.name' => 'wild onion' },
        },
        'The form returned a 2xx response code')
    } $c;

    is(@edits, 1, 'The edit was entered');

    my $edit = shift(@edits);

    isa_ok($edit, 'MusicBrainz::Server::Edit::Area::Edit');

    is_deeply(
        $edit->data,
        {
            entity => {
                gid => '29a709d8-0320-493e-8d0c-f2c386662b7f',
                id => 5099,
                name => 'Chicago'
            },
            new => { name => 'wild onion' },
            old => { name => 'Chicago' },
        },
        'The edit contains the right data',
    );
};

1;
