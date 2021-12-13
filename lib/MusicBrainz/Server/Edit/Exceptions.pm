package MusicBrainz::Server::Edit::Exceptions;

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
