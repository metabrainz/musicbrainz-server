package MusicBrainz::Server::Edit::Event::Create;
use Moose;

use MusicBrainz::Server::Constants qw( $EDIT_EVENT_CREATE );
use MusicBrainz::Server::Edit::Types qw( Nullable PartialDateHash );
use MusicBrainz::Server::Translation qw( N_l );
use aliased 'MusicBrainz::Server::Entity::PartialDate';
use Moose::Util::TypeConstraints;
use MooseX::Types::Moose qw( ArrayRef Bool Str Int );
use MooseX::Types::Structured qw( Dict Optional );

use aliased 'MusicBrainz::Server::Entity::Event';

extends 'MusicBrainz::Server::Edit::Generic::Create';
with 'MusicBrainz::Server::Edit::Role::Preview';
with 'MusicBrainz::Server::Edit::Event';

sub edit_name { N_l('Add event') }
sub edit_type { $EDIT_EVENT_CREATE }
sub _create_model { 'Event' }
sub event_id { shift->entity_id }

has '+data' => (
    isa => Dict[
        name        => Str,
        comment     => Nullable[Str],
        type_id     => Nullable[Int],
        setlist     => Nullable[Str],
        time        => Nullable[Str],
        begin_date  => Nullable[PartialDateHash],
        end_date    => Nullable[PartialDateHash],
        ended       => Optional[Bool],
        cancelled   => Optional[Bool],
    ]
);

sub foreign_keys
{
    my $self = shift;
    return {
        event       => [ $self->entity_id ],
        eventType   => [ $self->data->{type_id} ],
    };
}

sub build_display_data
{
    my ($self, $loaded) = @_;

    my $type = $self->data->{type_id};

    return {
        ( map { $_ => $_ ? $self->data->{$_} : '' } qw( name ) ),
        type        => $type ? $loaded->{eventType}->{$type} : '',
        begin_date  => PartialDate->new($self->data->{begin_date}),
        end_date    => PartialDate->new($self->data->{end_date}),
        event       => ($self->entity_id && $loaded->{event}->{ $self->entity_id }) ||
            event->new( name => $self->data->{name} ),
        ended       => $self->data->{ended} // 0,
        cancelled   => $self->data->{cancelled} // 0,
        comment     => $self->data->{comment},
        time        => $self->data->{time},
        setlist     => $self->data->{setlist}
    };
}

sub allow_auto_edit { 1 }

__PACKAGE__->meta->make_immutable;
no Moose;

1;
