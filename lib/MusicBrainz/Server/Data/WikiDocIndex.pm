package MusicBrainz::Server::Data::WikiDocIndex;

use Moose;
use namespace::autoclean;
use Readonly;
use List::UtilsBy qw( sort_by );
use List::MoreUtils qw( natatime);
use LWP::Simple qw();
use XML::Simple;
use Encode qw( decode );
use MusicBrainz::LWP;
use MusicBrainz::Server::Replication ':replication_type';

with 'MusicBrainz::Server::Data::Role::Sql';

Readonly my $CACHE_PREFIX => "wikidoc";
Readonly my $CACHE_KEY => "wikidoc-index";

sub _load_index_from_db {
    my $self = shift;
    return {
        map { @$_ } @{
            $self->sql->select_list_of_lists('SELECT page_name, revision FROM wikidocs.wikidocs_index')
        }
    };
}

sub _load_index
{
    my ($self) = @_;

    my $cache = $self->c->cache($CACHE_PREFIX);
    my $index = $cache->get($CACHE_KEY);
    return $index
        if defined $index;

    $index = $self->_load_index_from_db;

    $cache->set($CACHE_KEY, $index);
    return $index;
}

sub get_index
{
    my ($self) = @_;

    return $self->_load_index;
}

sub get_page_version
{
    my ($self, $page) = @_;

    return $self->_load_index->{$page};
}

sub set_page_version
{
    my ($self, $page, $version) = @_;

    my $index = $self->_load_index;
    if (defined $version) {
        my $query =
            qq{INSERT INTO wikidocs.wikidocs_index (revision, page_name)
               VALUES (?, ?)
               ON CONFLICT (page_name) DO UPDATE
               SET revision = EXCLUDED.revision};
        $self->sql->do($query, $version, $page);
    }
    else {
        my $query = "DELETE FROM wikidocs.wikidocs_index WHERE page_name = ?";
        $self->sql->do($query, $page);
    }

    $self->_delete_from_cache;
}

sub _delete_from_cache
{
    my ($self) = @_;
    my $cache = $self->c->cache($CACHE_PREFIX);
    $cache->delete($CACHE_KEY);
}

sub get_wiki_versions
{
    my ($self, $index) = @_;

    my @keys = sort_by { lc($_) } keys %$index;
    my @wiki_pages;

    # Query the API with 50 pages at a time
    my $it = natatime 50, @keys;

    while (my @queries = $it->()) {
        if (!defined DBDefs->WIKITRANS_SERVER_API) {
            warn 'WIKITRANS_SERVER_API must be defined within DBDefs.pm';
            return undef;
        }

        my $doc_url = sprintf "https://%s?action=query&prop=info&format=xml&titles=%s", DBDefs->WIKITRANS_SERVER_API, join('|', @queries);

        my $ua = MusicBrainz::LWP->new(
            global_timeout => 5,
            max_redirect => 0,
        );
        $ua->env_proxy;
        my $response = $ua->get($doc_url);

        if (!$response->is_success) {
            return undef;
        }

        my $content = decode "utf-8", $response->content;

        # Parse the XML and make it easier to use.
        my $xml = XMLin(
            $content,
            ForceArray => [ 'page' ],
            KeyAttr => { page => 'title', r => 'from', n => 'to'},
            GroupTags => { pages => 'page', redirects => 'r', normalized => 'n' }
        );

        my $pages = $xml->{query}->{pages};
        my $normalized = $xml->{query}->{normalized};

        foreach my $title (keys %$pages) {
            my $info->{wiki_version} = $pages->{$title}->{lastrevid};

            # Check if the page title was normalized and use it instead.
            # All page titles with a space/underscore will end up here.
            if (exists $normalized->{$title} ) {
                $info->{id} = $normalized->{$title}->{from};
            } else {
                $info->{id} = $title;
            }

            # If the page doesn't have a lastrevid, it doesn't exist.
            if (!$info->{wiki_version}) {
                warn "'$info->{id}' doesn't exist in the wiki";
                # Prevent "Use of uninitialized value" warnings
                $info->{wiki_version} = 0;
            }
            # Force numeric context
            $info->{wiki_version} += 0;

            push @wiki_pages, $info;
        }
    }

    @wiki_pages = sort { lc $a->{id} cmp lc $b->{id} } @wiki_pages;
    return @wiki_pages;
}

__PACKAGE__->meta->make_immutable;
no Moose;
1;

=head1 COPYRIGHT

Copyright (C) 2010 Pavan Chander
Copyright (C) 2009 Lukas Lalinsky

This program is free software; you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation; either version 2 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program; if not, write to the Free Software
Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.

=cut
