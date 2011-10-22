package MusicBrainz::Server::Email::AutoEditorElection::Rejected;
use Moose;
use namespace::autoclean;

use URI::Escape;
use String::TT qw( strip tt );

extends 'MusicBrainz::Server::Email::AutoEditorElection';

sub text
{
    my ($self) = @_;

    my $escape = sub { uri_escape_utf8(shift) };

    return strip tt <<EOF;
Voting in this election is now closed: the proposal to make
[% self.election.candidate.name %] an auto-editor was declined.

Details:
[% self.server %]/election/[% self.election.id %]

Thank you to everyone who took part.
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
