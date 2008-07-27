package MusicBrainz::Server::Controller::Doc;

use strict;
use warnings;

use base 'Catalyst::Controller';

sub show : Path('')
{
    my ($self, $c, $page_id) = @_;

    my $page          = $c->model('Documentation')->fetch_page($page_id);
    $c->stash->{page} = $page;

    $c->stash->{template} = $page->{success} ? 'doc/page.tt'
                          :                    'doc/error.tt';
}

1;
