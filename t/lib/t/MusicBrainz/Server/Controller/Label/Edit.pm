package t::MusicBrainz::Server::Controller::Label::Edit;
use Test::Routine;
use Test::More;
use MusicBrainz::Server::Test qw( html_ok );

with 't::Mechanize', 't::Context';

test all => sub {

my $test = shift;
my $mech = $test->mech;
my $c    = $test->c;

MusicBrainz::Server::Test->prepare_test_database($c);

$mech->get_ok('/login');
$mech->submit_form( with_fields => { username => 'new_editor', password => 'password' } );

$mech->get_ok('/label/46f0f4cd-8aab-4b33-b698-f459faf64190/edit');
html_ok($mech->content);
my $response = $mech->submit_form(
    with_fields => {
        'edit-label.name' => 'controller label',
        'edit-label.sort_name' => 'label, controller',
        'edit-label.type_id' => 2,
        'edit-label.label_code' => 12345,
        'edit-label.area_id' => 222,
        'edit-label.period.begin_date.year' => 1990,
        'edit-label.period.begin_date.month' => 01,
        'edit-label.period.begin_date.day' => 02,
        'edit-label.period.end_date.year' => 2003,
        'edit-label.period.end_date.month' => 4,
        'edit-label.period.end_date.day' => 15,
        'edit-label.comment' => 'label created in controller_label.t',
    }
);

my $edit = MusicBrainz::Server::Test->get_latest_edit($c);
isa_ok($edit, 'MusicBrainz::Server::Edit::Label::Edit');
is_deeply($edit->data, {
        entity => {
            id => 2,
            name => 'Warp Records'
        },
        new => {
            name => 'controller label',
            sort_name => 'label, controller',
            type_id => 2,
            area_id => 222,
            label_code => 12345,
            comment => 'label created in controller_label.t',
            begin_date => {
                year => 1990,
                month => 01,
                day => 02
            },
            end_date => {
                year => 2003,
                month => 4,
                day => 15
            },
        },
        old => {
            name => 'Warp Records',
            sort_name => 'Warp Records',
            type_id => 1,
            area_id => 221,
            label_code => 2070,
            comment => 'Sheffield based electronica label',
            begin_date => {
                year => 1989,
                month => 2,
                day => 3
            },
            end_date => {
                year => 2008,
                month => 05,
                day => 19
            },
        }
    });

$mech->get_ok('/edit/' . $edit->id, 'Fetch the edit page');
html_ok($mech->content, '..valid xml');
$mech->text_contains('controller label', '..has new name');
$mech->text_contains('Warp Records', '..has old name');
$mech->text_contains('label, controller', '..has new sortname');
$mech->text_contains('Warp Records', '..has old sortname');
$mech->text_contains('Special MusicBrainz Label', '..has new type');
$mech->text_contains('Production', '..has old type');
$mech->text_contains('United States', '..has new area');
$mech->text_contains('United Kingdom', '..has old area');
$mech->text_contains('12345', '..has new label code');
$mech->text_contains('2070', '..has old label code');
$mech->text_like(qr/2008\D+05\D+19/, '..has new date');
$mech->text_like(qr/1989\D+02\D+03/, '..has old date');

};

1;
