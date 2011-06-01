package MusicBrainz::Server::Data::Role::GetByGID;
use Moose::Role;
use namespace::autoclean;

sub get_by_gids {
    my ($self, @gids) = @_;
    return $self->_get_by_keys('gid', @gids)
}

sub get_by_gid {
    my ($self, $gid) = @_;
    my @result = values %{$self->_get_by_keys("gid", $gid)};
    if (scalar(@result)) {
        return $result[0];
    }
}

1;
