use strict;
use warnings;
use Plack::Builder;
use MusicBrainz::Server::WebService::2;

my $i = 0;
builder {
    enable "Plack::Middleware::AccessLog::Timed",
          format => "%v %h %l %u %t \"%r\" %>s %b %D";
    enable_if { $i++ > 2 && $ENV{DEBUG} } 'Debug' => panels => ['Profiler::NYTProf'];
    mount '/ws/2/' => MusicBrainz::Server::WebService::2->new
};
