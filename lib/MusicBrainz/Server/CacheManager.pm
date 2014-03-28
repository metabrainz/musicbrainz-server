package MusicBrainz::Server::CacheManager;

use Moose;
use MusicBrainz::Server::CacheWrapper;
use Class::Load qw( load_class );

has '_key_to_profile' => (
    is => 'ro',
    isa => 'HashRef',
    default => sub { +{} },
);

has '_cache' => (
    is => 'ro',
    isa => 'HashRef',
    default => sub { +{} },
    traits => [ 'Hash' ],
    handles => {
        _get_cache => 'get'
    }
);

has 'default_profile' => (
    is => 'ro',
    isa => 'Str',
);

sub BUILD
{
    my ($self, $params) = @_;

    my %profiles = %{$params->{profiles}};
    foreach my $name (keys %profiles) {
        my $profile = $profiles{$name};
        my $keys = $profile->{keys};
        if (defined $keys) {
            foreach my $key (@$keys) {
                $self->_key_to_profile->{$key} = $name;
            }
        }
        load_class($profile->{class});
        my $cache = $profile->{class}->new($profile->{options} || {});;
        if ($profile->{wrapped}) {
            $cache = MusicBrainz::Server::CacheWrapper->new(_orig => $cache);
        }
        $self->_cache->{$name} = $cache;
    }

    return $self;
}

sub cache
{
    my ($self, $key) = @_;
    my $profile;
    $profile = $self->_key_to_profile->{$key} if defined $key;
    $profile ||= $self->default_profile;
    return $self->_get_cache($profile);
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
