package MusicBrainz::Server::Form::Recording::Standalone;
use strict;
use warnings;

use HTML::FormHandler::Moose;
extends 'MusicBrainz::Server::Form::Recording';
use MusicBrainz::Server::Translation qw( N_l );

has_field '+edit_note' => (
    required => 1,
    required_message => N_l('You must provide an edit note when adding a standalone recording'),
);

1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2011 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
