package MusicBrainz::Server::Edit::Relationship::AddLinkType;
use Moose;
use MooseX::Types::Moose qw( Bool Int Str ArrayRef );
use MooseX::Types::Structured qw( Dict  Optional );
use MusicBrainz::Server::Constants qw( $EDIT_RELATIONSHIP_ADD_TYPE );
use MusicBrainz::Server::Edit::Types qw( Nullable );
use MusicBrainz::Server::Entity::Util::JSON qw( to_json_object );
use MusicBrainz::Server::Translation qw( N_l );

extends 'MusicBrainz::Server::Edit';
with 'MusicBrainz::Server::Edit::Relationship';
with 'MusicBrainz::Server::Edit::Role::Insert';
with 'MusicBrainz::Server::Edit::Role::AlwaysAutoEdit';

sub edit_name { N_l('Add relationship type') }
sub edit_kind { 'add' }
sub edit_type { $EDIT_RELATIONSHIP_ADD_TYPE }
sub edit_template { 'AddRelationshipType' }

has '+data' => (
    isa => Dict[
        entity0_type        => Str,
        entity1_type        => Str,
        name                => Str,
        parent_id           => Nullable[Str],
        gid                 => Nullable[Str],
        link_phrase         => Str,
        long_link_phrase   => Optional[Str],
        reverse_link_phrase => Str,
        child_order         => Optional[Int],
        description         => Nullable[Str],
        priority            => Optional[Int],
        attributes => ArrayRef[Dict[
            name => Optional[Str], # Used in old historic edits
            min  => Nullable[Int],
            max  => Nullable[Int],
            type => Optional[Int], # Used in the new edits
        ]],
        documentation => Optional[Str],
        is_deprecated => Optional[Bool],
        has_dates => Optional[Bool],
        entity0_cardinality => Optional[Int],
        entity1_cardinality => Optional[Int],
        orderable_direction => Optional[Int]
    ]
);

sub foreign_keys {
    my $self = shift;
    return {
        LinkType => [ $self->entity_id ],
        LinkAttributeType => [
            grep { defined }
            map { $_->{type} }
                @{ $self->data->{attributes} }
            ]
    }
}

sub insert {
    my $self = shift;

    my $entity = $self->c->model('LinkType')->insert($self->data);
    $self->entity_id($entity->id);
    $self->entity_gid($entity->gid);
}

sub reject {
    MusicBrainz::Server::Edit::Exceptions::MustApply->throw(
        'Edits of this type cannot be rejected'
    );
}

sub build_display_data {
    my ($self, $loaded) = @_;

    return {
        attributes => $self->_build_attributes($self->data->{attributes}, $loaded),
        description => $self->data->{description},
        documentation => $self->data->{documentation},
        entity0_cardinality => $self->data->{entity0_cardinality},
        entity0_type => $self->data->{entity0_type},
        entity1_cardinality => $self->data->{entity1_cardinality},
        entity1_type => $self->data->{entity1_type},
        link_phrase => $self->data->{link_phrase},
        long_link_phrase => $self->data->{long_link_phrase},
        name => $self->data->{name},
        orderable_direction => $self->data->{orderable_direction},
        defined($self->entity_id) ? (relationship_type => to_json_object(
            $loaded->{LinkType}{ $self->entity_id } ||
            MusicBrainz::Server::Entity::LinkType->new( name => $self->data->{name} ))
        ) : (),
        reverse_link_phrase => $self->data->{reverse_link_phrase},
    }
}

sub _build_attributes {
    my ($self, $list, $loaded) = @_;
    return [
        map {
            to_json_object(MusicBrainz::Server::Entity::LinkTypeAttribute->new(
                min => $_->{min},
                max => $_->{max},
                type => $loaded->{LinkAttributeType}{ $_->{type} } ||
                    MusicBrainz::Server::Entity::LinkAttributeType->new(
                        name => $_->{name}
                    )
                  ))
          } @$list
    ]
}

before restore => sub {
    my ($self, $data) = @_;
    $data->{long_link_phrase} = delete $data->{short_link_phrase}
        if exists $data->{short_link_phrase};
};

no Moose;
__PACKAGE__->meta->make_immutable;
