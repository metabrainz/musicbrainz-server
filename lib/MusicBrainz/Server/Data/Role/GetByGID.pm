package MusicBrainz::Server::Data::Role::GetByGID;
use Moose::Role;
use MusicBrainz::Server::Validation qw( is_guid );
use namespace::autoclean;

requires '_get_by_keys';

sub get_by_gid {
    my ($self, $gid) = @_;
    return unless is_guid($gid);
    my @result = $self->_get_by_keys('gid', $gid);
    if (scalar(@result)) {
        return $result[0];
    }
    else {
        return undef;
    }
}

sub get_by_gids {
    my ($self, @gids) = @_;
    my @result = $self->_get_by_keys('gid', grep { is_guid($_) } @gids);
    return { map { $_->gid => $_ } @result };
}

1;
