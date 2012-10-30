package MusicBrainz::Server::Data::Blog;
use Moose;
use namespace::autoclean;

use Readonly;
use XML::RSS::Parser::Lite;
use Try::Tiny;

with 'MusicBrainz::Server::Data::Role::Context';

Readonly my $BLOG_CACHE_TIMEOUT => 60 * 60 * 3; # 3 hours

sub get_latest_entries {
    my ($self) = @_;

    my $key = 'blog:entries';

    my $cache = $self->c->cache_manager->cache('blog');
    my $entry_parser = $cache->get($key);

    if (!$entry_parser) {
        my $xml;
        try {
            $xml = $self->c->lwp->get("http://blog.musicbrainz.org/?feed=rss2");
        };
        return undef unless $xml && $xml->is_success;

        $entry_parser = XML::RSS::Parser::Lite->new;
        $entry_parser->parse($xml->content);
        $cache->set($key => $entry_parser, $BLOG_CACHE_TIMEOUT);
    }

    return $entry_parser;
}

__PACKAGE__->meta->make_immutable;
1;
