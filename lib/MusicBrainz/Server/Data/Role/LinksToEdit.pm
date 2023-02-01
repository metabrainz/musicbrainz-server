package MusicBrainz::Server::Data::Role::LinksToEdit;
use MooseX::Role::Parameterized;

parameter 'table' => (
    isa => 'Str',
    required => 1
);

role {
    my $params = shift;
    method 'edit_link_table' => sub { $params->table }
};

1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2010 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
