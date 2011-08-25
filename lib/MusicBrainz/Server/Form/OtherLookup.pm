package MusicBrainz::Server::Form::OtherLookup;
use HTML::FormHandler::Moose;
extends 'MusicBrainz::Server::Form';

has '+name' => ( default => 'other-lookup' );

has_field 'catno'    => ( type => 'Text'    );
has_field 'barcode'  => ( type => 'Text'    );
has_field 'mbid'     => ( type => 'Text'    );
has_field 'isrc'     => ( type => 'Text'    );
has_field 'iswc'     => ( type => 'Text'    );
has_field 'puid'     => ( type => 'Text'    );
has_field 'discid'   => ( type => 'Text'    );
has_field 'freedbid' => ( type => 'Text'    );

1;
