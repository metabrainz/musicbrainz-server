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

package MusicBrainz::Server::Handlers::WS::1::TRM;

use Apache::Constants qw( OK AUTH_REQUIRED SERVER_ERROR NOT_FOUND FORBIDDEN BAD_REQUEST DECLINED);
use Apache::File ();
use DBDefs;
use MusicBrainz::Server::Handlers::WS::1::Common;
use Data::Dumper;

sub handler
{
    my $r = shift;

	# URLs are of the form:
	# http://server/ws/1/trm/?name=<user_name>&client=<client id>&trms=<trackid:trm+trackid:trm>

	return bad_req($r, "Only POST is acceptable")
		unless $r->method eq "GET";

	my %args; { no warnings; %args = $r->args };
    my $user = $args{name};
    my $data = $args{trms};
    my $client = $args{client};
    my @pairs = split(' ', $data);
    my @trms;
    foreach my $pair (@pairs)
    {
        my ($trackid, $trmid) = split(':', $pair);
        if (!MusicBrainz::IsGUID($trmid) || !MusicBrainz::IsGUID($trackid))
        {
            $r->status(BAD_REQUEST);
            return BAD_REQUEST;
        }
        push @trms, { trmid => $trmid, trackid => $trackid };
    }

    # We have to have a limit, I think.  It's only sensible.
    # So far I've not seen anyone submit more that about 4,500 TRMs at once,
    # so this limit won't affect anyone in a hurry.
    if (scalar(@trms) > 5000)
    {
		$r->status(DECLINED);
        return DECLINED;
    }

    # Ensure that the login name is the same as the resource requested 
    if ($r->user ne $user)
    {
		$r->status(FORBIDDEN);
        return FORBIDDEN;
    }
    # Ensure that we're not a replicated server and that we were given a client version
    if (&DBDefs::REPLICATION_TYPE == &DBDefs::RT_SLAVE || $client eq '')
    {
		$r->status(BAD_REQUEST);
        return BAD_REQUEST;
    }

	my $status = eval 
    {
		# Try to serve the request from the database
		{
			my $status = serve_from_db($r, $user, $client, \@trms);
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

    $r->status(OK);
	return OK;
}

sub serve_from_db
{
	my ($r, $user, $client, $trms) = @_;

	my $printer = sub {
		print_xml($user, $client, $trms);
	};

	send_response($r, $printer);
	return OK();
}

sub print_xml
{
	my ($user, $client, $links) = @_;

	require MusicBrainz;
	my $mb = MusicBrainz->new;
	$mb->Login;

    require UserStuff;
    my $us = UserStuff->new($mb->{DBH});
    $us = $us->newFromName($user) or die "Cannot load user.\n";

    require Sql;
    my $sql = Sql->new($mb->{DBH});

    # TODO: Check each track and then then adjust the list to have the row id of the track

    if (@$links)
    {
        eval
        {
            $sql->Begin;

            require Moderation;
            my @mods;

            # Break the list of TRMs up into 100 TRMs at a time.
            # This is so that each moderation is manageably small.
            while (@$links)
            {
                my @thistime;
                if (@$links > 100) { @thistime = splice(@$links, 0, 100) }
                else { @thistime = @$links; @$links = () }

                my @mods = Moderation->InsertModeration(
                    DBH => $mb->{DBH},
                    uid => $us->GetId,
                    privs => 0, # TODO
                    type => &ModDefs::MOD_ADD_TRMS,
                    # --
                    client => $client,
                    links => \@thistime,
                );
            }

            $sql->Commit;
        };
        if ($@)
        {
            print STDERR "Cannot insert TRM: $@\n";
            $sql->Rollback;
            die("Cannot write TRM Ids to database.\n")
        }
    }

	print '<?xml version="1.0" encoding="UTF-8"?>';
	print '<metadata xmlns="http://musicbrainz.org/ns/mmd-1.0#"/>';
}

1;
# eof TRM.pm
