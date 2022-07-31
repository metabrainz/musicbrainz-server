package MusicBrainz::Server::Controller::WS::2::Mood;
use Moose;

BEGIN { extends 'MusicBrainz::Server::ControllerBase::WS::2' }

use MusicBrainz::Server::WebService::TXTSerializer;
use aliased 'MusicBrainz::Server::WebService::WebServiceStash';

my $ws_defs = Data::OptList::mkopt([
    mood => {
        method   => 'GET',
        inc      => [ qw( aliases annotation _relations ) ],
        optional => [ qw(fmt limit offset) ],
    },
    mood => {
        action   => '/ws/2/mood/lookup',
        method   => 'GET',
        optional => [ qw(fmt) ],
    }
]);

with 'MusicBrainz::Server::WebService::Validator' => {
    defs => $ws_defs,
};

with 'MusicBrainz::Server::Controller::WS::2::Role::Lookup' => {
    model => 'Mood',
};

sub serializers {
    [
        'MusicBrainz::Server::WebService::XMLSerializer',
        'MusicBrainz::Server::WebService::JSONSerializer',
        'MusicBrainz::Server::WebService::TXTSerializer',
    ]
}

sub base : Chained('root') PathPart('mood') CaptureArgs(0) { }

sub mood_toplevel {
    my ($self, $c, $stash, $moods) = @_;

    my $inc = $c->stash->{inc};
    my @moods = @{$moods};

    $c->model('Mood')->annotation->load_latest(@moods)
        if $inc->annotation;

    if ($inc->aliases) {
        my $aliases = $c->model('Mood')->alias->find_by_entity_ids(
            map { $_->id } @moods
        );
        for (@moods) {
            $stash->store($_)->{aliases} = $aliases->{$_->id};
        }
    }

    $self->load_relationships($c, $stash, @moods);
}

sub mood_all : Chained('base') PathPart('all') {
    my ($self, $c) = @_;

    $c->detach('method_not_allowed')
        unless $c->req->method eq 'GET';

    my ($limit, $offset) = $self->_limit_and_offset($c);

    my $stash = WebServiceStash->new;

    my $mood_list;
    if ($c->stash->{args}{fmt} eq 'txt') {
        # If fmt=txt, limit and offset are ignored.
        $mood_list = $c->model('Mood')->get_all_names;
    } else {
        my ($moods, $hits) =
            $c->model('Mood')->get_all_limited($limit, $offset);

        $self->mood_toplevel($c, $stash, $moods);

        $mood_list = $self->make_list($moods, $hits, $offset);
    }

    $c->res->content_type(
        $c->stash->{serializer}->mime_type . '; charset=utf-8'
    );
    $c->res->body($c->stash->{serializer}->serialize(
        'mood-list',
        $mood_list,
        $c->stash->{inc},
        $stash
    ));
}

sub mood_browse : Private {
    my ($self, $c) = @_;

    $c->detach('not_implemented');
}

sub mood_search : Chained('root') PathPart('mood') Args(0) {
    my ($self, $c) = @_;

    $c->detach('mood_browse') if $c->stash->{linked};
    $c->detach('not_implemented');
}
__PACKAGE__->meta->make_immutable;
1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2022 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut