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

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2011 Lukas Lalinsky

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
