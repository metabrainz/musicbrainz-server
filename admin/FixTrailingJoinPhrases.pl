#!/usr/bin/env perl

use warnings;
use strict;
use FindBin;
use lib "$FindBin::Bin/../lib";
use JSON;
use Encode;
use Text::Trim qw(trim);
use MusicBrainz::Server::Context;

my $c = MusicBrainz::Server::Context->create_script_context();
my $sql = Sql->new($c->conn);
my $dbh = $c->dbh;

my $candidates = $c->sql->select_list_of_hashes(
    "SELECT id, data FROM edit WHERE status = 1 AND data LIKE '%join_phrase%'");


sub patch_artist_credit
{
    my ($edit, $artist_credit) = @_;

    my $name_idx = $#{ $artist_credit->{names} };
    my $join = $artist_credit->{names}->[$name_idx]->{join_phrase};

    return "not affected" if $join eq '';
    return "not affected" if trim ($join) ne '';

    $artist_credit->{names}->[$name_idx]->{join_phrase} = '';

    warn "edit #".$edit.': patched join phrase from "'.$join.'" to ""'."\n";

    return "patched";
}


print "BEGIN;\n";

for my $edit (@$candidates) {

    my $utf8_data = utf8::is_utf8 ($edit->{data})
        ? encode ("utf-8", $edit->{data}) : $edit->{data};

    my $data = decode_json (encode ("utf-8", $utf8_data));

    my $not_affected = 0;
    my $patched = 0;

    my $id = $edit->{id};

    if ($data->{artist_credit})
    {
        my $result = patch_artist_credit ($id, $data->{artist_credit});
        $not_affected += 1 if $result eq "not affected";
        $patched += 1 if $result eq "patched";
    }
    elsif ($data->{new}->{artist_credit})
    {
        my $result = patch_artist_credit ($id, $data->{new}->{artist_credit});
        $not_affected += 1 if $result eq "not affected";
        $patched += 1 if $result eq "patched";
    }
    elsif ($data->{tracklist})
    {
        for my $track (@{ $data->{tracklist} })
        {
            my $result = patch_artist_credit ($id, $track->{artist_credit});
            $not_affected += 1 if $result eq "not affected";
            $patched += 1 if $result eq "patched";
        }
    }
    elsif ($data->{new}->{tracklist})
    {
        for my $track (@{ $data->{new}->{tracklist} })
        {
            my $result = patch_artist_credit ($id, $track->{artist_credit});
            $not_affected += 1 if $result eq "not affected";
            $patched += 1 if $result eq "patched";
        }
    }
    else
    {
        use Data::Dumper;
        warn "need traversing: ".Dumper ($data)."\n";
    }

    if ($patched)
    {
        warn "edit #$id: UPDATE edit with patched edit data.\n";

        my $escaped = $dbh->quote (decode ("utf-8", encode_json ($data)));
        print "UPDATE edit SET data = $escaped WHERE id = $id;\n";

    }

    unless ($not_affected || $patched)
    {
        warn "edit $id not supported!\n";
        warn Dumper ($data)."\n";
    }
};

print "COMMIT;\n";
