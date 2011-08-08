use strict;
use warnings;

use FindBin '$Bin';
use lib "$Bin/../../../lib";

use MusicBrainz::Server::Context;

my $c = MusicBrainz::Server::Context->create_script_context;

my @fix = (
    [ 'artist_rating_raw', [qw( editor artist )], 'artist', 'artist' ],
    [ 'label_rating_raw', [qw( editor label )], 'label', 'label' ],
    [ 'release_group_rating_raw', [qw( editor release_group )], 'release_group', 'release_group' ],
    [ 'recording_rating_raw', [qw( editor recording )], 'recording', 'recording' ],
    [ 'work_rating_raw', [qw( editor work )], 'work', 'work' ],

    [ 'artist_tag_raw', [qw( editor artist )], 'artist', 'artist' ],
    [ 'label_tag_raw', [qw( editor label )], 'label', 'label' ],
    [ 'release_tag_raw', [qw( editor release )], 'release', 'release' ],
    [ 'release_group_tag_raw', [qw( editor release_group )], 'release_group', 'release_group' ],
    [ 'recording_tag_raw', [qw( editor recording )], 'recording', 'recording' ],
    [ 'work_tag_raw', [qw( editor work )], 'work', 'work' ],

    [ 'edit_artist', [qw( edit artist )], 'artist', 'artist' ],
    [ 'edit_label', [qw( edit label )], 'label', 'label' ],
    [ 'edit_recording', [qw( edit recording )], 'recording', 'recording' ],
    [ 'edit_release', [qw( edit release )], 'release', 'release' ],
    [ 'edit_release_group', [qw( edit release_group )], 'release_group', 'release_group' ],
    [ 'edit_work', [qw( edit work )], 'work', 'work' ],
    [ 'edit_url', [qw( edit url )], 'url', 'url' ],
);

printf "BEGIN;\n";

for my $fix (@fix) {
    my ($raw_table, $pk, $join_on, $join) = @$fix;

    my @offending_rows = @{
        $c->sql->select_list_of_hashes(
            sprintf("SELECT %s FROM %s LEFT JOIN %s ON %s.id = %s.%s WHERE %s.id IS NULL",
                    join(', ', map { "$raw_table.$_" } @$pk), $raw_table,
                    $join, $join, $raw_table, $join_on,
                    $join)
        )
    } or next;

    printf("DELETE FROM %s USING (VALUES %s) AS to_delete (%s) WHERE %s\n",
           $raw_table,
           join(', ', map {
               my $row = $_;
               '('.
                   join(', ', (map { $row->{$_} } @$pk)).
               ')'
           } @offending_rows),
           join(', ', @$pk),
           join(' AND ', map { "to_delete.$_ = $raw_table.$_" } @$pk)
       );
}

printf "COMMIT;\n";
