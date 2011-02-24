package MusicBrainz::Server::WebService::Validation;
use strict;
use warnings;

use Sub::Exporter -setup => {
    exports => [qw( gid inc )],
};

use Data::OptList qw( mkopt_hash );
use Data::TreeValidator::Sugar qw( branch leaf );
use MusicBrainz::Server::Validation qw( is_valid_gid );

sub gid {
    return leaf(
        constraints => [ sub {
            die 'Invalid MBID'
                unless is_valid_gid(shift);
        } ]
    );
}

sub inc {
    my (@options) = @_;
    return leaf(
        constraints => [ sub {
            _parse_inc(shift, mkopt_hash(\@options));
        } ],
        transformations => [ sub {
            my @inc = split /\s+/, shift;
            return { map { $_ => 1 } @inc };
        } ],
    )
}

sub _parse_inc {
    my ($inc_string, $options) = @_;
    my %inc = map { $_ => 1 } split /\s+/, $inc_string;

    my %opts = %$options;
    my %reverse_deps = map {
        my $dependency = $_;
        map { $_ => $dependency } @{ $opts{$_} }
    } grep { $opts{$_} } keys %opts;

    for my $supplied (keys %inc) {
        die "'$supplied' is not a valid inc parameter"
            unless exists($opts{$supplied}) || exists($reverse_deps{$supplied});

        my $dependency = $reverse_deps{$supplied};
        die "'$supplied' is not a valid inc parameter unless you also supply '$dependency'"
            if $dependency && !exists $inc{$dependency};
    }

    return 1;
}

1;
