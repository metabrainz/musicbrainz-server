package MusicBrainz::Server::Form::Artist::Edit;

use strict;
use warnings;

use base 'MusicBrainz::Server::Form::Model::Artist';

use MusicBrainz::Server::Artist;

sub name { 'edit_artist' }

sub profile
{
    return {
        required => {
            name => 'Text',
            sortname => 'Text',
            artist_type => 'Select'
        },
        optional => {
            start => '+MusicBrainz::Server::Form::Field::Date',
            end => '+MusicBrainz::Server::Form::Field::Date',
            editNote => 'TextArea'
        }
    };
}

sub options_artist_type {
    [ MusicBrainz::Server::Artist::ARTIST_TYPE_PERSON, "Person",
      MusicBrainz::Server::Artist::ARTIST_TYPE_GROUP, "Group",
      MusicBrainz::Server::Artist::ARTIST_TYPE_UNKNOWN, "Unknown" ]
}

sub validate_artist_type {
    my ($self, $field) = @_;

    $field->add_error($field->value . " is not a valid type")
        unless MusicBrainz::Server::Artist::IsValidType($field->value);
}

1;
