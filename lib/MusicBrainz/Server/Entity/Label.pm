package MusicBrainz::Server::Entity::Label;

use Moose;
use MusicBrainz::Server::Constants qw( $DLABEL_ID $NOLABEL_ID $NOLABEL_GID );
use MusicBrainz::Server::Entity::PartialDate;
use MusicBrainz::Server::Entity::Types;

extends 'MusicBrainz::Server::Entity::CoreEntity';
with 'MusicBrainz::Server::Entity::Role::Taggable';
with 'MusicBrainz::Server::Entity::Role::Linkable';
with 'MusicBrainz::Server::Entity::Role::Annotation';
with 'MusicBrainz::Server::Entity::Role::LastUpdate';
with 'MusicBrainz::Server::Entity::Role::Rating';
with 'MusicBrainz::Server::Entity::Role::DatePeriod';
with 'MusicBrainz::Server::Entity::Role::IPI';
with 'MusicBrainz::Server::Entity::Role::ISNI';
with 'MusicBrainz::Server::Entity::Role::Comment';
with 'MusicBrainz::Server::Entity::Role::Area';
with 'MusicBrainz::Server::Entity::Role::Type' => { model => 'LabelType' };

sub entity_type { 'label' }

has 'label_code' => (
    is => 'rw',
    isa => 'Int'
);

sub format_label_code
{
    my $self = shift;
    if ($self->label_code) {
        return sprintf "LC %05d", $self->label_code;
    }
    return "";
}

sub is_special_purpose {
    my $self = shift;
    return ($self->id && ($self->id == $DLABEL_ID ||
                          $self->id == $NOLABEL_ID))
        || ($self->gid && $self->gid eq $NOLABEL_GID);
}

around TO_JSON => sub {
    my ($orig, $self) = @_;

    my $json = $self->$orig;
    $json->{label_code} = $self->label_code;

    return $json;
};

__PACKAGE__->meta->make_immutable;
no Moose;
1;

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
