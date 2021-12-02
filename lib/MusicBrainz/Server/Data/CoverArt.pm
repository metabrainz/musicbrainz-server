package MusicBrainz::Server::Data::CoverArt;
use Moose;
use namespace::autoclean;

use aliased 'MusicBrainz::Server::CoverArt::Provider::RegularExpression'  => 'RegularExpressionProvider';
use aliased 'MusicBrainz::Server::CoverArt::Provider::WebService::Amazon' => 'AmazonProvider';
use aliased 'MusicBrainz::Server::Entity::Link';
use aliased 'MusicBrainz::Server::Entity::LinkType';
use aliased 'MusicBrainz::Server::Entity::Relationship';
use aliased 'MusicBrainz::Server::Entity::Release';
use aliased 'MusicBrainz::Server::Entity::URL';

use DateTime::Format::Pg;
use List::AllUtils qw( rev_sort_by );
use MusicBrainz::Server::Data::Utils qw( placeholders );
use MusicBrainz::Server::CoverArt;

with 'MusicBrainz::Server::Data::Role::Context';
with 'MusicBrainz::Server::Data::Role::QueryToList';

has 'providers' => (
    isa => 'ArrayRef',
    is  => 'ro',
    lazy_build => 1
);

sub _build_providers {
    my ($self) = @_;

    return [
        RegularExpressionProvider->new(
            name               => 'archive.org',
            domain             => 'archive.org',
            uri_expression     => '^(https?://.*archive\.org/.*(\.jpg|\.jpeg|\.png|\.gif|))$',
            image_uri_template => '$1',
        ),
        RegularExpressionProvider->new(
            name                 => 'www.ozon.ru',
            domain               => 'www.ozon.ru',
            uri_expression       => 'http://(?:www|mmedia).ozon\.ru/multimedia/(.*)',
            image_uri_template   => 'http://mmedia.ozon.ru/multimedia/$1',
        ),
        AmazonProvider->new(
            name => 'Amazon',
        )
    ];
}

has '_handled_link_types' => (
    isa        => 'HashRef',
    is         => 'ro',
    lazy_build => 1,
    traits     => [ 'Hash' ],
    handles    => {
        can_parse     => 'exists',
        get_providers => 'get',
        handled_types => 'keys',
        all_providers => 'values',
    }
);

sub _build__handled_link_types {
    my $self = shift;
    my %types;
    for my $provider (@{ $self->providers }) {
        $types{$provider->link_type_name} ||= [];
        push @{ $types{$provider->link_type_name} }, $provider;
    }

    return \%types;
}

sub load
{
    my ($self, @releases) = @_;
    for my $release (@releases) {
        for my $relationship ($release->all_relationships) {
            my $lt_name = $relationship->link->type->name;

            my $cover_art = $self->parse_from_type_url($lt_name, $relationship->target->url)
                # Couldn't parse cover art from this relationship, try another
                or next;

            # Loaded fine, finish parsing this release and move onto the next
            $release->cover_art($cover_art);
            last;
        }
    }
}

sub find_outdated_releases
{
    my ($self, $since) = @_;

    my @url_types = $self->handled_types;

    my $query = '
    SELECT r_id, url, link_type, last_updated AS c_last_updated
    FROM (
        SELECT DISTINCT ON (release.id)
            release.id AS r_id,
            url.url, link_type.name AS link_type,
            release_coverart.last_updated,
            CASE '.
              join(' ',
                   map {
                       my $providers = $self->get_providers($_);
                       "WHEN link_type.name = '$_' THEN " .
                           ((grep { $_->isa(RegularExpressionProvider) } @$providers)
                                ? 0 : 1)
                       } @url_types
                   ) . '
            END AS _sort_order
        FROM release
        JOIN release_coverart ON release.id = release_coverart.id
        LEFT JOIN l_release_url l ON ( l.entity0 = release.id )
        LEFT JOIN link ON ( link.id = l.link )
        LEFT JOIN link_type ON (
          link_type.id = link.link_type AND
          link_type.name IN (' . placeholders(@url_types) . ')
        )
        LEFT JOIN url ON ( url.id = l.entity1 )
        WHERE release.id IN (
            SELECT id FROM release_coverart
            WHERE
               last_updated IS NULL OR NOW() - last_updated > ?
        ) AND link_type.name IS NOT NULL
        ORDER BY release.id,
                 _sort_order DESC NULLS LAST,
                 l.last_updated DESC
    ) s
    ORDER BY last_updated ASC';

    my $pg_date_formatter = DateTime::Format::Pg->new;
    $self->query_to_list($query, [@url_types, $pg_date_formatter->format_duration($since)], sub {
        my ($model, $row) = @_;

        # Construction of these rows is slow, so this is lazy
        return sub {
            my $release = $self->c->model('Release')->_new_from_row($row, 'r_');
            $release->cover_art(
                MusicBrainz::Server::CoverArt->new(
                    $row->{c_last_updated} ? (last_updated => $row->{c_last_updated}) : ()
                )
            );
            my $url = $self->c->model('URL')->_new_from_row($row);

            $release->add_relationship(
                Relationship->new(
                    entity0 => $release,
                    entity1 => $url,
                    source => $release,
                    target => $url,
                    source_type => 'release',
                    target_type => 'url',
                    link => Link->new(
                        type => LinkType->new( name => $row->{link_type} )
                    )
                )
            );

            return $release;
        };
    });
}

sub cache_cover_art
{
    my ($self, $release) = @_;
    my @ordered_relationships =
        rev_sort_by { $_->last_updated } $release->all_relationships;

    my $cover_art;
    for my $relationship (@ordered_relationships) {
        $cover_art = $self->parse_from_type_url(
            $relationship->link->type->name,
            $relationship->entity1->url
        ) and last;
    }

    my $meta_update = { info_url => undef, amazon_asin => undef };
    if ($cover_art) {
        $meta_update = $cover_art->cache_data;
    }
    else {
        for my $relationship (@ordered_relationships) {
            if (my $meta = $self->fallback_meta(
                $relationship->link->type->name,
                $relationship->entity1->url
            )) {
                $meta_update = $meta;
                last;
            }
        }
    }

    my $cover_update = {
        last_updated => DateTime->now,
        cover_art_url  => $cover_art ? $cover_art->image_uri : undef
    };
    $self->c->sql->update_row('release_coverart', $cover_update, { id => $release->id });

    $self->c->sql->update_row('release_meta', $meta_update, { id => $release->id })
        if keys %$meta_update;

    return $cover_art;
}

sub parse_from_type_url
{
    my ($self, $type, $url) = @_;
    return unless $self->can_parse($type);

    my $cover_art;
    for my $provider (@{ $self->get_providers($type) }) {
        next unless $provider->handles($url);
        $cover_art = $provider->lookup_cover_art($url, undef)
            and return $cover_art;
    }
}

sub fallback_meta
{
    my ($self, $type, $url) = @_;
    return unless $self->can_parse($type);

    my $meta;
    for my $provider (@{ $self->get_providers($type) }) {
        next unless $provider->handles($url);
        $meta = $provider->fallback_meta($url)
            and return $meta;
    }
}

sub url_updated {
    my ($self, $url_id) = @_;
    my @release_ids = @{
        $self->c->sql->select_single_column_array(
            'SELECT entity0 FROM l_release_url
             WHERE entity1 = ?',
            $url_id
        )
    };

    my @releases = values %{ $self->c->model('Release')->get_by_ids(@release_ids) };
    $self->c->model('Relationship')->load_subset([ 'url' ], @releases);
    $self->cache_cover_art($_) for @releases;
}

sub mime_types {
    my $self = shift;

    return $self->c->sql->select_list_of_hashes(
        'SELECT mime_type, suffix FROM cover_art_archive.image_type');
}

sub image_type_suffix {
    my ($self, $mime_type) = @_;

    return $self->c->sql->select_single_value(
        'SELECT suffix FROM cover_art_archive.image_type WHERE mime_type = ?',
        $mime_type);
}

1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2010 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
