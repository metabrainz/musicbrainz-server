package MusicBrainz::Server::Controller::JS;
use Moose;
BEGIN { extends 'Catalyst::Controller' }

sub begin : Private {}
sub end : ActionClass('RenderView') { }

sub js_text_strings : Path('/text.js') {
    my ($self, $c) = @_;
    $c->res->content_type('text/javascript');
    $c->stash->{template} = 'scripts/text_strings.tt';
}

sub statistics_js_text_strings : Path('/statistics/view.js') {
    my ($self, $c) = @_;
    $c->res->content_type('text/javascript');
    $c->stash->{template} = 'statistics/view_js.tt';
}

sub js_unit_tests : Path('/unit_tests') {
    my ($self, $c) = @_;
    $c->stash->{template} = 'scripts/unit_tests.tt';
}

1;
