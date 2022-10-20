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

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2009,2011 Lukas Lalinsky
Copyright (C) 2010 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
