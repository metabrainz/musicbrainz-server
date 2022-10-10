package MusicBrainz::Server::Entity::ISWC;

use Moose;
use Readonly;
use MusicBrainz::Server::Entity::Types;

extends 'MusicBrainz::Server::Entity';
with 'MusicBrainz::Server::Entity::Role::PendingEdits';

has 'iswc' => (
    is => 'rw',
    isa => 'Str'
);

has 'work_id' => (
    is => 'rw',
    isa => 'Int'
);

has 'work' => (
    is => 'rw',
    isa => 'Work'
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

around TO_JSON => sub {
    my ($orig, $self) = @_;

    if ($self->work) {
        $self->link_entity('work', $self->work_id, $self->work);
    }

    my $json = $self->$orig;
    $json->{iswc} = $self->iswc;
    $json->{work_id} = $self->work_id;

    return $json;
};

__PACKAGE__->meta->make_immutable;
no Moose;
1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2012 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
