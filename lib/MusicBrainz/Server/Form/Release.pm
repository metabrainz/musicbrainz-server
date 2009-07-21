package MusicBrainz::Server::Form::Release;
use HTML::FormHandler::Moose;

extends 'MusicBrainz::Server::Form';
with 'MusicBrainz::Server::Form::Edit';

has '+name' => ( default => 'edit-release' );

has_field 'status_id' => (
    type => 'Select',
);

has_field 'packaging_id' => (
    type => 'Select',
);

has_field 'artist_credit' => (
    type => '+MusicBrainz::Server::Form::Field::ArtistCredit',
    required => 1,
);

has_field 'barcode' => (
    type => '+MusicBrainz::Server::Form::Field::Barcode',
);

has_field 'country_id' => (
    type => 'Select',
);

has_field 'date' => (
    type => '+MusicBrainz::Server::Form::Field::PartialDate',
);

has_field 'language_id' => (
    type => 'Select',
);

has_field 'script_id' => (
    type => 'Select',
);

has_field 'comment' => (
    type => 'Text'
);

has_field 'name' => (
    type => 'Text',
);

sub options_status_id    { shift->_select_all('ReleaseStatus') }
sub options_packaging_id { shift->_select_all('ReleasePackaging') }
sub options_country_id   { shift->_select_all('Country') }
sub options_language_id  { shift->_select_all('Language') }
sub options_script_id    { shift->_select_all('Script') }

__PACKAGE__->meta->make_immutable;
no Moose;
1;
