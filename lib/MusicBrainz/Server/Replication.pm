package MusicBrainz::Server::Replication;

use strict;
use warnings;

# The possible values for DBDefs->REPLICATION_TYPE
use constant RT_MASTER => 1;
use constant RT_SLAVE => 2;
use constant RT_STANDALONE => 3;

use Exporter;
{
    our @ISA = qw( Exporter );
    our %EXPORT_TAGS = (
        replication_type => [qw(
                RT_MASTER
                RT_SLAVE
                RT_STANDALONE
        )],
    );
    our @EXPORT_OK = do {
        my %seen;
        grep { not $seen{$_}++ } map { @$_ } values %EXPORT_TAGS
    };
    $EXPORT_TAGS{'all'} = \@EXPORT_OK;
}

1;
