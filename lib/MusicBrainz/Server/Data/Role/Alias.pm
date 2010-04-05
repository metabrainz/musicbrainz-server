package MusicBrainz::Server::Data::Role::Alias;
use MooseX::Role::Parameterized;
use Moose::Util qw( ensure_all_roles );
use MusicBrainz::Server::Data::Alias;
use namespace::autoclean;

parameter 'alias_table' => (
    required => 1
);

role
{
    my $params = shift;
    my $table  = $params->alias_table;

    has 'alias' => (
        is         => 'ro',
        lazy_build => 1
    );

    method '_build_alias' => sub
    {
        my $self = shift;
        my $alias = MusicBrainz::Server::Data::Alias->new(
            c      => $self->c,
            table  => $table,
            parent => $self
        );
        ensure_all_roles(
            $alias,
            'MusicBrainz::Server::Data::Role::Editable',
            'MusicBrainz::Server::Data::Role::Name' => {
                name_columns => [qw( name )],
            }
        );

        return $alias;
    };

    before _delete => sub {
        my ($self, @ids) = @_;
        $self->alias->delete_entities(@ids);
    };

    before merge => sub {
        my ($self, $new_id, @old_ids) = @_;
        $self->alias->merge($new_id, @old_ids);
    };
};

1;

=head1 COPYRIGHT

Copyright (C) 2009 Oliver Charles

This program is free software; you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation; either version 2 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program; if not, write to the Free Software
Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.

=cut

