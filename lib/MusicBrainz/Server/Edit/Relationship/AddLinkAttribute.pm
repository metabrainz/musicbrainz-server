package MusicBrainz::Server::Edit::Relationship::AddLinkAttribute;
use Moose;
use MooseX::Types::Structured qw( Dict Optional );
use MooseX::Types::Moose qw( Bool Int Str );
use MusicBrainz::Server::Constants qw( $EDIT_RELATIONSHIP_ADD_ATTRIBUTE );
use MusicBrainz::Server::Data::Utils qw( boolean_to_json );
use MusicBrainz::Server::Edit::Types qw( Nullable );
use MusicBrainz::Server::Entity::Util::JSON qw( to_json_object );
use MusicBrainz::Server::Translation qw( N_l );

extends 'MusicBrainz::Server::Edit';
with 'MusicBrainz::Server::Edit::Relationship',
     'MusicBrainz::Server::Edit::Role::Insert',
     'MusicBrainz::Server::Edit::Role::AlwaysAutoEdit';

sub edit_name { N_l('Add relationship attribute') }
sub edit_kind { 'add' }
sub edit_type { $EDIT_RELATIONSHIP_ADD_ATTRIBUTE }
sub edit_template { 'AddRelationshipAttribute' }

has '+data' => (
    isa => Dict[
        name        => Str,
        parent_id   => Nullable[Int],
        description => Nullable[Str],
        child_order => Str,
        creditable => Optional[Bool],
        free_text => Optional[Bool],
    ],
);

sub foreign_keys
{
    my $self = shift;
    return {
        LinkAttributeType => [ $self->data->{parent_id} ],
    };
}

sub build_display_data
{
    my ($self, $loaded) = @_;
    my $parent_id = $self->data->{parent_id};

    return {
        child_order => $self->data->{child_order},
        description => $self->data->{description},
        name => $self->data->{name},
        parent => defined $parent_id ? to_json_object($loaded->{LinkAttributeType}{$parent_id}) : undef,
        creditable => boolean_to_json($self->data->{creditable}),
        free_text => boolean_to_json($self->data->{free_text}),
    };
}

sub insert {
    my $self = shift;

    my $entity = $self->c->model('LinkAttributeType')->insert($self->data);
    $self->entity_id($entity->id);
    $self->entity_gid($entity->gid);
}

sub reject {
    MusicBrainz::Server::Edit::Exceptions::MustApply->throw(
        'Edits of this type cannot be rejected',
    );
}


no Moose;
__PACKAGE__->meta->make_immutable;

1;
