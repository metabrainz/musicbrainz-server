#!/home/httpd/musicbrainz/mb_server/cgi-bin/perl -w
# vi: set ts=4 sw=4 :
#____________________________________________________________________________
#
#   MusicBrainz -- the open internet music database
#
#   Copyright (C) 2004 Robert Kaye
#
#   This program is free software; you can redistribute it and/or modify
#   it under the terms of the GNU General Public License as published by
#   the Free Software Foundation; either version 2 of the License, or
#   (at your option) any later version.
#
#   This program is distributed in the hope that it will be useful,
#   but WITHOUT ANY WARRANTY; without even the implied warranty of
#   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#   GNU General Public License for more details.
#
#   You should have received a copy of the GNU General Public License
#   along with this program; if not, write to the Free Software
#   Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
#
#   $Id$
#____________________________________________________________________________

use strict;

package MusicBrainz::Server::Handlers::WS::1::Auth;

use Apache::Constants qw( OK AUTH_REQUIRED SERVER_ERROR NOT_FOUND FORBIDDEN);
use Apache::File ();
use Apache::AuthDigest::API;
use Digest::MD5 qw(md5_hex);

sub handler
{
    my $r = Apache::AuthDigest::API->new(shift);

    my $user = $1 if ($r->uri =~ /ws\/1\/user\/(.*)/);
	my %args; { no warnings; %args = $r->args };
    if (!$user)
    {
		return bad_req($r, "User (moderator) name must be part of the url: /ws/1/user/<name>.");
    }
    my $realm = $r->dir_config("DigestRealm");

    my ($status, $response) = $r->get_digest_auth_response;
    return $status unless $status == OK;

    # Ensure that the login name is the same as the resource requested
#print STDERR "resource: $user auth: ".$r->user."\n";
#return FORBIDDEN if ($r->user != $user);

    my $digest = md5_hex("rob:$realm:password");
    if (!$r->compare_digest_response($response, $digest))
    {
        print STDERR "bad password $status\n";
        $r->note_digest_auth_failure;
        return AUTH_REQUIRED;
    }

	return OK;
}

1;
