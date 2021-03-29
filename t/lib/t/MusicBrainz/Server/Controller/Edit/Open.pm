package t::MusicBrainz::Server::Controller::Edit::Open;
use Test::Routine;
use Test::More;

use MusicBrainz::Server::EditRegistry;
use MusicBrainz::Server::Test qw( accept_edit html_ok );

my $mock_edit_class = 1000 + int(rand(1000));

{
    package t::Controller::Edit::Open::FakeEdit;
    use Moose;
    extends 'MusicBrainz::Server::Edit';
    sub edit_type { $mock_edit_class }
    sub edit_name { 'Remove label alias' } # Just so it grabs an edit template
    sub edit_kind { 'other' }
    sub edit_category { 'Utterly Fake' }
    sub edit_template_react { 'historic/RemoveLabelAlias' }
    sub initialize {
        my $self = shift;
        $self->data({ fake => 'data' });
    }
};

MusicBrainz::Server::EditRegistry->register_type("t::Controller::Edit::Open::$_")
    for qw( FakeEdit );

around run_test => sub {
    my ($orig, $test, @args) = @_;
    $test->clear_edit;
    $test->edit;
    $test->mech->get('/login');
    $test->mech->submit_form( with_fields => { username => 'editor', password => 'pass' } );
    $test->$orig(@args);
};

with 't::Edit', 't::Mechanize', 't::Context';

test '/edit/open shows open edits' => sub {
    my $test = shift;
    $test->mech->get_ok('/edit/open', 'fetch open edits');
    html_ok($test->mech->content);
    $test->mech->content_contains('/edit/' . $test->edit->id);
};

test '/edit/open does not show accepted edits' => sub {
    my $test = shift;
    accept_edit($test->c, $test->edit);

    $test->mech->get_ok('/edit/open', 'fetch open edits');
    html_ok($test->mech->content);
    $test->mech->content_lacks('/edit/' . $test->edit->id);
};

has edit => (
    is => 'ro',
    clearer => 'clear_edit',
    lazy => 1,
    default => sub {
        shift->c->model('Edit')->create(
            editor_id => 200,
            edit_type => $mock_edit_class
        );
    }
);

1;
