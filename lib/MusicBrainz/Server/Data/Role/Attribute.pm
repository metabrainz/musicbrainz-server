package MusicBrainz::Server::Data::Role::Attribute;
use Moose::Role;
use namespace::autoclean;

with 'MusicBrainz::Server::Data::Role::InsertUpdateDelete';

sub _columns {
    return 'id, gid, name, parent, child_order, description';
}

sub _column_mapping {
    return {
        id              => 'id',
        gid             => 'gid',
        name            => 'name',
        parent_id       => 'parent',
        child_order     => 'child_order',
        description     => 'description',
    };
}

no Moose;
1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2014 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
