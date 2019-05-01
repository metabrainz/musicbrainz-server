package MusicBrainz::Server::Controller::Genre;
use Moose;

BEGIN { extends 'MusicBrainz::Server::Controller' }

use List::UtilsBy qw( sort_by );

sub list : Path('/genres') Args(0) {
    my ($self, $c) = @_;

    my @genres = $c->model('Genre')->get_all;
    my $coll = $c->get_collator();
    my @sorted_genres = sort_by { $coll->getSortKey($_->name) } @genres;

    $c->stash(
        current_view => 'Node',
        component_path => 'genre/List',
        component_props => { genres => \@sorted_genres },
    );
}

1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2019 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
