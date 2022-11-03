package Plack::Middleware::Debug::ExclusiveTime;
use strict;
use warnings;

use parent qw(Plack::Middleware::Debug::Base);
use Scalar::Util qw( blessed );
use Time::HiRes qw( gettimeofday tv_interval );
use List::AllUtils qw( sum );

our %call_times;
my $i = 0;

sub run {
    my ($self, $env, $panel) = @_;

    %call_times = ();
    $i = 0;

    return sub {
        $panel->content(
            $self->render_list_pairs(
                [
                    map { $_, sprintf('%.5f', $call_times{$_}) }
                        reverse sort { $call_times{$a} <=> $call_times{$b} }
                            keys %call_times ]));
    };
}

sub install_timing {
    my ($package, $method) = @_;
    $package->add_around_method_modifier($method->name, sub {
        my $orig = shift;
        if (blessed($_[0])) {
            my $self = shift;

            my $cons_name = $package->name . '->' . $method->name;

            my %retained_times = %call_times;
            %call_times = ();

            my $t0 = [ gettimeofday ];
            my @ret = wantarray ? $self->$orig(@_) : (scalar($self->$orig(@_)));
            my $t = tv_interval($t0) - (sum(values %call_times) // 0);

            $call_times{$cons_name} += $t;

            for my $n (keys %call_times) {
                $retained_times{$n} += $call_times{$n};
            }

            %call_times = %retained_times;

            return wantarray ? @ret : $ret[0];
        }
        else {
            $orig->(@_);
        }
    });
};

1;
