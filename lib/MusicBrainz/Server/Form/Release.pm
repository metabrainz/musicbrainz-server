package MusicBrainz::Server::Form::Release;
use HTML::FormHandler::Moose;

use MusicBrainz::Server::Track;

extends 'MusicBrainz::Server::Form';
with 'MusicBrainz::Server::Form::Role::Edit';

has '+name' => ( default => 'edit-release' );

has_field 'status_id' => (
    type => 'Select',
);

has_field 'packaging_id' => (
    type => 'Select',
);

has_field 'artist_credit' => (
    type => '+MusicBrainz::Server::Form::Field::ArtistCredit',
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
    type => '+MusicBrainz::Server::Form::Field::Comment',
);

has_field 'name' => (
    type => 'Text',
    required => 1
);

has_field 'labels' => ( type => 'Repeatable' );
has_field 'labels.catalog_number' => ( type => 'Text' );
has_field 'labels.deleted' => ( type => 'Checkbox' );
has_field 'labels.label_id' => ( type => 'Text' );

has_field 'mediums' => (
    num_when_empty => 0,
    type => 'Repeatable'
);
has_field 'mediums.id' => ( type => '+MusicBrainz::Server::Form::Field::Integer' );
has_field 'mediums.name' => ( type => 'Text', maxlength => 255 );
has_field 'mediums.deleted' => ( type => 'Checkbox' );
has_field 'mediums.format_id' => ( type => 'Select' );
has_field 'mediums.position' => ( type => '+MusicBrainz::Server::Form::Field::Integer' );

has_field 'mediums.tracklist' => ( type => 'Compound' );
has_field 'mediums.tracklist.id' => ( type => '+MusicBrainz::Server::Form::Field::Integer' );
has_field 'mediums.tracklist.tracks' => (
    num_when_empty => 0,
    type => 'Repeatable'
);
has_field 'mediums.tracklist.tracks.id' => ( type => '+MusicBrainz::Server::Form::Field::Integer' );
has_field 'mediums.tracklist.tracks.position' => ( type => '+MusicBrainz::Server::Form::Field::Integer' );
has_field 'mediums.tracklist.tracks.name' => ( type => 'Text', required => 1 );
has_field 'mediums.tracklist.tracks.artist_credit' => ( type => '+MusicBrainz::Server::Form::Field::ArtistCredit' );
has_field 'mediums.tracklist.tracks.length' => ( type => '+MusicBrainz::Server::Form::Field::Length' );
has_field 'mediums.tracklist.tracks.deleted' => ( type => 'Checkbox' );

has_field 'artist_credit' => ( type => '+MusicBrainz::Server::Form::Field::ArtistCredit' );

sub options_status_id         { shift->_select_all('ReleaseStatus') }
sub options_packaging_id      { shift->_select_all('ReleasePackaging') }
sub options_country_id        { shift->_select_all('CountryArea', sort_by_accessor => 1) }
sub options_language_id       { shift->_select_all('Language') }
sub options_script_id         { shift->_select_all('Script') }
sub options_mediums_format_id { shift->_select_all('MediumFormat') }

sub edit_field_names { qw() }

__PACKAGE__->meta->make_immutable;
no Moose;
1;
