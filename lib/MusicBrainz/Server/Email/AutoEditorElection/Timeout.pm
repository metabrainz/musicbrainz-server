package MusicBrainz::Server::Email::AutoEditorElection::Timeout;
use Moose;
use namespace::autoclean;

use URI::Escape;
use String::TT qw( strip tt );
use MusicBrainz::Server::Data::AutoEditorElection;

extends 'MusicBrainz::Server::Email::AutoEditorElection';

sub text
{
    my ($self) = @_;

    my $timeout = $MusicBrainz::Server::Data::AutoEditorElection::PROPOSAL_TIMEOUT; ## no critic 'ProhibitUnusedVarsStricter'

    return strip tt <<EOF;
This election has been cancelled, because two seconders could not be
found within the allowed time ([% timeout %]).

Details:
[% self.server %]/election/[% self.election.id %]
EOF
}

1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2011 Lukas Lalinsky

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
