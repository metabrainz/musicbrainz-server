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

package MusicBrainz::Server::Handlers::WS::1::Label;

use Apache::Constants qw( );
use Apache::File ();
use MusicBrainz::Server::Handlers::WS::1::Common qw( :DEFAULT apply_rate_limit );

sub handler
{
	my ($r) = @_;
	# URLs are of the form:
	# http://server/ws/1/label or
	# http://server/ws/1/label/MBID 

	return bad_req($r, "Only GET is acceptable")
		unless $r->method eq "GET";

    my $mbid = $1 if ($r->uri =~ /ws\/1\/label\/([a-z0-9-]*)/);

	my %args; { no warnings; %args = $r->args };
    my ($inc, $bad) = convert_inc($args{inc});
    my ($info, $bad) = get_type_and_status_from_inc($bad);
    if ($bad)
    {
		return bad_req($r, "Invalid inc options: '$bad'.");
	}
    my $type = $args{type};
    if (!defined($type) || $type ne 'xml')
    {
		return bad_req($r, "Invalid content type. Must be set to xml.");
	}
	if ((!MusicBrainz::Server::Validation::IsGUID($mbid) && $mbid ne '') || $inc eq 'error')
	{
		return bad_req($r, "Incorrect URI.");
	}
    if ($inc & INC_TRACKS)
	{
		return bad_req($r, "Cannot use track parameter for label resources.");
	}
    if (!$mbid)
    {
        my $name = $args{name} or "";
        my $limit = $args{limit};
        my $offset = $args{offset} or 0;
        $limit = 25 if ($limit < 1 || $limit > 100);
        my $query = $args{query} or "";

		return bad_req($r, "Must specify a name OR query argument for label collections.") if ($name eq '' && $query eq '');
		return bad_req($r, "Must specify a name OR query argument for label collections. Not both.") if ($name && $query);
		if (my $st = apply_rate_limit($r)) { return $st }
        return xml_search($r, { type => 'label', label => $name, limit => $limit, offset => $offset, query => $query });
    }

	if (my $st = apply_rate_limit($r)) { return $st }

	my $user = get_user($r->user, $inc); 
	my $status = eval {
		# Try to serve the request from the database
		{
			my $status = serve_from_db($r, $mbid, $inc, $info, $user);
			return $status if defined $status;
		}
        undef;
	};

	if ($@)
	{
		my $error = "$@";
        print STDERR "WS Error: $error\n";
		$r->status(Apache::Constants::SERVER_ERROR());
		$r->send_http_header("text/plain; charset=utf-8");
		$r->print($error."\015\012") unless $r->header_only;
		return Apache::Constants::SERVER_ERROR();
	}
    if (!defined $status)
    {
        $r->status(Apache::Constants::NOT_FOUND());
        return Apache::Constants::NOT_FOUND();
    }

    $r->status(Apache::Constants::OK());
	return Apache::Constants::OK();
}

sub serve_from_db
{
	my ($r, $mbid, $inc, $info, $user) = @_;

	my $ar;
	my $al;

	require MusicBrainz;
	my $mb = MusicBrainz->new;
	$mb->Login;
	require MusicBrainz::Server::Label;

	$ar = MusicBrainz::Server::Label->new($mb->{DBH});
    $ar->SetMBId($mbid);
	return undef unless $ar->LoadFromId(1);
	
	if ($inc & INC_ALIASES) {
        require MusicBrainz::Server::Alias;
        my $alias = MusicBrainz::Server::Alias->new($mb->{DBH}, "LabelAlias");
        my @list = $alias->GetList($ar->GetId);
        $info->{aliases} = \@list;
    }

	my $printer = sub {
		print_xml($mbid, $inc, $ar, $info, $user);
	};

	send_response($r, $printer);
	return Apache::Constants::OK();
}

sub print_xml
{
	my ($mbid, $inc, $ar, $info, $user) = @_;

	print '<?xml version="1.0" encoding="UTF-8"?>';
	print '<metadata xmlns="http://musicbrainz.org/ns/mmd-1.0#">';
    print xml_label($ar, $inc, $info, $user);
	print '</metadata>';
}

1;
# eof Label.pm
