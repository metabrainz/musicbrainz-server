package MusicBrainz::Server::Model::Feeds;

use strict;
use warnings;

use URI;
use XML::Feed;
use LWP::UserAgent;
use Encode qw( encode );

sub get_cached
{
    my ($self, $feed_id, $uri) = @_;

    # Check cache first
    my $feed = MusicBrainz::Server::Cache->get("feed-id-${feed_id}");
    if (!$feed)
    {
        # Loading is a bit complicated, but we have to ensure we fetch the
        # feed using any user defined proxies...
        my $ua = LWP::UserAgent->new;
        $ua->env_proxy;

        my $res = $ua->get($uri);
        if ($res->is_success)
        {
            my $content = $res->content;
            my $feed_obj = XML::Feed->parse(\$content)
                or die XML::Feed->errstr;

            my @entries;
            for my $entry ($feed_obj->entries) {
                push @entries, {
                    title => encode("utf-8", $entry->title),
                    summary => {
                        body => encode("utf-8", $entry->summary->body),
                    },
                    link => encode("utf-8", $entry->link),
                    issued => encode("utf-8", $entry->issued),
                };
            }

            $feed = { entries => \@entries };

            MusicBrainz::Server::Cache->set("feed-id-${feed_id}", $feed);
        }
    }

    return $feed;
}

1;
