package MusicBrainz::Server::Replication;

use strict;
use warnings;

# The possible values for DBDefs->REPLICATION_TYPE
use constant RT_MASTER => 1;
use constant RT_SLAVE => 2; # deprecated in favor of RT_MIRROR
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

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2005 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
