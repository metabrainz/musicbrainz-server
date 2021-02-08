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

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2009 Lukas Lalinsky

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
