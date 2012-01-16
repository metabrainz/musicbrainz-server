package MusicBrainz::Data::TreeValidator::Constraints;
use Date::Calc ();
use Try::Tiny;
use strict;
use warnings;
use Scalar::Util qw( looks_like_number );
use Data::TreeValidator::Util qw( fail_constraint );
use MusicBrainz::Server::Validation qw( is_positive_integer );

use Sub::Exporter -setup => {
    exports => [ qw( integer partial_date ) ]
};

sub integer { \&_integer }
sub _integer {
    local $_ = shift;
    fail_constraint ("Not an integer") if defined $_ && !is_positive_integer ($_);
}

sub partial_date { \&_partial_date }
sub _partial_date {
    my $date = shift;

    return unless $date;

    my $invalid = "Not a valid date";

    my ($year, $month, $day) = split ("-", $date);

    fail_constraint($invalid) if defined $year  && !is_positive_integer ($year);
    fail_constraint($invalid) if defined $month && !is_positive_integer ($month);
    fail_constraint($invalid) if defined $day   && !is_positive_integer ($day);

    # anything partial cannot be checked, and is therefore considered valid.
    return unless ($year && $month && $day);

    fail_constraint ($invalid) unless Date::Calc::check_date ($year, $month, $day);
}

1;

