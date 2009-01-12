package MusicBrainz::Server::Controller::Browse;

use strict;
use warnings;

use base 'MusicBrainz::Server::Controller';

use Data::Page;

sub browse : Path('')
{
    my ($self, $c, $type, $index) = @_;
    
    my $page = $c->req->query_params->{page} || 1;
    
    # Set up paging
    my $pager = Data::Page->new;
    $pager->entries_per_page(50);
    $pager->current_page($page);
    
    # Query for matching entities
    $index = uc $index;
    my ($count, $entities) = $c->model(ucfirst $type)->get_browse_selection($index, ($page - 1) * $pager->entries_per_page);

    $pager->total_entries($count);

    $c->stash->{count}    = $count;
    $c->stash->{entities} = $entities;
    $c->stash->{pager}    = $pager;
    $c->stash->{index}    = $index;
    $c->stash->{type}     = $type;
}

1;