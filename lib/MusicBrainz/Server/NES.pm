package MusicBrainz::Server::NES;
use Moose;

use Data::Dumper::Concise qw( Dumper );
use Devel::Dwarn;
use Encode;
use JSON;
use Try::Tiny;
use Time::HiRes qw( gettimeofday tv_interval );

has lwp => (
    is => 'ro',
    required => 1
);

has session_token => (
    is => 'rw',
    clearer => 'clear_session_token',
    predicate => 'in_session'
);

sub request {
    my ($self, $path, $body) = @_;

    my $uri = DBDefs->DATA_ACCESS_SERVICE.$path;
    my $content = to_json ($body, { canonical => 1 });

    printf STDERR "> Request: $uri\n";
    printf STDERR Dumper($body), "\n";

    my @headers;
    push @headers, ('MB-Session' => $self->session_token)
        if $self->in_session && $self->session_token;

    my $t0 = [ gettimeofday ];
    my $response = $self->lwp->post($uri, @headers, Content => encode('utf8', $content));
    my $t = tv_interval($t0);

    printf STDERR "Response in ${t}s\n";
    printf STDERR $response->content;

    if (!$response->is_success) {
        printf STDERR "FAILURE!\n";
        die "Failed request '$path': " . $response->content;;
    }

    return try {
        printf STDERR "\n\n";

        return decode_json($response->content);
    }
    catch {
        die 'Failed to decode response: ' . $response->content;
    }
}

sub with_transaction {
    my ($self, $code) = @_;

    $self->clear_session_token;
    $self->session_token($self->request('/open-session', {})->{token});

    return try {
        my $ret = $code->();
        $self->request('/close-session', {});

        return $ret;
    }
    catch {
        try { $self->request('/close-session', {}) };
        $self->clear_session_token;

        die $_;
    };
}

1;
