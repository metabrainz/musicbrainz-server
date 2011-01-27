package MusicBrainz::Server::Form::Collection;
use HTML::FormHandler::Moose;

extends 'MusicBrainz::Server::Form';

has '+name' => ( default => 'edit-collection' );

has_field 'name' => (
    type => 'Text',
    required => 1,
);

has_field 'public' => (
    type => 'Boolean',
);

has_field 'subscribed' => (
    type => 'Boolean',
);

sub edit_field_names
{
    return qw( name public subscribed );
}

1;
