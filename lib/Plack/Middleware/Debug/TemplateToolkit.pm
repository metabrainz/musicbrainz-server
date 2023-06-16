package Plack::Middleware::Debug::TemplateToolkit;
use strict;
use warnings;

use parent qw(Plack::Middleware::Debug::Base);

our @output;

sub run {
    my ($self, $env, $panel) = @_;

    @output = ();
    return sub {
        my $res = shift;

        $panel->content(
            join('<br />',
                 map {
                     my ($template, $ltime, $calls) = @$_;
                     my $i = 0;
                     "<h3>$template (at $ltime)</h3>" .
                     '<table><thead><tr>'.
                     join('', map { "<th>$_</th>" } qw(cnt clk user sys cuser csys template)) .
                     '</tr><thead>'.
                     join('', map {
                         sprintf('<tr class="%s">', $i++ % 2 == 0 ? 'plDebugEven' : 'plDebugOdd').
                         sprintf('<td>%d</td><td>%d</td><td>%.2f</td>'.
                                 '<td>%.2f</td><td>%.2f</td><td>%.2f</td><td>%s</td>', @$_).
                     '</tr>'
                     } @$calls).
                     '</table>'
                 } @output)
        );
    }
}

package My::Template::Context;
use strict;
use warnings;
use base qw( Template::Context );

our @stack;
our %totals;

sub process {
  my $self = shift;

  my $template = $_[0];
  if ($template->isa('Template::Document')) {
    $template = $template->name || $template;
  }

  push @stack, [time, times];

  my @return = wantarray ?
    $self->SUPER::process(@_) :
      scalar $self->SUPER::process(@_);

  my @delta_times = @{pop @stack};
  @delta_times = map { $_ - shift @delta_times } time, times;
  for (0..$#delta_times) {
    $totals{$template}[$_] += $delta_times[$_];
    for my $parent (@stack) {
      $parent->[$_] += $delta_times[$_] if @stack; # parent adjust
    }
  }
  $totals{$template}[5] ++;     # count of calls

  unless (@stack) {
    ## top level again, time to display results
    push @Plack::Middleware::Debug::TemplateToolkit::output, [
        $template, scalar(localtime),
        [map {
            my @values = @{$totals{$_}};
            [$values[5], @values[0..4], $_]
        } (sort keys %totals)]
    ];
    %totals = ();               # clear out results
  }

  # return value from process:
  wantarray ? @return : $return[0];
}

1;
