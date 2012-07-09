package MusicBrainz::Server::Form::AddISWC;

use HTML::FormHandler::Moose;
extends 'MusicBrainz::Server::Form';

with 'MusicBrainz::Server::Form::Role::Edit';

sub edit_field_names { qw( iswc ) }

has '+name' => ( default => 'add-iswc' );

has_field 'iswc' => (
    type      => '+MusicBrainz::Server::Form::Field::ISWC',
    required  => 1,
);

no Moose;
__PACKAGE__->meta->make_immutable;

1;
