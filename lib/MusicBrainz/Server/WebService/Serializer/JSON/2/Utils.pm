package MusicBrainz::Server::WebService::Serializer::JSON::2::Utils;

use warnings;
use strict;

use base 'Exporter';
use Class::Load qw( load_class );
use List::AllUtils qw( any sort_by );
use MusicBrainz::Server::Constants qw( %ENTITIES );

our @EXPORT_OK = qw(
    boolean
    count_of
    list_of
    number
    serialize_artist_credit
    serialize_date_period
    serialize_entity
    serialize_rating
    serialize_type
    serializer
);

our $hide_aliases = 0;
our $hide_tags_and_genres = 0;
our $force_ratings = 0;

my %serializers =
    map {
        my $class = "MusicBrainz::Server::WebService::Serializer::JSON::2::$_";
        my $entity_class = "MusicBrainz::Server::Entity::$_";
        load_class($class);
        load_class($entity_class);
        $entity_class->entity_type => $class->new
    } qw(
        Area
        Artist
        ArtistCredit
        CDStub
        CDTOC
        Collection
        Event
        Genre
        Instrument
        ISRC
        Label
        Place
        Medium
        Recording
        Relationship
        Release
        ReleaseGroup
        Series
        URL
        Work
    );

sub boolean { return (shift) ? JSON::true : JSON::false; }

sub number {
    my $value = shift;
    return defined $value ? $value + 0 : JSON::null;
}

sub serialize_date_period {
    my ($into, $entity) = @_;

    $into->{begin} = $entity->begin_date->format || JSON::null;
    $into->{end} = $entity->end_date->format || JSON::null;
    $into->{ended} = boolean($entity->ended);
    return;
}

sub serializer
{
    my $entity = shift;

    if ($entity->can('entity_type')) {
        my $serializer = $serializers{$entity->entity_type};
        return $serializer if $serializer;
    }

    die 'No serializer found for ' . ref($entity);
}

sub serialize_entity
{
    my ($entity) = @_;

    return unless defined $entity;

    my $output = serializer($entity)->serialize(@_);
    my $props = $ENTITIES{$entity->entity_type};

    serialize_aliases($output, @_)
        if $props->{aliases};

    serialize_annotation($output, @_)
        if $props->{annotations};

    serialize_id($output, @_)
        if $props->{mbid};

    serialize_ipis($output, @_)
        if $props->{ipis};

    serialize_isnis($output, @_)
        if $props->{isnis};

    serialize_life_span($output, @_)
        if $props->{date_period};

    serialize_rating($output, @_)
        if $props->{ratings};

    serialize_relationships($output, @_)
        if $props->{mbid} && $props->{mbid}{relatable};

    serialize_tags($output, @_)
        if $props->{tags};

    serialize_type($output, @_)
        if $props->{type} && $props->{type}{simple};

    return $output;
}

sub list_of
{
    my ($entity, $inc, $stash, $type, $toplevel) = @_;

    my $opts = $stash->store($entity);
    my $list = $opts->{$type};
    my $items = (ref $list eq 'HASH') ? $list->{items} : $list;

    return [map { serialize_entity($_, $inc, $stash, $toplevel) } @$items];
}

sub count_of
{
    my ($entity, $inc, $stash, $type, $toplevel) = @_;

    my $opts = $stash->store($entity);
    my $list = $opts->{$type};
    my $items = (ref $list eq 'HASH') ? $list->{items} : $list;

    return number(scalar @$items);
}

sub serialize_aliases {
    my ($into, $entity, $inc, $stash) = @_;

    return if $hide_aliases;

    return unless defined $inc && $inc->aliases;

    # We don't show aliases again for recording artists if they're on the release or track AC
    if ($entity->isa('MusicBrainz::Server::Entity::Artist')) {
        if (my $release_ac = $stash->{release_artist_credit}) {
            # We make sure a track AC is set (i.e. this is a recording)
            # to avoid breaking stuff that expects track artist aliases
            if (my $track_ac = $stash->{track_artist_credit}) {
                return if (any { $_->artist_id == $entity->id } $release_ac->all_names);
                return if (any { $_->artist_id == $entity->id } $track_ac->all_names);
            }
        }
    }

    my $opts = $stash->store($entity);

    $into->{aliases} = [map {
        my %item;

        $item{name} = $_->name;
        $item{'sort-name'} = $_->sort_name;
        $item{locale} = $_->locale // JSON::null;
        $item{primary} = $_->locale ?
            boolean($_->primary_for_locale) : JSON::null;

        serialize_type(\%item, $_, $inc, $stash, 1);
        serialize_date_period(\%item, $_);

        \%item;
    } sort_by { $_->name } @{ $opts->{aliases} }];

    return;
}

sub serialize_annotation {
    my ($into, $entity, $inc, $stash, $toplevel) = @_;

    return unless $toplevel && defined $inc && $inc->annotation;

    my $annotation = $entity->latest_annotation;
    $into->{annotation} = defined $annotation ?
        $annotation->text : JSON::null;
    return;
}

sub serialize_artist_credit {
    my ($into, $entity, $inc, $stash, $toplevel) = @_;

    # In contrast to most other serialize_* methods,
    # this method has to be called only when appropriate.
    # Because the conditions to decided whether or not to serialize
    # artist credit vary a lot depending on the entity type,
    # no further check is made here.

    my $artist_credit = $entity->artist_credit;

    $into->{'artist-credit'} = [map {
        {
            'name' => $_->name,
            'joinphrase' => $_->join_phrase,
            'artist' => serialize_entity($_->artist, $inc, $stash),
        }
    } @{ $artist_credit->{names} }];

    $into->{'artist-credit-id'} = $artist_credit->{gid};

    return;
}

sub serialize_id {
    my ($into, $entity) = @_;

    $into->{id} = $entity->gid;
    return;
}

sub serialize_ipis {
    my ($into, $entity, $inc, $stash, $toplevel) = @_;

    return unless $toplevel;

    $into->{ipis} = [map { $_->ipi } $entity->all_ipi_codes];
    return;
}

sub serialize_isnis {
    my ($into, $entity, $inc, $stash, $toplevel) = @_;

    return unless $toplevel;

    $into->{isnis} = [map { $_->isni } $entity->all_isni_codes];
    return;
}

sub serialize_life_span {
    my ($into, $entity, $inc, $stash, $toplevel) = @_;

    return unless $toplevel;

    my $life_span = {};
    serialize_date_period($life_span, $entity);
    $into->{'life-span'} = $life_span;
    return;
}

sub serialize_rating {
    my ($into, $entity, $inc, $stash, $toplevel) = @_;

    return unless
        (($toplevel || $force_ratings) &&
         (defined $inc && ($inc->ratings || $inc->user_ratings)));

    my $opts = $stash->store($entity);

    if ($inc->ratings) {
        my $ratings = $opts->{ratings};
        $into->{rating} = {
            value => number($ratings->{rating}),
            'votes-count' => defined $ratings->{count} ?
                number($ratings->{count}) : 0,
        };
    }

    $into->{'user-rating'} = {value => number($opts->{user_ratings})}
        if $inc->user_ratings;

    return;
}

sub serialize_relationships {
    my ($into, $entity, $inc, $stash) = @_;

    return unless
        (defined $inc &&
         $inc->has_rels &&
         $entity->has_loaded_relationships);

    local $hide_tags_and_genres = 1;
    local $hide_aliases = 1;

    my @relationships =
        map { serialize_entity($_, $inc, $stash) }
        $entity->all_relationships;

    $into->{relations} = \@relationships;
    return;
}

sub serialize_tags {
    my ($into, $entity, $inc, $stash, $toplevel) = @_;

    return if $hide_tags_and_genres;

    return unless
        (defined $inc &&
         ($inc->tags || $inc->user_tags || $inc->genres || $inc->user_genres));

    if ($entity->isa('MusicBrainz::Server::Entity::Artist')) {
        if (my $release_ac = $stash->{release_artist_credit}) {
            return if (any { $_->artist_id == $entity->id } $release_ac->all_names);
        }
        if (my $track_ac = $stash->{track_artist_credit}) {
            return if (any { $_->artist_id == $entity->id } $track_ac->all_names);
        }
    }

    my $opts = $stash->store($entity);

    if ($inc->tags) {
        $into->{tags} = [
            sort { $a->{name} cmp $b->{name} }
            map +{ count => $_->count, name => $_->tag->name },
                grep { $_->count > 0 } @{ $opts->{tags} }
        ];
    }

    if ($inc->genres) {
        $into->{genres} = [
            sort { $a->{name} cmp $b->{name} }
            map +{ count => $_->count, disambiguation => $_->genre->comment, id => $_->genre->gid, name => $_->genre->name },
                grep { $_->count > 0 } @{ $opts->{genres} }
        ];
    }

    if ($inc->user_tags) {
        $into->{'user-tags'} = [
            sort { $a->{name} cmp $b->{name} }
            map +{ name => $_->tag->name },
                grep { $_->is_upvote }
                @{ $opts->{user_tags} }
        ];
    }

    if ($inc->user_genres) {
        $into->{'user-genres'} = [
            sort { $a->{name} cmp $b->{name} }
            map +{ disambiguation => $_->genre->comment, id => $_->genre->gid, name => $_->genre->name },
                grep { $_->is_upvote }
                @{ $opts->{user_genres} }
        ];
    }

    return;
}

sub serialize_type {
    my ($into, $entity, $inc, $stash, $toplevel) = @_;

    my $type = $entity->type;
    $into->{type} = defined $type ? $type->name : JSON::null;
    $into->{'type-id'} = defined $type ? $type->gid : JSON::null;
    return;
}

1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2012-2013 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
