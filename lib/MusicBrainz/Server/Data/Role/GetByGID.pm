package MusicBrainz::Server::Data::Role::GetByGID;
use Moose::Role;
use namespace::autoclean;

requires '_get_by_keys';

sub get_by_gid {
    my ($self, $gid) = @_;
    return unless $gid;
    my @result = values %{$self->_get_by_keys("gid", $gid)};
    if (scalar(@result)) {
        return $result[0];
    }
    else {
        return undef;
    }
}

sub get_by_gids {
    my ($self, @gids) = @_;
    return { map { $_->gid => $_ } values %{ $self->_get_by_keys('gid', @gids) } };
}

1;
