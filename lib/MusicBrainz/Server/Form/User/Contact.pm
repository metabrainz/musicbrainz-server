package MusicBrainz::Server::Form::User::Contact;
use strict;
use warnings;

use HTML::FormHandler::Moose;

extends 'MusicBrainz::Server::Form';
with 'MusicBrainz::Server::Form::Role::CSRFToken';

has '+name' => ( default => 'contact' );

has_field 'subject' => (
    type => 'Text',
    required => 1,
);

has_field 'body' => (
    type => 'Text',
    required => 1,
);

has_field 'reveal_address' => (
    type => 'Boolean',
);

has_field 'send_to_self' => (
    type => 'Boolean',
);

1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2009 Lukas Lalinsky

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
