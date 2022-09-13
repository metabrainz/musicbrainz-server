package MusicBrainz::Server::Edit::Event::Create;
use Moose;

use MusicBrainz::Server::Constants qw( $EDIT_EVENT_CREATE );
use MusicBrainz::Server::Data::Utils qw( boolean_to_json );
use MusicBrainz::Server::Edit::Types qw( Nullable PartialDateHash );
use MusicBrainz::Server::Entity::Util::JSON qw( to_json_object );
use MusicBrainz::Server::Translation qw( N_l );
use aliased 'MusicBrainz::Server::Entity::PartialDate';
use Moose::Util::TypeConstraints;
use MooseX::Types::Moose qw( Bool Str Int );
use MooseX::Types::Structured qw( Dict );

use aliased 'MusicBrainz::Server::Entity::Event';

extends 'MusicBrainz::Server::Edit::Generic::Create';
with 'MusicBrainz::Server::Edit::Role::Preview';
with 'MusicBrainz::Server::Edit::Event';
with 'MusicBrainz::Server::Edit::Role::AlwaysAutoEdit';
with 'MusicBrainz::Server::Edit::Role::DatePeriod';

sub edit_name { N_l('Add event') }
sub edit_type { $EDIT_EVENT_CREATE }
sub _create_model { 'Event' }
sub event_id { shift->entity_id }

has '+data' => (
    isa => Dict[
        name        => Str,
        comment     => Str,
        type_id     => Nullable[Int],
        setlist     => Str,
        time        => Nullable[Str],
        begin_date  => Nullable[PartialDateHash],
        end_date    => Nullable[PartialDateHash],
        ended       => Bool,
        cancelled   => Bool,
    ]
);

sub foreign_keys
{
    my $self = shift;
    return {
        Event       => [ $self->entity_id ],
        EventType   => [ $self->data->{type_id} ],
    };
}

sub build_display_data
{
    my ($self, $loaded) = @_;

    my $type = $self->data->{type_id};
    my $event = to_json_object((defined($self->entity_id) &&
            $loaded->{Event}{ $self->entity_id }) ||
            Event->new( name => $self->data->{name} )
    );

    return {
        name        => $self->data->{name} // '',
        type        => $type ? to_json_object($loaded->{EventType}{$type}) : undef,
        begin_date  => to_json_object(PartialDate->new($self->data->{begin_date})),
        end_date    => to_json_object(PartialDate->new($self->data->{end_date})),
        event       => $event,
        ended       => boolean_to_json($self->data->{ended}),
        cancelled   => boolean_to_json($self->data->{cancelled}),
        comment     => $self->data->{comment},
        time        => $self->data->{time},
        setlist     => $self->data->{setlist}
    };
}

sub edit_template { 'AddEvent' };

__PACKAGE__->meta->make_immutable;
no Moose;

1;
