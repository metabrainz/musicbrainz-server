package MusicBrainz::Server::Form::Account::DigestAuthentication;

use strict;
use warnings;

use HTML::FormHandler::Moose;

extends 'MusicBrainz::Server::Form';

with 'MusicBrainz::Server::Form::Role::CSRFToken';

has '+name' => ( default => 'digestauth' );

has_field 'action' => (
    type => 'Select',
    required => 1,
);

sub options_action {
    return [
        'disable' => 'disable',
        'reset_token' => 'reset_token',
    ];
}

1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2026 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
