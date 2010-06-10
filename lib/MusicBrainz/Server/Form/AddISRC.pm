package MusicBrainz::Server::Form::AddISRC;

use HTML::FormHandler::Moose;
extends 'MusicBrainz::Server::Form';

with 'MusicBrainz::Server::Form::Role::Edit';

sub edit_field_names { qw( isrc ) }

has '+name' => ( default => 'add-isrc' );

has_field 'isrc' => (
    type      => 'Text',
    required  => 1,
    minlength => 12,
    maxlength => 12
);

no Moose;
__PACKAGE__->meta->make_immutable;

