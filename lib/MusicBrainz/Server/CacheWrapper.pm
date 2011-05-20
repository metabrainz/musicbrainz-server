package MusicBrainz::Server::CacheWrapper;

use Moose;
use Moose::Util::TypeConstraints;
use Storable;

has '_orig' => (
    is => 'ro',
    isa => duck_type(['get', 'set']),
    handles => { 'delete' => 'remove', exists => 'exists' }
);

sub get
{
    my ($self, $key) = @_;
    my $data = $self->_orig->get($key);
    return ${Storable::thaw($data)} if defined $data;
    return undef;
}

sub get_multi
{
    my ($self, @keys) = @_;
    my %result;
    foreach my $key (@keys) {
        my $data = $self->_orig->get($key);
        $result{$key} = ${Storable::thaw($data)} if defined $data;
    }
    return \%result;
}

sub set
{
    my ($self, $key, $data) = @_;
    $self->_orig->set($key, Storable::freeze(\$data));
}

sub set_multi
{
    my ($self, @items) = @_;
    foreach my $item (@items) {
        my $data = $item->[1];
        $self->_orig->set($item->[0], Storable::freeze(\$data));
    }
}

sub delete_multi
{
    my ($self, @keys) = @_;
    foreach my $key (@keys) {
        $self->_orig->remove($key);
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
