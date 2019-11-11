package MusicBrainz::Server::Controller::Vote;
use Moose;

BEGIN { extends 'MusicBrainz::Server::Controller'; }

sub index : Path('/vote') Args(0)
{
    my ($self, $c) = @_;

    $c->stash(
        current_view => 'Node',
        component_path => 'vote/VotingIndex',
    );
}

no Moose;
1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2019 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
