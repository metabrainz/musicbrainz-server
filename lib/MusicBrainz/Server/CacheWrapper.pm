package MusicBrainz::Server::CacheWrapper;

use Moose;
use namespace::autoclean;
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
    my ($self, $key, $data, $exptime) = @_;
    $self->_orig->set($key, Storable::freeze(\$data), $exptime);
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

sub disconnect {}

sub clear {}

__PACKAGE__->meta->make_immutable;
1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2009 Lukas Lalinsky

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
