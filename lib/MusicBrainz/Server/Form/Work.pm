package MusicBrainz::Server::Form::Work;
use HTML::FormHandler::Moose;
extends 'MusicBrainz::Server::Form';

with 'MusicBrainz::Server::Form::Role::Edit';

has '+name' => ( default => 'edit-work' );

has_field 'type_id' => (
    type => 'Select',
);

has_field 'name' => (
    type => 'Text',
    required => 1,
);

has_field 'iswc' => (
    type => '+MusicBrainz::Server::Form::Field::ISWC',
);

has_field 'comment' => (
    type      => 'Text',
    maxlength => 255
);

has_field 'artist_credit' => (
    type => '+MusicBrainz::Server::Form::Field::ArtistCredit',
);

sub edit_field_names { qw( type_id name iswc comment artist_credit ) }

sub options_type_id { shift->_select_all('WorkType') }

1;
