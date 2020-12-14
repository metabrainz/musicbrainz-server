package MusicBrainz::Server::Form::Role::Art;
use strict;
use warnings;

use HTML::FormHandler::Moose::Role;

requires qw( options_type_id );

sub edit_field_names { qw( comment type_id position ) }

has_field 'comment' => (
    type => '+MusicBrainz::Server::Form::Field::Text',
    not_nullable => 1,
);

has_field 'type_id' => (
    type      => 'Select',
    multiple  => 1,
);

1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2012 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
