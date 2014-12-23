package MusicBrainz::Server::Edit::Instrument;
use Moose::Role;
use namespace::autoclean;

use MusicBrainz::Server::Translation 'l';

sub edit_category { l('Instrument') }

sub editor_may_edit {
    my ($self) = @_;
    return $self->editor->is_relationship_editor;
}

1;
