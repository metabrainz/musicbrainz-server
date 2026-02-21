package MusicBrainz::Server::Edit::Relationship::RemoveLinkAttribute;
use Moose;
use MooseX::Types::Structured qw( Dict Optional );
use MooseX::Types::Moose qw( Str Int );
use MusicBrainz::Server::Constants qw( $EDIT_RELATIONSHIP_REMOVE_LINK_ATTRIBUTE );
use MusicBrainz::Server::Edit::Constants qw( %EDIT_KIND_LABELS );
use MusicBrainz::Server::Edit::Types qw( Nullable );
use MusicBrainz::Server::Translation qw( N_lp );

extends 'MusicBrainz::Server::Edit';
with 'MusicBrainz::Server::Edit::Relationship',
     'MusicBrainz::Server::Edit::Role::AlwaysAutoEdit';

sub edit_name { N_lp('Remove relationship attribute', 'edit type') }
sub edit_kind { $EDIT_KIND_LABELS{'remove'} }
sub edit_type { $EDIT_RELATIONSHIP_REMOVE_LINK_ATTRIBUTE }
sub edit_template { 'RemoveRelationshipAttribute' }

has '+data' => (
    isa => Dict[
        name        => Str,
        description => Nullable[Str],
        id          => Int,
        parent_id   => Nullable[Int],
        child_order => Optional[Str],
    ],
);

sub build_display_data {
    my ($self, $loaded) = @_;

    return {
        description => $self->data->{description},
        name => $self->data->{name},
    };
}

sub accept {
    my $self = shift;
    $self->c->model('LinkAttributeType')->delete($self->data->{id});
}

no Moose;
__PACKAGE__->meta->make_immutable;

1;
