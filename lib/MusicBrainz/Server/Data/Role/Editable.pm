package MusicBrainz::Server::Data::Role::Editable;
use Moose::Role;
use Fey::Literal::Term;
use Fey::SQL;
use Method::Signatures::Simple;
use namespace::autoclean;

method adjust_edit_pending ($amount, @ids) {
    my $ep_column  = $self->table->column('editpending');
    my $adjustment = Fey::Literal::Term->new($ep_column, '+', $amount);
    my $query = Fey::SQL->new_update
        ->update($self->table)
        ->set($ep_column, $adjustment)
        ->where($self->table->column('id'), 'IN', @ids);

    $self->sql->do($query->sql($self->sql->dbh),
                   $query->bind_params);
}

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
