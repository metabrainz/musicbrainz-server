package MusicBrainz::Server::Form::Collection;
use HTML::FormHandler::Moose;

extends 'MusicBrainz::Server::Form';

has '+name' => ( default => 'edit-list' );

has_field 'name' => (
    type => '+MusicBrainz::Server::Form::Field::Text',
    required => 1,
);

has_field 'description' => (
    type => '+MusicBrainz::Server::Form::Field::Text',
    required => 0,
);

has_field 'public' => (
    type => 'Boolean',
);

has_field 'preview' => (
    type => 'Submit',
    value => ''
);

sub edit_field_names
{
    return qw( name description public );
}

1;
