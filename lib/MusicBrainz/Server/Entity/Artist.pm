package MusicBrainz::Server::Entity::Artist;

use Moose;
use MusicBrainz::Server::Constants qw( $DARTIST_ID $VARTIST_ID $VARTIST_GID );
use MusicBrainz::Server::Entity::PartialDate;
use MusicBrainz::Server::Entity::Types;

extends 'MusicBrainz::Server::Entity';
with 'MusicBrainz::Server::Entity::Role::Annotation',
     'MusicBrainz::Server::Entity::Role::Area',
     'MusicBrainz::Server::Entity::Role::Comment',
     'MusicBrainz::Server::Entity::Role::DatePeriod',
     'MusicBrainz::Server::Entity::Role::IPI',
     'MusicBrainz::Server::Entity::Role::ISNI',
     'MusicBrainz::Server::Entity::Role::Rating',
     'MusicBrainz::Server::Entity::Role::Relatable',
     'MusicBrainz::Server::Entity::Role::Review',
     'MusicBrainz::Server::Entity::Role::Taggable',
     'MusicBrainz::Server::Entity::Role::Type' => { model => 'ArtistType' };

sub entity_type { 'artist' }

has 'sort_name' => (
    is => 'rw',
    isa => 'Str',
);

has 'aliases' => (
    is => 'rw',
    isa => 'ArrayRef[MusicBrainz::Server::Entity::Alias]',
    default => sub { [] },
);

has 'primary_alias' => (
    is => 'rw',
    isa => 'Str',
);

has 'gender_id' => (
    is => 'rw',
    isa => 'Int',
);

has 'gender' => (
    is => 'rw',
    isa => 'Gender',
);

sub gender_name
{
    my ($self) = @_;
    return $self->gender ? $self->gender->name : undef;
}

sub l_gender_name
{
    my ($self) = @_;
    return $self->gender ? $self->gender->l_name : undef;
}

has 'begin_area_id' => (
    is => 'rw',
    isa => 'Int',
);

has 'begin_area' => (
    is => 'rw',
    isa => 'Area',
);

has 'end_area_id' => (
    is => 'rw',
    isa => 'Int',
);

has 'end_area' => (
    is => 'rw',
    isa => 'Area',
);

sub is_special_purpose {
    my $self = shift;
    return ($self->id && ($self->id == $DARTIST_ID ||
                          $self->id == $VARTIST_ID))
        || ($self->gid && $self->gid eq $VARTIST_GID);
}

around TO_JSON => sub {
    my ($orig, $self) = @_;

    return {
        %{$self->$orig},
        $self->begin_area ? (begin_area => $self->begin_area->TO_JSON) : (),
        $self->end_area ? (end_area => $self->end_area->TO_JSON) : (),
        $self->gender ? (gender => $self->gender->TO_JSON) : (),
        $self->primary_alias ? (primaryAlias => $self->primary_alias) : (),
        begin_area_id => $self->begin_area_id,
        end_area_id => $self->end_area_id,
        gender_id => $self->gender_id,
        sort_name => $self->sort_name,
    };
};

__PACKAGE__->meta->make_immutable;
no Moose;
1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2009 Lukas Lalinsky

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
