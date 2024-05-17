package MusicBrainz::Server::Edit::Role::AlwaysAutoEdit;
use Moose::Role;
use namespace::autoclean;
use MusicBrainz::Server::Constants qw( :expire_action :quality );

around 'edit_conditions' => sub {
    my ($orig, $self, @args) = @_;

    my $conditions = $self->$orig(@args);
    $conditions->{auto_edit} = 1;

    return $conditions;
};

around 'allow_auto_edit' => sub { 1 };

1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2014 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
