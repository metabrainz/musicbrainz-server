package ModerationTests;

use Test::More tests => 19;

BEGIN { use_ok('Moderation') }

use ModDefs;
use MusicBrainz;
use MusicBrainz::Server::Editor;

use Moderation;

#TODO Shouldn't we be using a MOCK moderation?
my $test_mod = new Moderation('MOD_ADD_ARTIST');

isa_ok($test_mod, 'MusicBrainz::Server::Moderation::MOD_ADD_ARTIST');

is($test_mod->allow_for_any_editor, 0,
    'Moderations should not be allowed for any editor by default');

#
# Test accessors
my $mb = new MusicBrainz;
$mb->Login;

my $editor = new MusicBrainz::Server::Editor($mb->{DBH});
$editor = $editor->newFromId(4);

my %test_data = (
    moderator            => $editor,
    expired              => 1,
    grace_period_expired => 1,
    open_time            => 'some time',
    close_time           => 'close time',
    expire_time          => 'expire time',
    status               => 'magical',

);

for my $key (keys %test_data)
{
    ok($test_mod->can($key), "Moderation should be able to $key");

    $test_mod->$key($test_data{$key});
    is($test_mod->$key, $test_data{$key}, "Setting $key and fetching gave differing values");
}

TODO: {
    local $TODO = 'Remove these methods';

    ok(!$test_mod->can('language_id'), "Shouldn't be able to call language_id");
    
    my $orig_type = $test_mod->type;
    $test_mod->type($orig_type + 1);
    is($test_mod->type, $orig_type, "Type of moderation should not be able to change");
}

1;
