#!/usr/bin/env perl
use strict;
use warnings;

use DBDefs;
use Moose::Util qw( ensure_all_roles );
use Plack::App::Cascade;
use Plack::App::URLMap;
use Plack::Builder;
use Plack::Middleware::Debug::DAOLogger;
use Plack::Middleware::Debug::ExclusiveTime;
use Plack::Middleware::Debug::TemplateToolkit;

# Has to come before requiring MusicBrainz::Server
BEGIN {
    use Template;
    if (DBDefs::CATALYST_DEBUG) {
        $Template::Config::CONTEXT = 'My::Template::Context';
        $INC{'My/Template/Context.pm'} = 1;
    }
}

use MusicBrainz::Server;
use MusicBrainz::WebService;

debug_method_calls() if DBDefs::CATALYST_DEBUG;

builder {
    if (DBDefs::CATALYST_DEBUG) {
        enable 'Debug', panels => [ qw( Memory Session Timer DAOLogger ExclusiveTime TemplateToolkit Parameters ) ];
    }
    if ($ENV{'MUSICBRAINZ_USE_PROXY'}) {
        enable 'Plack::Middleware::ReverseProxy';
    }

    enable 'Static', path => qr{^/static/}, root => 'root';

    my $sloth_ws = Plack::App::URLMap->new;
    $sloth_ws->map('/ws/2/', MusicBrainz::WebService->new);

    my $app_stack = Plack::App::Cascade->new;
    $app_stack->add($sloth_ws);
    $app_stack->add(MusicBrainz::Server->psgi_app);
    return $app_stack;
};

sub debug_method_calls {
    for my $model (sort MusicBrainz::Server->models) {
        my $m = MusicBrainz::Server->model($model);
        $m->meta->make_mutable;
        for my $method ($m->meta->get_all_methods) {
            next if uc($method->name) eq $method->name;
            next if $method->name =~ /^(new|does|can|c|sql|dbh)$/;

            unless ($method->name =~ /^_/) {
                Plack::Middleware::Debug::DAOLogger::install_logging($m->meta, $method);
            }

            Plack::Middleware::Debug::ExclusiveTime::install_timing($m->meta, $method);
        }
        $m->meta->make_immutable;
    }
}
