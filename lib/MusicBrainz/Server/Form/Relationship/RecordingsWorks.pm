package MusicBrainz::Server::Form::Relationship::RecordingsWorks;
use Moose;
use HTML::FormHandler::Moose;

extends 'MusicBrainz::Server::Form::Relationship';
with 'MusicBrainz::Server::Form::Role::Edit';
with 'MusicBrainz::Server::Form::Relationship::LinkType';
with 'MusicBrainz::Server::Form::Role::DatePeriod';

has '+name' => ( default => 'ar' );

has_field 'works' => (
    type => '+MusicBrainz::Server::Form::Field::DynamicRepeatable',
);

has_field 'works.name' => (
    type => '+MusicBrainz::Server::Form::Field::Text',
);

has_field 'works.id' => (
    type => 'Integer'
);

has_field 'works.recording_id' => (
    type => 'Integer'
);

1;
