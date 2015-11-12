package MusicBrainz::Server::Form::User::Report;

use HTML::FormHandler::Moose;
use MusicBrainz::Server::Translation qw( l );
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
);

Readonly our %REASONS => (
    'spam' => l('Editor is spamming'),
    'unresponsiveness' => l('Editor is unresponsive to edit notes'),
    'ignoring_guidelines' => l('Editor intentionally ignores accepted guidelines'),
    'enforcing_guidelines' => l('Editor is overzealous in enforcing guidelines as rules'),
    'voting' => l('Editor engages in overzealous or abusive yes/no voting'),
    'other' => l('Editor has violated some other part of our Code of Conduct'),
);

sub options_reason {
    [map { $_ => $REASONS{$_} } qw(
        spam
        unresponsiveness
        ignoring_guidelines
        enforcing_guidelines
        voting
        other
    )];
}

1;

=head1 COPYRIGHT

This file is part of MusicBrainz, the open internet music database.
Copyright (C) 2015 MetaBrainz Foundation
Licensed under the GPL version 2, or (at your option) any later version:
http://www.gnu.org/licenses/gpl-2.0.txt

=cut
