#!/usr/bin/env perl
use strict;
use warnings;

BEGIN {
    use Plack::Middleware::Debug::TemplateToolkit;
    use Template;
    $Template::Config::CONTEXT = 'My::Template::Context';
    $INC{'My/Template/Context.pm'} = 1;
}

use Plack::Builder;
use Moose::Util qw( ensure_all_roles );
use MusicBrainz::Server;
use Plack::Middleware::Debug::DAOLogger;
use Plack::Middleware::Debug::ExclusiveTime;

MusicBrainz::Server->setup_engine('PSGI');
my $app = sub { MusicBrainz::Server->run(@_) };

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

builder {
    enable 'Debug', panels => [ qw( Memory Session Timer DAOLogger ExclusiveTime TemplateToolkit Parameters ) ];
    $app
};
