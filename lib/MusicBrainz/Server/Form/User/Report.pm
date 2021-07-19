package MusicBrainz::Server::Form::User::Report;

use HTML::FormHandler::Moose;
use MusicBrainz::Server::Translation qw( l N_l );
use Readonly;

extends 'MusicBrainz::Server::Form';

has '+name' => (
    default => 'report',
);

has_field 'reason' => (
    type => 'Select',
    required => 1,
);

has_field 'message' => (
    type => 'Text',
    required => 1,
);

has_field 'reveal_address' => (
    type => 'Boolean',
    default => 1,
);

has_field 'send_to_self' => (
    type => 'Boolean',
);

Readonly our %REASONS => (
    'spam' => N_l('Editor is spamming'),
    'unresponsiveness' => N_l('Editor is unresponsive to edit notes'),
    'ignoring_guidelines' => N_l('Editor intentionally ignores accepted guidelines'),
    'enforcing_guidelines' => N_l('Editor is overzealous in enforcing guidelines as rules'),
    'voting' => N_l('Editor engages in overzealous or abusive yes/no voting'),
    'other' => N_l('Editor has violated some other part of our Code of Conduct'),
);

sub options_reason {
    [map { $_ => l($REASONS{$_}) } qw(
        spam
        unresponsiveness
        ignoring_guidelines
        enforcing_guidelines
        voting
        other
    )];
}

1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2015 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
