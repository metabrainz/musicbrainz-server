package MusicBrainz::Server::Controller::JS;
use Moose;
use MusicBrainz::Server::Data::Utils qw( generate_gid );
use Date::Calc qw( Today Add_Delta_Days Date_to_Time );
use DBDefs;

BEGIN { extends 'Catalyst::Controller' }

sub begin : Private {}
sub end : ActionClass('RenderView') { }

sub js_text_setup : Chained('/') PathPart('scripts') CaptureArgs(2) {
    my ($self, $c, $lang_hash, $hash) = @_;
    # We rely on templates to correctly pass hash/language;
    # They're just here to ensure a different URL

    unless (DBDefs->DEVELOPMENT_SERVER) {
        # Far in the future - 1 year
        my $expiration = Date_to_Time(Add_Delta_Days(Today(1), 365), 0, 0, 0);
        $c->res->headers->expires($expiration);
    }
}

sub js_text_strings : Chained('js_text_setup') PathPart('text.js') {
    my ($self, $c) = @_;
    $c->res->content_type('text/javascript');
    $c->stash->{template} = 'scripts/text_strings.tt';
}

sub statistics_js_text_strings : Chained('js_text_setup') PathPart('statistics/view.js') {
    my ($self, $c) = @_;
    my @countries = $c->model('CountryArea')->get_all();
    $c->model('Area')->load_codes(@countries);
    my %countries = map { $_->country_code => $_ } @countries;
    my %languages = map { $_->iso_code_3 => $_ }
        grep { defined $_->iso_code_3 } $c->model('Language')->get_all();
    my %scripts = map { $_->iso_code => $_ } $c->model('Script')->get_all();
    my %formats = map { $_->id => $_ } $c->model('MediumFormat')->get_all();
    my @rel_pairs = $c->model('Relationship')->all_pairs;
    $c->stash(
        template => 'statistics/view_js.tt',
        countries => \%countries,
        languages => \%languages,
        scripts => \%scripts,
        formats => \%formats,
        relationships => \@rel_pairs,
    );
    $c->res->content_type('text/javascript');
}

sub js_unit_tests : Path('/unit_tests') {
    my ($self, $c) = @_;
    $c->stash->{template} = 'scripts/unit_tests.tt';
}

1;
