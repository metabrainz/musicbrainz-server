package MusicBrainz::Server::Email::AutoEditorElection::Nomination;
use Moose;
use namespace::autoclean;

use URI::Escape;
use String::TT qw( strip tt );
use MusicBrainz::Server::Data::AutoEditorElection;

extends 'MusicBrainz::Server::Email::AutoEditorElection';

sub text
{
    my ($self) = @_;

    my $escape = sub { uri_escape_utf8(shift) }; ## no critic 'ProhibitUnusedVarsStricter'
    my $timeout = $MusicBrainz::Server::Data::AutoEditorElection::PROPOSAL_TIMEOUT; ## no critic 'ProhibitUnusedVarsStricter'

    return strip tt <<EOF;
A new candidate has been put forward for autoeditor status:

Candidate: [% self.election.candidate.name %]
           [% self.server %]/user/[% escape(self.election.candidate.name) %]
Proposer:  [% self.election.proposer.name %]
           [% self.server %]/user/[% escape(self.election.proposer.name) %]

* If two seconders are found within [% timeout %], voting will begin
* Otherwise, the proposal will automatically be rejected
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
