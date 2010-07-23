use strict;
use warnings;

use Catalyst::Test 'MusicBrainz::Server';
use MusicBrainz::Server::Test qw( accept_edit xml_ok );
use Test::More;
use Test::WWW::Mechanize::Catalyst;

my $c = MusicBrainz::Server::Test->create_test_context;
my $mech = Test::WWW::Mechanize::Catalyst->new(catalyst_app => 'MusicBrainz::Server');

{
    package MockEdit;
    use Moose;
    extends 'MusicBrainz::Server::Edit';
    sub edit_name { 'Add artist' } # Just so we use an edit template
    sub edit_type { 5001 }
};

{
    package MockEdit::Hard;
    use Moose;
    extends 'MockEdit';
    sub edit_name { 'Remove label' } # Just so we use an edit template
    sub edit_type { 5002 }

    use MusicBrainz::Server::Constants qw( :expire_action :quality );
    sub determine_quality { $QUALITY_HIGH }
    sub edit_conditions {
        return {
            $QUALITY_HIGH => {
                duration      => 29,
                votes         => 50,
                expire_action => $EXPIRE_REJECT,
                auto_edit     => 0
            }
        };
    }
};

use MusicBrainz::Server::EditRegistry;
MusicBrainz::Server::EditRegistry->register_type($_) for qw( MockEdit MockEdit::Hard );

my $easy = $c->model('Edit')->create(
    edit_type => 5001,
    editor_id => 1,
    foo => 'bar',
);

my $hard = $c->model('Edit')->create(
    edit_type => 5002,
    editor_id => 1,
    foo => 'bar',
);

$mech->get('/login');
$mech->submit_form( with_fields => { username => 'new_editor', password => 'password' } );

subtest 'Check edit conditions for default settings' => sub {
    $mech->get_ok('/edit/' . $easy->id, 'fetch edit page');
    xml_ok($mech->content);

    $mech->content_lacks('quality level', 'mentions quality level');
    $mech->content_contains('on expiration', 'mentions expire action');
    $mech->content_contains('3 unanimous votes', 'mentions vote period');

    done_testing;
};

subtest 'Check edit conditions for alternative settings' => sub {
    $mech->get_ok('/edit/' . $hard->id, 'fetch edit page');
    xml_ok($mech->content);

    $mech->content_contains('high quality level', 'mentions quality level');
    $mech->content_contains('50 unanimous votes', 'mentions vote period');
    $mech->content_contains('Reject upon expiration', 'mentions expire action');

    done_testing;
};

done_testing;
