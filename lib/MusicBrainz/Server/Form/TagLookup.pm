package MusicBrainz::Server::Form::TagLookup;
use strict;
use warnings;

use HTML::FormHandler::Moose;
extends 'MusicBrainz::Server::Form';

has '+name' => ( default => 'tag-lookup' );

has_field 'artist'   => ( type => 'Text'    );
has_field 'release'  => ( type => 'Text'    );
has_field 'tracknum' => ( type => '+MusicBrainz::Server::Form::Field::Integer' );
has_field 'track'    => ( type => 'Text'    );
has_field 'duration' => ( type => '+MusicBrainz::Server::Form::Field::Integer' );
has_field 'filename' => ( type => 'Text'    );

1;
