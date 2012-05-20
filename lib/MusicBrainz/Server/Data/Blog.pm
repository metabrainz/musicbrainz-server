package MusicBrainz::Server::Data::Blog;
use Moose;
use namespace::autoclean;

use XML::RSS::Parser::Lite;
use LWP::UserAgent;

with 'MusicBrainz::Server::Data::Role::Context';

has lwp => (
    is => 'ro',
    default => sub {
        my $ua = LWP::UserAgent->new;
        $ua->env_proxy;
        return $ua;
    }
);

sub get_latest_entries {
    my ($self) = @_;

    my $key = 'blog:entries';

    my $cache = $self->c->cache_manager->cache('blog');
    my $entry_parser = $cache->get($key);

    if (!$entry_parser) {
        my $xml = $self->lwp->get("http://blog.musicbrainz.org/?feed=rss2");
        $entry_parser = XML::RSS::Parser::Lite->new;
        $entry_parser->parse($xml->content);
        $cache->set($key => $entry_parser);
    }

    return $entry_parser;
}

__PACKAGE__->meta->make_immutable;
1;
