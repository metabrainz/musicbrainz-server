package MusicBrainz::Server::Controller::Browse;

use strict;
use warnings;

use base 'MusicBrainz::Server::Controller';

sub browse : Path('') Local
{
	my ($self, $c, $type, $index) = @_;
	
	$index = uc $index;
	my $page   = $c->req->query_params->{page}   || 0;
	my $offset = $c->req->query_params->{offset} || 0;
	
	# handle offset argument
	my $max_items = 50;
	
	if ($page > 0)
	{
		$offset = ($page-1) * $max_items;
	}
	
	$offset = $offset < 0 ? 0 : $offset;
	
	my ($count, $artists) = $c->model($type | ucfirst)->get_browse_selection($index, $offset);

	$c->stash->{count}   = $count;
	$c->stash->{artists} = $artists;
	$c->stash->{index}   = $index;
	$c->stash->{type}    = $type;
}

1;