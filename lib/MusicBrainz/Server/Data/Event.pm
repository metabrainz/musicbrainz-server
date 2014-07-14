package MusicBrainz::Server::Data::Event;

use Moose;
use namespace::autoclean;
use List::AllUtils qw( uniq zip );
use MusicBrainz::Server::Constants qw( $STATUS_OPEN );
use MusicBrainz::Server::Data::Edit;
use MusicBrainz::Server::Entity::Event;
use MusicBrainz::Server::Entity::PartialDate;
use MusicBrainz::Server::Data::Utils qw(
    add_partial_date_to_row
    generate_gid
    hash_to_row
    load_subobjects
    merge_table_attributes
    merge_string_attributes
    merge_partial_date
    placeholders
);
use MusicBrainz::Server::Data::Utils::Cleanup qw( used_in_relationship );

extends 'MusicBrainz::Server::Data::CoreEntity';
with 'MusicBrainz::Server::Data::Role::Annotation' => { type => 'event' };
with 'MusicBrainz::Server::Data::Role::Name' => { name_table => undef };
with 'MusicBrainz::Server::Data::Role::Alias' => { type => 'event' };
with 'MusicBrainz::Server::Data::Role::CoreEntityCache' => { prefix => 'event' };
with 'MusicBrainz::Server::Data::Role::Editable' => { table => 'event' };
with 'MusicBrainz::Server::Data::Role::Rating' => { type => 'event' };
with 'MusicBrainz::Server::Data::Role::Tag' => { type => 'event' };
with 'MusicBrainz::Server::Data::Role::Browse';
with 'MusicBrainz::Server::Data::Role::LinksToEdit' => { table => 'event' };
with 'MusicBrainz::Server::Data::Role::Merge';

sub _table
{
    return 'event ';
}

sub _columns
{
    return 'event.id, event.gid, event.name, event.type, event.time, event.cancelled,' .
           'event.setlist, event.edits_pending, event.begin_date_year, ' .
           'event.begin_date_month, event.begin_date_day, event.end_date_year, ' .
           'event.end_date_month, event.end_date_day, event.ended, ' . 
           'event.comment, event.last_updated';
}

sub browse_column { 'name' }

sub _id_column
{
    return 'event.id';
}

sub _gid_redirect_table
{
    return 'event_gid_redirect';
}

sub _column_mapping
{
    return {
        id => 'id',
        gid => 'gid',
        name => 'name',
        type_id => 'type',
        time => 'time',
        setlist => 'setlist',
        begin_date => sub { MusicBrainz::Server::Entity::PartialDate->new_from_row(shift, shift() . 'begin_date_') },
        end_date => sub { MusicBrainz::Server::Entity::PartialDate->new_from_row(shift, shift() . 'end_date_') },
        edits_pending => 'edits_pending',
        comment => 'comment',
        last_updated => 'last_updated',
        ended => 'ended',
        cancelled => 'cancelled'
    };
}

sub _entity_class
{
    return 'MusicBrainz::Server::Entity::Event';
}

sub load
{
    my ($self, @objs) = @_;
    load_subobjects($self, 'event', @objs);
}

sub insert
{
    my ($self, @events) = @_;
    my $class = $self->_entity_class;
    my @created;
    for my $event (@events)
    {
        my $row = $self->_hash_to_row($event);
        $row->{gid} = $event->{gid} || generate_gid();

        my $created = $class->new(
            name => $event->{name},
            id => $self->sql->insert_row('event', $row, 'id'),
            gid => $row->{gid}
        );

        push @created, $created;
    }
    return @events > 1 ? @created : $created[0];
}

sub update
{
    my ($self, $event_id, $update) = @_;

    my $row = $self->_hash_to_row($update);

    $self->sql->update_row('event', $row, { id => $event_id }) if %$row;

    return 1;
}

sub can_delete { 1 }

sub delete
{
    my ($self, @event_ids) = @_;

    $self->c->model('Relationship')->delete_entities('event', @event_ids);
    $self->annotation->delete(@event_ids);
    $self->alias->delete_entities(@event_ids);
    $self->tags->delete(@event_ids);
    $self->rating->delete(@event_ids);
    $self->remove_gid_redirects(@event_ids);
    $self->delete_returning_gids('event', @event_ids);
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
    $self->c->model('Relationship')->merge_entities('event', $new_id, @old_ids);

    my @merge_options = ($self->sql => (
                           table => 'event',
                           old_ids => \@old_ids,
                           new_id => $new_id
                        ));

    merge_table_attributes(@merge_options, columns => [ qw( time type ) ]);
    merge_string_attributes(@merge_options, columns => [ qw( setlist ) ]);
    merge_partial_date(@merge_options, field => $_) for qw( begin_date end_date );

    $self->_delete_and_redirect_gids('event', $new_id, @old_ids);
    return 1;
}

sub _hash_to_row
{
    my ($self, $event, $names) = @_;
    my $row = hash_to_row($event, {
        type => 'type_id',
        ended => 'ended',
        name => 'name',
        cancelled => 'cancelled',
        map { $_ => $_ } qw( comment setlist time)
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

=method find_artists

This method will return a map with lists of artist names for the given
event. 

=cut

sub find_artists
{
    my ($self, $events, $limit) = @_;

    my @ids = map { $_->id } @$events;
    return () unless @ids;

    my (%performers);
    $self->_find_performers(\@ids, \%performers);

    my %map = map +{
        $_ => {
            performers => { hits => 0, results => [] }
        }
    }, @ids;

    for my $event_id (@ids) {
        my @performers = uniq map { $_->{entity}->name } @{ $performers{$event_id} };

        $map{$event_id} = {
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
        SELECT lae.entity1 AS event, lae.entity0 AS artist, array_agg(lt.name) AS roles
        FROM l_artist_event lae
        JOIN link l ON lae.link = l.id
        JOIN link_type lt ON l.link_type = lt.id
        WHERE lae.entity1 IN (" . placeholders(@$ids) . ")
        GROUP BY lae.entity1, lae.entity0
        ORDER BY count(*) DESC, artist
    ";

    my $rows = $self->sql->select_list_of_lists($query, @$ids);

    my @artist_ids = map { $_->[1] } @$rows;
    my $artists = $self->c->model('Artist')->get_by_ids(@artist_ids);

    for my $row (@$rows) {
        my ($event_id, $artist_id, $roles) = @$row;
        $map->{$event_id} ||= [];
        push @{ $map->{$event_id} }, {
            entity => $artists->{$artist_id},
            roles => $roles
        }
    }
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
