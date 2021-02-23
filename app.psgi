#!/usr/bin/env perl
use strict;
use warnings;

use DBDefs;
use Moose::Util qw( ensure_all_roles );
use Plack::Builder;

BEGIN {
    # We've hit some pathological cases where different JSON backends are
    # used on different systems (e.g. JSON::PP instead of JSON::XS, due to the
    # latter not being installed despite existing in the Makefile), which
    # then breaks the code in some opaque way (e.g. JSON::PP doesn't assign a
    # ($) prototype to decode_json).
    #
    # The effect of the environment variable here is to force the use of
    # JSON::XS as the JSON backend, and die if it's not available.
    $ENV{PERL_JSON_BACKEND} = 2;
}

BEGIN {
    if (DBDefs->CATALYST_DEBUG) {
        require Plack::Middleware::Debug::DAOLogger;
        require Plack::Middleware::Debug::ExclusiveTime;
        require Plack::Middleware::Debug::TemplateToolkit;
    }
}

# Has to come before requiring MusicBrainz::Server
BEGIN {
    use Template;
    if (DBDefs->CATALYST_DEBUG) {
        $Template::Config::CONTEXT = 'My::Template::Context';
        $INC{'My/Template/Context.pm'} = 1;
    }
}

use MusicBrainz::Server;

BEGIN {
    if (DBDefs->FORK_RENDERER) {
        if (my $child = fork) {
            use POSIX;
            my $action = POSIX::SigAction->new(sub {
                kill 'TERM', $child;
                exit;
            });
            $action->safe(1);
            POSIX::sigaction(SIGTERM, $action);
        } else {
            exec './script/start_renderer.pl',
                 '--socket', DBDefs->RENDERER_SOCKET;
        }
    }
}

debug_method_calls() if DBDefs->CATALYST_DEBUG;

builder {
    if (DBDefs->CATALYST_DEBUG) {
        enable 'Debug', panels => [ qw( Memory Session Timer DAOLogger ExclusiveTime TemplateToolkit Parameters ) ];
    }
    if ($ENV{'MUSICBRAINZ_USE_PROXY'}) {
        enable 'Plack::Middleware::ReverseProxy';
    }

    enable 'Static', path => qr{^/(static/|browserconfig\.xml|favicon\.ico$)}, root => 'root';
    MusicBrainz::Server->psgi_app;
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
