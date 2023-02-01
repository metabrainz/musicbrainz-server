package MusicBrainz::Server::Edit::Exceptions;
use strict;
use warnings;

use Exception::Class ( ## no critic 'ProhibitUnusedImport'
    'MusicBrainz::Server::Edit::Exceptions::NoChanges',
    'MusicBrainz::Server::Edit::Exceptions::FailedDependency',
    'MusicBrainz::Server::Edit::Exceptions::HistoricDataCorrupt',
    'MusicBrainz::Server::Edit::Exceptions::MustApply',
    'MusicBrainz::Server::Edit::Exceptions::GeneralError',
    'MusicBrainz::Server::Edit::Exceptions::DuplicateViolation' => {
        fields => [qw( conflict )]
    },
    'MusicBrainz::Server::Edit::Exceptions::NoLongerApplicable',
    'MusicBrainz::Server::Edit::Exceptions::Forbidden',
    'MusicBrainz::Server::Edit::Exceptions::NeedsDisambiguation'
);

1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2009 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
