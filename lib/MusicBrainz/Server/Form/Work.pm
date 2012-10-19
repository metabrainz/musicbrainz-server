package MusicBrainz::Server::Form::Work;
use HTML::FormHandler::Moose;
use MusicBrainz::Server::Form::Utils qw( language_options );

extends 'MusicBrainz::Server::Form';

with 'MusicBrainz::Server::Form::Role::Edit';

has '+name' => ( default => 'edit-work' );

has_field 'type_id' => (
    type => 'Select',
);

has_field 'language_id' => (
    type => 'Select',
);

has_field 'name' => (
    type => '+MusicBrainz::Server::Form::Field::Text',
    required => 1,
);

has_field 'comment' => (
    type => '+MusicBrainz::Server::Form::Field::Comment',
);

sub edit_field_names { qw( type_id language_id name comment artist_credit ) }

sub options_type_id           { shift->_select_all('WorkType') }
sub options_language_id       { return language_options (shift->ctx); }

1;
