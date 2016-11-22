use strict;
use warnings;

use MusicBrainz::Server::Context;

my $c = MusicBrainz::Server::Context->create_script_context;

my $tokens = $c->sql->select_single_column_array(
    "SELECT editor.name || '|' || token
     FROM editor_remember_me
     JOIN editor ON editor.id = editor_remember_me.editor"
);
for my $token (@$tokens) {
    $c->store->set($token, 1, 60 * 60 * 24 * 7 * 52);
}
