#!/usr/bin/env perl
use strict;
use warnings;
use FindBin '$Bin';
use lib "$Bin/../../../lib";

use JSON::Any;
use MusicBrainz::Server::Context;
use MusicBrainz::Server::Constants qw( $EDIT_ARTIST_EDIT );

my $c = MusicBrainz::Server::Context->create_script_context;

my @to_fix = @{
    $c->sql->select_list_of_hashes(
        q{SELECT edit.id, edit.data, mod.prevvalue
            FROM edit
            JOIN public.moderation_closed mod ON mod.id = edit.id
           WHERE edit.type = ?
             AND edit.open_time < '2011-05-16'},
        $EDIT_ARTIST_EDIT
    )
};

$c->sql->begin;

my $json = JSON::Any->new( utf8 => 1 );

for my $edit (@to_fix) {
    my $data = $edit->{data} = $json->jsonToObj($edit->{data});

    if ($edit->{prevvalue} =~ "\n") {
        my %kv;
        for my $line (split /\n/, $edit->{prevvalue}) {
            my ($k, $v) = split /=/, $line, 2;
            next unless defined $v;
            $kv{$k} = _decode_value($v);
        }

        $data->{entity}{name} = $kv{ArtistName} // '[removed]';
    }
    else {
        $data->{entity}{name} = $edit->{prevvalue};
    }

    $c->sql->do(
        'UPDATE edit SET data = ? WHERE id = ?',
        $json->objToJson($data), $edit->{id}
    );
}

$c->sql->commit;

sub _decode_value
{
    my ($value) = @_;
    my ($scheme, $data) = $value =~ /\A\x1B(\w+);(.*)\z/s
        or return $value;

    return uri_unescape($data) if $scheme eq "URI";
    die "Unknown encoding scheme '$scheme'";
}
