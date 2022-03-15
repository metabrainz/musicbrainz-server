package MusicBrainz::Server::Controller::WS::2::Genre;
use Moose;

BEGIN { extends 'MusicBrainz::Server::ControllerBase::WS::2' }

use MusicBrainz::Server::WebService::TXTSerializer;
use aliased 'MusicBrainz::Server::WebService::WebServiceStash';

my $ws_defs = Data::OptList::mkopt([
    genre => {
        method   => 'GET',
        # TODO: Add include when implementing MBS-10062
        # inc      => [ qw(aliases) ],
        optional => [ qw(fmt limit offset) ],
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

sub serializers {
    [
        'MusicBrainz::Server::WebService::XMLSerializer',
        'MusicBrainz::Server::WebService::JSONSerializer',
        'MusicBrainz::Server::WebService::TXTSerializer',
    ]
}

sub base : Chained('root') PathPart('genre') CaptureArgs(0) { }

# Nothing extra to load yet, but this is required by Role::Lookup
sub genre_toplevel {}

sub genre_all : Chained('base') PathPart('all') {
    my ($self, $c) = @_;

    $c->detach('method_not_allowed')
        unless $c->req->method eq 'GET';

    my ($limit, $offset) = $self->_limit_and_offset($c);

    my $stash = WebServiceStash->new;

    my $genre_list;
    if ($c->stash->{args}{fmt} eq 'txt') {
        # If fmt=txt, limit and offset are ignored.
        $genre_list = $c->model('Genre')->get_all_names;
    } else {
        my ($genres, $hits) =
            $c->model('Genre')->get_all_limited($limit, $offset);
        $genre_list = $self->make_list($genres, $hits, $offset);
    }

    $c->res->content_type(
        $c->stash->{serializer}->mime_type . '; charset=utf-8'
    );
    $c->res->body($c->stash->{serializer}->serialize(
        'genre-list',
        $genre_list,
        $c->stash->{inc},
        $stash
    ));
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