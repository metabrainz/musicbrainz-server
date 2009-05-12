package MusicBrainz::Server::CacheWrapper;

use Moose;
use Moose::Util::TypeConstraints;

has '_orig' => (
    is => 'ro',
    isa => duck_type(['get', 'set']),
    handles => ['get', 'set']
);

sub get_multi
{
    my ($self, @keys) = @_;
    my %result;
    foreach my $key (@keys) {
        my $data = $self->_orig->get($key);
        $result{$key} = $data if defined $data;
    }
    return \%result;
}

sub set_multi
{
    my ($self, @items) = @_;
    foreach my $item (@items) {
        $self->_orig->set($item->[0], $item->[1]);
    }
}

__PACKAGE__->meta->make_immutable;
no Moose;
1;

=head1 COPYRIGHT

Copyright (C) 2009 Lukas Lalinsky

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
