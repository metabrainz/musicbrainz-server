package MusicBrainz::Server::Form::AddISRC;
use strict;
use warnings;

use HTML::FormHandler::Moose;
extends 'MusicBrainz::Server::Form';

with 'MusicBrainz::Server::Form::Role::Edit';

sub edit_field_names { qw( isrc ) }

has '+name' => ( default => 'add-isrc' );

has_field 'isrc' => (
    type      => '+MusicBrainz::Server::Form::Field::ISRC',
    required  => 1,
);

no Moose;
__PACKAGE__->meta->make_immutable;

