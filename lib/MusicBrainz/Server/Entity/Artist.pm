package MusicBrainz::Server::Entity::Artist;

use Moose;
use MusicBrainz::Server::Constants qw( $DARTIST_ID $VARTIST_ID $VARTIST_GID );
use MusicBrainz::Server::Entity::PartialDate;
use MusicBrainz::Server::Entity::Types;
use MusicBrainz::Server::Entity::Util::JSON qw( to_json_object );

extends 'MusicBrainz::Server::Entity';
with 'MusicBrainz::Server::Entity::Role::Alias',
     'MusicBrainz::Server::Entity::Role::Annotation',
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

# Unlike `area->country_code`, this stores the containing country code.
has 'country_code' => (
    is => 'rw',
    isa => 'Maybe[Str]',
    predicate => 'has_loaded_country_code',
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
        begin_area => to_json_object($self->begin_area),
        end_area => to_json_object($self->end_area),
        gender => to_json_object($self->gender),
        begin_area_id => defined $self->begin_area_id ? (0 + $self->begin_area_id) : undef,
        end_area_id => defined $self->end_area_id ? (0 + $self->end_area_id) : undef,
        gender_id => defined $self->gender_id ? (0 + $self->gender_id) : undef,
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
