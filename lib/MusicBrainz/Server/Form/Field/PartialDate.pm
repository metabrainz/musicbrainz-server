package MusicBrainz::Server::Form::Field::PartialDate;
use HTML::FormHandler::Moose;

extends 'HTML::FormHandler::Field::Compound';

has_field 'year' => (
    type => 'Integer',
    required => 1,
);

has_field 'month' => (
    type => 'Integer',
    range_start => 1,
    range_end => 12,
);

has_field 'day' => (
    type => 'Integer',
    range_start => 1,
    range_end => 31,
);

1;
