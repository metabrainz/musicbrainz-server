package MusicBrainz::Server::Edit::Relationship::Edit;
use Moose;
use namespace::autoclean;
use Carp;
use Clone qw( clone );
use Data::Compare;
use List::AllUtils qw( sort_by );
use Moose::Util::TypeConstraints qw( as subtype find_type_constraint );
use MooseX::Types::Moose qw( Bool Int Str );
use MooseX::Types::Structured qw( Dict Optional );
use MusicBrainz::Server::Constants qw(
    $AMAZON_ASIN_LINK_TYPE_ID
    $EDIT_RELATIONSHIP_EDIT
);
use MusicBrainz::Server::Edit::Exceptions;
use MusicBrainz::Server::Entity::LinkAttribute;
use MusicBrainz::Server::Entity::Types;
use MusicBrainz::Server::Entity::Util::JSON qw( to_json_object );
use MusicBrainz::Server::Edit::Types qw( LinkAttributesArray PartialDateHash Nullable NullableOnPreview );
use MusicBrainz::Server::Data::Utils qw(
    boolean_to_json
    partial_date_to_hash
    type_to_model
);
use MusicBrainz::Server::Edit::Utils qw( gid_or_id );
use MusicBrainz::Server::Translation qw( l N_l );

use aliased 'MusicBrainz::Server::Entity::Link';
use aliased 'MusicBrainz::Server::Entity::LinkType';
use aliased 'MusicBrainz::Server::Entity::Relationship';
use aliased 'MusicBrainz::Server::Entity::PartialDate';

extends 'MusicBrainz::Server::Edit::WithDifferences';
with 'MusicBrainz::Server::Edit::Relationship';
with 'MusicBrainz::Server::Edit::Relationship::RelatedEntities';
with 'MusicBrainz::Server::Edit::Role::Preview';
with 'MusicBrainz::Server::Edit::Role::DatePeriod';

sub edit_type { $EDIT_RELATIONSHIP_EDIT }
sub edit_name { N_l('Edit relationship') }
sub edit_kind { 'edit' }
sub edit_template { 'EditRelationship' }

subtype 'LinkHash'
    => as Dict[
        link_type => Dict[
            id => Int,
            name => Str,
            link_phrase => Str,
            reverse_link_phrase => Str,
            long_link_phrase => Str
        ],
        attributes => Nullable[LinkAttributesArray],
        begin_date => Nullable[PartialDateHash],
        end_date => Nullable[PartialDateHash],
        ended => Optional[Bool],
        entity0 => Nullable[Dict[
            id => Int,
            gid => Optional[Str],
            name => Str,
        ]],
        entity1 => Nullable[Dict[
            id => Int,
            gid => Optional[Str],
            name => Str,
        ]],
    ];

subtype 'RelationshipHash'
    => as Dict[
        link_type => Nullable[Dict[
            id => Int,
            name => Str,
            link_phrase => Str,
            reverse_link_phrase => Str,
            long_link_phrase => Str
        ]],
        attributes => Nullable[LinkAttributesArray],
        begin_date => Nullable[PartialDateHash],
        end_date => Nullable[PartialDateHash],
        ended => Optional[Bool],
        entity0 => Nullable[Dict[
            id => NullableOnPreview[Int],
            gid => NullableOnPreview[Str],
            name => Str,
        ]],
        entity1 => Nullable[Dict[
            id => NullableOnPreview[Int],
            gid => NullableOnPreview[Str],
            name => Str,
        ]],
        entity0_credit => Optional[Str],
        entity1_credit => Optional[Str],
    ];

has '+data' => (
    isa => Dict[
        relationship_id => Int,
        type0 => Str,
        type1 => Str,
        entity0_credit => Optional[Str],
        entity1_credit => Optional[Str],
        link => find_type_constraint('LinkHash'),
        new => find_type_constraint('RelationshipHash'),
        old => find_type_constraint('RelationshipHash'),
        edit_version => Optional[Int],
    ]
);

has 'relationship' => (
    isa => 'Relationship',
    is => 'rw'
);

sub link_type { shift->data->{link}{link_type} }

sub foreign_keys
{
    my ($self) = @_;

    my $model0 = type_to_model($self->data->{type0});
    my $model1 = type_to_model($self->data->{type1});

    my %load;
    my $old = $self->data->{old};
    my $new = $self->data->{new};
    my $link = $self->data->{link};

    $load{LinkType} = [
        $link->{link_type}{id},
        $new->{link_type} ? $new->{link_type}{id} : (),
        $old->{link_type} ? $old->{link_type}{id} : (),
    ];
    $load{LinkAttributeType} = {
        map { $_->{type}{id} => ['LinkAttributeType'] } (
            @{ $link->{attributes} },
            @{ $new->{attributes} || [] },
            @{ $old->{attributes} || [] },
        )
    };

    $load{$model0} = {};
    $load{$model1} = {};

    $load{$model0}->{gid_or_id($link->{entity0})} = ['ArtistCredit'];
    $load{$model1}->{gid_or_id($link->{entity1})} = ['ArtistCredit'];

    # Autovivification can create subtle bugs elsewhere if the change data is modified,
    # so guard these to where the properties exist.
    $load{$model0}->{gid_or_id($old->{entity0})} = ['ArtistCredit'] if defined $old->{entity0};
    $load{$model1}->{gid_or_id($old->{entity1})} = ['ArtistCredit'] if defined $old->{entity1};
    $load{$model0}->{gid_or_id($new->{entity0})} = ['ArtistCredit'] if defined $new->{entity0};
    $load{$model1}->{gid_or_id($new->{entity1})} = ['ArtistCredit'] if defined $new->{entity1};

    return \%load;
}

sub _build_relationship {
    my ($self, $loaded, $data, $change) = @_;

    my $link = $data->{link};
    my $type0 = $data->{type0};
    my $type1 = $data->{type1};
    my $model0 = type_to_model($type0);
    my $model1 = type_to_model($type1);

    my $begin      = defined $change->{begin_date}   ? $change->{begin_date}   : $link->{begin_date};
    my $end        = defined $change->{end_date}     ? $change->{end_date}     : $link->{end_date};
    my $ended      = defined $change->{ended}        ? $change->{ended}        : $link->{ended};
    my $attributes = defined $change->{attributes}   ? $change->{attributes}   : $link->{attributes};
    my $entity0    = defined $change->{entity0}      ? $change->{entity0}      : $link->{entity0};
    my $entity1    = defined $change->{entity1}      ? $change->{entity1}      : $link->{entity1};
    my $lt         = defined $change->{link_type}    ? $change->{link_type}    : $link->{link_type};

    return unless $entity0 && $entity1;

    my $entity0_id = gid_or_id($entity0) // 0;
    my $entity1_id = gid_or_id($entity1) // 0;

    $entity0 = $loaded->{$model0}{$entity0_id} ||
        $self->c->model($model0)->_entity_class->new(
            defined $entity0->{id} ? (id => $entity0->{id}) : (),
            name => $entity0->{name},
        );
    $entity1 = $loaded->{$model1}{$entity1_id} ||
        $self->c->model($model1)->_entity_class->new(
            defined $entity1->{id} ? (id => $entity1->{id}) : (),
            name => $entity1->{name},
        );
    # We want to show the entities as actually credited even if the credit
    # didn't change with this edit, but old edits won't have that data. 
    my $entity0_credit = $change->{entity0_credit} // $data->{entity0_credit} // '';
    my $entity1_credit = $change->{entity1_credit} // $data->{entity1_credit} // '';

    return to_json_object(Relationship->new(
        id => $data->{relationship_id},
        link => Link->new(
            type       => $loaded->{LinkType}{ $lt->{id} } ||
                              LinkType->new(
                                  %{$lt},
                                  entity0_type => $data->{type0},
                                  entity1_type => $data->{type1},
                              ),
            type_id    => $lt->{id},
            begin_date => PartialDate->new_from_row( $begin ),
            end_date   => PartialDate->new_from_row( $end ),
            ended      => $ended,
            attributes => [
                map {
                    my $type_id = $_->{type}{id};
                    my $attr = $loaded->{LinkAttributeType}{$type_id};

                    if ($attr) {
                        MusicBrainz::Server::Entity::LinkAttribute->new(
                            type => $attr,
                            type_id => $type_id,
                            credited_as => $_->{credited_as},
                            text_value => $_->{text_value},
                        );
                    }
                    else {
                        ();
                    }
                } @$attributes
            ],
        ),
        entity0 => $entity0,
        entity1 => $entity1,
        entity0_credit => $entity0_credit,
        entity1_credit => $entity1_credit,
        defined $entity0->{id} ? (entity0_id => $entity0->{id}) : (),
        defined $entity1->{id} ? (entity1_id => $entity1->{id}) : (),
        source => $entity0,
        target => $entity1,
        source_type => $type0,
        target_type => $type1,
        source_credit => $entity0_credit,
        target_credit => $entity1_credit,
    ));
}

sub build_display_data {
    my ($self, $loaded) = @_;

    my $old = $self->data->{old};
    my $new = $self->data->{new};

    return {
        old => $self->_build_relationship($loaded, $self->data, $old),
        new => $self->_build_relationship($loaded, $self->data, $new),
        unknown_attributes => boolean_to_json(scalar(
            grep { !exists $loaded->{LinkAttributeType}{$_->{type}{id}} }
                @{ $old->{attributes} // [] },
                @{ $new->{attributes} // [] },
                @{ $self->data->{link}{attributes} // [] }
        ))
    };
}

sub directly_related_entities {
    my ($self) = @_;

    my $old = $self->data->{old};
    my $new = $self->data->{new};
    my $link = $self->data->{link};

    my $type0 = $self->data->{type0};
    my $type1 = $self->data->{type1};

    my %result;
    $result{$type0} = [];
    $result{$type1} = [];

    push @{ $result{$type0} }, gid_or_id($old->{entity0}) if $old->{entity0};
    push @{ $result{$type0} }, gid_or_id($new->{entity0}) if $new->{entity0};
    push @{ $result{$type0} }, gid_or_id($link->{entity0});
    push @{ $result{$type1} }, gid_or_id($old->{entity1}) if $old->{entity1};
    push @{ $result{$type1} }, gid_or_id($new->{entity1}) if $new->{entity1};
    push @{ $result{$type1} }, gid_or_id($link->{entity1});

    return \%result;
}

sub adjust_edit_pending
{
    my ($self, $adjust) = @_;

    $self->c->model('Relationship')->adjust_edit_pending(
        $self->data->{type0}, $self->data->{type1},
        $adjust, $self->data->{relationship_id});
}

sub _mapping {
    my ($self) = @_;

    return (
        begin_date => sub { return partial_date_to_hash(shift->link->begin_date); },
        end_date =>   sub { return partial_date_to_hash(shift->link->end_date);   },
        ended => sub { return shift->link->ended },
        attributes => sub { $self->serialize_link_attributes(shift->link->all_attributes) },
        link_type => sub {
            my $rel = shift;
            my $lt = $rel->link->type;
            return {
                id => $lt->id,
                name => $lt->name,
                link_phrase => $lt->link_phrase,
                reverse_link_phrase => $lt->reverse_link_phrase,
                long_link_phrase => $lt->long_link_phrase,
            };
        },
        entity0 => sub {
            my $rel = shift;
            return { id => $rel->entity0->id, gid => $rel->entity0->gid, name => $rel->entity0->name };
        },
        entity1 => sub {
            my $rel = shift;
            return { id => $rel->entity1->id, gid => $rel->entity1->gid, name => $rel->entity1->name };
        },
        entity0_credit => sub { shift->entity0_credit },
        entity1_credit => sub { shift->entity1_credit },
    );
}

around _changes => sub {
    my ($orig, $self) = splice(@_, 0, 2);

    my %data = $self->$orig(@_);
    my ($new, $old) = @data{qw( new old )};

    # MBS-7282: Handle the case where the name of an entity changes, but the
    # entity itself does not.

    for my $prop (qw( entity0 entity1 )) {
        if (defined $new->{$prop} &&
            defined $old->{$prop} &&
            $new->{$prop}->{id} == $old->{$prop}->{id}) {

            delete $new->{$prop};
            delete $old->{$prop};
        }
    }

    my @old_attributes = sort_by { $_->{type}{id} } @{ $old->{attributes} // [] };
    my @new_attributes = sort_by { $_->{type}{id} } @{ $new->{attributes} // [] };

    $old->{attributes} = \@old_attributes;
    $new->{attributes} = \@new_attributes;

    if (@old_attributes != @new_attributes) {
        return %data;
    }

    for (my $i = 0; $i < @old_attributes; $i++) {
        return %data unless Compare($old_attributes[$i], $new_attributes[$i]);
    }

    delete $old->{attributes};
    delete $new->{attributes};

    return %data;
};

sub initialize
{
    my ($self, %opts) = @_;

    my $relationship = delete $opts{relationship};
    my $link = $relationship->link;
    my $type0 = $link->type->entity0_type;
    my $type1 = $link->type->entity1_type;

    unless ($relationship->entity0 && $relationship->entity1) {
        $self->c->model('Relationship')->load_entities($relationship);
    }

    my $new_entity0 = $opts{entity0} // $relationship->entity0;
    my $new_entity1 = $opts{entity1} // $relationship->entity1;
    my $new_link_type = $opts{link_type} // $link->type;
    my $current_attributes = $self->serialize_link_attributes($link->all_attributes);
    my $new_attributes = $opts{attributes} // $current_attributes;

    $self->check_attributes($new_link_type, $new_attributes);
    $self->sanitize_entity_credits(\%opts, $new_link_type);

    delete $opts{link_order}; # Not supported by this edit type.

    $opts{entity0} = {
        id => $opts{entity0}->id,
        gid => $opts{entity0}->gid,
        name => $opts{entity0}->name
    } if $opts{entity0};

    $opts{entity1} = {
        id => $opts{entity1}->id,
        gid => $opts{entity1}->gid,
        name => $opts{entity1}->name
    } if $opts{entity1};

    $opts{link_type} = {
        id => $opts{link_type}->id,
        name => $opts{link_type}->name,
        link_phrase => $opts{link_type}->link_phrase,
        reverse_link_phrase => $opts{link_type}->reverse_link_phrase,
        long_link_phrase => $opts{link_type}->long_link_phrase
    } if $opts{link_type};

    my $existent_id = $self->c->model('Relationship')->exists(
        $new_link_type->entity0_type,
        $new_link_type->entity1_type, {
        link_type_id => $new_link_type->id,
        begin_date   => $opts{begin_date},
        end_date     => $opts{end_date},
        ended        => $opts{ended},
        attributes   => $opts{attributes},
        entity0_id   => $new_entity0->id,
        entity1_id   => $new_entity1->id,
        link_order   => $relationship->link_order,
    });

    if ($existent_id && $relationship->id != $existent_id) {
        MusicBrainz::Server::Edit::Exceptions::DuplicateViolation->throw(
            l('The “{relationship_type}” relationship between “{entity0}” and “{entity1}” already exists.',
              {
                entity0 => $new_entity0->name,
                entity1 => $new_entity1->name,
                relationship_type => MusicBrainz::Server::Translation::Relationships::l($new_link_type->name),
              }
            )
        );
    }

    $self->relationship($relationship);
    $self->data({
        type0 => $type0,
        type1 => $type1,
        relationship_id => $relationship->id,
        link => {
            begin_date => partial_date_to_hash($link->begin_date),
            end_date =>   partial_date_to_hash ($link->end_date),
            ended => $link->ended,
            attributes => $current_attributes,
            link_type => {
                id => $link->type_id,
                name => $link->type->name,
                link_phrase => $link->type->link_phrase,
                reverse_link_phrase => $link->type->reverse_link_phrase,
                long_link_phrase => $link->type->long_link_phrase
            },
            entity0 => {
                id => $relationship->entity0_id,
                gid => $relationship->entity0->gid,
                name => $relationship->entity0->name
            },
            entity1 => {
                id => $relationship->entity1_id,
                gid => $relationship->entity1->gid,
                name => $relationship->entity1->name
            },
        },
        entity0_credit => $relationship->entity0_credit,
        entity1_credit => $relationship->entity1_credit,
        edit_version => 2,
        $self->_change_data($relationship, %opts)
    });
}

sub initialize_date_period {
    my ($self, $opts) = @_;

    my $link = $opts->{relationship}->link;
    $opts->{begin_date} //= partial_date_to_hash($link->begin_date);
    $opts->{end_date} //= partial_date_to_hash($link->end_date);
    $opts->{ended} //= $link->ended;
}

sub accept
{
    my $self = shift;

    my $data = clone($self->data);

    my $relationship = $self->c->model('Relationship')->get_by_id(
        $data->{type0}, $data->{type1},
        $data->{relationship_id}
    );

    MusicBrainz::Server::Edit::Exceptions::FailedDependency->throw(
        'This relationship has already been deleted'
    ) if !$relationship;

    $self->c->model('Link')->load($relationship);

    # If the relationship type has changed, then it doesn't make sense to
    # perform further edits as the entire context has changed.
    MusicBrainz::Server::Edit::Exceptions::FailedDependency->throw(
        'This relationship has changed type since this edit was entered'
    ) if $data->{link}{link_type}{id} != $relationship->link->type_id;;

    # Because we're using a "find_or_insert" instead of an update, this link
    # dict should be complete.  If a value isn't defined in $values it doesn't
    # change, so take the original value as it was stored in $link.
    my $values = {
        entity0_id      => $data->{new}{entity0}{id}    // $relationship->entity0_id,
        entity1_id      => $data->{new}{entity1}{id}    // $relationship->entity1_id,
        entity0_credit  => $data->{new}{entity0_credit} // $relationship->entity0_credit,
        entity1_credit  => $data->{new}{entity1_credit} // $relationship->entity1_credit,
        attributes      => $data->{new}{attributes}     // $self->serialize_link_attributes($relationship->link->all_attributes),
        link_type_id    => $data->{new}{link_type}{id}  // $relationship->link->type_id,
        begin_date      => $data->{new}{begin_date}     // partial_date_to_hash($relationship->link->begin_date),
        end_date        => $data->{new}{end_date}       // partial_date_to_hash($relationship->link->end_date),
        ended           => $data->{new}{ended}          // $relationship->link->ended,
        link_order      => $relationship->link_order,
    };

    my $existent_id = $self->c->model('Relationship')->exists($data->{type0}, $data->{type1}, $values);

    MusicBrainz::Server::Edit::Exceptions::FailedDependency->throw(
        'This relationship already exists.'
    ) if $existent_id && $relationship->id != $existent_id;

    MusicBrainz::Server::Edit::Exceptions::FailedDependency->throw(
        'One of the end points of this relationship no longer exists'
    ) if !$self->c->model(type_to_model($data->{type0}))->get_by_id($values->{entity0_id}) ||
         !$self->c->model(type_to_model($data->{type1}))->get_by_id($values->{entity1_id});

    $self->c->model('Relationship')->update(
        $data->{type0},
        $data->{type1},
        $data->{relationship_id},
        $values
    );

    # Determine the old link type ID. It shouldn't be defined if the user
    # didn't change the link type.
    my $old_link_type_id =
        defined $data->{old}{link_type} &&
        $data->{old}{link_type}{id};

    # This is always defined; if the link type wasn't changed, it defaults to
    # the existing link type.
    my $new_link_type_id = $values->{link_type_id};

    my $old_link_type_is_amazon_asin =
        defined $old_link_type_id &&
        $old_link_type_id == $AMAZON_ASIN_LINK_TYPE_ID;
    my $new_link_type_is_amazon_asin =
        $new_link_type_id == $AMAZON_ASIN_LINK_TYPE_ID;

    if ($old_link_type_is_amazon_asin || $new_link_type_is_amazon_asin) {
        my $link_type_changed =
            defined $old_link_type_id &&
            $old_link_type_id != $new_link_type_id;

        my $release_changed = (
            defined $data->{old}{entity0} &&
            defined $data->{new}{entity0} &&
            $data->{old}{entity0}{id} != $data->{new}{entity0}{id}
        );

        if ($link_type_changed || $release_changed) {
            $self->c->model('Release')->update_amazon_asin(
                $values->{entity0_id}
            );
        }

        if ($release_changed) {
            $self->c->model('Release')->update_amazon_asin(
                $data->{old}{entity0}{id}
            );
        }
    }
}

before restore => sub {
    my ($self, $data) = @_;
    $data->{link}{link_type}{long_link_phrase} =
        delete $data->{link}{link_type}{short_link_phrase}
            if exists $data->{link}{link_type}{short_link_phrase};

    for my $side (qw( old new )) {
        next unless exists $data->{$side}{link_type};
        $data->{$side}{link_type}{long_link_phrase} =
            delete $data->{$side}{link_type}{short_link_phrase}
                if exists $data->{$side}{link_type}{short_link_phrase};
    }

    unless (defined $data->{edit_version}) {
        $self->restore_int_attributes($data->{$_}) for qw( link old new );
    }
};

around editor_may_edit => sub {
    my ($orig, $self, $opts) = @_;

    my $old_lt = $opts->{relationship}->link->type;
    my $new_lt = $opts->{link_type} // $old_lt;

    return (
        $self->$orig &&
        $self->editor_may_edit_types($old_lt->entity0_type, $old_lt->entity1_type) &&
        $self->editor_may_edit_types($new_lt->entity0_type, $new_lt->entity1_type)
    );
};

sub allow_auto_edit {
    my ($self) = @_;

    my $data = $self->data;
    my $entity0 = $data->{new}{entity0};
    my $entity1 = $data->{new}{entity1};

    # MBS-7972
    # Make auto-editable if neither endpoint changed.
    return 1 if !($entity0 || $entity1);

    # Switching the entities around should also be an auto-edit.
    return 0 if $data->{type0} ne $data->{type1};

    return 0 if defined($entity0) xor defined($entity1);

    return ($data->{old}{entity0}{id} == $entity1->{id} &&
            $data->{old}{entity1}{id} == $entity0->{id});
}

__PACKAGE__->meta->make_immutable;

no Moose;
1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2009 Lukas Lalinsky
Copyright (C) 2010 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
