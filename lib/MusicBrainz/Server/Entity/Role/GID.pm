package MusicBrainz::Server::Entity::Role::GID;

use Moose::Role;

has 'gid' => (
    is => 'rw',
    isa => 'Str'
);

has 'gid_redirects' => (
    is => 'rw',
    isa => 'ArrayRef[Str]',
    default => sub { [] },
    traits => [ 'Array' ],
    handles => {
        add_gid_redirect => 'push',
        clear_gid_redirects => 'clear',
        all_gid_redirects => 'elements',
    }
);

around TO_JSON => sub {
    my ($orig, $self) = @_;

    my $json = $self->$orig;
    $json->{gid} = $self->gid;
    return $json;
};

no Moose::Role;
1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2009 Lukas Lalinsky

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
