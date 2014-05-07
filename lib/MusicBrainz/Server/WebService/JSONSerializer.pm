package MusicBrainz::Server::WebService::JSONSerializer;

use Moose;
use JSON;
use List::MoreUtils qw( any );
use List::UtilsBy 'sort_by';
use MusicBrainz::Server::Data::Utils qw( partial_date_to_hash );
use MusicBrainz::Server::WebService::WebServiceInc;
use MusicBrainz::Server::WebService::Serializer::JSON::2::Utils qw( list_of number serializer serialize_entity );

sub mime_type { 'application/json' }
sub fmt { 'json' }

sub serialize
{
    my ($self, $type, @data) = @_;

    $type =~ s/-/_/g;

    my $override = $self->meta->find_method_by_name ($type);
    return $override->execute ($self, @data) if $override;

    my ($entity, $inc, $opts) = @data;

    my $ret = serialize_entity($entity, $inc, $opts, 1);
    return encode_json($ret);
}

sub entity_list
{
    my ($self, $list, $inc, $opts, $type, $type_plural) = @_;

    my %ret;

    if (defined $list->{offset} || defined $list->{total})
    {
        $ret{$type."-offset"} = number ($list->{offset});
        $ret{$type."-count"} = number ($list->{total});
    }
    $ret{$type_plural} = [
        map { serialize_entity($_, $inc, $opts, 1) }
        sort_by { $_->gid } @{ $list->{items} }];

    return encode_json (\%ret);
}

sub artist_list        { shift->entity_list (@_, "artist", "artists") };
sub label_list         { shift->entity_list (@_, "label", "labels") };
sub recording_list     { shift->entity_list (@_, "recording", "recordings") };
sub release_list       { shift->entity_list (@_, "release", "releases") };
sub release_group_list { shift->entity_list (@_, "release-group", "release-groups") };
sub work_list          { shift->entity_list (@_, "work", "works") };
sub area_list          { shift->entity_list (@_, "area", "areas") };
sub place_list         { shift->entity_list (@_, "place", "places") };

sub serialize_release
{
    my ($self, $c, $release) = @_;

    my $inc = $c->stash->{inc};
    my $data = $self->_release($release, $inc->media, $inc->recordings, $inc->rels);

    $data->{releaseGroup} = $self->_release_group($release->release_group);

    if ($inc->rels) {
        $data->{relationships} =
            $self->serialize_relationships($release->all_relationships);

        $data->{releaseGroup}->{relationships} =
            $self->serialize_relationships($release->release_group->all_relationships);
    }

    if ($inc->annotation) {
        $data->{annotation} = defined $release->latest_annotation ?
            $release->latest_annotation->text : "";
    }

    return encode_json($data);
}

sub serialize_relationships
{
    my ($self, @relationships) = @_;

    [ map { $self->serialize_relationship($_) } @relationships ];
}

sub serialize_relationship {
    my ($self, $relationship) = @_;

    my $entity = '_' . $relationship->target_type;
    $entity =~ s/\-/_/g;

    my $link = $relationship->link;

    my $out = {
        id              => $relationship->id,
        linkTypeID      => $link->type_id,
        attributes      => [ sort map { $_->id } $link->all_attributes ],
        ended           => $link->ended ? \1 : \0,
        target          => $self->$entity( $_->target ),
        editsPending    => $relationship->edits_pending ? \1 : \0,
        verbosePhrase   => $relationship->verbose_phrase,
        linkOrder       => $relationship->link_order,
    };

    if (any { $_->free_text } $link->all_attributes) {
        $out->{attributeTextValues} = $link->attribute_text_values;
    }

    $out->{beginDate} = $link->begin_date->is_empty ? undef : partial_date_to_hash($link->begin_date);
    $out->{endDate} = $link->end_date->is_empty ? undef : partial_date_to_hash($link->end_date);
    $out->{direction} = 'backward' if $relationship->direction == $MusicBrainz::Server::Entity::Relationship::DIRECTION_BACKWARD;

    if (my @rels = $relationship->target->all_relationships) {
        $out->{target}->{relationships} = $self->serialize_relationships(@rels);
    }

    return $out;
}

sub autocomplete_generic
{
    my ($self, $output, $pager) = @_;

    my @output = map $self->_generic($_), @$output;

    push @output, {
        pages => $pager->last_page,
        current => $pager->current_page
    } if $pager;

    return encode_json (\@output);
}

sub autocomplete_label
{
    my ($self, $results, $pager) = @_;

    my $output = _with_primary_alias(
        $results,
        sub { $self->_label( shift->{entity} ) }
    );

    push @$output, {
        pages => $pager->last_page,
        current => $pager->current_page
    } if $pager;

    return encode_json ($output);
}

sub _generic
{
    my ($self, $entity, $type) = @_;

    return {
        name    => $entity->name,
        id      => $entity->id,
        gid     => $entity->gid,
        $entity->meta->has_attribute('comment')
            ? (comment => $entity->comment) : (),
        $entity->meta->has_attribute('sort_name')
            ? (sortName => $entity->sort_name) : (),
        $entity->meta->has_attribute('artist_credit') && $entity->artist_credit
            ? (artistCredit => $self->_artist_credit($entity->artist_credit)) : (),
        $type ? (entityType => $type) : (),
    };
}

sub _artist { _generic(@_, "artist") }

sub _label { _generic(@_, "label") }

sub autocomplete_release
{
    my ($self, $output, $pager) = @_;

    my @output = map $self->_release($_), @$output;

    push @output, {
        pages => $pager->last_page,
        current => $pager->current_page
    } if $pager;

    return encode_json (\@output);
}

sub _release
{
    my ($self, $release, $inc_media, $inc_recordings, $inc_rels) = @_;

    my $data = {
        entityType   => "release",
        name         => $release->name,
        id           => $release->id,
        gid          => $release->gid,
        comment      => $release->comment,
        statusID     => $release->status_id,
        languageID   => $release->language_id,
        scriptID     => $release->script_id,
        packagingID  => $release->packaging_id,
        barcode      => $release->barcode->code
    };

    if ($release->release_group) {
        $data->{releaseGroup} = $self->_release_group($release->release_group);
    }

    if ($release->artist_credit) {
        $data->{artistCredit} = $self->_artist_credit($release->artist_credit);
    }

    if (scalar($release->all_events)) {
        $data->{events} = [
            map {
                date => $_->date->format,
                countryID => $_->country_id
            }, $release->all_events
        ];

        $data->{countryCodes} = [ map { $_->country->primary_code }
            grep { $_->country_id } $release->all_events ];
    }

    if (scalar($release->all_labels)) {
        $data->{labels} = [
            map {
                id => $_->id,
                label => $_->label ? $self->_label($_->label) : undef,
                catalogNumber => $_->catalog_number
            }, $release->all_labels
        ];
    }

    if (scalar($release->all_mediums)) {
        if ($inc_media) {
            $data->{mediums} = [
                map $self->_medium($_, $inc_recordings, $inc_rels),
                        $release->all_mediums
            ];
        }

        $data->{trackCounts} = $release->combined_track_count;
        $data->{formats} = $release->combined_format_name;
    }

    return $data;
}

sub _medium
{
    my ($self, $medium, $inc_recordings, $inc_rels) = @_;

    my $data = {
        entityType => "medium",
        id        => $medium->id,
        position  => $medium->position,
        name      => $medium->name,
        format    => $medium->l_format_name,
        formatID  => $medium->format_id,
        cdtocs    => scalar($medium->all_cdtocs),
    };

    if ($inc_recordings) {
        my $tracks_data = $data->{tracks} = [];

        for my $track ($medium->all_tracks) {
            my $track_data = $self->_track($track);

            if ($inc_rels) {
                $track_data->{recording}->{relationships} =
                    $self->serialize_relationships($track->recording->all_relationships);
            }
            push @{ $data->{tracks} }, $track_data;
        }
    }
    return $data;
}

sub _track
{
    my ($self, $track) = @_;

    my $output = {
        entityType    => "track",
        id            => $track->id,
        gid           => $track->gid,
        name          => $track->name,
        position      => $track->position,
        number        => $track->number,
        length        => $track->length,
        artistCredit  => $self->_artist_credit( $track->artist_credit )
    };

    if ($track->recording) {
        $output->{recording} = $self->_recording( $track->recording,
            !MusicBrainz::Server::Entity::ArtistCredit::is_different(
                $track->artist_credit, $track->recording->artist_credit) )
    }

    return $output;
}

sub autocomplete_area
{
    my ($self, $results, $pager) = @_;

    my $output = _with_primary_alias(
        $results,
        sub { $self->_area( shift->{entity} ) }
    );

    push @$output, {
        pages => $pager->last_page,
        current => $pager->current_page
    } if $pager;

    return encode_json ($output);
}

sub autocomplete_artist
{
    my ($self, $results, $pager) = @_;

    my $output = _with_primary_alias(
        $results,
        sub { $self->_artist( shift->{entity} ) }
    );

    push @$output, {
        pages => $pager->last_page,
        current => $pager->current_page
    } if $pager;

    return encode_json ($output);
}

sub _area
{
    my ($self, $area) = @_;

    return {
        entityType => "area",
        name    => $area->name,
        id      => $area->id,
        gid     => $area->gid,
        comment => $area->comment,
        typeID  => $area->type_id,
        $area->type ? (typeName => $area->type->name) : (),
        $area->parent_country ? (parentCountry => $area->parent_country->name) : (),
        $area->parent_subdivision ? (parentSubdivision => $area->parent_subdivision->name) : (),
        $area->parent_city ? (parentCity => $area->parent_city->name) : ()
    };
}

sub autocomplete_editor
{
    my ($self, $output, $pager) = @_;

    return encode_json([
        (map +{
            name => $_->name,
            id => $_->id,
        }, @$output),
        {
            pages => $pager->last_page,
            current => $pager->current_page
        }
    ]);
}

sub output_error
{
    my ($self, $err) = @_;

    return encode_json ({ error => $err });
}

sub autocomplete_release_group
{
    my ($self, $results, $pager) = @_;

    my @output;
    push @output, $self->_release_group($_) for @$results;

    push @output, {
        pages => $pager->last_page,
        current => $pager->current_page
    } if $pager;

    return encode_json (\@output);
}

sub _release_group
{
    my ($self, $item) = @_;

    my $output = {
        entityType => "release_group",
        name    => $item->name,
        id      => $item->id,
        gid     => $item->gid,
        comment => $item->comment,
        typeID  => $item->primary_type_id,
        typeName => $item->type_name,
        firstReleaseDate => $item->first_release_date->format,
        secondaryTypeIDs => [ map { $_->id } $item->all_secondary_types ],
    };

    if ($item->artist_credit) {
        $output->{artist} = $item->artist_credit->name;
        $output->{artistCredit} = $self->_artist_credit($item->artist_credit);
    }

    return $output;
}

sub autocomplete_recording
{
    my ($self, $results, $pager) = @_;

    my @output;

    for (@$results) {
        my $out = $self->_recording( $_->{recording} );

        $out->{appearsOn} = {
            hits    => $_->{appearsOn}{hits},
            results => [ map { {
                'name' => $_->name,
                'gid'  => $_->gid
            } } @{ $_->{appearsOn}{results} } ],
        };

        push @output, $out
    }

    push @output, {
        pages => $pager->last_page,
        current => $pager->current_page
    } if $pager;

    return encode_json (\@output);
}

sub _recording
{
    my ($self, $recording, $hide_ac) = @_;

    my $output = {
        entityType  => "recording",
        name        => $recording->name,
        id          => $recording->id,
        gid         => $recording->gid,
        comment     => $recording->comment,
        length      => $recording->length,
        isrcs       => [ map { $_->isrc } $recording->all_isrcs ],
        video       => $recording->video ? \1 : \0
    };

    # Relationship target entities in Controller::Role::EditRelationships
    # don't have/need any additional information like artist credits loaded,
    # so at least for there this won't be defined.

    if ($recording->artist_credit) {
        $output->{artist} = $recording->artist_credit->name;

        $output->{artistCredit} =
            $self->_artist_credit($recording->artist_credit) unless $hide_ac;
    }

    return $output;
}

sub autocomplete_work
{
    my ($self, $results, $pager) = @_;

    my $output = _with_primary_alias(
        $results,
        sub {
            my $result = shift;

            my $out = $self->_work( $result->{entity} );
            $out->{artists} = $result->{artists};

            return $out;
        }
    );

    push @$output, {
        pages => $pager->last_page,
        current => $pager->current_page
    } if $pager;

    return encode_json ($output);
}

sub _with_primary_alias {
    my ($results, $renderer) = @_;

    my @output;
    if (@$results) {
        my $munge_lang = sub {
            my $lang = shift;
            $lang =~ s/_[A-Z]{2}/_/;
            return $lang;
        };

        my %alias_preference = (
            en => 2,
            en_ => 1
        );
        my $lang = $munge_lang->($results->[0]->{current_language});
        $lang =~ s/_$//;
        $alias_preference{$lang} = 4 if $lang ne 'en';
        $alias_preference{$lang . '_'} = 3 if $lang ne 'en';

        for my $result (@$results) {
            my $out = $renderer->($result);

            my ($primary_alias, @others) =
                reverse sort {
                    my $pref_a = $alias_preference{$munge_lang->($a->locale)};
                    my $pref_b = $alias_preference{$munge_lang->($b->locale)};

                    defined($pref_a) && defined($pref_b)
                        ? $pref_a <=> $pref_b
                        : defined($pref_a) || -(defined($pref_b)) || 0;
                } grep {
                    $_->primary_for_locale
                } @{ $result->{aliases} };

            $out->{primary_alias} = $primary_alias && $primary_alias->name;
            push @output, $out;
        }
    }

    return \@output;
}

sub _work
{
    my ($self, $work) = @_;

    return {
        entityType  => "work",
        name        => $work->name,
        id          => $work->id,
        gid         => $work->gid,
        comment     => $work->comment,
        language    => $work->language && $work->language->l_name
    };
}

sub autocomplete_place
{
    my ($self, $results, $pager) = @_;

    my $output = _with_primary_alias(
        $results,
        sub { $self->_place(shift->{entity}) }
    );

    push @$output, {
        pages => $pager->last_page,
        current => $pager->current_page
    } if $pager;

    return encode_json ($output);
}

sub _place
{
    my ($self, $place) = @_;

    return {
        entityType  => "place",
        name        => $place->name,
        id          => $place->id,
        gid         => $place->gid,
        typeID      => $place->type_id,
        comment     => $place->comment,
        $place->type ? (typeName => $place->type->name) : (),
        $place->area ? (area => $place->area->name) : (),
    };
}

sub autocomplete_instrument {
    my ($self, $results, $pager) = @_;

    my $output = _with_primary_alias(
        $results,
        sub { $self->_instrument(shift->{entity}) }
    );

    push @$output, {
        pages => $pager->last_page,
        current => $pager->current_page
    } if $pager;

    return encode_json($output);
}

sub _instrument {
    my ($self, $instrument) = @_;

    return {
        name    => $instrument->name,
        id      => $instrument->id,
        gid     => $instrument->gid,
        typeID  => $instrument->type_id,
        comment => $instrument->comment,
        description => $instrument->l_description,
        $instrument->type ? (typeName => $instrument->type->name) : (),
    };
}

sub _url
{
    my ($self, $url) = @_;

    return {
        entityType    => "url",
        name          => $url->name,
        id            => $url->id,
        gid           => $url->gid,
    };
}

sub _artist_credit
{
    my ($self, $ac) = @_;

    return [ map +{
        artist      => $self->_artist( $_->artist ),
        joinPhrase  => $_->join_phrase,
        $_->artist->name eq $_->name ? () : ( name => $_->name )
    }, $ac->all_names ];
}

sub _series {
    my ($self, $series) = @_;

    return {
        name                => $series->name,
        id                  => $series->id,
        gid                 => $series->gid,
        comment             => $series->comment,
        type => {
            id          => $series->type_id,
            name        => $series->type->l_name,
            entityType  => $series->type->entity_type,
        },
        orderingAttributeID => $series->ordering_attribute_id,
        orderingTypeID      => $series->ordering_type_id,
        entityType          => 'series',
    };
}

sub autocomplete_series {
    my ($self, $results, $pager) = @_;

    my $output = _with_primary_alias(
        $results,
        sub { $self->_series(shift->{entity}) }
    );

    push @$output, {
        pages => $pager->last_page,
        current => $pager->current_page
    } if $pager;

    return encode_json($output);
}

__PACKAGE__->meta->make_immutable;
no Moose;
1;

=head1 COPYRIGHT

Copyright (C) 2010 MetaBrainz Foundation

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
