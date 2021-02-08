package MusicBrainz::Errors;

use v5.10;
use strict;
use warnings;

use base 'Exporter';
use Carp qw( croak );
use DBDefs;
use Devel::StackTrace;
use IO::File;
use Scalar::Util qw( blessed );
use Try::Tiny;

our @EXPORT_OK = qw(
    capture_exceptions
    get_error_message
    send_error_to_sentry
    sentry_enabled
    sig_die_handler
);

our $_sentry_enabled;
sub sentry_enabled () {
    return $_sentry_enabled if defined $_sentry_enabled;
    if (DBDefs->SENTRY_DSN) {
        eval {
            require Sentry::Raven;
            Sentry::Raven->import;
        };
        $_sentry_enabled = $@ ? 0 : 1;
    } else {
        $_sentry_enabled = 0;
    }
    return $_sentry_enabled;
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
    # twice, but we want to keep the original stack trace, not the re-thrown
    # one (which will be from a different context).
    #
    # This is why we key $stack_traces by $message and return if the key
    # exists -- we only want the first stack trace for a given error.
    my $stacktrace_info = $stack_traces->{$message};
    return if $stacktrace_info;

    my $stacktrace;
    {
        local $@;
        eval {
            $stacktrace = Devel::StackTrace->new(
                message => $message,
                ignore_class => [qw(
                    MusicBrainz::Errors
                    Try::Tiny
                )],
                defined $frame_filter ? (frame_filter => sub {
                    return $_[0]{caller}[0] =~ qr/$frame_filter/;
                }) : (),
            );
        };
    };
    return unless $stacktrace;

    my %sentry_frames;
    if (sentry_enabled) {
        my $frames = Sentry::Raven->_get_frames_from_devel_stacktrace($stacktrace);
        my @included_frames;
        my $i = -1;

        for my $frame (reverse $stacktrace->frames) {
            ++$i;
            my %context;
            {
                local $@;
                eval {
                    %context = get_context($frame->filename, $frame->line);
                };
            };

            push @included_frames, { %{ $frames->[$i] }, %context };
        }
        $sentry_frames{sentry_frames} = [reverse @included_frames];
    }

    $stack_traces->{$message} = {
        as_string => $stacktrace->as_string(max_arg_length => 0),
        %sentry_frames,
    };
}

our $sentry;
sub send_error_to_sentry {
    my ($error, $stack_traces, @context) = @_;

    my $message = get_error_message($error);
    my @stacktrace = reverse @{ $stack_traces->{$message}{sentry_frames} // [] };
    if (@stacktrace) {
        push @context, Sentry::Raven->stacktrace_context(\@stacktrace);
    }

    unless (defined $sentry) {
        my $sentry_dsn = DBDefs->SENTRY_DSN;
        my $git_branch = DBDefs->GIT_BRANCH;
        my $git_sha = DBDefs->GIT_SHA;

        $sentry = Sentry::Raven->new(
            sentry_dsn => $sentry_dsn,
            $git_branch ? (environment => $git_branch) : (),
            $git_sha ? (tags => {
                git_commit => $git_sha,
            }) : (),
        );
    }

    $sentry->capture_exception($message, @context);
}

sub capture_exceptions {
    my ($try_code, $catch_code) = @_;

    my $stack_traces = {};
    try {
        local $SIG{__DIE__} = sub {
            sig_die_handler(shift, $stack_traces);
        };
        $try_code->();
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

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2017 MetaBrainz Foundation
Copyright (C) 2015 Chisel Wright

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
