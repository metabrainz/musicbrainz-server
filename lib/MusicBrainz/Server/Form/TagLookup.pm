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

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2010 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
