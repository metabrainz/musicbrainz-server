package MusicBrainz::Server::Edit::Relationship::EditLinkAttribute;
use Moose;
use MooseX::Types::Structured qw( Dict Optional );
use MooseX::Types::Moose qw( Int Str );
use MusicBrainz::Server::Constants qw( $EDIT_RELATIONSHIP_ATTRIBUTE );
use MusicBrainz::Server::Edit::Types qw( Nullable );
use MusicBrainz::Server::Edit::Utils qw( changed_display_data );

extends 'MusicBrainz::Server::Edit';

sub edit_name { 'Edit relationship attribute' }
sub edit_type { $EDIT_RELATIONSHIP_ATTRIBUTE }

sub change_fields
{
    return Dict[
        name        => Optional[Str],
        description => Nullable[Str],
        parent_id   => Nullable[Int],
        child_order => Optional[Int]
    ]
}

has '+data' => (
    isa => Dict[
        entity_id => Int,
        old       => change_fields(),
        new       => change_fields()
    ]
);

sub foreign_keys
{
    my $self = shift;
    return {
        LinkAttributeType => [ map { $self->data->{$_}{parent_id} } qw( old new ) ],
    };
}

sub build_display_data
{
    my ($self, $loaded) = @_;

    my %map = (
        parent      => [ qw( parent_id LinkAttributeType )],
        name        => 'name',
        description => 'description',
        child_order => 'child_order',
    );

    my $data = changed_display_data($self->data, $loaded, %map);
    return $data;
}

no Moose;
__PACKAGE__->meta->make_immutable;

