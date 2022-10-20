package MusicBrainz::Server::Data::Role::MainTable;

use Moose::Role;
use namespace::autoclean;

use MusicBrainz::Server::Constants qw( %ENTITIES );

# '_type' is indirectly required.

sub _main_table {
    my $type = shift->_type;
    return $ENTITIES{$type}{table} // $type;
};

sub _table { shift->_main_table }

no Moose::Role;
1;

=head1 NAME

MusicBrainz::Server::Data::Role::MainTable

=head1 DESCRIPTION

Define C<_main_table> method using either
the value of C<_type> match the key of
an object literal in C<entities.json> file
with a C<table> subkey, C<_type> otherwise.

Also define C<_table> with the same value.

=head1 METHODS

=head2 _main_class

Return the name of the main table of this entity type.

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2009,2011 Lukas Lalinsky
Copyright (C) 2010 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
