package MusicBrainz::Server::Form::Recording;
use HTML::FormHandler::Moose;
extends 'MusicBrainz::Server::Form';

with 'MusicBrainz::Server::Form::Role::Edit';

has '+name' => ( default => 'edit-recording' );

has_field 'name' => (
    type => '+MusicBrainz::Server::Form::Field::Text',
    required => 1,
);

has_field 'length' => (
    type => '+MusicBrainz::Server::Form::Field::Length'
);

has_field 'comment' => (
    type => '+MusicBrainz::Server::Form::Field::Comment',
);

has_field 'artist_credit' => (
    type => '+MusicBrainz::Server::Form::Field::ArtistCredit',
    required => 1
);

sub edit_field_names
{
    return qw( name length comment artist_credit );
}

sub options_type_id { shift->_select_all('RecordingType') }

1;
