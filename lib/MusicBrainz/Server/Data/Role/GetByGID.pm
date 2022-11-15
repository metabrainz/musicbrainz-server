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

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2011 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
