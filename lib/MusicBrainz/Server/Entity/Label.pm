package MusicBrainz::Server::Entity::Label;

use Moose;
use MusicBrainz::Server::Constants qw( $DLABEL_ID $NOLABEL_ID $NOLABEL_GID );
use MusicBrainz::Server::Entity::PartialDate;
use MusicBrainz::Server::Entity::Types;

extends 'MusicBrainz::Server::Entity::CoreEntity';
with 'MusicBrainz::Server::Entity::Role::Taggable';
with 'MusicBrainz::Server::Entity::Role::Annotation';
with 'MusicBrainz::Server::Entity::Role::LastUpdate';
with 'MusicBrainz::Server::Entity::Role::Rating';
with 'MusicBrainz::Server::Entity::Role::Review';
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
        return sprintf 'LC %05d', $self->label_code;
    }
    return '';
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

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2009 Lukas Lalinsky

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
