package MusicBrainz::Server::Test::Utils;
use strict;
use warnings;

use base 'Exporter';

use Test::More;

=head1 DESCRIPTION

Utility functions to run MusicBrainz tests.

=cut

our @EXPORT_OK = qw(
    verify_name_and_id
);

=sub verify_name_and_id

Checks whether the entity passed has the expected name and ID.

=cut

sub verify_name_and_id {
    my ($id, $name, $entity) = @_;
    is($entity->id, $id , "Expected ID $id found");
    is($entity->name, $name, "Expected name $name found");
}

1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2022 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
