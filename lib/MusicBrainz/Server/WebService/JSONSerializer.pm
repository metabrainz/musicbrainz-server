package MusicBrainz::Server::WebService::JSONSerializer;

use Moose;
use JSON;
use List::UtilsBy 'sort_by';
use MusicBrainz::Server::Track qw( format_track_length );
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

sub serialize_data
{
    my ($self, $data) = @_;

    return encode_json($data);
}

sub serialize_release
{
    my ($self, $c, $release) = @_;

    my $data = $self->_release($release);
    my $mediums = $data->{mediums} = [];

    $data->{release_group} = $self->_release_group( $release->release_group );
    $data->{release_group}->{relationships} =
        $self->serialize_relationships( $release->release_group->all_relationships );

    if ($c->stash->{inc}->recordings) {
        for my $medium ($release->all_mediums) {

            my $medium_data = {
                position => $medium->position,
                $medium->name   ? ( name   => $medium->name ) : (),
                $medium->format ? ( format => $medium->format_name ) : (),
                tracks => [],
            };

            my $tracks_data = $medium_data->{tracks};

            for my $track ($medium->all_tracks) {
                my $track_data = {
                    name     => $track->name,
                    position => $track->position,
                    number   => $track->number,
                    length   => $track->length,
                    artist_credit => $self->_artist_credit( $track->artist_credit ),
                    recording     => $self->_recording( $track->recording,
                        MusicBrainz::Server::Entity::ArtistCredit::is_different
                                   ( $track->artist_credit,
                                     $track->recording->artist_credit) ),
                };

                if ($c->stash->{inc}->{rels}) {
                    $track_data->{recording}->{relationships} =
                        $self->serialize_relationships( $track->recording->all_relationships );
                }

                push @{ $medium_data->{tracks} }, $track_data;
            }

            push @{ $mediums }, $medium_data;
        }
    }
    if ($c->stash->{inc}->{rels}) {
        $data->{relationships} = $self->serialize_relationships( $release->all_relationships );
    }
    return $self->serialize_data($data);
}

sub serialize_relationships
{
    my ($self, @relationships) = @_;

    my $data = {};

    for (@relationships) {
        my $rels = $data->{ $_->target_type } //= {};
        $rels = $rels->{ $_->link->type->name } //= [];

        my $entity = '_' . $_->target_type;
        $entity =~ s/\-/_/g;

        my $out = {
            id         => $_->id,
            link_type  => $_->link->type_id,
            attributes => $_->link->get_attribute_hash,
            $_->link->begin_date->has_year
                ? ( begin_date => $_->link->begin_date->format ) : (),
            $_->link->end_date->has_year
                ? ( end_date => $_->link->end_date->format ) : (),
            ended         => $_->link->ended ? 1 : 0,
            target        => $self->$entity( $_->target ),
            edits_pending => $_->edits_pending,
            verbose_phrase => $_->verbose_phrase
        };

        $out->{direction} = 'backward'
            if ($_->direction == $MusicBrainz::Server::Entity::Relationship::DIRECTION_BACKWARD);

        $out->{target}->{relationships} = $self->serialize_relationships
            ( $_->target->all_relationships ) if $_->target->all_relationships;

        push @{ $rels }, $out;
    }

    return $data;
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

sub _generic
{
    my ($self, $entity) = @_;

    return {
        name    => $entity->name,
        id      => $entity->id,
        gid     => $entity->gid,
        $entity->meta->has_attribute('comment') 
            ? (comment => $entity->comment) : (),
        $entity->meta->has_attribute('sort_name')
            ? (sortname => $entity->sort_name) : (),
        $entity->meta->has_attribute('artist_credit') && $entity->artist_credit
            ? (artist_credit => $self->_artist_credit($entity->artist_credit)) : ()
    };
}

sub _artist { goto &_generic }

sub _label { goto &_generic }

sub _release { goto &_generic }

sub autocomplete_area
{
    my ($self, $results, $pager) = @_;

    my @output;
    push @output, $self->_area($_) for @$results;

    push @output, {
        pages => $pager->last_page,
        current => $pager->current_page
    } if $pager;

    return encode_json (\@output);
}

sub _area
{
    my ($self, $area) = @_;

    return {
        name    => $area->name,
        id      => $area->id,
        gid     => $area->gid,
        type    => $area->type_id,
        $area->type ? (typeName => $area->type->name) : (),
        $area->parent_country ? (parentCountry => $area->parent_country->name) : () };
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

sub generic
{
    my ($self, $response) = @_;

    return encode_json($response);
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

    return {
        name    => $item->name,
        id      => $item->id,
        gid     => $item->gid,
        comment => $item->comment,
        artist  => $item->artist_credit->name,
        type    => $item->primary_type_id,
        $item->primary_type ? (typeName => $item->primary_type->name) : ()
    };
}

sub autocomplete_recording
{
    my ($self, $results, $pager) = @_;

    my @output;

    for (@$results) {
        my $out = $self->_recording( $_->{recording} );

        $out->{appears_on} = {
            hits    => $_->{appears_on}{hits},
            results => [ map { {
                'name' => $_->name,
                'gid'  => $_->gid
            } } @{ $_->{appears_on}{results} } ],
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
    my ($self, $recording, $show_ac) = @_;

    return {
        name    => $recording->name,
        id      => $recording->id,
        gid     => $recording->gid,
        comment => $recording->comment,
        length  => format_track_length ($recording->length),
        artist  => $recording->artist_credit->name,
        $show_ac ? ( artist_credit  =>
            $self->_artist_credit($recording->artist_credit) ) : (),
        isrcs => [ map { $_->isrc } $recording->all_isrcs ],
    };
}

sub autocomplete_work
{
    my ($self, $results, $pager) = @_;

    my @output;

    for (@$results) {
        my $out = $self->_work( $_->{work} );
        $out->{artists} = $_->{artists};
        push @output, $out;
    }

    push @output, {
        pages => $pager->last_page,
        current => $pager->current_page
    } if $pager;

    return encode_json (\@output);
}

sub _work
{
    my ($self, $work) = @_;

    return {
        name    => $work->name,
        id      => $work->id,
        gid     => $work->gid,
        comment => $work->comment,
    };
}

sub _url
{
    my ($self, $url) = @_;

    return {
        url           => $url->pretty_name,
        id            => $url->id,
        gid           => $url->gid,
        edits_pending => $url->edits_pending,
    };
}

sub _artist_credit
{
    my ($self, $ac) = @_;

    return [ map +{
        artist     => $self->_artist( $_->artist ),
        joinphrase => $_->join_phrase,
    }, $ac->all_names ];
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
