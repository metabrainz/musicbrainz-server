package MusicBrainz::Server::Edit::Relationship::AddLinkType;
use Moose;
use MooseX::Types::Moose qw( Bool Int Str ArrayRef );
use MooseX::Types::Structured qw( Dict  Optional );
use MusicBrainz::Server::Constants qw( $EDIT_RELATIONSHIP_ADD_TYPE );
use MusicBrainz::Server::Edit::Types qw( Nullable );
use MusicBrainz::Server::Translation qw( N_l );

extends 'MusicBrainz::Server::Edit';
with 'MusicBrainz::Server::Edit::Relationship';
with 'MusicBrainz::Server::Edit::Role::AlwaysAutoEdit';

sub edit_name { N_l('Add relationship type') }
sub edit_kind { 'add' }
sub edit_type { $EDIT_RELATIONSHIP_ADD_TYPE }

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
        entity1_cardinality => Optional[Int]
    ]
);

sub foreign_keys {
    my $self = shift;
    return {
        LinkAttributeType => [
            grep { defined }
            map { $_->{type} }
                @{ $self->data->{attributes} }
            ]
    }
}

has entity_id => (
    isa => 'Int',
    is => 'rw'
);

sub accept {
    my $self = shift;
    $self->entity_id($self->c->model('LinkType')->insert($self->data)->id);
}

sub build_display_data {
    my ($self, $loaded) = @_;

    return {
        attributes => $self->_build_attributes($self->data->{attributes}, $loaded),
    }
}

sub _build_attributes {
    my ($self, $list, $loaded) = @_;
    return [
        map {
            MusicBrainz::Server::Entity::LinkTypeAttribute->new(
                min => $_->{min},
                max => $_->{max},
                type => $loaded->{LinkAttributeType}{ $_->{type} } ||
                    MusicBrainz::Server::Entity::LinkAttributeType->new(
                        name => $_->{name}
                    )
                  )
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
