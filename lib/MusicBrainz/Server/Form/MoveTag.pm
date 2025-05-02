package MusicBrainz::Server::Form::MoveTag;
use strict;
use warnings;

use HTML::FormHandler::Moose;

extends 'MusicBrainz::Server::Form';

has '+name' => ( default => 'move-tag' );

has_field 'tags' => (
    type => '+MusicBrainz::Server::Form::Field::Text',
    required => 1,
);

sub edit_field_names { qw( tags ) }

1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2021 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
