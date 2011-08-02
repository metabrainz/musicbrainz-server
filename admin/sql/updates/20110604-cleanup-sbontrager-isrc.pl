#!/usr/bin/env perl
use strict;
use warnings;
use FindBin '$Bin';
use lib "$Bin/../../../lib";

use JSON::Any;
use MusicBrainz::Server::Context;
use MusicBrainz::Server::Data::Utils qw( placeholders );
use MusicBrainz::Server::Constants qw( $EDIT_RECORDING_ADD_ISRCS );
use MusicBrainz::Server::Log 'log_warning', 'logger';

my $c = MusicBrainz::Server::Context->create_script_context;
my $json = JSON::Any->new( utf8 => 1 );

# All edits by sbontrager's script
my @edits = @{ $c->raw_sql->select_list_of_hashes(
    'SELECT * FROM edit
      WHERE editor = ?
        AND type = ?
        AND id >= ?',
    478668, $EDIT_RECORDING_ADD_ISRCS, 14674615
) };

# Create a single array of all the <ISRC, recording> additions
my @additions = map {
    @{ $json->jsonToObj($_->{data})->{isrcs} }
} @edits;

# Find add isrc edits to these recordings that might have been correct
my @existing_edits = @{ $c->raw_sql->select_list_of_hashes(
    'SELECT DISTINCT ON (edit.id) * FROM edit
       JOIN edit_recording ON edit_recording.edit = edit.id
      WHERE id != any(?) AND type = ? AND recording = any(?) AND editor != ?',
    [ map { $_->{id} } @edits ],
    $EDIT_RECORDING_ADD_ISRCS,
    [ map { $_->{recording}{id} } @additions ],
    478668
) };

# Create an array of all additions here
my @existing_additions = map {
    my $edit = $_;
    map +{
       %$_,
       from => $edit->{id}
    }, @{ $json->jsonToObj($_->{data})->{isrcs} };
} @existing_edits;

# Find the difference, and which isrcs to remove
my ($remove, $keep) = difference(\@additions, \@existing_additions);

# Remove the offending ISRCs
log_warning { "Will remove the following ISRCs: $_" } $remove;
log_warning { "Will *not* remove the following ISRCs: $_" } $keep;

$c->sql->begin;
$c->sql->do(
    'DELETE FROM isrc
     USING (VALUES ' . (('(?, ?)') x @$remove) . ') remove (isrc, recording)
     WHERE isrc.isrc = remove.isrc AND isrc.recording = remove.recording',
    map { $_->{isrc}, $_->{recording} } @$remove
);
$c->sql->commit;

sub difference {
    my ($a, $b) = @_;
    my %in_b = map { hash_isrc_addition($_) => 1 } @$b;

    return
        [ grep { !$in_b{ hash_isrc_addition($_) } } @$a ],
        [ grep {  $in_b{ hash_isrc_addition($_) } } @$a ];

}

sub hash_isrc_addition {
    my $x = shift;
    return join('=', $x->{isrc}, $x->{recording}{id})
}
