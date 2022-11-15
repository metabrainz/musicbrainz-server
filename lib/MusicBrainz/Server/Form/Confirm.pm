package MusicBrainz::Server::Form::Confirm;
use strict;
use warnings;

use HTML::FormHandler::Moose;
extends 'MusicBrainz::Server::Form';

with 'MusicBrainz::Server::Form::Role::Edit';
has '+name' => ( default => 'confirm' );

has_field 'cancel' => ( type => 'Submit' );
has_field 'submit' => ( type => 'Submit' );

sub edit_field_names { () }

1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2009 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
