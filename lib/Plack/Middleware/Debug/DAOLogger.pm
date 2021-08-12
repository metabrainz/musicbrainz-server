package Plack::Middleware::Debug::DAOLogger;

use utf8;

use parent qw(Plack::Middleware::Debug::Base);
use List::Util qw( sum );
use Scalar::Util qw( blessed );
use Statistics::Basic qw( stddev mean );
use Time::HiRes qw( gettimeofday tv_interval );

our @call_stack;
my $i = 0;

sub run {
    my ($self, $env, $panel) = @_;

    @call_stack = ();
    $i = 0;

    return sub {
        my $sum = sum(map { $_->[1] } @call_stack);

        $panel->content(
            "<p>This panel shows time spent within the data access layer. Rows ".
            "highlighted in red indicate that time spent within this method ".
            "deviates by more than 1 σ for all calls amongst siblings</p>".
            "<table>".
                '<thead><tr><th style="width: 6em">Time</th><th>Call</th></tr></thead>' .
                    render_stack(0, @call_stack) .
                        qq(<tr><th style="text-align: left" colspan="2">$sum</th></tr>).
                            "</table>");

        $panel->nav_title('Data Access');
        $panel->title('Time Spent in Data Access Objects');
        $panel->nav_subtitle(sprintf "%.4fs", $sum);
    };
}

sub render_stack {
    my ($indent, @stack) = @_;
    return unless @stack;

    my @times = map { $_->[1] } @stack;
    my $mean = mean(@times);
    my $std_dev = stddev(@times);

    my $content = '';
    while (@stack) {
        my ($name, $time, $calls) = @{ shift(@stack) };

        my $outlier = abs($time - $mean) > ($std_dev * 1);

        $content .= sprintf '<tr class="%s" %s>',
            ($i++ % 2 == 0 ? 'plDebugEven' : 'plDebugOdd'),
            ($outlier && 'style="background: #ffcccc"');
        $content .= sprintf '<td><div style="padding-left: %dem">%.5f</div></td>', $indent, $time;
        $content .= sprintf '<td style="padding-left: %dem">%s</td>', $indent * 2, $name;
        $content .= "</tr>";
        $content .= render_stack($indent + 1, @$calls);
    }

    return $content;
}

sub install_logging {
    my ($package, $method) = @_;
    $package->add_around_method_modifier($method->name, sub {
        my $orig = shift;
        if (blessed($_[0])) {
            my $self = shift;

            my @retained_stack = @call_stack;
            @call_stack = ();

            my $t0 = [ gettimeofday ];
            my @ret = wantarray ? $self->$orig(@_) : (scalar($self->$orig(@_)));
            my $t = tv_interval($t0);

            push @retained_stack, [
                $package->name . '->' . $method->name, $t, [@call_stack]
            ];

            @call_stack = @retained_stack;

            return wantarray ? @ret : $ret[0];
        }
        else {
            $orig->(@_);
        }
    });
};

1;
