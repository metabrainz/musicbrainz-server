package MusicBrainz::Server::Controller::Doc;

use strict;
use warnings;

use base 'Catalyst::Controller';

sub show : Path('')
{
    my ($self, $c, $page) = @_;

    my $page          = $c->model('Documentation')->fetch_page($page);
    $c->stash->{page} = $page;

    $c->stash->{template} = $page->{success} ? 'doc/page.tt'
                          :                    'doc/error.tt';
}

1;
