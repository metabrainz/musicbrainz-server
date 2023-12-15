package MusicBrainz::Server::Form::Admin::DeleteUsers;
use strict;
use warnings;

use HTML::FormHandler::Moose;
extends 'MusicBrainz::Server::Form::SecureConfirm';

has '+name' => ( default => 'delete-users' );

has_field 'users' => (
    type => 'TextArea',
);

1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2022 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
