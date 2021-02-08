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
   isa => Str
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

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2011 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
