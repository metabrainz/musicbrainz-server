package MusicBrainz::Server::Form::Release::AddCoverArt;

use HTML::FormHandler::Moose;
extends 'MusicBrainz::Server::Form';

with 'MusicBrainz::Server::Form::Role::Edit';

sub edit_field_names { qw( type page ) }

has '+name' => ( default => 'add-cover-art' );

has_field 'filename' => (
    type      => 'Text',
    required  => 1,
);

has_field 'type' => (
    type      => 'Select',
    required  => 1,
);

has_field 'page' => ( 
    type      => '+MusicBrainz::Server::Form::Field::Integer',
);

sub options_type  {
    # FIXME: move.  (to MusicBrainz/Server/Constants.pm or database?).
    return map { $_ => $_ } qw( front back inner booklet sleeve medium obi spine box other );
}

no Moose;
__PACKAGE__->meta->make_immutable;

