package MusicBrainz::Server::Edit::Relationship::Reorder;
use strict;
use Moose;
use namespace::autoclean;
use Moose::Util::TypeConstraints qw( as subtype find_type_constraint );
use MooseX::Types::Moose qw( ArrayRef Int Str Bool );
use MooseX::Types::Structured qw( Dict Optional );
use MusicBrainz::Server::Constants qw(
    $EDIT_RELATIONSHIPS_REORDER
    :quality
);
use MusicBrainz::Server::Data::Utils qw( partial_date_to_hash type_to_model );
use MusicBrainz::Server::Edit::Exceptions;
use MusicBrainz::Server::Edit::Types qw( PartialDateHash LinkAttributesArray );
use MusicBrainz::Server::Entity::Util::JSON qw( to_json_object );
use MusicBrainz::Server::Translation qw ( N_l );
use aliased 'MusicBrainz::Server::Entity::Link';
use aliased 'MusicBrainz::Server::Entity::LinkAttribute';
use aliased 'MusicBrainz::Server::Entity::Relationship';

extends 'MusicBrainz::Server::Edit';

sub edit_name { N_l('Reorder relationships') }
sub edit_kind { 'other' }
sub edit_type { $EDIT_RELATIONSHIPS_REORDER }
sub edit_template { 'ReorderRelationships' }

with 'MusicBrainz::Server::Edit::Role::AlwaysAutoEdit';
with 'MusicBrainz::Server::Edit::Role::Preview';
with 'MusicBrainz::Server::Edit::Relationship';
with 'MusicBrainz::Server::Edit::Relationship::RelatedEntities';

subtype 'LinkTypeHash'
    => as Dict[
        id => Int,
        name => Str,
        link_phrase => Str,
        reverse_link_phrase => Str,
        long_link_phrase => Str,
        entity0_type => Str,
        entity1_type => Str,
    ];

subtype 'ReorderedRelationshipHash'
    => as Dict[
        id => Int,
        attributes => LinkAttributesArray,
        begin_date => PartialDateHash,
        end_date => PartialDateHash,
        ended => Bool,
        entity0 => Dict[
            id => Int,
            name => Str,
        ],
        entity1 => Dict[
            id => Int,
            name => Str,
        ],
    ];

has '+data' => (
    isa => Dict[
        link_type => find_type_constraint('LinkTypeHash'),
        relationship_order => ArrayRef[
            Dict[
                relationship => find_type_constraint('ReorderedRelationshipHash'),
                old_order => Int,
                new_order => Int,
            ]
        ],
        edit_version => Optional[Int],
    ]
);

sub link_type { shift->data->{link_type} }

sub foreign_keys {
    my ($self) = @_;

    my $model0 = type_to_model($self->data->{link_type}{entity0_type});
    my $model1 = type_to_model($self->data->{link_type}{entity1_type});

    my %load;

    $load{LinkType} = [$self->data->{link_type}{id}];
    $load{LinkAttributeType} = {};
    $load{$model0} = {};
    $load{$model1} = {};

    for (map { $_->{relationship} } @{ $self->data->{relationship_order} }) {
        $load{LinkAttributeType}->{$_->{type}{id}} = ['LinkAttributeType'] for @{ $_->{attributes} };
        $load{$model0}->{ $_->{entity0}{id} } = [];
        $load{$model1}->{ $_->{entity1}{id} } = [];
    }

    return \%load;
}

sub _build_relationship {
    my ($self, $loaded, $data) = @_;

    my $lt = $self->data->{link_type};
    my $model0 = type_to_model($lt->{entity0_type});
    my $model1 = type_to_model($lt->{entity1_type});

    my $entity0 = $loaded->{$model0}{ $data->{entity0}{id} } ||
        $self->c->model($model0)->_entity_class->new(name => $data->{entity0}{name});
    my $entity1 = $loaded->{$model1}{ $data->{entity1}{id} } ||
        $self->c->model($model1)->_entity_class->new(name => $data->{entity1}{name});

    return to_json_object(Relationship->new(
        link => Link->new(
            type       => $loaded->{LinkType}{$lt->{id}} || LinkType->new($lt),
            type_id    => $lt->{id},
            begin_date => MusicBrainz::Server::Entity::PartialDate->new_from_row($data->{begin_date}) // {},
            end_date   => MusicBrainz::Server::Entity::PartialDate->new_from_row($data->{end_date}) // {},
            ended      => $data->{ended},
            attributes => [
                map {
                    my $attr = $loaded->{LinkAttributeType}{$_->{type}{id}};

                    if ($attr) {
                        LinkAttribute->new(
                            type_id => $_->{type}{id},
                            type => $attr,
                            credited_as => $_->{credited_as},
                            text_value => $_->{text_value},
                        );
                    } else {
                        ();
                    }
                } @{ $data->{attributes} }
            ],
        ),
        entity0 => $entity0,
        entity0_credit => $data->{entity0}{name},
        entity0_id => $data->{entity0}{id},
        entity1 => $entity1,
        entity1_credit => $data->{entity1}{name},
        entity1_id => $data->{entity1}{id},
        source => $entity0,
        target => $entity1,
        source_type => $entity0->entity_type,
        target_type => $entity1->entity_type,
    ));
}

sub directly_related_entities {
    my ($self) = @_;

    my $type0 = $self->data->{link_type}{entity0_type};
    my $type1 = $self->data->{link_type}{entity1_type};

    my %result;
    $result{$type0} = [];
    $result{$type1} = [];

    for (@{ $self->data->{relationship_order} }) {
        push @{ $result{$type0} }, $_->{relationship}{entity0}{id};
        push @{ $result{$type1} }, $_->{relationship}{entity1}{id};
    }

    return \%result;
}

sub adjust_edit_pending
{
    my ($self, $adjust) = @_;

    $self->c->model('Relationship')->adjust_edit_pending(
        $self->data->{link_type}{entity0_type},
        $self->data->{link_type}{entity1_type},
        $adjust,
        map { $_->{relationship}{id} } @{ $self->data->{relationship_order} }
    );
}

sub initialize {
    my ($self, %opts) = @_;

    my $link_type = delete $opts{link_type} or die 'Missing link type';
    my $relationship_order = $opts{relationship_order} or die 'Missing relationship order';

    die 'Link type is unorderable'
        unless $link_type->orderable_direction;

    $relationship_order = [ grep {
        $_->{old_order} != $_->{new_order}
    } @$relationship_order ];

    MusicBrainz::Server::Edit::Exceptions::NoChanges->throw
        unless @$relationship_order;

    my @relationships = map { $_->{relationship} } @$relationship_order;
    $self->c->model('Relationship')->load_entities(@relationships);

    my $unorderable_entity;

    for my $order_item (@$relationship_order) {
        my $relationship = delete $order_item->{relationship};
        my $link = $relationship->link;

        die 'Relationship link type mismatch' if $link->type_id != $link_type->id;

        if (defined $unorderable_entity) {
            if ($unorderable_entity->id != $relationship->unorderable_entity->id) {
                die 'Relationship unorderable entity mismatch';
            }
        } else {
            $unorderable_entity = $relationship->unorderable_entity;
        }

        $order_item->{relationship} = {
            id => $relationship->id,
            begin_date => partial_date_to_hash($link->begin_date),
            end_date => partial_date_to_hash($link->end_date),
            ended => $link->ended,
            attributes => $self->serialize_link_attributes($link->all_attributes),
            entity0 => {
                id => $relationship->entity0_id,
                name => $relationship->entity0->name
            },
            entity1 => {
                id => $relationship->entity1_id,
                name => $relationship->entity1->name
            },
        };
    }

    $opts{link_type} = {
        id => $link_type->id,
        name => $link_type->name,
        link_phrase => $link_type->link_phrase,
        reverse_link_phrase => $link_type->reverse_link_phrase,
        long_link_phrase => $link_type->long_link_phrase,
        entity0_type => $link_type->entity0_type,
        entity1_type => $link_type->entity1_type,
    };

    $opts{edit_version} = 2;

    $self->data(\%opts);

    return $self;
}

sub build_display_data {
    my ($self, $loaded) = @_;

    return {
        relationships => [
            map +{
                old_order => $_->{old_order} + 0,
                new_order => $_->{new_order} + 0,
                relationship => $self->_build_relationship($loaded, $_->{relationship}),
            },
            sort { $a->{new_order} <=> $b->{new_order} }
                @{ $self->data->{relationship_order} }
        ]
    };
}

sub accept {
    my $self = shift;

    $self->c->model('Relationship')->reorder(
        $self->data->{link_type}{entity0_type},
        $self->data->{link_type}{entity1_type},
        map { $_->{relationship}{id} => $_->{new_order} } @{ $self->data->{relationship_order} }
    );
}

before restore => sub {
    my ($self, $data) = @_;

    unless (defined $data->{edit_version}) {
        $self->restore_int_attributes($_->{relationship}) for @{ $data->{relationship_order} };
    }
};

1;
