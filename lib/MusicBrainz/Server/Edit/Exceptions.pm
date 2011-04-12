package MusicBrainz::Server::Edit::Exceptions;

use Exception::Class (
    'MusicBrainz::Server::Edit::Exceptions::NoChanges',
    'MusicBrainz::Server::Edit::Exceptions::FailedDependency',
    'MusicBrainz::Server::Edit::Exceptions::HistoricDataCorrupt',
    'MusicBrainz::Server::Edit::Exceptions::MustApply'
);

1;
