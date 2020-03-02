package MusicBrainz::Server::Controller::WS::2::Genre;
use Moose;

BEGIN { extends 'MusicBrainz::Server::ControllerBase::WS::2' }

use aliased 'MusicBrainz::Server::WebService::WebServiceStash';

my $ws_defs = Data::OptList::mkopt([
    genre => {
        method   => 'GET',
        optional => [ qw(fmt) ],
    }
]);

with 'MusicBrainz::Server::WebService::Validator' => {
    defs => $ws_defs,
};

with 'MusicBrainz::Server::Controller::WS::2::Role::Lookup' => {
    model => 'Genre',
};

sub base : Chained('root') PathPart('genre') CaptureArgs(0) { }

# Nothing extra to load yet, but this is required by Role::Lookup
sub genre_toplevel {}

sub genre_browse : Private {
    my ($self, $c) = @_;

    $c->detach('not_implemented');
}

sub genre_search : Chained('root') PathPart('genre') Args(0) {
    my ($self, $c) = @_;

    $c->detach('genre_browse') if $c->stash->{linked};
    $c->detach('not_implemented');
}
__PACKAGE__->meta->make_immutable;
1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2019 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut