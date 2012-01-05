package MusicBrainz::Server::Controller::JS;
use Moose;
use MusicBrainz::Server::Data::Utils qw( generate_gid );

BEGIN { extends 'Catalyst::Controller' }

sub begin : Private {}
sub end : ActionClass('RenderView') { }

sub js_text_strings : Path('/text.js') {
    my ($self, $c) = @_;
    $c->res->content_type('text/javascript');
    $c->stash->{template} = 'scripts/text_strings.tt';
}

sub js_register : Path('/register.js') {
    my ($self, $c) = @_;

    my $nonce = generate_gid;

    $c->session (nonce => $nonce);
    $c->stash (nonce => $nonce);

    $c->res->content_type('text/javascript');
    $c->stash->{template} = 'scripts/register.tt';
}

sub statistics_js_text_strings : Path('/statistics/view.js') {
    my ($self, $c) = @_;
    my %countries = map { $_->iso_code => $_ } $c->model('Country')->get_all();
    my %languages = map { $_->iso_code_3t => $_ } $c->model('Language')->get_all();
    my %scripts = map { $_->iso_code => $_ } $c->model('Script')->get_all();
    my @rel_pairs = $c->model('Relationship')->all_pairs;
    $c->stash(
        template => 'statistics/view_js.tt',
	countries => \%countries,
	languages => \%languages,
	scripts => \%scripts,
        relationships => \@rel_pairs,
    );
    $c->res->content_type('text/javascript');
}

sub js_unit_tests : Path('/unit_tests') {
    my ($self, $c) = @_;
    $c->stash->{template} = 'scripts/unit_tests.tt';
}

1;
