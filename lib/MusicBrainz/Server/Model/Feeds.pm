package MusicBrainz::Server::Model::Feeds;

use strict;
use warnings;

use URI;
use Readonly;
use XML::Feed;
use LWP::UserAgent;
use Encode qw( encode );

Readonly my $DEFAULT_UPDATE_INTERVAL => 10*60;

sub get
{
    my ($self, $c, $feed_id, $uri) = @_;

    # Check cache first
    my $feed = $c->cache("feed")->get("feed:${feed_id}");
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
                    title => $entry->title,
                    summary => {
                        body => $entry->summary->body,
                    },
                    link => $entry->link,
                    issued => $entry->issued,
                };
            }

            $feed = { entries => \@entries };

            $c->cache("feed")->set("feed:${feed_id}", $feed, $DEFAULT_UPDATE_INTERVAL);
        }
    }

    return $feed;
}

1;
