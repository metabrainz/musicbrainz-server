package MusicBrainz::Server::Controller::Statistics;

use strict;
use warnings;

use base 'MusicBrainz::Server::Controller';

=head1 NAME

MusicBrainz::Server::Controller::Statistics - display various statistics

=head1 DESCRIPTION

Displays various statistics, such as top moderators, etc.

=head1 METHODS

=head2 top_editors

Display a list of the top 10 editors in various timeframes

=cut

sub top_editors : Local
{
    my ($self, $c) = @_;

    $c->stash->{editors_last_week} = $c->model('Moderation')->top_moderators(25);
    $c->stash->{editors_overall}   = $c->model('Moderation')->top_moderators_overall;

    $c->stash->{voters_last_week} = $c->model('Moderation')->top_voters(25);
    $c->stash->{voters_overall}   = $c->model('Moderation')->top_voters(25, '10 years');
}

1;
