package MusicBrainz::Server::Data::Blog;
use Moose;
use namespace::autoclean;

use Readonly;
use XML::RSS::Parser::Lite;
use Try::Tiny;
use Encode qw( decode );

with 'MusicBrainz::Server::Data::Role::Context';

Readonly my $BLOG_CACHE_TIMEOUT => 60 * 60 * 3; # 3 hours

sub get_latest_entries {
    my ($self) = @_;

    my $key = 'blog:entries';

    my $cache = $self->c->cache_manager->cache('blog');
    my $entries = $cache->get($key);

    if (!$entries) {
        my $xml;
        try {
            $xml = $self->c->lwp->get('http://blog.metabrainz.org/?feed=rss2');
        };
        return undef unless $xml && $xml->is_success;

        my $entry_parser = XML::RSS::Parser::Lite->new;
        try {
            $entry_parser->parse($xml->content);
        } finally {
            unless (@_) {
                $entries = [
                    map +{ title => decode('utf-8', $_->{title}), url => decode('utf-8', $_->{url}) },
                        @{ $entry_parser->{items} }
                ];

                $cache->set($key => $entries, $BLOG_CACHE_TIMEOUT);
            }
        };
    }

    return $entries;
}

__PACKAGE__->meta->make_immutable;
1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2012 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
