use strict;
use warnings;

use Test::More tests => 16;

use ModDefs;
use MusicBrainz;
use MusicBrainz::Server::Artist;
use MusicBrainz::Server::Script;
use MusicBrainz::Server::Language;

BEGIN { use_ok('MusicBrainz::Server::Release') };

# Test accessors
my $release = new MusicBrainz::Server::Release;

ok (defined $release, 'MB::S::Release->new returned an object');
isa_ok($release, 'MusicBrainz::Server::Release',
    'MB::S::Release->new returned a correctly blessed object');

# Test accessors;
my %test_data = (
    artist      => new MusicBrainz::Server::Artist,
    language_id => new MusicBrainz::Server::Language,
    script_id   => new MusicBrainz::Server::Script,
    quality     => ModDefs::QUALITY_NORMAL,
);

for my $key (keys %test_data)
{
    can_ok($release, $key);
    $release->$key($test_data{$key});
    is($release->$key, $test_data{$key});
}

# Test loading
my $mb = new MusicBrainz;
$mb->Login;

$release = new MusicBrainz::Server::Release($mb->{DBH});

$release->id(21);
$release->LoadFromId;

TODO: {
    local $TODO = 'return objects';
    isa_ok($release->script_id, 'MusicBrainz::Server::Script');
    isa_ok($release->language_id, 'MusicBrainz::Server::Language');
    isa_ok($release->artist, 'MusicBrainz::Server::Artist');
}

TODO: {
    local $TODO = 'rename methods';
    ok(!$release->can('script_id'));
    ok(!$release->can('language_id'));
}
