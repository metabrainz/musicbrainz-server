package MusicBrainz::Server::Edit::Role::DatePeriod;
use Moose::Role;
use namespace::autoclean;
use Hash::Merge qw( merge );
use List::AllUtils qw( any );
use MusicBrainz::Server::Data::Utils qw( non_empty partial_date_to_hash );

use aliased 'MusicBrainz::Server::Entity::PartialDate';

around initialize => sub {
    my ($orig, $self, %opts) = @_;

    if ($self->can('initialize_date_period')) {
        $self->initialize_date_period(\%opts);
    }

    my $empty_date = partial_date_to_hash(PartialDate->new);
    if (exists $opts{begin_date}) {
        $opts{begin_date} = merge($opts{begin_date} // {}, $empty_date);
    }

    if (exists $opts{end_date}) {
        $opts{end_date} = merge($opts{end_date} // {}, $empty_date);

        # year can be 0 in the proleptic Gregorian calendar
        $opts{ended} = 1 if any { non_empty($_) } values %{$opts{end_date}};
    }

    $opts{ended} //= 0;
    $self->$orig(%opts);
};

1;
