package MusicBrainz::Server::Form::ReleaseGroup;
use HTML::FormHandler::Moose;
extends 'MusicBrainz::Server::Form';

with 'MusicBrainz::Server::Form::Edit';

has '+name' => ( default => 'edit-release-group' );

has_field 'type_id' => (
    type => 'Select',
);

has_field 'name' => (
    type => 'Text',
    required => 1,
);

has_field 'comment' => (
    type => 'Text',
);

has_field 'artist_credit' => (
    type => '+MusicBrainz::Server::Form::Field::ArtistCredit',
);

sub options_type_id { shift->_select_all('ReleaseGroupType') }

sub edit_field_names { qw( type_id name comment artist_credit ) }

1;
