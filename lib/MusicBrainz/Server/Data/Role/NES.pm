package MusicBrainz::Server::Data::Role::NES;
use Moose::Role;

with 'MusicBrainz::Server::Data::Role::Context';

use Data::Dumper::Concise qw( Dumper );
use Devel::Dwarn;
use Encode;
use JSON;
use Try::Tiny;
use Time::HiRes qw( gettimeofday tv_interval );

sub request {
    my ($self, $path, $body) = @_;

    my $uri = DBDefs->DATA_ACCESS_SERVICE.$path;
    my $content = to_json ($body, { canonical => 1 });

    printf STDERR "> Request: $uri\n";
    printf STDERR Dumper($body), "\n";

    my $t0 = [ gettimeofday ];
    my $response = $self->c->lwp->post($uri, Content => encode('utf8', $content));
    my $t = tv_interval($t0);

    return try {
        printf STDERR "Response in ${t}s\n";
        printf STDERR $response->content;
        printf STDERR "\n\n";

        return decode_json($response->content);
    }
    catch {
        die 'Failed to decode response: ' . $response->content;
    }
}

1;
