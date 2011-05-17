package MusicBrainz::Server::Edit::Relationship::Edit;
use Moose;
use Carp;
use Moose::Util::TypeConstraints qw( as subtype find_type_constraint );
use MooseX::Types::Moose qw( ArrayRef Int Str );
use MooseX::Types::Structured qw( Dict );
use MusicBrainz::Server::Constants qw( $EDIT_RELATIONSHIP_EDIT );
use MusicBrainz::Server::Entity::Types;
use MusicBrainz::Server::Edit::Types qw( PartialDateHash Nullable );
use MusicBrainz::Server::Data::Utils qw(
  partial_date_to_hash
  partial_date_from_row
  type_to_model
);
use MusicBrainz::Server::Translation qw( l ln );

use aliased 'MusicBrainz::Server::Entity::Link';
use aliased 'MusicBrainz::Server::Entity::LinkType';
use aliased 'MusicBrainz::Server::Entity::Relationship';

extends 'MusicBrainz::Server::Edit::WithDifferences';
with 'MusicBrainz::Server::Edit::Relationship';

sub edit_type { $EDIT_RELATIONSHIP_EDIT }
sub edit_name { l("Edit relationship") }

sub _xml_arguments { ForceArray => ['attributes'] }

subtype 'LinkHash'
    => as Dict[
        link_type_id => Int,
        attributes => Nullable[ArrayRef[Int]],
        begin_date => Nullable[PartialDateHash],
        end_date => Nullable[PartialDateHash],
        entity0_id => Nullable[Int],
        entity1_id => Nullable[Int],
    ];

subtype 'RelationshipHash'
    => as Dict[
        link_type_id => Nullable[Int],
        attributes => Nullable[ArrayRef[Int]],
        begin_date => Nullable[PartialDateHash],
        end_date => Nullable[PartialDateHash],
        entity0_id => Nullable[Int],
        entity1_id => Nullable[Int],
    ];

has '+data' => (
    isa => Dict[
        relationship_id => Int,
        type0 => Str,
        type1 => Str,
        link => find_type_constraint('LinkHash'),
        new => find_type_constraint('RelationshipHash'),
        old => find_type_constraint('RelationshipHash'),
    ]
);

has 'relationship' => (
    isa => 'Relationship',
    is => 'rw'
);

sub foreign_keys
{
    my ($self) = @_;

    my $model0 = type_to_model($self->data->{type0});
    my $model1 = type_to_model($self->data->{type1});

    my %load;

    $load{LinkType} = [
        $self->data->{link}->{link_type_id},
        $self->data->{new}->{link_type_id},
        $self->data->{old}->{link_type_id}
    ];
    $load{LinkAttributeType} = [
        @{ $self->data->{link}->{attributes} },
        @{ $self->data->{new}->{attributes} || [] },
        @{ $self->data->{old}->{attributes} || [] }
    ];

    my $old = $self->data->{old};
    my $new = $self->data->{new};

    $load{$model0} = [];
    $load{$model1} = [];

    push @{ $load{$model0} }, $self->data->{link}->{entity0_id};
    push @{ $load{$model1} }, $self->data->{link}->{entity1_id};
    push @{ $load{$model0} }, $old->{entity0_id} if $old->{entity0_id};
    push @{ $load{$model1} }, $old->{entity1_id} if $old->{entity1_id};
    push @{ $load{$model0} }, $new->{entity0_id} if $new->{entity0_id};
    push @{ $load{$model1} }, $new->{entity1_id} if $new->{entity1_id};

    return \%load;
}

sub _build_relationship
{
    my ($self, $loaded, $data, $change) = @_;

    my $link = $data->{link};
    my $model0 = type_to_model($data->{type0});
    my $model1 = type_to_model($data->{type1});

    my $begin      = defined $change->{begin_date}   ? $change->{begin_date}   : $link->{begin_date};
    my $end        = defined $change->{end_date}     ? $change->{end_date}     : $link->{end_date};
    my $attributes = defined $change->{attributes}   ? $change->{attributes}   : $link->{attributes};
    my $entity0    = defined $change->{entity0_id}   ? $change->{entity0_id}   : $link->{entity0_id};
    my $entity1    = defined $change->{entity1_id}   ? $change->{entity1_id}   : $link->{entity1_id};
    my $lt_id      = defined $change->{link_type_id} ? $change->{link_type_id} : $link->{link_type_id};

    return unless $entity0 && $entity1;

    return Relationship->new(
        link => Link->new(
            type       => $loaded->{LinkType}{ $lt_id },
            begin_date => partial_date_from_row( $begin ),
            end_date   => partial_date_from_row( $end ),
            attributes => [
                map {
                    my $attr    = $loaded->{LinkAttributeType}{ $_ };
                    my $root_id = $self->c->model('LinkAttributeType')->find_root($attr->id);
                    $attr->root( $self->c->model('LinkAttributeType')->get_by_id($root_id) );
                    $attr;
                } @$attributes
            ]
        ),
        entity0 => $loaded->{$model0}{ $entity0 },
        entity1 => $loaded->{$model1}{ $entity1 },
    );
}

sub build_display_data
{
    my ($self, $loaded) = @_;

    my $old = $self->data->{old};
    my $new = $self->data->{new};

    return {
        old => $self->_build_relationship ($loaded, $self->data, $old),
        new => $self->_build_relationship ($loaded, $self->data, $new),
    };
}

sub related_entities
{
    my ($self) = @_;

    my $old = $self->data->{old};
    my $new = $self->data->{new};

    my $type0 = $self->data->{type0};
    my $type1 = $self->data->{type1};

    my %result;
    $result{$type0} = [];
    $result{$type1} = [];

    push @{ $result{$type0} }, $old->{entity0_id} if $old->{entity0_id};
    push @{ $result{$type0} }, $new->{entity0_id} if $new->{entity0_id};
    push @{ $result{$type0} }, $self->data->{link}{entity0_id};
    push @{ $result{$type1} }, $old->{entity1_id} if $old->{entity1_id};
    push @{ $result{$type1} }, $new->{entity1_id} if $new->{entity1_id};
    push @{ $result{$type1} }, $self->data->{link}{entity1_id};

    return \%result;
}

sub adjust_edit_pending
{
    my ($self, $adjust) = @_;

    $self->c->model('Relationship')->adjust_edit_pending(
        $self->data->{type0}, $self->data->{type1},
        $adjust, $self->data->{relationship_id});
}

sub _mapping
{
    return (
        begin_date => sub { return partial_date_to_hash (shift->link->begin_date); },
        end_date =>   sub { return partial_date_to_hash (shift->link->end_date);   },
        attributes => sub { return [ map { $_->id } shift->link->all_attributes ]; },
        link_type_id => sub { return shift->link->type_id; },
    );
}

sub initialize
{
    my ($self, %opts) = @_;

    my $relationship = delete $opts{relationship};
    my $type0 = delete $opts{type0};
    my $type1 = delete $opts{type1};
    my $change_direction = delete $opts{change_direction};

    if ($change_direction)
    {
        croak ("Cannot change direction unless both endpoints are the same type")
            if ($type0 ne $type1);

        $opts{entity0_id} ||= $relationship->entity0_id;
        $opts{entity1_id} ||= $relationship->entity1_id;
        ($opts{entity0_id}, $opts{entity1_id}) = ($opts{entity1_id}, $opts{entity0_id});
    }

    my $link = $relationship->link;

    $self->relationship($relationship);
    $self->data({
        type0 => $type0,
        type1 => $type1,
        relationship_id => $relationship->id,
        link => {
            begin_date => partial_date_to_hash ($link->begin_date),
            end_date =>   partial_date_to_hash ($link->end_date),
            attributes => [ map { $_->id } $link->all_attributes ],
            link_type_id => $link->type_id,
            entity0_id => $relationship->entity0_id,
            entity1_id => $relationship->entity1_id,
        },
        $self->_change_data($relationship, %opts)
    });
}

sub accept
{
    my $self = shift;

    $self->c->model('Relationship')->update(
        $self->data->{type0},
        $self->data->{type1},
        $self->data->{relationship_id},
        $self->data->{new},
        $self->data->{link},
    );
}

__PACKAGE__->meta->make_immutable;

no Moose;
1;

=head1 COPYRIGHT

Copyright (C) 2009 Lukas Lalinsky
Copyright (C) 2010 MetaBrainz Foundation

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
