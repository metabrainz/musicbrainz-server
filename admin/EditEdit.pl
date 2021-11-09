#!/usr/bin/env perl
use strict;
use warnings;
use open qw( :std :utf8 );

use Encode;
use FindBin;
use JSON::XS;
use lib "$FindBin::Bin/../lib";
use MusicBrainz::Server::Context;
use MusicBrainz::Server::Validation qw( is_positive_integer );

my $id = $ARGV[0];
is_positive_integer($id) or die 'invalid edit id';

my $c = MusicBrainz::Server::Context->create_script_context(database => 'READWRITE');
my $old_data = $c->sql->select_single_value('SELECT data FROM edit_data WHERE edit = ?', $id)
    or die 'edit not found';

print "current edit data:\n" . $old_data . "\n";
print "paste new edit data:\n";

my $new_data = <STDIN>;
chomp($new_data);

# will die if JSON is invalid
JSON::XS->new->decode($new_data);

$c->sql->auto_commit;
$c->sql->do('UPDATE edit_data SET data = ? WHERE edit = ?', $new_data, $id);
