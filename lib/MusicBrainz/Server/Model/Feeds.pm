package MusicBrainz::Server::Model::Feeds;

use strict;
use warnings;

use URI;
use XML::Feed;
use LWP::UserAgent;

sub get_cached
{
    my ($self, $feed_id, $uri) = @_;

    # Check cache first
    my $feed = MusicBrainz::Server::Cache->get("feed-id-${feed_id}");
    if ($feed)
    {
        # HACK Force XML::Feed::RSS to load.
        require XML::Feed;
        my $fake = _fake_feed();
        XML::Feed->parse(\$fake);
    }
    else
    {
	# Loading is a bit complicated, but we have to ensure we fetch the
	# feed using any user defined proxies...
	my $ua = LWP::UserAgent->new;
	$ua->env_proxy;

	my $res = $ua->get($uri);
	if ($res->is_success)
	{
	    my $content = $res->content;
	    $feed = XML::Feed->parse(\$content)
		or die XML::Feed->errstr;

	    MusicBrainz::Server::Cache->set("feed-id-${feed_id}", $feed);
	}
    }

    return $feed;
}

sub _fake_feed
{
    return <<'END_OF_FEED'
<?xml version="1.0"?>
<rss version="2.0">
  <channel>
    <description>Fake feed</description>
    <link>http://example.org</link>
    <title>Fake feed</title>
  </channel>
</rss>
END_OF_FEED
}

1;
