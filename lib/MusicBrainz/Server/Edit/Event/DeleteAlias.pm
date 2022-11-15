package MusicBrainz::Server::Edit::Event::DeleteAlias;
use Moose;

use MusicBrainz::Server::Constants qw( $EDIT_EVENT_DELETE_ALIAS );
use MusicBrainz::Server::Entity::Types;
use MusicBrainz::Server::Entity::Util::JSON qw( to_json_object );
use MusicBrainz::Server::Translation qw( N_l );

extends 'MusicBrainz::Server::Edit::Alias::Delete';
with 'MusicBrainz::Server::Edit::Event';

use aliased 'MusicBrainz::Server::Entity::Event';

sub _alias_model { shift->c->model('Event')->alias }

sub edit_name { N_l('Remove event alias') }
sub edit_kind { 'remove' }
sub edit_type { $EDIT_EVENT_DELETE_ALIAS }

sub _build_related_entities { { event => [ shift->event_id ] } }

sub adjust_edit_pending
{
    my ($self, $adjust) = @_;

    $self->c->model('Event')->adjust_edit_pending($adjust, $self->event_id);
    $self->c->model('Event')->alias->adjust_edit_pending($adjust, $self->alias_id);
}

sub models {
    my $self = shift;
    return [ $self->c->model('Event'), $self->c->model('Event')->alias ];
}

has 'event_id' => (
    isa => 'Int',
    is => 'rw',
    lazy => 1,
    default => sub { shift->data->{entity}{id} }
);

has 'event' => (
    isa => 'Event',
    is => 'rw'
);

sub foreign_keys
{
    my $self = shift;
    return {
        Event => [ $self->event_id ],
    };
}

around 'build_display_data' => sub
{
    my $orig = shift;
    my ($self, $loaded) = @_;

    my $data = $self->$orig($loaded);
    $data->{event} = to_json_object(
        $loaded->{Event}{ $self->event_id } ||
        Event->new(name => $self->data->{entity}{name})
    );

    return $data;
};


__PACKAGE__->meta->make_immutable;
no Moose;

1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2014 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
