use strict;
use warnings;

use English;
use MusicBrainz::Server::Context;
use Sql;

$OUTPUT_AUTOFLUSH = 1;
my $c = MusicBrainz::Server::Context->create_script_context;

my $i = 0;
while(1) {
    my @batch = @{
        $c->sql->select_single_column_array(
            'SELECT recording.id
             FROM recording
             JOIN track ON track.recording = recording.id
             GROUP BY track.recording, recording.id
             HAVING median(track.length) IS DISTINCT FROM recording.length
             LIMIT 100'
        )
    } or last;

    Sql::run_in_transaction(sub {
        $c->sql->do(
            'SELECT materialise_recording_length(id)
             FROM unnest(?::int[]) recording (id)',
            \@batch
        );
    }, $c->sql);

    print "Batches complete: ", $i++, "\r";
}
