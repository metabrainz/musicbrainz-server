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

package MusicBrainz::Server::Handlers::WS::1::User;

use Apache::Constants qw( OK AUTH_REQUIRED SERVER_ERROR NOT_FOUND FORBIDDEN);
use Apache::File ();
use MusicBrainz::Server::Handlers::WS::1::Common;
use Data::Dumper;

sub handler
{
    my $r = shift;

	# URLs are of the form:
	# http://server/ws/1/user/?name=<user_name>

	return bad_req($r, "Only GET is acceptable")
		unless $r->method eq "GET";

	my %args; { no warnings; %args = $r->args };
    my $user = $args{name};

    # Ensure that the login name is the same as the resource requested
    if ($r->user ne $user)
    {
		$r->status(FORBIDDEN);
        return FORBIDDEN;
    }

	my $status = eval 
    {
		# Try to serve the request from the database
		{
			my $status = serve_from_db($r, $user);
			return $status if defined $status;
		}
        undef;
	};

	if ($@)
	{
		my $error = "$@";
        print STDERR "WS Error: $error\n";
		$r->status(SERVER_ERROR);
		$r->content_type("text/plain; charset=utf-8");
		$r->print($error."\015\012") unless $r->header_only;
		return SERVER_ERROR;
	}
    if (!defined $status)
    {
        $r->status(NOT_FOUND);
        return NOT_FOUND;
    }

	return OK;
}

sub serve_from_db
{
	my ($r, $user) = @_;

	my $printer = sub {
		print_xml($user);
	};

	send_response($r, $printer);
	return OK();
}

sub print_xml
{
	my ($user) = @_;

	require MusicBrainz;
	my $mb = MusicBrainz->new;
	$mb->Login(db => 'READWRITE');
	require MusicBrainz::Server::Artist;

    require MusicBrainz::Server::Editor;
    my $us = MusicBrainz::Server::Editor->new($mb->{DBH});
    $us = $us->newFromName($user) or die "Cannot load user.\n";

    my @types;
    push @types, "AutoEditor" if ($us->is_auto_editor($us->privs));
    push @types, "RelationshipEditor" if $us->is_link_moderator($us->privs);
    push @types, "Bot" if $us->is_bot($us->privs);
    push @types, "NotNaggable" if $us->DontNag($us->privs);
    my ($nag, $days) = $us->NagCheck;

	print '<?xml version="1.0" encoding="UTF-8"?>';
	print '<metadata xmlns="http://musicbrainz.org/ns/mmd-1.0#" xmlns:ext="http://musicbrainz.org/ns/ext-1.0#">';
    print '<ext:user-list><ext:user type="'. join(' ', @types) . '">';
    print '<name>'.$user.'</name>';
    print '<ext:nag show="' . ($nag ? 'true' : 'false') . '"/>';
    print '</ext:user></ext:user-list>';
	print '</metadata>';
}

1;
# eof User.pm
