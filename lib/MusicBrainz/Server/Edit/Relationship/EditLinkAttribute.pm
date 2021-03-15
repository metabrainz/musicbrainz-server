package MusicBrainz::Server::Edit::Relationship::EditLinkAttribute;
use Moose;
use MooseX::Types::Structured qw( Dict Optional );
use MooseX::Types::Moose qw( Int Str );
use MusicBrainz::Server::Constants qw( $EDIT_RELATIONSHIP_ATTRIBUTE );
use MusicBrainz::Server::Edit::Types qw( Nullable );
use MusicBrainz::Server::Edit::Utils qw( changed_display_data );
use MusicBrainz::Server::Entity::Util::JSON qw( to_json_object );
use MusicBrainz::Server::Translation qw( N_l );

extends 'MusicBrainz::Server::Edit';
with 'MusicBrainz::Server::Edit::Relationship';
with 'MusicBrainz::Server::Edit::Role::AlwaysAutoEdit';

sub edit_name { N_l('Edit relationship attribute') }
sub edit_kind { 'edit' }
sub edit_type { $EDIT_RELATIONSHIP_ATTRIBUTE }
sub edit_template_react { 'EditRelationshipAttribute' }

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

    if (exists $data->{parent}) {
        $data->{parent}{old} = to_json_object($data->{parent}{old});
        $data->{parent}{new} = to_json_object($data->{parent}{new});
    }

    return $data;
}

sub accept {
    my $self = shift;
    $self->c->model('LinkAttributeType')->update($self->data->{entity_id},
                                                 $self->data->{new})
};

no Moose;
__PACKAGE__->meta->make_immutable;

