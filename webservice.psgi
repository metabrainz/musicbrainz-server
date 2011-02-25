use strict;
use warnings;
use Plack::Builder;
use MusicBrainz::Server::WebService::2;

builder {
    enable "Plack::Middleware::AccessLog::Timed",
          format => "%v %h %l %u %t \"%r\" %>s %b %D";
    mount '/ws/2/' => MusicBrainz::Server::WebService::2->new
};
