package MusicBrainz::Server::Plugin::Age;

use strict;
use warnings;

use base 'Template::Plugin';
use Date::Calc qw(N_Delta_YMD Today);

sub _YMD
{
    my ($date) = @_;
    return ($date->year, $date->month, $date->day);
}

sub age
{
    my ($self, $begin) = @_;

    my @end_YMD = Today;
    my ($y, $m, $d) = N_Delta_YMD (_YMD ($begin), @end_YMD);

    return ($y, $m, $d);
}

1;
