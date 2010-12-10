package MusicBrainz::Server::Controller::ReleaseEditor::Add;
use Moose;
BEGIN { extends 'MusicBrainz::Server::ControllerBase::ReleaseEditor' };

use aliased 'MusicBrainz::Server::Wizard::ReleaseEditor::Add'
    => 'ReleaseEditor';

sub add : Path('/release/add') Edit RequireAuth
{
    my ($self, $c) = @_;
    ReleaseEditor->new(c => $c)->run($c);
}

1;
