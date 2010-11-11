package MusicBrainz::Server::Edit::Relationship::AddLinkAttribute;
use Moose;
use MooseX::Types::Structured qw( Dict );
use MooseX::Types::Moose qw( Int Str );
use MusicBrainz::Server::Constants qw( $EDIT_RELATIONSHIP_ADD_ATTRIBUTE );
use MusicBrainz::Server::Translation qw( l ln );

extends 'MusicBrainz::Server::Edit';

sub edit_name { l('Add relationship attribute') }
sub edit_type { $EDIT_RELATIONSHIP_ADD_ATTRIBUTE }

has '+data' => (
    isa => Dict[
        name        => Str,
        parent_id   => Int,
        description => Str,
        child_order => Str
    ]
);

sub foreign_keys
{
    my $self = shift;
    return {
        LinkAttributeType => [ $self->data->{parent_id} ],
    }
}

sub build_display_data
{
    my ($self, $loaded) = @_;
    return {
        parent => $loaded->{LinkAttributeType}->{ $self->data->{parent_id} }
    }
}

no Moose;
__PACKAGE__->meta->make_immutable;
