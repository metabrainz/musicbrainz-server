package MusicBrainz::Server::Replication;

use strict;
use warnings;

# The possible values for DBDefs->REPLICATION_TYPE
use constant RT_MASTER => 1;
use constant RT_SLAVE => 2;
use constant RT_MIRROR => 2;
use constant RT_STANDALONE => 3;

use constant REPLICATION_ACCESS_URI => 'https://metabrainz.org/api/musicbrainz';

use Exporter;
{
    our @ISA = qw( Exporter );
    our %EXPORT_TAGS = (
        replication_type => [qw(
                RT_MASTER
                RT_MIRROR
                RT_SLAVE
                RT_STANDALONE
        )],
    );
    our @EXPORT_OK = do {
        my %seen;
        grep { not $seen{$_}++ } map { @$_ } values %EXPORT_TAGS
    };
    push @EXPORT_OK, qw(
        REPLICATION_ACCESS_URI
    );
    $EXPORT_TAGS{'all'} = \@EXPORT_OK;
}

1;
