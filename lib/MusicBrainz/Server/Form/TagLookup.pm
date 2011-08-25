package MusicBrainz::Server::Form::TagLookup;
use HTML::FormHandler::Moose;
extends 'MusicBrainz::Server::Form';

has '+name' => ( default => 'tag-lookup' );

has_field 'artist'   => ( type => 'Text'    );
has_field 'release'  => ( type => 'Text'    );
has_field 'tracknum' => ( type => 'Integer' );
has_field 'track'    => ( type => 'Text'    );
has_field 'duration' => ( type => 'Integer' );
has_field 'filename' => ( type => 'Text'    );
has_field 'puid'     => ( type => 'Text'    );

1;
