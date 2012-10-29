package MusicBrainz::Server::Entity::Statistics::ByDate;
use Moose;
use namespace::autoclean;

use MusicBrainz::Server::Types qw( DateTime );
use MooseX::Types::Moose qw( Str Int );
use MooseX::Types::Structured qw( Map );

has data => (
    is => 'rw',
    isa => Map[ Str, Int ], # Map stat name to value
    traits => [ 'Hash' ],
    default => sub { {} },
    handles => {
        statistic => 'get',
        statistic_names => 'keys'
    }
);

has date_collected => (
   is => 'rw',
   isa => DateTime,
   coerce => 1
);

sub summed_statistics {
    my ($self, $stats) = @_;
    my $sum = 0;
    if (ref($stats) eq 'ARRAY') {
        foreach my $i (@{$stats}) {
            $sum += $self->statistic($i);
        }
    } else {
        $sum = $self->statistic($stats) || 0;
    }
    return $sum
}

sub ratio {
    my ($self, $num_stat, $denom_stat) = @_;
    my $denominator = $self->summed_statistics($denom_stat);

    return 0 unless $denominator > 0;
    return $self->summed_statistics($num_stat) * 100 / $denominator;
}

__PACKAGE__->meta->make_immutable;
no Moose;
1;

=head1 COPYRIGHT

Copyright (C) 2011 MetaBrainz Foundation Inc.

This program is free software; you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation; either version 2 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program; if not, write to the Free Software
Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.

=cut
