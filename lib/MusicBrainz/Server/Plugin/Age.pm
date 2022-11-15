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
    my ($y, $m, $d) = N_Delta_YMD(_YMD($begin), @end_YMD);

    return ($y, $m, $d);
}

1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2012 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
