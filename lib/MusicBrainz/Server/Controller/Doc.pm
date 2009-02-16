package MusicBrainz::Server::Controller::Doc;

use strict;
use warnings;

use base 'MusicBrainz::Server::Controller';

sub load : Chained('/') PathPart('doc') CaptureArgs(1)
{
    my ($self, $c, $page_id) = @_;
    $c->stash->{page} = $c->model('Documentation')->fetch_page($page_id);
}

sub show : Chained('load') PathPart('')
{
    my ($self, $c) = @_;

    my $page = $c->stash->{page};
    $c->stash->{template} = $page->{success} ? 'doc/page.tt'
                          : 'doc/error.tt';
}

sub bare : Chained('load') PathPart
{
    my ($self, $c) = @_;

    my $page = $c->stash->{page};
    $c->stash->{template} = $page->{success} ? 'doc/bare.tt'
                          : 'doc/bare_error.tt';
}

1;
