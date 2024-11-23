package MusicBrainz::Server::Controller::WS::js::CheckDuplicates;
use Moose;
use MooseX::MethodAttributes;
use namespace::autoclean;
use HTTP::Status qw( :constants );
use JSON;
use Try::Tiny;
use MusicBrainz::Server::Data::Utils qw(type_to_model);
use aliased 'MusicBrainz::Server::WebService::JSONSerializer';

extends 'MusicBrainz::Server::ControllerBase::WS::js';

my $ws_defs = Data::OptList::mkopt([
    'check_duplicates' => {
        method => 'GET',
        required => [qw(type name)],
        optional => [qw(mbid)],
    },
]);

with 'MusicBrainz::Server::WebService::Validator' => {
     defs => $ws_defs,
     version => 'js',
     default_serialization_type => 'json',
};

sub check_duplicates : Chained('root') PathPart('check_duplicates') Args(0) {
    my ($self, $c) = @_;

    $c->res->content_type($c->stash->{serializer}->mime_type . '; charset=utf-8');

    my ($type, $name, $mbid) = @{$c->stash->{args}}{qw(type name mbid)};
    my $model;

    try {
        $model = type_to_model($type);
    } catch {
        $c->res->status(HTTP_BAD_REQUEST);
        $c->res->body(encode_json({error => $_}));
        $c->detach;
    };

    my @duplicates;
    if ($c->model($model)->can('search_by_names')) {
        my $ret = $c->model($model)->search_by_names($name)->{$name};
        if ($ret) {
            @duplicates = @{ $ret };
        }
    } else {
        @duplicates = $c->model($model)->find_by_name($name);
    }

    $c->res->body(encode_json({
        duplicates => [
            map {JSONSerializer->serialize_internal($c, $_)}
            grep {$_->gid ne ($mbid // '')}
            @duplicates,
        ],
    }));
}

1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2015 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
