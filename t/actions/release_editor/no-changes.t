use utf8;
use strict;
use warnings;
use Test::More;

use FindBin qw( $Bin );

warn "bin: $Bin\n";

my $koek = eval ('{ koek => "KOEK" }');

use Data::Dumper;
warn Dumper ($koek)."\n";

ok (1, "testing ok?");
# is ($koek, "KOEK", "is a koek a koek?");

done_testing;


# use Catalyst::Test 'MusicBrainz::Server';
# use MusicBrainz::Server::Test qw( xml_ok );
# use Test::WWW::Mechanize::Catalyst;

# my $c = MusicBrainz::Server::Test->create_test_context;
# MusicBrainz::Server::Test->prepare_test_server();
# my $mech = Test::WWW::Mechanize::Catalyst->new(catalyst_app => 'MusicBrainz::Server');


# my $wizard = MusicBrainz::Server::Wizard::ReleaseEditor->new (c => $c);

# my $release = $c->model('Release')->get_by_gid ('cacc586f-c2f2-49db-8534-6f44b55196f2');

# $c->model('Release')->load_meta($release);
# $c->model('ReleaseLabel')->load($release);
# $c->model('Label')->load(@{ $release->labels });
# $c->model('ReleaseGroup')->load($release);
# $c->model('ReleaseGroupType')->load($release->release_group);
# # $c->model('MediumFormat')->load(@mediums);

# $wizard->render ($release);
# my $data = $wizard->value;

# $mech->get_ok('/login');
# $mech->submit_form( with_fields => { username => 'new_editor', password => 'password' } );

# # Test deleting aliases
# $mech->get_ok('/artist/745c079d-374e-4436-9448-da92dedef3ce/alias/1/edit');
# my $response = $mech->submit_form(
#     with_fields => {
#         'edit-alias.name' => 'Edited alias'
#     });

# my $edit = MusicBrainz::Server::Test->get_latest_edit($c);
# isa_ok($edit, 'MusicBrainz::Server::Edit::Artist::EditAlias');
# is_deeply($edit->data, {
#     entity_id => 3,
#     alias_id  => 1,
#     new => {
#         name => 'Edited alias',
#     },
#     old => {
#         name => 'Test Alias',
#     }
# });

# $mech->get_ok('/edit/' . $edit->id, 'Fetch edit page');
# xml_ok($mech->content, '..valid xml');
# $mech->content_contains('Test Artist', '..has artist name');
# $mech->content_contains('Test Alias', '..has old alias name');
# $mech->content_contains('Edited alias', '..has new alias name');

