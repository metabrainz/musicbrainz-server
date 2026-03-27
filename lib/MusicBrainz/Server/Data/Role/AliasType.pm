package MusicBrainz::Server::Data::Role::AliasType;

use Moose::Role;
use namespace::autoclean;
use MusicBrainz::Server::Entity::AliasType;
use MusicBrainz::Server::Data::Utils qw( load_subobjects );

with 'MusicBrainz::Server::Data::Role::OptionsTree',
     'MusicBrainz::Server::Data::Role::Attribute';

sub load {
    my ($self, @objs) = @_;

    load_subobjects($self, 'type', @objs);
}

sub in_use {
    my ($self, $id) = @_;
    # We can get the alias table by just dropping "_type" from the type table
    my $alias_table = $self->_table =~ s/_type$//r;
    return $self->sql->select_single_value(
        "SELECT 1 FROM $alias_table WHERE type = ? LIMIT 1",
        $id);
}

1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2016 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
