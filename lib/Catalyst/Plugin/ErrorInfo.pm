package Catalyst::Plugin::ErrorInfo;

use v5.10;
use strict;
use warnings;

use CGI::Simple::Util qw( escape );
use MusicBrainz::Errors qw(
    get_error_message
    send_error_to_sentry
    sentry_enabled
    sig_die_handler
);

BEGIN {
    if (sentry_enabled) {
        require Sentry::Raven;
        Sentry::Raven->import;
    }
}

our $suppress_sentry = 0;

sub execute {
    my $c = shift;

    my $frame_filter = qr/^MusicBrainz::Server/;
    my $stack_traces = ($c->stash->{_stack_trace_info} //= {});

    local $SIG{__DIE__} = sub {
        sig_die_handler(shift, $stack_traces, $frame_filter);
    };

    return $c->next::method(@_);
}

sub finalize_error {
    my $c = shift;

    my @sentry_context;
    if (sentry_enabled) {
        my $req = $c->req;
        my $body = $req->body;
        if (ref $body) {
            $body = eval { local $/; seek $body, 0, 0; <$body> };
        }

        push @sentry_context, Sentry::Raven->request_context(
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
            push @sentry_context, Sentry::Raven->user_context(
                id => $c->user->id,
                username => $c->user->name,
            );
        }
    }

    my $stack_traces = ($c->stash->{_stack_trace_info} //= {});
    for my $error (@{ $c->error }) {
        if (sentry_enabled && !$suppress_sentry) {
            send_error_to_sentry($error, $stack_traces, @sentry_context);
        }

        my $error_message = get_error_message($error);
        push @{ $c->stash->{formatted_errors} //= [] },
            (exists $stack_traces->{$error_message}
                ? $stack_traces->{$error_message}{as_string}
                : $error_message);
    }
}

1;

=head1 DESCRIPTION

Catalyst plugin that catches exceptions in the app, stores them
as C<formatted_errors> in the stash for display, and sends them
to Sentry.

When you don't want an error sent, use C<local> to temporarily
give C<$suppress_sentry> a true value.

=head1 COPYRIGHT

Copyright (C) 2017 MetaBrainz Foundation
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
