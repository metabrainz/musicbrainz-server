#!/usr/bin/perl -w
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
use MusicBrainz::Server::Handlers::WS::1::Common qw( :DEFAULT apply_rate_limit );

sub handler
{
    my $r = Apache::AuthDigest::API->new(shift);
    my %args; { no warnings; %args = $r->args };
    my ($inc) = convert_inc($args{inc});

    # Artist, Label, Release & Track in GET mode don't require authentication
    # unless user data (tags, ratings) are requested
    return OK if($r->method eq "GET" 
        && $r->uri =~ /^\/ws\/1\/(artist|label|release|track)/
        && not ($inc & INC_USER_TAGS)
        && not ($inc & INC_USER_RATINGS) );

    my ($status, $response) = $r->get_digest_auth_response;
    return $status unless $status == OK;

    my $realm = $r->dir_config("DigestRealm");

    require MusicBrainz;
    my $mb = MusicBrainz->new;
	$mb->Login(db => 'READWRITE');

    require UserStuff;
    my $us = UserStuff->new($mb->{DBH});
    if (!($us = $us->newFromName($r->user)))
    {
        #print STDERR "User not found: '$r->user'\n";
        $r->note_digest_auth_failure;
        return AUTH_REQUIRED;
    }
    my $digest = md5_hex($r->user.":$realm:".$us->GetPassword);
    if (!$r->compare_digest_response($response, $digest))
    {
        #print STDERR "Bad password\n";
        $r->note_digest_auth_failure;
        $r->note_digest_auth_failure;
        return AUTH_REQUIRED;
    }

	return OK;
}

1;
