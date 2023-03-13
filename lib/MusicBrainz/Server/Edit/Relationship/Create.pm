package MusicBrainz::Server::Edit::Relationship::Create;
use Moose;

use List::AllUtils qw( any );
use MusicBrainz::Server::Edit::Types qw( LinkAttributesArray PartialDateHash Nullable NullableOnPreview );
use MusicBrainz::Server::Translation qw( N_l );

extends 'MusicBrainz::Server::Edit::Generic::Create';
with 'MusicBrainz::Server::Edit::Relationship';
with 'MusicBrainz::Server::Edit::Relationship::RelatedEntities';
with 'MusicBrainz::Server::Edit::Role::Preview';
with 'MusicBrainz::Server::Edit::Role::DatePeriod';
with 'MusicBrainz::Server::Edit::Role::AlwaysAutoEdit';

use MooseX::Types::Moose qw( Bool Int Str );
use MooseX::Types::Structured qw( Dict Optional );
use MusicBrainz::Server::Constants qw(
    $AMAZON_ASIN_LINK_TYPE_ID
    $EDIT_RELATIONSHIP_CREATE
);
use MusicBrainz::Server::Data::Utils qw( boolean_to_json type_to_model non_empty );
use MusicBrainz::Server::Edit::Utils qw( gid_or_id );
use MusicBrainz::Server::Entity::Util::JSON qw( to_json_object );
use MusicBrainz::Server::Validation qw( is_positive_integer );

use aliased 'MusicBrainz::Server::Entity::Link';
use aliased 'MusicBrainz::Server::Entity::LinkType';
use aliased 'MusicBrainz::Server::Entity::Relationship';
use aliased 'MusicBrainz::Server::Entity::PartialDate';

sub edit_type { $EDIT_RELATIONSHIP_CREATE }
sub edit_name { N_l('Add relationship') }
sub _create_model { 'Relationship' }
sub edit_template { 'AddRelationship' }

has '+data' => (
    isa => Dict[
        entity0      => Dict[
            id   => NullableOnPreview[Int],
            gid  => NullableOnPreview[Str],
            name => Str
        ],
        entity1      => Dict[
            id   => NullableOnPreview[Int],
            gid  => NullableOnPreview[Str],
            name => Str
        ],
        entity0_credit => Optional[Str],
        entity1_credit => Optional[Str],
        link_type    => Dict[
            id => Int,
            name => Str,
            link_phrase => Str,
            reverse_link_phrase => Str,
            long_link_phrase => Str
        ],
        attributes   => Nullable[LinkAttributesArray],
        begin_date   => Nullable[PartialDateHash],
        end_date     => Nullable[PartialDateHash],
        type0        => Str,
        type1        => Str,
        ended        => Optional[Bool],
        link_order   => Optional[Int],
        edit_version => Optional[Int],
    ]
);

sub link_type { shift->data->{link_type} }

sub initialize
{
    my ($self, %opts) = @_;
    my $e0 = delete $opts{entity0} or die 'No entity0';
    my $e1 = delete $opts{entity1} or die 'No entity1';
    my $lt = delete $opts{link_type} or die 'No link type';

    my $link_type_id = $lt->id;
    die "Link type $link_type_id is only used for grouping" unless $lt->description;

    if (my $attributes = $opts{attributes}) {
        if (@$attributes) {
            $self->check_attributes($lt, $attributes);
        } else {
            delete $opts{attributes};
        }
    }

    die 'Entities in a relationship cannot be the same'
        if $lt->entity0_type eq $lt->entity1_type && $e0->id == $e1->id;

    $opts{entity0} = {
        id => $e0->id,
        gid => $e0->gid,
        name => $e0->name,
    };

    $opts{entity1} = {
        id => $e1->id,
        gid => $e1->gid,
        name => $e1->name,
    };

    $self->sanitize_entity_credits(\%opts, $lt);
    for (qw(entity0_credit entity1_credit)) {
        delete $opts{$_} unless non_empty($opts{$_});
    }

    $opts{link_type} = {
        id => $lt->id,
        name => $lt->name,
        link_phrase => $lt->link_phrase,
        reverse_link_phrase => $lt->reverse_link_phrase,
        long_link_phrase => $lt->long_link_phrase
    };

    $opts{type0} = $lt->entity0_type;
    $opts{type1} = $lt->entity1_type;

    unless (is_positive_integer($opts{link_order}) && $lt->orderable_direction) {
        delete $opts{link_order};
    }

    # Don't include entity0_credit/entity1_credit here, they don't determine uniqueness.
    MusicBrainz::Server::Edit::Exceptions::NoChanges->throw
        if $self->c->model('Relationship')->exists(
            $lt->entity0_type,
            $lt->entity1_type, {
            link_type_id => $lt->id,
            begin_date   => $opts{begin_date},
            end_date     => $opts{end_date},
            ended        => $opts{ended},
            attributes   => $opts{attributes},
            entity0_id   => $e0->id,
            entity1_id   => $e1->id,
            link_order   => $opts{link_order} // 0,
        });

    $self->data({ %opts, edit_version => 2 });
}

sub initialize_date_period {
    my ($self, $opts) = @_;

    for (qw(begin_date end_date)) {
        delete $opts->{$_} unless any { non_empty($_) } values %{$opts->{$_} // {}};
    }
}

sub foreign_keys
{
    my ($self) = @_;

    my %load = (
        LinkType            => [ $self->data->{link_type}{id} ],
        LinkAttributeType   => { map { $_->{type}{id} => ['LinkAttributeType'] } @{ $self->data->{attributes} // [] } },
    );

    my $type0 = $self->data->{type0};
    my $type1 = $self->data->{type1};

    my $entity0_id = gid_or_id($self->data->{entity0});
    my $entity1_id = gid_or_id($self->data->{entity1});

    $load{ type_to_model($type0) } = { $entity0_id => ['ArtistCredit'] } if $entity0_id;

    # Type 1 my be equal to type 0, so we need to be careful
    $load{ type_to_model($type1) } ||= {};
    $load{ type_to_model($type1) }{$entity1_id} = [ 'ArtistCredit' ] if $entity1_id;

    return \%load;
}

sub build_display_data
{
    my ($self, $loaded) = @_;
    my $type0 = $self->data->{type0};
    my $type1 = $self->data->{type1};
    my $model0 = type_to_model($type0);
    my $model1 = type_to_model($type1);
    my $entity0_gid_or_id = gid_or_id($self->data->{entity0});
    my $loaded_entity_0;
    if ($entity0_gid_or_id) {
        $loaded_entity_0 = $loaded->{$model0}{$entity0_gid_or_id};
    }
    my $entity0 = $loaded_entity_0 ||
        $self->c->model($model0)->_entity_class->new(
            id => $self->data->{entity0}{id} // 0,
            name => $self->data->{entity0}{name}
        );
    my $entity1_gid_or_id = gid_or_id($self->data->{entity1});
    my $loaded_entity_1;
    if ($entity1_gid_or_id) {
        $loaded_entity_1 = $loaded->{$model1}{$entity1_gid_or_id};
    }
    my $entity1 = $loaded_entity_1 ||
        $self->c->model($model1)->_entity_class->new(
            id => $self->data->{entity1}{id} // 0,
            name => $self->data->{entity1}{name}
        );
    my $entity0_credit = $self->data->{entity0_credit} // '';
    my $entity1_credit = $self->data->{entity1_credit} // '';

    return {
        relationship => to_json_object(Relationship->new(
            link => Link->new(
                type_id => $self->data->{link_type}{id},
                type       => $loaded->{LinkType}{ $self->data->{link_type}{id} }
                    || LinkType->new($self->data->{link_type}),
                begin_date => PartialDate->new_from_row( $self->data->{begin_date} ),
                end_date   => PartialDate->new_from_row( $self->data->{end_date} ),
                ended      => $self->data->{ended},
                attributes => [
                    map {
                        my $attr = $loaded->{LinkAttributeType}{ $_->{type}{id} };
                        if ($attr) {
                            MusicBrainz::Server::Entity::LinkAttribute->new(
                                type_id => $attr->id,
                                type => $attr,
                                credited_as => $_->{credited_as},
                                text_value => $_->{text_value},
                            )
                        }
                        else {
                            ()
                        }
                    } @{ $self->data->{attributes} }
                ],
            ),
            entity0 => $entity0,
            entity1 => $entity1,
            entity0_id => $entity0->id,
            entity1_id => $entity1->id,
            entity0_credit => $entity0_credit,
            entity1_credit => $entity1_credit,
            source => $entity0,
            target => $entity1,
            source_type => $type0,
            target_type => $type1,
            source_credit => $entity0_credit,
            target_credit => $entity1_credit,
            link_order => $self->data->{link_order} // 0,
        )),
        unknown_attributes => boolean_to_json(scalar(
            grep { !exists $loaded->{LinkAttributeType}{$_->{type}{id}} }
                @{ $self->data->{attributes} // [] }
        )),
    }
}

sub directly_related_entities {
    my ($self) = @_;

    my $data = $self->data;
    my $result;

    push @{ $result->{$data->{type0}} //= [] }, gid_or_id($data->{entity0});
    push @{ $result->{$data->{type1}} //= [] }, gid_or_id($data->{entity1});

    return $result;
}

sub adjust_edit_pending
{
    my ($self, $adjust) = @_;

    $self->c->model('Relationship')->adjust_edit_pending(
        $self->data->{type0}, $self->data->{type1},
        $adjust, $self->entity_id);
}

sub insert
{
    my ($self) = @_;

    my $link_type_id = $self->data->{link_type}{id};
    my $link_type = $self->c->model('LinkType')->get_by_id($link_type_id);
    die "Link type $link_type_id is deprecated" if $link_type->is_deprecated;

    my $relationship = $self->c->model('Relationship')->insert(
        $self->data->{type0},
        $self->data->{type1}, {
            entity0_id      => $self->data->{entity0}{id},
            entity1_id      => $self->data->{entity1}{id},
            entity0_credit  => $self->data->{entity0_credit},
            entity1_credit  => $self->data->{entity1_credit},
            attributes      => $self->data->{attributes},
            link_type_id    => $self->data->{link_type}{id},
            begin_date      => $self->data->{begin_date},
            end_date        => $self->data->{end_date},
            ended           => $self->data->{ended},
            link_order      => $self->data->{link_order} // 0,
        });

    $self->entity_id($relationship->id);

    if ($link_type_id == $AMAZON_ASIN_LINK_TYPE_ID) {
        $self->c->model('Release')->update_amazon_asin(
            $self->data->{entity0}{id},
        );
    }
}

sub reject
{
    my $self = shift;
    $self->c->model('Relationship')->delete(
        $self->data->{type0},
        $self->data->{type1},
        $self->entity_id
    );
}

before restore => sub {
    my ($self, $data) = @_;
    $data->{link_type}{long_link_phrase} =
        delete $data->{link_type}{short_link_phrase}
            if exists $data->{link_type}{short_link_phrase};

    $self->restore_int_attributes($data) unless defined $data->{edit_version};
};

around editor_may_edit => sub {
    my ($orig, $self, $opts) = @_;

    my $lt = $opts->{link_type};
    return $self->$orig && $self->editor_may_edit_types($lt->entity0_type, $lt->entity1_type);
};

__PACKAGE__->meta->make_immutable;
no Moose;

1;
