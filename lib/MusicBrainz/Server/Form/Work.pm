package MusicBrainz::Server::Form::Work;
use HTML::FormHandler::Moose;
extends 'MusicBrainz::Server::Form';

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
    type => 'Text',
);

sub options_type_id { shift->_select_all('WorkType') }

1;
