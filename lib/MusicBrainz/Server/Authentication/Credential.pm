package MusicBrainz::Server::Authentication::Credential;
use strict;
use warnings;

sub new {
    my ($class, $config, $app, $realm) = @_;
    return $class;
}

sub authenticate {
    my ($self, $c, $realm, $authinfo) = @_;
    if (my $user = $realm->find_user($authinfo, $c)) {
        return $user if $user->match_password($authinfo->{password}) && !$user->deleted;
    }

    return;
}

1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2013 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
