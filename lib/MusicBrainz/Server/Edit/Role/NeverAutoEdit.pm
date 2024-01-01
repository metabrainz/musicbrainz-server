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

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2014 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
