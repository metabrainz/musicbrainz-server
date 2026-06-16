package MusicBrainz::Server::Authentication::WebService::HTTPDigestStore;

use strict;
use warnings;

use Encode qw( decode );

use parent 'MusicBrainz::Server::Authentication::Store';

sub find_user {
    my ($self, $authinfo, $c) = @_;

    if (exists $authinfo->{username}) {
        $authinfo->{username} = decode('utf-8', $authinfo->{username}, Encode::FB_QUIET);
    }
    return $self->SUPER::find_user($authinfo, $c);
}

1;

=head1 DESCRIPTION

An extension of C<MusicBrainz::Server::Authentication::Store> for the digest
authentication realm which decodes the UTF8 username field as it was encoded
in the C<Authorization> header.

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2026 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
