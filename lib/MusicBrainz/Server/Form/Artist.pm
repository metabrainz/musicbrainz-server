package MusicBrainz::Server::Form::Artist;
use HTML::FormHandler::Moose;

extends 'MusicBrainz::Server::Form';
with 'MusicBrainz::Server::Form::Role::Edit';
with 'MusicBrainz::Server::Form::Role::DatePeriod';
with 'MusicBrainz::Server::Form::Role::CheckDuplicates';

has '+name' => ( default => 'edit-artist' );

has_field 'name' => (
    type => 'Text',
    required => 1,
);

has_field 'sort_name' => (
    type => 'Text',
    required => 1,
);

has_field 'gender_id' => (
    type => 'Select',
);

has_field 'type_id' => (
    type => 'Select',
);

has_field 'country_id' => (
    type => 'Select',
);

has_field 'comment' => (
    type      => 'Text',
    maxlength => 255
);

sub edit_field_names
{
    return qw( name sort_name type_id gender_id country_id
               begin_date end_date comment );
}

sub options_gender_id   { shift->_select_all('Gender') }
sub options_type_id     { shift->_select_all('ArtistType') }
sub options_country_id  { shift->_select_all('Country') }

sub dupe_model { shift->ctx->model('Artist') }

1;
