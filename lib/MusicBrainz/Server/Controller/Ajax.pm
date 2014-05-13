package MusicBrainz::Server::Controller::Ajax;
BEGIN { use Moose; extends 'Catalyst::Controller' };

use List::Util qw( min );
use Encode qw(decode_utf8);
use MusicBrainz::Server::Translation qw( l );
use MusicBrainz::Server::FilterUtils qw(
    create_artist_release_groups_form
    create_artist_releases_form
    create_artist_recordings_form
);

sub lookup_tracklist : Local
{
    my ($self, $c) = @_;

    my $release_name = $c->req->query_params->{release};
    my $offset = $c->req->query_params->{offset} || 0;
    my $limit = min($c->req->query_params->{limit} || 10), 100;

    if ($release_name) {
        my ($search_results, $hits) = $c->model('Search')->search('release',
            $release_name, $limit, $offset);

        my @releases = map { $_->entity } @$search_results;

        $c->model('Medium')->load_for_releases(@releases);
        my @mediums = map { $_->all_mediums } @releases;

        my @tracklists = map { $_->tracklist } @mediums;
        $c->model('Track')->load_for_tracklists(@tracklists);
        $c->model('ArtistCredit')->load(@releases, map { $_->all_tracks } @tracklists);

        $c->stash(
            releases => [ @releases ],
        );
    }
}

sub search : Local
{
    my ($self, $c) = @_;

    my $query = $c->req->query_params->{query};
    my $type = $c->req->query_params->{type};
    my $offset = $c->req->query_params->{offset} || 0;
    my $limit = min($c->req->query_params->{limit} || 10), 100;

    my $json = {};
    if ($query && $type)
    {
        my ($search_results, $hits) = $c->model('Search')->search($type, $query,
                                                                  $limit, $offset);


        $json = {
            results => [ map {
                my $dec_name = decode_utf8($_->entity->name);
                my $name_is_latin = $dec_name =~ /^[\p{Latin}\p{Common}\p{Inherited}]+$/;

                my $r = {
                    name => $_->entity->name,
                    id => $_->entity->id,
                    gid => $_->entity->gid
                };

                $r->{comment} = $_->entity->comment
                    if ($_->entity->can('comment') && $_->entity->comment);

                $r->{sort_name} = $_->entity->sort_name
                    if (!$name_is_latin && $_->entity->can('sort_name') &&
                            $_->entity->sort_name);

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

sub filter_artist_release_groups_form : Local {
    my ($self, $c) = @_;

    my $artist_id = $c->req->query_params->{artist_id};
    create_artist_release_groups_form($c, $artist_id);

    $c->stash(template => 'components/filter-form.tt');
}

sub filter_artist_releases_form : Local {
    my ($self, $c) = @_;

    my $artist_id = $c->req->query_params->{artist_id};
    create_artist_releases_form($c, $artist_id);

    $c->stash(template => 'components/filter-form.tt');
}

sub filter_artist_recordings_form : Local {
    my ($self, $c) = @_;

    my $artist_id = $c->req->query_params->{artist_id};
    create_artist_recordings_form($c, $artist_id);

    $c->stash(template => 'components/filter-form.tt');
}

1;
