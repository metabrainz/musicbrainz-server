package MusicBrainz::Server::Edit::Role::NeverAutoEdit;
use Moose::Role;
use namespace::autoclean;
use MusicBrainz::Server::Edit::Utils qw( conditions_without_autoedit );

around edit_conditions => sub {
    my ($orig, $self, @args) = @_;
    return conditions_without_autoedit($self->$orig(@args));
};

1;
