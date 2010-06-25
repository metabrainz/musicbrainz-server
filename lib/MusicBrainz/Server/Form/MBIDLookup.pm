package MusicBrainz::Server::Form::MBIDLookup;
use HTML::FormHandler::Moose;
extends 'MusicBrainz::Server::Form';

has '+html_prefix' => ( default => 0 );

has_field 'mbid'   => ( type => 'Text'    );

1;
