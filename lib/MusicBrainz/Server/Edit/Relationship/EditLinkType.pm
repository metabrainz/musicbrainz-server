package MusicBrainz::Server::Edit::Relationship::EditLinkType;
use Moose;
use Data::Compare;
use MooseX::Types::Moose qw( ArrayRef Bool Int Str );
use MooseX::Types::Structured qw( Dict  Optional Tuple );
use MusicBrainz::Server::Constants qw( $EDIT_RELATIONSHIP_EDIT_LINK_TYPE );
use MusicBrainz::Server::Data::Utils qw( type_to_model );
use MusicBrainz::Server::Edit::Types qw( Nullable PartialDateHash );
use MusicBrainz::Server::Entity::ExampleRelationship;
use MusicBrainz::Server::Entity::Link;
use MusicBrainz::Server::Entity::Relationship;
use MusicBrainz::Server::Translation qw( N_l );
use Scalar::Util qw( looks_like_number );

use aliased 'MusicBrainz::Server::Entity::LinkType';

extends 'MusicBrainz::Server::Edit';
with 'MusicBrainz::Server::Edit::Relationship';
with 'MusicBrainz::Server::Edit::Role::AlwaysAutoEdit';

sub edit_name { N_l('Edit relationship type') }
sub edit_kind { 'edit' }
sub edit_type { $EDIT_RELATIONSHIP_EDIT_LINK_TYPE }

sub change_fields
{
    return Dict[
        parent_id           => Nullable[Str],
        name                => Optional[Str],
        child_order         => Optional[Int],
        link_phrase         => Optional[Str],
        reverse_link_phrase => Optional[Str],
        long_link_phrase   => Optional[Str],
        description         => Nullable[Str],
        priority            => Optional[Int],
        attributes          => Optional[ArrayRef[Dict[
            name => Str,
            min  => Nullable[Int],
            max  => Nullable[Int],
            type => Int,
        ]]],
        documentation => Optional[Str],
        is_deprecated => Optional[Bool],
        has_dates => Optional[Bool],
        entity0_cardinality => Optional[Int],
        entity1_cardinality => Optional[Int],
        orderable_direction => Optional[Int],
        examples => Optional[ArrayRef[Dict[
            relationship => Dict[
                id => Int,
                entity0 => Dict[
                    id => Int,
                    name => Str,
                    gid => Str,
                    comment => Str
                ],
                entity1 => Dict[
                    id => Int,
                    name => Str,
                    gid => Str,
                    comment => Str
                ],
                verbose_phrase => Str,
                link => Dict[
                    begin_date => PartialDateHash,
                    end_date => PartialDateHash,
                    link_type => Dict[
                        entity0_type => Str,
                        entity1_type => Str
                    ]
                ]
            ],
            name => Str,
            published => Bool
        ]]]
    ]
}

has '+data' => (
    isa => Dict[
        link_id => Int,
        old     => change_fields(),
        new     => change_fields(),
        types   => Optional[Tuple[Str, Str]],
    ]
);

sub foreign_keys {
    my $self = shift;
    return {
        LinkAttributeType => [
            grep { defined }
            map { $_->{type} }
                @{ $self->data->{old}{attributes} },
                @{ $self->data->{new}{attributes} }
            ],
        LinkType => [ $self->data->{link_id},
            grep { looks_like_number($_) }
            map { $self->data->{$_}{parent_id} }
                qw( old new )
            ]
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

sub build_display_data {
    my ($self, $loaded) = @_;
    my $display_data = {};

    my ($old_attributes, $new_attributes) =
        map { $self->data->{$_}{attributes} } qw( old new );

    if (!Compare($old_attributes, $new_attributes)) {
        $display_data->{attributes} = {
            old => $self->_build_attributes($old_attributes, $loaded),
            new => $self->_build_attributes($new_attributes, $loaded),
        };
    }

    $display_data->{link_type} = $loaded->{LinkType}{ $self->data->{link_id} };

    if ($self->data->{old}{parent_id} != $self->data->{new}{parent_id} || $self->data->{old}{parent_id} ne $self->data->{new}{parent_id}) {
        $display_data->{parent} = {
            map {
                $_ => $loaded->{LinkType}{ $self->data->{$_}{parent_id} } // (looks_like_number($self->data->{$_}{parent_id} // 0) ? undef : LinkType->new( name => $self->data->{$_}{parent_id} ));
            } qw( old new )
        }
    }

    my ($old_examples, $new_examples) =
        map { $self->data->{$_}{examples} } qw( old new );

    if (!Compare($old_examples, $new_examples)) {
        $display_data->{examples} = {
            map {
                $_ => [
                    map {
                        my $data = $_;
                        my ($class0, $class1) = map {
                            $self->c->model(
                                type_to_model($data->{relationship}{link}{link_type}{$_})
                            )->_entity_class;
                        } qw( entity0_type entity1_type );

                        my $rel = $_->{relationship};
                        my $entity0 = $class0->new($rel->{entity0});
                        my $entity1 = $class1->new($rel->{entity1});
                        MusicBrainz::Server::Entity::ExampleRelationship->new(
                            published => $_->{published},
                            name => $_->{name},
                            relationship =>
                                MusicBrainz::Server::Entity::Relationship->new(
                                    id => $rel->{id},
                                    entity0 => $entity0,
                                    entity1 => $entity1,
                                    source => $entity0,
                                    target => $entity1,
                                    source_type => $entity0->entity_type,
                                    target_type => $entity1->entity_type,
                                    verbose_phrase => $rel->{verbose_phrase},
                                    link =>
                                        MusicBrainz::Server::Entity::Link->new(
                                            begin_date => MusicBrainz::Server::Entity::PartialDate->new(
                                                $rel->{link}{begin_date}
                                            ),
                                            end_date => MusicBrainz::Server::Entity::PartialDate->new(
                                                $rel->{link}{end_date}
                                            ),
                                            type => $display_data->{link_type} //
                                                    LinkType->new(
                                                        id => $self->data->{link_id},
                                                        name => $self->data->{new}{name}
                                                    ),
                                        )
                                )
                        )
                    } @{ $self->data->{$_}{examples} // [] }
                ]
            } qw( old new )
        }
    }

    return $display_data;
}

sub accept {
    my $self = shift;
    $self->c->model('LinkType')->update($self->data->{link_id}, $self->data->{new});
}

before restore => sub {
    my ($self, $data) = @_;
    for my $side (qw( old new )) {
        $data->{$side}{long_link_phrase} =
            delete $data->{$side}{short_link_phrase}
                if exists $data->{$side}{short_link_phrase};
    }
};

__PACKAGE__->meta->make_immutable;
no Moose;

