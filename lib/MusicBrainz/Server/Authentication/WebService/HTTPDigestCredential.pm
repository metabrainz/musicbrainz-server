package MusicBrainz::Server::Authentication::WebService::HTTPDigestCredential;

use strict;
use warnings;

use Encode qw( decode );
use Moose;
use namespace::autoclean;
use Scalar::Util qw( blessed );
use Try::Tiny;

use MusicBrainz::Server::Authentication::Utils qw( can_user_login );
use MusicBrainz::Server::Data::Utils qw( is_blank );

extends qw/Catalyst::Authentication::Credential::HTTP/;

sub authenticate {
    my ($self, $c, $realm, $auth_info) = @_;

    # We can only use digest authentication if the Authorization header is
    # correctly encoded as UTF-8. Catalyst::Plugin::Unicode::Encoding only
    # deals with parameters and URL captures - not arbitrary headers.
    try {
        decode('utf-8', $c->req->header('Authorization'), Encode::FB_CROAK);
    } catch {
        $c->stash->{bad_auth_encoding} = 1;
    };

    return if $c->stash->{bad_auth_encoding};

    # For some odd reason, this may return '1' if authentication fails while
    # `no_unprompted_authorization_required` is enabled.
    my $user = $self->SUPER::authenticate($c, $realm, $auth_info);

    return unless (
        defined $user &&
        blessed($user) &&
        $user->isa('MusicBrainz::Server::Authentication::User') &&
        can_user_login($user)
    );

    return if is_blank($user->ha1);

    return $user;
}

sub no_unprompted_authorization_required { 1 }

sub _build_auth_header_common {
    my ($self, $c, $opts) = @_;
    return (
        $self->SUPER::_build_auth_header_common($c, $opts),
        'charset=UTF-8',
    );
}

__PACKAGE__->meta->make_immutable( inline_constructor => 0 );

no Moose;

1;

=head1 DESCRIPTION

Extension of C<Catalyst::Authentication::Credential::HTTP> to support Digest
authentication in the web service, with the requirement that usernames are
encoded as UTF-8, and that the user has a non-empty C<ha1> set.

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2026 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
