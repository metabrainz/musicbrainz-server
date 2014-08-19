package MusicBrainz::Server::Edit::Relationship::Delete;
use Moose;

use MusicBrainz::Server::Constants qw( $EDIT_RELATIONSHIP_DELETE );
use MusicBrainz::Server::Data::Utils qw(
    partial_date_to_hash
    type_to_model
);
use MusicBrainz::Server::Edit::Types qw( LinkAttributesArray PartialDateHash );
use MusicBrainz::Server::Entity::Types;
use MooseX::Types::Moose qw( Int Str ArrayRef );
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
with 'MusicBrainz::Server::Edit::Role::NeverAutoEdit';

sub edit_type { $EDIT_RELATIONSHIP_DELETE }
sub edit_name { N_l("Remove relationship") }
sub edit_kind { 'remove' }

has '+data' => (
    isa => Dict[
        relationship => Dict[
            id => Int,
            entity0 => Dict[
                id => Int,
                name => Str,
            ],
            entity1 => Dict[
                id => Int,
                name => Str,
            ],
            phrase => Optional[Str],
            extra_phrase_attributes => Optional[Str],
            link => Dict[
                begin_date => PartialDateHash,
                end_date => PartialDateHash,
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

sub model0 { type_to_model(shift->data->{relationship}{link}{type}{entity0_type}) }
sub model1 { type_to_model(shift->data->{relationship}{link}{type}{entity1_type}) }

sub foreign_keys
{
    my $self = shift;

    my %ids;
    $ids{ $self->model0 } ||= {};
    $ids{ $self->model1 } ||= {};

    $ids{$self->model0}->{ $self->data->{relationship}{entity0}{id} } = [ 'ArtistCredit' ];
    $ids{$self->model1}->{ $self->data->{relationship}{entity1}{id} } = [ 'ArtistCredit' ];

    return \%ids;
}

sub build_display_data
{
    my ($self, $loaded) = @_;

    my $attrs = $self->data->{relationship}{phrase} ? [] : [
        map {
            my $type = $_->{type};
            MusicBrainz::Server::Entity::LinkAttribute->new(
                type => MusicBrainz::Server::Entity::LinkAttributeType->new(
                    name => $type->{name},
                    root => MusicBrainz::Server::Entity::LinkAttributeType->new(
                        name => $type->{root}{name},
                    )
                ),
                credited_as => $_->{credited_as},
                text_value => $_->{text_value},
            );
        } @{ $self->data->{relationship}{link}{attributes} }
    ];

    my $link = MusicBrainz::Server::Entity::Link->new(
        begin_date => MusicBrainz::Server::Entity::PartialDate->new_from_row($self->data->{relationship}{link}{begin_date}),
        end_date => MusicBrainz::Server::Entity::PartialDate->new_from_row($self->data->{relationship}{link}{end_date}),
        type => MusicBrainz::Server::Entity::LinkType->new(long_link_phrase => $self->data->{relationship}{link}{type}{long_link_phrase} // ''),
        attributes => $attrs
    );

    my %relationship_opts = (
        entity0 => $loaded->{ $self->model0 }->{ $self->data->{relationship}{entity0}{id} } ||
            $self->c->model($self->model0)->_entity_class->new(
                name => $self->data->{relationship}{entity0}{name}
            ),
        entity1 => $loaded->{ $self->model1 }->{ $self->data->{relationship}{entity1}{id} } ||
            $self->c->model($self->model1)->_entity_class->new(
                name => $self->data->{relationship}{entity1}{name}
            ),
        link => $link
    );
    if ($self->data->{relationship}{phrase}) {
        $relationship_opts{_verbose_phrase} = [
                $self->data->{relationship}{phrase},
                $self->data->{relationship}{extra_phrase_attributes},
            ],
    }

    return {
        relationship => MusicBrainz::Server::Entity::Relationship->new(
            %relationship_opts
        )
    }
}

sub directly_related_entities
{
    my ($self) = @_;

    my $result;
    if ($self->data->{relationship}{link}{type}{entity0_type} eq
        $self->data->{relationship}{link}{type}{entity1_type}) {
        $result = {
            $self->data->{relationship}{link}{type}{entity0_type} => [
                $self->relationship->entity0_id,
                $self->relationship->entity1_id
            ]
        };
    }
    else {
        $result = {
            $self->data->{relationship}{link}{type}{entity0_type} => [
                $self->relationship->entity0_id
            ],
            $self->data->{relationship}{link}{type}{entity1_type} => [
                $self->relationship->entity1_id
            ]
        };
    }

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
                name => $relationship->entity0->name
            },
            entity1 => {
                id => $relationship->entity1_id,
                name => $relationship->entity1->name
            },
            link => {
                begin_date => partial_date_to_hash($relationship->link->begin_date),
                end_date => partial_date_to_hash($relationship->link->end_date),
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

sub accept
{
    my $self = shift;

    my $relationship = $self->c->model('Relationship')->get_by_id(
        $self->data->{relationship}{link}{type}{entity0_type},
        $self->data->{relationship}{link}{type}{entity1_type},
        $self->data->{relationship}{id}
    ) or return;

    $self->c->model('Relationship')->delete(
        $self->data->{relationship}{link}{type}{entity0_type},
        $self->data->{relationship}{link}{type}{entity1_type},
        $self->data->{relationship}{id});

    if ($self->data->{relationship}{link}{type}{entity0_type} eq 'release' &&
        $self->data->{relationship}{link}{type}{entity1_type} eq 'url')
    {
        my $release = $self->c->model('Release')->get_by_id(
            $relationship->entity0_id
        );
        $self->c->model('Relationship')->load_subset([ 'url' ], $release);
        $self->c->model('CoverArt')->cache_cover_art($release);
    }
}

before restore => sub {
    my ($self, $data) = @_;

    return if defined $data->{edit_version};

    my $link = $data->{relationship}{link};

    if (my $attributes = $link->{attributes}) {
        $link->{attributes} = [
            map +{
                type => {
                    root => {
                        id => $_->{root_id},
                        gid => $_->{root_gid},
                        name => $_->{root_name},
                    },
                    id => $_->{id},
                    gid => $_->{gid},
                    name => $_->{name},
                }
            }, @$attributes
        ];
    }
};

__PACKAGE__->meta->make_immutable;

no Moose;
1;

=head1 NAME

MusicBrainz::Server::Data::Relationship

=head1 COPYRIGHT

Copyright (C) 2009 Lukas Lalinsky

This program is free software; you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation; either version 2 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program; if not, write to the Free Software
Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.

=cut
