package MusicBrainz::Server::Edit::Relationship::Delete;
use Moose;
use Try::Tiny;

use List::MoreUtils qw( any );
use MusicBrainz::Server::Constants qw( $CONTACT_URL $EDIT_RELATIONSHIP_DELETE );
use MusicBrainz::Server::Data::Utils qw(
    localized_note
    partial_date_to_hash
    type_to_model
);
use MusicBrainz::Server::Edit::Utils qw( gid_or_id );
use MusicBrainz::Server::Edit::Types qw( LinkAttributesArray PartialDateHash );
use MusicBrainz::Server::Entity::Types;
use MooseX::Types::Moose qw( Int Str ArrayRef Bool );
use MooseX::Types::Structured qw( Dict Optional );

use MusicBrainz::Server::Entity::Relationship;
use MusicBrainz::Server::Entity::Link;
use MusicBrainz::Server::Entity::LinkAttribute;
use MusicBrainz::Server::Entity::LinkAttributeType;
use MusicBrainz::Server::Entity::PartialDate;
use MusicBrainz::Server::Translation qw( N_l );

extends 'MusicBrainz::Server::Edit';
with 'MusicBrainz::Server::Edit::Relationship';
with 'MusicBrainz::Server::Edit::Relationship::RelatedEntities';
with 'MusicBrainz::Server::Edit::Role::Preview';

sub edit_type { $EDIT_RELATIONSHIP_DELETE }
sub edit_name { N_l("Remove relationship") }
sub edit_kind { 'remove' }
sub edit_template_react { 'RemoveRelationship' }

has '+data' => (
    isa => Dict[
        relationship => Dict[
            id => Int,
            entity0 => Dict[
                id => Int,
                gid => Optional[Str],
                name => Str,
            ],
            entity1 => Dict[
                id => Int,
                gid => Optional[Str],
                name => Str,
            ],
            entity0_credit => Optional[Str],
            entity1_credit => Optional[Str],
            phrase => Optional[Str],
            extra_phrase_attributes => Optional[Str],
            link => Dict[
                begin_date => PartialDateHash,
                end_date => PartialDateHash,
                ended => Bool,
                attributes => Optional[LinkAttributesArray],
                type => Dict[
                    id => Optional[Int],
                    entity0_type => Str,
                    entity1_type => Str,
                    long_link_phrase => Optional[Str]
                ]
            ]
        ],
        edit_version => Optional[Int],
    ]
);

has 'relationship' => (
    isa => 'Relationship',
    is => 'rw'
);

# Some old edits don't actually have a link type ID stored
# We use this dirty hack so that we can access the data in linkedEntities
my $link_type_fake_id = 10000;

sub model0 { type_to_model(shift->data->{relationship}{link}{type}{entity0_type}) }
sub model1 { type_to_model(shift->data->{relationship}{link}{type}{entity1_type}) }

sub link_type { shift->data->{relationship}{link}{type} }

sub foreign_keys
{
    my $self = shift;

    my %ids;
    $ids{ $self->model0 } ||= {};
    $ids{ $self->model1 } ||= {};

    my $entity0 = $self->data->{relationship}{entity0};
    my $entity1 = $self->data->{relationship}{entity1};

    $ids{$self->model0}->{gid_or_id($entity0)} = [ 'ArtistCredit' ];
    $ids{$self->model1}->{gid_or_id($entity1)} = [ 'ArtistCredit' ];

    $ids{LinkType} = [$self->data->{link}{type}{id}];
    $ids{LinkAttributeType} = { map { $_->{type}{id} => ['LinkAttributeType'] } @{ $self->data->{relationship}{link}{attributes} // [] } };

    return \%ids;
}

sub build_display_data
{
    my ($self, $loaded) = @_;

    my $relationship = $self->data->{relationship};

    my $attrs = $relationship->{phrase} ? [] : [
        map {
            my $type = $_->{type};
            MusicBrainz::Server::Entity::LinkAttribute->new(
                type_id => $type->{id},
                type => $loaded->{LinkAttributeType}{$type->{id}} // MusicBrainz::Server::Entity::LinkAttributeType->new(
                    id => $type->{id},
                    name => $type->{name},
                    root_id => $type->{root}{id},
                    root => MusicBrainz::Server::Entity::LinkAttributeType->new(
                        name => $type->{root}{name},
                    )
                ),
                credited_as => $_->{credited_as},
                text_value => $_->{text_value},
            );
        } @{ $relationship->{link}{attributes} }
    ];

    my $link_type = $relationship->{link}{type};
    my $entity0_type = $link_type->{entity0_type};
    my $entity1_type = $link_type->{entity1_type};

    # If no link type exists, we use the fake ID and ensure the next one doesn't clash
    my $link_type_id = $link_type->{id} // $link_type_fake_id++;

    my $link = MusicBrainz::Server::Entity::Link->new(
        type_id => $link_type_id,
        begin_date => MusicBrainz::Server::Entity::PartialDate->new_from_row($relationship->{link}{begin_date}),
        end_date => MusicBrainz::Server::Entity::PartialDate->new_from_row($relationship->{link}{end_date}),
        ended => $relationship->{link}{ended},
        type => $loaded->{LinkType}{$link_type->{id}} // MusicBrainz::Server::Entity::LinkType->new(
            id => $link_type_id,
            entity0_type => $entity0_type,
            entity1_type => $entity1_type,
            long_link_phrase => $link_type->{long_link_phrase} // $relationship->{phrase} // '',
        ),
        attributes => $attrs
    );

    my $entity0_data = $relationship->{entity0};
    my $entity1_data = $relationship->{entity1};
    my $entity0 = $loaded->{ $self->model0 }->{gid_or_id($entity0_data)} ||
        $self->c->model($self->model0)->_entity_class->new(
            id => $entity0_data->{id},
            name => $entity0_data->{name}
        );
    my $entity1 = $loaded->{ $self->model1 }->{gid_or_id($entity1_data)} ||
        $self->c->model($self->model1)->_entity_class->new(
            id => $entity1_data->{id},
            name => $entity1_data->{name}
        );
    my $entity0_credit = $relationship->{entity0_credit} // '';
    my $entity1_credit = $relationship->{entity1_credit} // '';

    my %relationship_opts = (
        entity0 => $entity0,
        entity1 => $entity1,
        entity0_id => $entity0->id,
        entity1_id => $entity1->id,
        entity0_credit => $entity0_credit,
        entity1_credit => $entity1_credit,
        source => $entity0,
        target => $entity1,
        source_type => $entity0_type,
        target_type => $entity1_type,
        source_credit => $entity0_credit,
        target_credit => $entity1_credit,
        link => $link
    );
    if ($relationship->{phrase}) {
        $relationship_opts{_verbose_phrase} = [
                $relationship->{phrase},
                $relationship->{extra_phrase_attributes},
            ],
    }

    return {
        relationship => MusicBrainz::Server::Entity::Relationship->new(
            %relationship_opts
        )
    }
}

sub directly_related_entities {
    my ($self) = @_;

    my $result;
    my $relationship = $self->data->{relationship};
    my $link_type = $relationship->{link}{type};
    my $entity0 = $relationship->{entity0};
    my $entity1 = $relationship->{entity1};

    push @{ $result->{$link_type->{entity0_type}} //= [] }, gid_or_id($entity0);
    push @{ $result->{$link_type->{entity1_type}} //= [] }, gid_or_id($entity1);

    return $result;
}

sub adjust_edit_pending
{
    my ($self, $adjust) = @_;

    $self->c->model('Relationship')->adjust_edit_pending(
        $self->data->{relationship}{link}{type}{entity0_type},
        $self->data->{relationship}{link}{type}{entity1_type},
        $adjust, $self->data->{relationship}{id});
}

sub initialize
{
    my ($self, %opts) = @_;

    my $relationship = $opts{relationship}
        or die 'You must pass the relationship object';

    $self->c->model('Link')->load($relationship) unless $relationship->link;
    $self->c->model('LinkType')->load($relationship->link) unless $relationship->link->type;
    $self->c->model('Relationship')->load_entities($relationship)
        unless $relationship->entity0 && $relationship->entity1;

    $self->relationship($relationship);
    $self->data({
        relationship => {
            id => $relationship->id,
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
            $relationship->entity0_credit ? (entity0_credit => $relationship->entity0_credit) : (),
            $relationship->entity1_credit ? (entity1_credit => $relationship->entity1_credit) : (),
            link => {
                begin_date => partial_date_to_hash($relationship->link->begin_date),
                end_date => partial_date_to_hash($relationship->link->end_date),
                ended => $relationship->link->ended,
                attributes => $self->serialize_link_attributes($relationship->link->all_attributes),
                type => {
                    id => $relationship->link->type->id,
                    entity0_type => $relationship->link->type->entity0_type,
                    entity1_type => $relationship->link->type->entity1_type,
                    long_link_phrase => $relationship->link->type->long_link_phrase,
                }
            }
        },
        edit_version => 2,
    });
}

sub accept {
    my $self = shift;

    my $relationship = $self->c->model('Relationship')->get_by_id(
        $self->data->{relationship}{link}{type}{entity0_type},
        $self->data->{relationship}{link}{type}{entity1_type},
        $self->data->{relationship}{id}
    ) or return;

    $self->c->model('Link')->load($relationship);
    $self->c->model('LinkType')->load($relationship->link);
    $self->c->model('LinkType')->load_documentation($relationship->link->type);
    my @examples = $relationship->link->type->all_examples;

    if (any { $_->{relationship}->id == $relationship->id } @examples) {
        my $error = localized_note(
            N_l(
                'This edit would remove a relationship that is set ' .
                'as an example of its relationship type in the documentation. ' .
                'If you still think this should be removed, please ' .
                '{contact_url|contact us}.'),
            vars => {contact_url => $CONTACT_URL},
        );
        MusicBrainz::Server::Edit::Exceptions::GeneralError->throw($error);
    }

    $self->c->model('Relationship')->delete(
        $self->data->{relationship}{link}{type}{entity0_type},
        $self->data->{relationship}{link}{type}{entity1_type},
        $self->data->{relationship}{id});

    if ($self->data->{relationship}{link}{type}{entity0_type} eq 'release' &&
        $self->data->{relationship}{link}{type}{entity1_type} eq 'url')
    {
        my $release = $self->c->model('Release')->get_by_id($relationship->entity0_id);
        $self->c->model('Relationship')->load_subset([ 'url' ], $release);
        $self->c->model('CoverArt')->cache_cover_art($release);
    }
}

before restore => sub {
    my ($self, $data) = @_;

    my $link = $data->{relationship}{link};

    # old edits lack the "ended" flag in edit data
    my $ed = $link->{end_date};
    my $ended = defined $ed->{year} || $ed->{month} || $ed->{day};
    $link->{ended} //= $ended ? 1 : 0;

    return if defined $data->{edit_version};

    if (my $attributes = $link->{attributes}) {
        $link->{attributes} = [
            map +{
                type => {
                    root => {
                        id => $_->{root_id},
                        $_->{root_gid} ? (gid => $_->{root_gid}) : (),
                        name => $_->{root_name},
                    },
                    id => ($_->{id} // $_->{root_id}),
                    $_->{gid} ? (gid => $_->{gid}) : (),
                    name => ($_->{name} // $_->{root_name}),
                }
            }, @$attributes
        ];
    }
};

around editor_may_edit => sub {
    my ($orig, $self, $opts) = @_;

    my $lt = $opts->{relationship}->link->type;
    return $self->$orig && $self->editor_may_edit_types($lt->entity0_type, $lt->entity1_type);
};

around edit_conditions => sub {
    my ($orig, $self, @args) = @_;

    my $conditions = $self->$orig(@args);

    # This is wrapped in try/catch so that it will behave something resembling
    # properly when called as a class method by the edit type documentation
    # templates.
    try {
        my $editor = $self->editor // $self->c->model('Editor')->get_by_id($self->editor_id);
        $conditions->{auto_edit} = $self->_editor_may_auto_edit($editor) ? 1 : 0;
    } catch {
        warn $_;
    };

    return $conditions;
};

around editor_may_approve => sub {
    my ($orig, $self, $editor) = @_;

    return $self->is_open && ($self->_editor_may_auto_edit($editor) || $self->$orig($editor));
};

sub _editor_may_auto_edit {
    my ($self, $editor) = @_;

    if ($editor->is_auto_editor) {
        my $lt = $self->data->{relationship}{link}{type};

        # MBS-8332
        return $lt->{entity0_type} eq 'url' || $lt->{entity1_type} eq 'url';
    }

    return 0;
}

__PACKAGE__->meta->make_immutable;

no Moose;
1;

=head1 NAME

MusicBrainz::Server::Data::Relationship

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2009 Lukas Lalinsky

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
