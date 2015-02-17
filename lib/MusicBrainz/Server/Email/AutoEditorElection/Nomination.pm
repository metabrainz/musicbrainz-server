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

    my $escape = sub { uri_escape_utf8(shift) };
    my $timeout = $MusicBrainz::Server::Data::AutoEditorElection::PROPOSAL_TIMEOUT;

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

=head1 COPYRIGHT

Copyright (C) 2011 Lukas Lalinsky

This program is free software; you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation; either version 2 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program; if not, write to the Free Software
Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.

=cut
