package MusicBrainz::Server::Entity::EditNoteChange;

use 5.18.2;

use Moose;
use namespace::autoclean;

use MusicBrainz::Server::Data::Utils qw( datetime_to_iso8601 );
use MusicBrainz::Server::Entity::Types;
use MusicBrainz::Server::Types qw( DateTime );

extends 'MusicBrainz::Server::Entity';

has 'editor_id' => (
    isa => 'Int',
    is => 'rw',
);

has 'editor' => (
    isa => 'Editor',
    is => 'rw'
);

has 'edit_note_id' => (
    isa => 'Int',
    is => 'rw',
);

has 'edit_note' => (
    isa => 'EditNote',
    is => 'rw',
    weak_ref => 1
);

has 'reason' => (
    isa => 'Str',
    is => 'rw',
);

has 'change_time' => (
    isa => DateTime,
    is => 'rw',
    coerce => 1
);

has 'status' => (
    isa => 'Str',
    is  => 'rw',
);

has 'new_note' => (
    isa => 'Str',
    is => 'rw',
);

has 'old_note' => (
    isa => 'Str',
    is => 'rw',
);

around TO_JSON => sub {
    my ($orig, $self) = @_;

    my $json = $self->$orig;
    $json->{change_editor_id} = $self->editor_id + 0;
    $json->{change_time} = datetime_to_iso8601($self->change_time);
    $json->{edit_note_id} = $self->edit_note_id + 0;
    $json->{id} = $self->id + 0;
    $json->{new_note} = $self->new_note;
    $json->{old_note} = $self->old_note;
    $json->{reason} = $self->reason;
    $json->{status} = $self->status;

    if (my $editor = $self->editor) {
        $self->link_entity('editor', $self->editor_id, $editor);
    }

    return $json;
};

no Moose;
__PACKAGE__->meta->make_immutable;
1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2021 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
