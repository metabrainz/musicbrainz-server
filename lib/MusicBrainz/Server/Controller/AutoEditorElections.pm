package MusicBrainz::Server::Controller::AutoEditorElections;
BEGIN { use Moose; extends 'MusicBrainz::Server::Controller' }

__PACKAGE__->config( namespace => 'elections' );

sub index : Path('') { }

1;
