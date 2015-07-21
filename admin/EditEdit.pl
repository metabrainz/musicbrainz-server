#!/usr/bin/env perl
use strict;
use warnings;

use Encode;
use FindBin;
use JSON::Any;
use lib "$FindBin::Bin/../lib";
use MusicBrainz::Server::Context;
use MusicBrainz::Server::Validation qw( is_positive_integer );

my $id = $ARGV[0];
is_positive_integer($id) or die "invalid edit id";

my $c = MusicBrainz::Server::Context->create_script_context(database => 'READWRITE');
my $old_data = $c->sql->select_single_value('SELECT data FROM edit WHERE id = ?', $id)
    or die 'edit not found';

print "current edit data:\n" . encode('UTF-8', $old_data) . "\n";
print "paste new edit data:\n";

my $new_data = <STDIN>;
chomp($new_data);

# will die if JSON is invalid
JSON::Any->new(utf8 => 1)->jsonToObj($new_data);
$new_data = decode('UTF-8', $new_data, Encode::FB_CROAK);

$c->sql->auto_commit;
$c->sql->do('UPDATE edit SET data = ? WHERE id = ?', $new_data, $id);
