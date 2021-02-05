package MusicBrainz::Server::Email::AutoEditorElection::VotingOpen;
use Moose;
use namespace::autoclean;

use URI::Escape;
use String::TT qw( strip tt );
use MusicBrainz::Server::Data::AutoEditorElection;

extends 'MusicBrainz::Server::Email::AutoEditorElection';

sub text
{
    my ($self) = @_;

    my $escape = sub { uri_escape_utf8(shift) };
    my $timeout = $MusicBrainz::Server::Data::AutoEditorElection::VOTING_TIMEOUT;

    return strip tt <<EOF;
Voting in this election is now open:

Candidate: [% self.election.candidate.name %]
           [% self.server %]/user/[% escape(self.election.candidate.name) %]
Proposer:  [% self.election.proposer.name %]
           [% self.server %]/user/[% escape(self.election.proposer.name) %]
Seconder:  [% self.election.seconder_1.name %]
           [% self.server %]/user/[% escape(self.election.seconder_1.name) %]
Seconder:  [% self.election.seconder_2.name %]
           [% self.server %]/user/[% escape(self.election.seconder_2.name) %]

* Voting will now remain open for the next [% timeout %]
* Alternatively, [% self.election.proposer.name %] may withdraw the proposal

Please participate:
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
