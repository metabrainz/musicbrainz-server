package MusicBrainz::Server::Form::List;
use HTML::FormHandler::Moose;

extends 'MusicBrainz::Server::Form';

has '+name' => ( default => 'edit-list' );

has_field 'name' => (
    type => 'Text',
    required => 1,
);

has_field 'public' => (
    type => 'Boolean',
);

sub edit_field_names
{
    return qw( name public );
}

1;
