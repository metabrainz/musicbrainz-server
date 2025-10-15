package MusicBrainz::Server::Form::Role::ReorderArt;
use strict;
use warnings;

use HTML::FormHandler::Moose::Role;

with 'MusicBrainz::Server::Form::Role::Edit';

sub edit_field_names { qw( artwork ) }

has_field 'artwork' => ( type => 'Repeatable' );
has_field 'artwork.id' => ( type => '+MusicBrainz::Server::Form::Field::Integer' );
has_field 'artwork.position' => ( type => '+MusicBrainz::Server::Form::Field::Integer' );

1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2012 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
