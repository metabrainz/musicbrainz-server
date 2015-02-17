package MusicBrainz::Server::Edit::Role::NeverAutoEdit;
use Moose::Role;
use namespace::autoclean;

around edit_conditions => sub {
    my ($orig, $self, @args) = @_;

    my $conditions = $self->$orig(@args);
    $conditions->{auto_edit} = 0;

    return $conditions;
};

1;
