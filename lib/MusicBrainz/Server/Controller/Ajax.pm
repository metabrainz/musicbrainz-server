package MusicBrainz::Server::Controller::Ajax;
BEGIN { use Moose; extends 'Catalyst::Controller' };

use List::Util qw( max );

sub search : Local
{
    my ($self, $c) = @_;

    my $query = $c->req->query_params->{query};
    my $type = $c->req->query_params->{type};
    my $offset = $c->req->query_params->{offset} || 0;
    my $limit = max ($c->req->query_params->{limit} || 10), 25;

    my $json = {};
    if ($query && $type)
    {
        my ($search_results, $hits) = $c->model('DirectSearch')->search($type, $query,
                                                                        $limit, $offset);

        $json = {
            results => [ map {
                my $r = {
                    name => $_->entity->name,
                    id => $_->entity->id,
                    gid => $_->entity->gid
                };

                $r->{comment} = $_->entity->comment
                    if ($_->entity->can('comment') && $_->entity->comment);

                $r->{sort_name} = $_->entity->sort_name
                    if ($_->entity->can('sort_name') && $_->entity->sort_name);

                $r;
            } @$search_results ],
            hits => $hits
        };
    }
    else
    {
        $json = {
            results => [],
            hits => 0,
        }
    }

    $c->stash( json => $json );
    $c->detach('View::JSON');
}

1;
