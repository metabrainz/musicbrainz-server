package MusicBrainz::Server::Form::Admin::DeleteUser;
use strict;
use warnings;

use HTML::FormHandler::Moose;
extends 'MusicBrainz::Server::Form::SecureConfirm';

has '+name' => ( default => 'delete-user' );

has_field 'allow_reuse' => (
    type => 'Checkbox',
    default => 1,
);

1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2020 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
