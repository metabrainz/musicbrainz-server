package MusicBrainz::Server::Edit::Instrument;
use Moose::Role;
use namespace::autoclean;

use MusicBrainz::Server::Translation qw ( l );

sub edit_category { l('Instrument') }

around editor_may_edit => sub {
    my ($orig, $self) = @_;
    return $self->$orig && $self->editor->is_relationship_editor;
};

1;
