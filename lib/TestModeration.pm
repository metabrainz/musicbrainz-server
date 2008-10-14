use strict;
use warnings;

use Moderation;
use MusicBrainz;
use MusicBrainz::Server::Artist;
use MusicBrainz::Server::Editor;

my $mb = new MusicBrainz;
$mb->Login;

my $artist = new MusicBrainz::Server::Artist($mb->{DBH});
$artist->id(20);
$artist->LoadFromId;

my $user = new MusicBrainz::Server::Editor($mb->{DBH});
my $user = $user->newFromId(4);

my $mod = Moderation->new('MOD_ADD_TRACK_KV', $mb->{DBH});
$mod->insert(
    DBH  => $mb->{DBH},
    user => $user,

    artist => $artist,
    trackname => "OMG TESTING",
    tracklength => "73631"
);

