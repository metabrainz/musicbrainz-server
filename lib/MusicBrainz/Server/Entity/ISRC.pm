package MusicBrainz::Server::Entity::ISRC;

use Moose;
use Readonly;
use MusicBrainz::Server::Entity::Types;

extends 'MusicBrainz::Server::Entity';
with 'MusicBrainz::Server::Entity::Role::Editable';

sub entity_type { 'isrc' }

has 'isrc' => (
    is => 'rw',
    isa => 'Str'
);

has 'recording_id' => (
    is => 'rw',
    isa => 'Int'
);

has 'recording' => (
    is => 'rw',
    isa => 'Recording'
);

has 'source_id' => (
    is => 'rw',
    isa => 'Int'
);

Readonly my $SOURCE_MUSICBRAINZ => 0;

Readonly my %SOURCES => (
    $SOURCE_MUSICBRAINZ => 'MusicBrainz',
);

sub source
{
    my ($self) = @_;

    return defined $self->source_id ? $SOURCES{$self->source_id} : undef;
}

sub name { shift->isrc }

around TO_JSON => sub {
    my ($orig, $self) = @_;

    if ($self->recording) {
        $self->link_entity('recording', $self->recording_id, $self->recording);
    }

    my $json = $self->$orig;
    $json->{isrc} = $self->isrc;
    $json->{recording_id} = $self->recording_id;
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
