package MusicBrainz::Server::Controller::WS::2::Genre;
use Moose;

BEGIN { extends 'MusicBrainz::Server::ControllerBase::WS::2' }

use aliased 'MusicBrainz::Server::WebService::WebServiceStash';

my $ws_defs = Data::OptList::mkopt([
    genre => {
        method   => 'GET',
        optional => [ qw(fmt) ],
    },
    genre => {
        action   => '/ws/2/genre/lookup',
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

sub genre_list : Chained('base') PathPart('list') {
    my ($self, $c) = @_;

    $c->detach('method_not_allowed')
        unless $c->req->method eq 'GET';

    $c->detach('genre_browse')
        if $c->stash->{linked};

    my $stash = WebServiceStash->new;
    my @genres = $c->model('Genre')->get_all;

    my $genres->{items} = $self->make_list(\@genres, scalar @genres)->{items};

    $c->res->content_type($c->stash->{serializer}->mime_type . '; charset=utf-8');
    $c->res->body($c->stash->{serializer}->serialize('genre-list', $genres,
                                                     $c->stash->{inc}, $stash));
}

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