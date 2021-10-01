package MusicBrainz::Server::Edit::Area;
use Moose::Role;
use namespace::autoclean;

use MusicBrainz::Server::Translation qw ( l );

sub edit_category { l('Area') }

around editor_may_edit => sub {
    my ($orig, $self) = @_;
    return $self->$orig && $self->editor->is_location_editor;
};

1;
