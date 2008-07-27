package MusicBrainz::Server::Model::Feeds;

use strict;
use warnings;

use base 'Catalyst::Model::XML::Feed';

sub get_cached
{
    my ($self, $feed_id, $uri) = @_;

    # Check cache first
    my $feed = MusicBrainz::Server::Cache->get("feed-id-${feed_id}");
    if ($feed)
    {
        return $feed;
    }
    else
    {
        $self->Catalyst::Model::XML::Feed::register($feed_id, $uri);
        $feed = $self->Catalyst::Model::XML::Feed::get($feed_id);

        MusicBrainz::Server::Cache->set("feed-id-${feed_id}", $feed);

        return $feed;
    }
}

1;
