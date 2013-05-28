package MusicBrainz::Server::Data::WikiDocIndex;

use Moose;
use namespace::autoclean;
use Readonly;
use List::UtilsBy qw( sort_by );
use List::MoreUtils qw ( natatime);
use LWP::Simple qw();
use LWP::UserAgent;
use XML::Simple;
use Encode qw( decode );
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
        my $query;
        # NOTE: There is a race condition in the following code.
        # It is ignored, however, because the set of transclusion editors
        # is small, making the likelihood of triggering the condition
        # small. It could be fixed by way of a PL/pgsql function for error
        # trapping, as described in the postgresql docs.
        #
        # It is my (ianmcorvidae) opinion that the clarity of the following
        # code, with the race condition, is preferable to the potential
        # confusion of writing such an error-trapping function.
        if (exists $index->{$page}) {
            $query = "UPDATE wikidocs.wikidocs_index SET revision = ? where page_name = ?";
        } else {
            $query = "INSERT INTO wikidocs.wikidocs_index (revision, page_name) VALUES (?, ?)";
        }
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

        my $doc_url = sprintf "http://%s?action=query&prop=info&format=xml&titles=%s", DBDefs->WIKITRANS_SERVER_API, join('|', @queries);

        my $ua = LWP::UserAgent->new(max_redirect => 0, timeout => 5);
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

            push @wiki_pages, $info;
        }
    }

    return sort { lc $a->{id} cmp lc $b->{id} } @wiki_pages;
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
