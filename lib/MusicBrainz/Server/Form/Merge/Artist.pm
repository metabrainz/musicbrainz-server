package MusicBrainz::Server::Form::Merge::Artist;
use strict;
use warnings;

use HTML::FormHandler::Moose;

extends 'MusicBrainz::Server::Form::Merge';

has_field 'rename' => (
    type => 'Checkbox',
);

sub edit_field_names { return ('rename') }

1;
