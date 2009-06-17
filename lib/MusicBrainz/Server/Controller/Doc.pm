package MusicBrainz::Server::Controller::Doc;

use strict;
use warnings;
use DBDefs;

use base 'MusicBrainz::Server::Controller';

sub load :Path('') 
{
    my ($self, $c, @args) = @_;

    my $page_id = join '/', @args;  
    my $bare = $c->req->param('bare') || 0;
    
    my $page = $c->model('WikiDoc')->fetch_page($page_id);
    $c->stash->{page} = $page;
    $c->stash->{wiki_server} = &DBDefs::WIKITRANS_SERVER;

    if ($bare)
    {
        $c->stash->{template} = $page->success ? 'doc/bare.tt' : 'doc/bare_error.tt';
    }
    else
    {
        $c->stash->{template} = $page->success ? 'doc/page.tt' : 'doc/error.tt';
    }
}

1;
