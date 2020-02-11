package MusicBrainz::Server::Data::Event;

use DateTime;
use Moose;
use namespace::autoclean;
use List::AllUtils qw( any uniq );
use MusicBrainz::Server::Constants qw( $STATUS_OPEN );
use MusicBrainz::Server::Data::Edit;
use MusicBrainz::Server::Entity::Event;
use MusicBrainz::Server::Entity::PartialDate;
use MusicBrainz::Server::Data::Utils qw(
    add_partial_date_to_row
    generate_gid
    get_area_containment_query
    hash_to_row
    load_subobjects
    merge_table_attributes
    merge_string_attributes
    merge_date_period
    order_by
    placeholders
);
use MusicBrainz::Server::Data::Utils::Cleanup qw( used_in_relationship );

extends 'MusicBrainz::Server::Data::CoreEntity';
with 'MusicBrainz::Server::Data::Role::Annotation' => { type => 'event' };
with 'MusicBrainz::Server::Data::Role::Alias' => { type => 'event' };
with 'MusicBrainz::Server::Data::Role::CoreEntityCache';
with 'MusicBrainz::Server::Data::Role::DeleteAndLog' => { type => 'event' };
with 'MusicBrainz::Server::Data::Role::Editable' => { table => 'event' };
with 'MusicBrainz::Server::Data::Role::Rating' => { type => 'event' };
with 'MusicBrainz::Server::Data::Role::Tag' => { type => 'event' };
with 'MusicBrainz::Server::Data::Role::LinksToEdit' => { table => 'event' };
with 'MusicBrainz::Server::Data::Role::Merge';
with 'MusicBrainz::Server::Data::Role::Collection';

sub _type {
    return 'event';
}

sub _columns
{
    return 'event.id, event.gid, event.name, event.type, event.time, event.cancelled,' .
           'event.setlist, event.edits_pending, event.begin_date_year, ' .
           'event.begin_date_month, event.begin_date_day, event.end_date_year, ' .
           'event.end_date_month, event.end_date_day, event.ended, ' .
           'event.comment, event.last_updated';
}

sub _id_column
{
    return 'event.id';
}

sub _column_mapping
{
    return {
        type_id => 'type',
        begin_date => sub { MusicBrainz::Server::Entity::PartialDate->new_from_row(shift, shift() . 'begin_date_') },
        end_date => sub { MusicBrainz::Server::Entity::PartialDate->new_from_row(shift, shift() . 'end_date_') },
        map { $_ => $_ } qw( id gid comment setlist time ended name cancelled edits_pending last_updated)
    };
}

sub load
{
    my ($self, @objs) = @_;
    load_subobjects($self, 'event', @objs);
}

sub update
{
    my ($self, $event_id, $update) = @_;

    my $row = $self->_hash_to_row($update);

    $self->sql->update_row('event', $row, { id => $event_id }) if %$row;

    if (any { exists $update->{$_} } qw( name begin_date end_date time )) {
        $self->c->model('Series')->reorder_for_entities('event', $event_id);
    }

    return 1;
}

sub can_delete { 1 }

sub delete
{
    my ($self, @event_ids) = @_;

    $self->c->model('Collection')->delete_entities('event', @event_ids);
    $self->c->model('Relationship')->delete_entities('event', @event_ids);
    $self->annotation->delete(@event_ids);
    $self->alias->delete_entities(@event_ids);
    $self->tags->delete(@event_ids);
    $self->rating->delete(@event_ids);
    $self->remove_gid_redirects(@event_ids);
    $self->delete_returning_gids(@event_ids);
    return 1;
}

sub _merge_impl
{
    my ($self, $new_id, @old_ids) = @_;

    $self->alias->merge($new_id, @old_ids);
    $self->tags->merge($new_id, @old_ids);
    $self->rating->merge($new_id, @old_ids);
    $self->annotation->merge($new_id, @old_ids);
    $self->c->model('Edit')->merge_entities('event', $new_id, @old_ids);
    $self->c->model('Relationship')->merge_entities('event', $new_id, \@old_ids);
    $self->c->model('Collection')->merge_entities('event', $new_id, @old_ids);

    my @merge_options = ($self->sql => (
                           table => 'event',
                           old_ids => \@old_ids,
                           new_id => $new_id
                        ));

    merge_table_attributes(@merge_options, columns => [ qw( time type ) ]);
    merge_string_attributes(@merge_options, columns => [ qw( setlist ) ]);
    merge_date_period(@merge_options);

    $self->_delete_and_redirect_gids('event', $new_id, @old_ids);
    return 1;
}

sub _hash_to_row
{
    my ($self, $event, $names) = @_;
    my $row = hash_to_row($event, {
        type => 'type_id',
        map { $_ => $_ } qw( comment setlist time ended name cancelled )
    });

    add_partial_date_to_row($row, $event->{begin_date}, 'begin_date');
    add_partial_date_to_row($row, $event->{end_date}, 'end_date');
    return $row;
}

sub load_meta
{
    my $self = shift;
    MusicBrainz::Server::Data::Utils::load_meta($self->c, "event_meta", sub {
        my ($obj, $row) = @_;
        $obj->rating($row->{rating}) if defined $row->{rating};
        $obj->rating_count($row->{rating_count}) if defined $row->{rating_count};
    }, @_);
}

sub is_empty {
    my ($self, $event_id) = @_;

    my $used_in_relationship = used_in_relationship($self->c, event => 'event_row.id');
    return $self->sql->select_single_value(<<EOSQL, $event_id, $STATUS_OPEN);
        SELECT TRUE
        FROM event event_row
        WHERE id = ?
        AND edits_pending = 0
        AND NOT (
          EXISTS (
            SELECT TRUE
            FROM edit_event JOIN edit ON edit_event.edit = edit.id
            WHERE status = ? AND event = event_row.id
          ) OR
          $used_in_relationship
        )
EOSQL
}

sub load_related_info {
    my ($self, @events) = @_;

    my $c = $self->c;
    $c->model('Event')->load_performers(@events);
    $c->model('Event')->load_locations(@events);
    $c->model('EventType')->load(@events);
}

sub load_areas {
    my ($self, @events) = @_;

    my $c = $self->c;
    $c->model('Area')->load(map { map { $_->{entity} } $_->all_places } @events);
    $c->model('Area')->load_containment(map { (map { $_->{entity} } $_->all_areas),
                                              (map { $_->{entity}->area } $_->all_places) } @events);
}

sub find_by_area
{
    my ($self, $area_id, $limit, $offset) = @_;
    my (
        $containment_query,
        @containment_query_args,
    ) = get_area_containment_query('$2', 'lae.entity0');
    my $query =
        "SELECT " . $self->_columns ."
           FROM (
                    SELECT lae.entity1 AS event
                      FROM l_area_event lae
                     WHERE lae.entity0 = \$1 OR EXISTS (
                        SELECT 1 FROM ($containment_query) ac
                         WHERE ac.descendant = lae.entity0 AND ac.parent = \$1
                     )
                ) s, " . $self->_table . "
          WHERE event.id = s.event
       ORDER BY event.begin_date_year, event.begin_date_month, event.begin_date_day, event.time, musicbrainz_collate(event.name)";
    $self->query_to_list_limited(
        $query, [$area_id, @containment_query_args], $limit, $offset, undef,
        dollar_placeholders => 1,
    );
}

sub find_by_artist
{
    my ($self, $artist_id, $limit, $offset) = @_;

    my $query =
        'SELECT ' . $self->_columns .'
           FROM (
                    SELECT entity1 AS event
                      FROM l_artist_event ar
                      JOIN link ON ar.link = link.id
                      JOIN link_type lt ON lt.id = link.link_type
                     WHERE entity0 = ?
                ) s, ' . $self->_table .'
          WHERE event.id = s.event
       ORDER BY event.begin_date_year, event.begin_date_month, event.begin_date_day, event.time, musicbrainz_collate(event.name)';

    $self->query_to_list_limited($query, [$artist_id], $limit, $offset);
}

sub _order_by {
    my ($self, $order) = @_;
    $order = (($order // "") eq "") ? "-date" : $order;

    my $order_by = order_by($order, "date", {
        "date" => sub {
            return "begin_date_year, begin_date_month, begin_date_day, time, musicbrainz_collate(name)"
        },
        "name" => sub {
            return "musicbrainz_collate(name), begin_date_year, begin_date_month, begin_date_day, time"
        },
        "type" => sub {
            return "type, begin_date_year, begin_date_month, begin_date_day, time, musicbrainz_collate(name)"
        },
    });

    return $order_by;
}

sub find_by_place
{
    my ($self, $place_id, $limit, $offset) = @_;

    my $query =
        'SELECT ' . $self->_columns .'
           FROM (
                    SELECT entity0 AS event
                      FROM l_event_place ar
                      JOIN link ON ar.link = link.id
                      JOIN link_type lt ON lt.id = link.link_type
                     WHERE entity1 = ?
                ) s, ' . $self->_table .'
          WHERE event.id = s.event
       ORDER BY event.begin_date_year, event.begin_date_month, event.begin_date_day, event.time, musicbrainz_collate(event.name)';

    $self->query_to_list_limited($query, [$place_id], $limit, $offset);
}

=method find_related_entities

This method will return a map with lists of artists and locations
for the given event.

=cut

sub find_related_entities
{
    my ($self, $events, $limit) = @_;

    my @ids = map { $_->id } @$events;
    return () unless @ids;

    my (%performers, %places, %areas);
    $self->_find_performers(\@ids, \%performers);
    $self->_find_places(\@ids, \%places);
    $self->_find_areas(\@ids, \%areas);

    my %map = map +{
        $_ => {
            performers => { hits => 0, results => [] },
            places => { hits => 0, results => [] },
            areas => { hits => 0, results => [] }
        }
    }, @ids;

    for my $event_id (@ids) {
        my @performers = uniq map { $_->{entity}->name } @{ $performers{$event_id} };
        my @places = uniq map { $_->{entity}->name } @{ $places{$event_id} };
        my @areas = uniq map { $_->{entity}->name } @{ $areas{$event_id} };

        $map{$event_id} = {
            places => {
                hits => scalar @places,
                results => $limit && scalar @places > $limit
                    ? [ @places[ 0 .. ($limit-1) ] ]
                    : \@places,
            },
            areas => {
                hits => scalar @areas,
                results => $limit && scalar @areas > $limit
                    ? [ @areas[ 0 .. ($limit-1) ] ]
                    : \@areas,
            },
            performers => {
                hits => scalar @performers,
                results => $limit && scalar @performers > $limit
                    ? [ @performers[ 0 .. ($limit-1) ] ]
                    : \@performers,
            },
        }
    }

    return %map;
}

=method load_ids

Load internal IDs for event objects that only have GIDs.

=cut

sub load_ids
{
    my ($self, @events) = @_;

    my @gids = map { $_->gid } @events;
    return () unless @gids;

    my $query = "
        SELECT gid, id FROM event
        WHERE gid IN (" . placeholders(@gids) . ")
    ";
    my %map = map { $_->[0] => $_->[1] }
        @{ $self->sql->select_list_of_lists($query, @gids) };

    for my $event (@events) {
        $event->id($map{$event->gid}) if exists $map{$event->gid};
    }
}

=method load_performers

This method will load the event's performers based on the event-artist
relationships.

=cut

sub load_performers
{
    my ($self, @events) = @_;

    @events = grep { scalar $_->all_performers == 0 } @events;
    my @ids = map { $_->id } @events;
    return () unless @ids;

    my %map;
    $self->_find_performers(\@ids, \%map);
    for my $event (@events) {
        $event->add_performer(@{ $map{$event->id} })
            if exists $map{$event->id};
    }
}

sub _find_performers
{
    my ($self, $ids, $map) = @_;
    return unless @$ids;

    my $query = "
        SELECT lae.entity1 AS event, lae.entity0 AS artist,
            lae.entity0_credit AS credit, array_agg(lt.name) AS roles
        FROM l_artist_event lae
        JOIN link l ON lae.link = l.id
        JOIN link_type lt ON l.link_type = lt.id
        WHERE lae.entity1 IN (" . placeholders(@$ids) . ")
        GROUP BY lae.entity1, lae.entity0, lae.entity0_credit
        ORDER BY count(*) DESC, artist, credit
    ";

    my $rows = $self->sql->select_list_of_lists($query, @$ids);

    my @artist_ids = map { $_->[1] } @$rows;
    my $artists = $self->c->model('Artist')->get_by_ids(@artist_ids);

    for my $row (@$rows) {
        my ($event_id, $artist_id, $credit, $roles) = @$row;
        $map->{$event_id} ||= [];
        push @{ $map->{$event_id} }, {
            credit => $credit,
            entity => $artists->{$artist_id},
            roles => [ uniq @{ $roles } ]
        }
    }
}

=method load_locations

This method will load the event's locations based on the event-place and event-area relationships.

=cut

sub load_locations
{
    my ($self, @events) = @_;

    @events = grep { (scalar $_->all_places == 0) && (scalar $_->all_areas == 0) } @events;
    my @ids = map { $_->id } @events;
    return () unless @ids;

    my %places_map;
    $self->_find_places(\@ids, \%places_map);
    for my $event (@events) {
        $event->add_place(@{ $places_map{$event->id} })
            if exists $places_map{$event->id};
    }

    my %areas_map;
    $self->_find_areas(\@ids, \%areas_map);
    for my $event (@events) {
        $event->add_area(@{ $areas_map{$event->id} })
            if exists $areas_map{$event->id};
    }
}

sub _find_places
{
    my ($self, $ids, $map) = @_;
    return unless @$ids;

    my $query = "
        SELECT lep.entity0 AS event, lep.entity1 AS place
        FROM l_event_place lep
        JOIN link l ON lep.link = l.id
        JOIN link_type lt ON l.link_type = lt.id
        WHERE lep.entity0 IN (" . placeholders(@$ids) . ")
        GROUP BY lep.entity0, lep.entity1
        ORDER BY count(*) DESC, place
    ";

    my $rows = $self->sql->select_list_of_lists($query, @$ids);

    my @place_ids = map { $_->[1] } @$rows;
    my $places = $self->c->model('Place')->get_by_ids(@place_ids);

    for my $row (@$rows) {
        my ($event_id, $place_id) = @$row;
        $map->{$event_id} ||= [];
        push @{ $map->{$event_id} }, {
            entity => $places->{$place_id}
        }
    }
}

sub _find_areas
{
    my ($self, $ids, $map) = @_;
    return unless @$ids;

    my $query = "
        SELECT lare.entity1 AS event, lare.entity0 AS area
        FROM l_area_event lare
        JOIN link l ON lare.link = l.id
        JOIN link_type lt ON l.link_type = lt.id
        WHERE lare.entity1 IN (" . placeholders(@$ids) . ")
        GROUP BY lare.entity1, lare.entity0
        ORDER BY count(*) DESC, area
    ";

    my $rows = $self->sql->select_list_of_lists($query, @$ids);

    my @area_ids = map { $_->[1] } @$rows;
    my $areas = $self->c->model('Area')->get_by_ids(@area_ids);

    for my $row (@$rows) {
        my ($event_id, $area_id) = @$row;
        $map->{$event_id} ||= [];
        push @{ $map->{$event_id} }, {
            entity => $areas->{$area_id}
        }
    }
}

sub series_ordering {
    my ($self, $a, $b) = @_;

    my $zero = DateTime->new(year => 0);

    $a->entity0->begin_date <=> $b->entity0->begin_date ||
    $a->entity0->end_date <=> $b->entity0->end_date ||
    ($a->entity0->time // $zero) <=> ($b->entity0->time // $zero);
}

__PACKAGE__->meta->make_immutable;
no Moose;
1;

=head1 COPYRIGHT

Copyright (C) 2014 MetaBrainz Foundation

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
