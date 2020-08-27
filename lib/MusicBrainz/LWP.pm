package MusicBrainz::LWP;

use Moose;
use namespace::autoclean;

use AnyEvent;
use AnyEvent::HTTP::LWP::UserAgent;
use DBDefs;
use HTTP::Status qw( HTTP_INTERNAL_SERVER_ERROR );
use LWP::UserAgent;
use MooseX::Types::Moose qw( Int );
use MusicBrainz::Server::Log qw( log_debug );
use feature 'switch';

no if $] >= 5.018, warnings => 'experimental::smartmatch';

BEGIN { $ENV{PERL_ANYEVENT_MODEL} = 'EV'; }

has 'global_timeout' => (
    is => 'rw',
    isa => Int,
);

has '_lwp_user_agent' => (
    is => 'rw',
    isa => 'LWP::UserAgent',
);

sub BUILD {
    my ($self, $args) = @_;

    $args->{agent} = DBDefs->LWP_USER_AGENT unless exists $args->{agent};

    my $global_timeout =
        exists $args->{global_timeout}
            ? delete $args->{global_timeout}
            : 0;

    $self->global_timeout($global_timeout);
    $self->_lwp_user_agent(AnyEvent::HTTP::LWP::UserAgent->new(%$args));
}

sub _call_lwp_method_with_global_timeout {
    my ($self, $lwp_method, $http_method, $arg) = @_;

    my $ua = $self->_lwp_user_agent;
    my $cv = AE::cv;
    $cv->begin;

    my $response;
    my $global_timeout = $self->global_timeout;
    my $got_timeout = 0;

    my $uri;
    my $request;
    my $req_cv;
    given ($lwp_method) {
        when ('get') {
            $uri = $arg;
            $req_cv = $ua->get_async($uri);
        }
        when ('mirror') {
            $uri = $arg;
            $req_cv = $ua->mirror_async($uri);
        }
        when ('post') {
            $uri = $arg;
            $req_cv = $ua->post_async($uri);
        }
        when ('request') {
            $request = $arg;
            $req_cv = $ua->request_async($request);
        }
    }

    $req_cv->cb(sub {
        $response = shift->recv;
        $cv->end;
    });

    my $timer = AnyEvent->timer(after => $global_timeout, cb => sub {
        $req_cv->croak;
        $got_timeout = 1;
        $cv->croak;
    }) unless $global_timeout == 0;

    $cv->recv;

    undef $timer; # cancels the timer

    if ($got_timeout) {
        $uri //= $request->uri;
        $request //= HTTP::Request->new($http_method, $uri);
        my $message = "$lwp_method $uri took more than $global_timeout seconds";
        log_debug { $message };
        $response = LWP::UserAgent::_new_response(
            $request,
            HTTP_INTERNAL_SERVER_ERROR,
            $message,
        );
    }

    return $response;
}

sub get { shift->_call_lwp_method_with_global_timeout('get', 'GET', @_); }
sub mirror { shift->_call_lwp_method_with_global_timeout('mirror', 'GET', @_); }
sub post { shift->_call_lwp_method_with_global_timeout('post', 'POST', @_); }
sub request {
    my ($self, $request) = @_;
    $self->_call_lwp_method_with_global_timeout('request', $request->method, $request);
}

sub env_proxy { shift->_lwp_user_agent->env_proxy; }
sub ssl_opts { shift->_lwp_user_agent->ssl_opts(@_); }

sub inactivity_timeout {
    my ($self, $seconds) = @_;
    if (defined $seconds) {
        $self->_lwp_user_agent->timeout($seconds);
    } else {
        return $self->_lwp_user_agent->timeout;
    }
}

__PACKAGE__->meta->make_immutable;
no Moose;
1;

=head1 NAME

MusicBrainz::LWP - MusicBrainz wrapper of libwww-perl

=head1 DESCRIPTION

A wrapper that forges a custom response with error status code 503 when
a call to a request method takes globally more than C<global_timeout>.

By default, the value of C<global_timeout> is 0, that is no global timeout.

Additionally, it sets MusicBrainz Server User-Agent header if missing.

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2019 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
