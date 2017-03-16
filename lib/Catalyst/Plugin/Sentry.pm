package Catalyst::Plugin::Sentry;

use v5.10;
use strict;
use warnings;

use CGI::Simple::Util qw( escape );
use DBDefs;
use Devel::StackTrace;
use IO::File;
use Moose;
use Scalar::Util qw( blessed );
use Sentry::Raven;

our $suppress = 0;

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

sub execute {
    my $c = shift;

    # Since Catalyst runs all actions within an eval, we depend on the
    # "feature" that the __DIE__ handler is even invoked inside evals, even
    # though the perlvar docs say this was a mistake and is deprecated.
    # Unfortunately, there doesn't seem to be any other way to implement this.
    # Overriding CORE::GLOBAL::die doesn't work with C modules, for example,
    # because they don't invoke `die` through Perl.
    local $SIG{__DIE__} = sub {
        my $error = shift;

        return if ignored_error($error);

        my $message = get_error_message($error);
        # If an exception is caught and then re-thrown, __DIE__ will run
        # twice, but we want to keep the original stack trace.
        my $stacktrace = $c->stash->{stack_trace}{$message};
        return if $stacktrace;

        {
            local $@;
            eval { $stacktrace = Devel::StackTrace->new };
        };
        return unless $stacktrace;

        my $app = "$c" =~ s/=.*//r;
        my $frames = Sentry::Raven->_get_frames_from_devel_stacktrace($stacktrace);
        my @app_frames;
        my $i = -1;

        for my $frame (reverse $stacktrace->frames) {
            ++$i;

            next unless $frame->package =~ /^$app/;

            my %context;
            {
                local $@;
                eval {
                    %context = get_context($frame->filename, $frame->line);
                };
            };

            push @app_frames, { %{ $frames->[$i] }, %context };
        }

        $c->stash->{stack_trace}{$message} = [reverse @app_frames];
    };

    return $c->next::method(@_);
}

sub finalize_error {
    return if $suppress;

    my $c = shift;

    my $req = $c->req;
    my $body = $req->body;
    if (ref $body) {
        $body = eval { local $/; seek $body, 0, 0; <$body> };
    }

    my @context;
    push @context, Sentry::Raven->request_context(
        $req->uri,
        cookies => (join ';', map {
            my $name = escape($_->name);
            my $value = join '&', map { escape($_) } $_->value;
            "$name=$value";
        } values %{ $req->cookies }),
        ($body ? (data => $body) : ()),
        headers => {
            map { my $value = $req->headers->header($_); ($_ => $value) }
                $req->headers->header_field_names
        },
        method => $req->method,
    );

    if ($c->user_exists) {
        push @context, Sentry::Raven->user_context(
            id => $c->user->id,
            username => $c->user->name,
        );
    }

    my $message = get_error_message($c->error->[0]);
    my @stacktrace = reverse @{ $c->stash->{stack_trace}{$message} // [] };
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

=head1 DESCRIPTION

Catalyst plugin that catches exceptions in the app and sends them to
Sentry. When you don't want an error sent, use C<local> to
temporarily give C<$suppress> a true value.

=head1 COPYRIGHT

Copyright (C) 2017 MetaBrainz Foundation
Copyright (C) 2015 Chisel Wright
Copyright (C) 2015 Ulrich Klauer

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
