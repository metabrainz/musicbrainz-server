package MusicBrainz::Sentry;

use v5.10;
use strict;
use warnings;

use base 'Exporter';
use Carp qw( croak );
use DBDefs;
use Devel::StackTrace;
use IO::File;
use Scalar::Util qw( blessed );
use Sentry::Raven;
use Try::Tiny;

our @EXPORT_OK = qw(
    capture_exceptions
    send_error_to_sentry
    sentry_enabled
    sig_die_handler
);

sub sentry_enabled () {
    return 1 if (DBDefs->SENTRY_DSN && !$ENV{MUSICBRAINZ_RUNNING_TESTS});
    return 0;
}

sub get_error_message {
    my $error = shift;

    my $message;
    # Some exception classes which overload q{""} include the entire trace
    # in as_string, which we don't want. If we can get the message on its
    # own, do that.
    if (blessed($error) && $error->can('message')) {
        $message = $error->message;
    } else {
        $message = "$error";
    }
    # For ad-hoc (string) exceptions, Catalyst chomps the message and wraps
    # it in some "Caught exception in ..." text, so we'll need to munge
    # things appropriately.
    chomp $message;
    $message =~ s/^Caught exception in [^"]+ "(.*)"$/$1/s;
    # Remove lines added when errors are rethrown.
    $message =~ s/^ at .+ line [0-9]+.*\.$//m;
    # Chomp again, since blank lines can be left.
    chomp $message;
    return $message;
}

sub ignored_error {
    my $error = shift;

    # These aren't actual errors, and are always caught in their respective
    # modules.
    my $class = blessed $error;
    return ($class && (
            $class eq 'Catalyst::Exception::Detach' ||
            $class eq 'Redis::X::Reconnect'));
}

# Since Catalyst runs all actions within an eval, we depend on the "feature"
# that the __DIE__ handler is even invoked inside evals, even though the
# perlvar docs say this was a mistake and is deprecated. Unfortunately, there
# doesn't seem to be any other way to implement this. Overriding
# CORE::GLOBAL::die doesn't work with C modules, for example, because they
# don't invoke `die` through Perl.
sub sig_die_handler {
    my ($error, $stack_traces, $frame_filter) = @_;

    return if ignored_error($error);

    my $message = get_error_message($error);
    # If an exception is caught and then re-thrown, __DIE__ will run
    # twice, but we want to keep the original stack trace.
    my $stacktrace = $stack_traces->{$message};
    return if $stacktrace;

    {
        local $@;
        eval { $stacktrace = Devel::StackTrace->new };
    };
    return unless $stacktrace;

    my $frames = Sentry::Raven->_get_frames_from_devel_stacktrace($stacktrace);
    my @included_frames;
    my $i = -1;

    for my $frame (reverse $stacktrace->frames) {
        ++$i;

        next if $frame->package =~ /^MusicBrainz::Sentry/;
        next if $frame->package =~ /^Try::Tiny/;

        if (defined $frame_filter) {
            next unless $frame->package =~ $frame_filter;
        }

        my %context;
        {
            local $@;
            eval {
                %context = get_context($frame->filename, $frame->line);
            };
        };

        push @included_frames, { %{ $frames->[$i] }, %context };
    }

    $stack_traces->{$message} = [reverse @included_frames];
}

sub send_error_to_sentry {
    my ($error, $stack_traces, @context) = @_;

    my $message = get_error_message($error);
    my @stacktrace = reverse @{ $stack_traces->{$message} // [] };
    if (@stacktrace) {
        push @context, Sentry::Raven->stacktrace_context(\@stacktrace);
    }

    state $sentry = Sentry::Raven->new(
        sentry_dsn => DBDefs->SENTRY_DSN,
        environment => DBDefs->GIT_BRANCH,
        tags => {
            git_commit => DBDefs->GIT_SHA,
        },
    );
    $sentry->capture_exception($message, @context);
}

sub capture_exceptions {
    my ($try_code, $catch_code) = @_;

    my $stack_traces = {};
    try {
        if (sentry_enabled) {
            local $SIG{__DIE__} = sub {
                sig_die_handler(shift, $stack_traces);
            };
            $try_code->();
        } else {
            $try_code->();
        }
    } catch {
        my $error = $_;
        if (sentry_enabled) {
            send_error_to_sentry($error, $stack_traces);
        }
        if (defined $catch_code) {
            $catch_code->($error);
        } else {
            croak $error;
        }
    };
}

# Based on Catalyst::Plugin::ErrorCatcher; modified to output context in the
# format expected by Sentry::Raven.
sub get_context {
    my ($file, $lineno) = @_;

    return unless -f $file;

    my %context;
    my $start = $lineno - 5;
    my $end = $lineno + 5;
    $start = $start < 1 ? 1 : $start;

    if (my $fh = IO::File->new($file, 'r')) {
        my $cur_lineno = 0;

        while (my $line = <$fh>) {
            ++$cur_lineno;
            last if $cur_lineno > $end;
            next if $cur_lineno < $start;

            if ($cur_lineno == $lineno) {
                $context{context_line} = $line;
            } elsif ($cur_lineno < $lineno) {
                push @{ $context{pre_context} }, $line;
            } else {
                push @{ $context{post_context} }, $line;
            }
        }
    }

    return %context;
}

1;

=head1 COPYRIGHT

Copyright (C) 2017 MetaBrainz Foundation
Copyright (C) 2015 Chisel Wright

This program is free software; you can redistribute it and/or
modify it under the terms of the GNU General Public License as
published by the Free Software Foundation; either version 2 of
the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program; if not, write to the Free Software
Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston,
MA 02110-1301, USA.

=cut
