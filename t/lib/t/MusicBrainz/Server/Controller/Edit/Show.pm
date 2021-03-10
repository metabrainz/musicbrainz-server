package t::MusicBrainz::Server::Controller::Edit::Show;
use Test::Routine;
use Test::More;

use MusicBrainz::Server::EditRegistry;
use MusicBrainz::Server::Test qw( accept_edit html_ok );

my $mock_edit_class = 1000 + int(rand(1000));
my $hard_mock_edit_class = $mock_edit_class + 1;

{
    package t::Controller::Edit::Show::MockEdit;
    use Moose;
    extends 'MusicBrainz::Server::Edit';
    sub edit_name { 'Remove label alias' } # Just so we use an edit template
    sub edit_type { $mock_edit_class }
    sub edit_kind { 'other' }
    sub edit_category { 'Fake' }
    sub edit_template_react { 'historic/RemoveLabelAlias' }
};

{
    package t::Controller::Edit::Show::MockEdit::Hard;
    use Moose;
    extends 't::Controller::Edit::Show::MockEdit';
    sub edit_name { 'Remove label' }
    sub edit_template_react { 'RemoveEntity' };
    sub edit_type { $hard_mock_edit_class }
    sub display_data {
        return {
            entity_type => 'label',
            entity => MusicBrainz::Server::Entity::Label->new(
                name => "Testy",
                id => 1,
            )->TO_JSON,
        }
    }
    use MusicBrainz::Server::Constants qw( :expire_action );
    sub edit_conditions {
        return {
            duration      => 29,
            votes         => 50,
            expire_action => $EXPIRE_REJECT,
            auto_edit     => 0
        };
    }
};

MusicBrainz::Server::EditRegistry->register_type("t::Controller::Edit::Show::$_")
    for qw( MockEdit MockEdit::Hard );

around run_test => sub {
    my ($orig, $test, @args) = @_;

    for my $mock (qw( easy hard )) {
        $test->${\"clear_$mock"};
        $test->$mock;
    }

    $test->mech->get('/login');
    $test->mech->submit_form( with_fields => { username => 'editor', password => 'pass' } );

    $test->$orig(@args);
};

with 't::Edit', 't::Mechanize', 't::Context';

test 'Check edit conditions for default settings' => sub {
    my $test = shift;

    $test->mech->get_ok('/edit/' . $test->easy->id, 'fetch edit page');
    html_ok($test->mech->content);

    $test->mech->content_contains('Accept upon closing', 'mentions expire action');
    $test->mech->content_contains('3 unanimous votes', 'mentions vote period');

    done_testing;
};

test 'Check edit conditions for alternative settings' => sub {
    my $test = shift;

    $test->mech->get_ok('/edit/' . $test->hard->id, 'fetch edit page');
    html_ok($test->mech->content);

    $test->mech->content_contains('50 unanimous votes', 'mentions vote period');
    $test->mech->content_contains('Reject upon closing', 'mentions expire action');

    done_testing;
};

has easy => (
    lazy => 1,
    is => 'ro',
    clearer => 'clear_easy',
    default => sub {
        shift->c->model('Edit')->create(
            edit_type => $mock_edit_class,
            editor_id => 1,
            foo => 'bar',
        )
    }
);

has hard => (
    lazy => 1,
    clearer => 'clear_hard',
    is => 'ro',
    default => sub {
        shift->c->model('Edit')->create(
            edit_type => $hard_mock_edit_class,
            editor_id => 1,
            foo => 'bar',
        )
    }
);

1;
