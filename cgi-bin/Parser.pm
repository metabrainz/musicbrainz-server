#!/usr/bin/perl -w
# vi: set ts=4 sw=4 :
#____________________________________________________________________________
#
#   MusicBrainz -- the internet music database
#
#   Copyright (C) 2003 Robert Kaye
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

package Parser;

use strict;
use DBDefs;

# Normally these modules generate warnings as they compile.  We suppress those
# warnings.
BEGIN
{
	local $^W = 0;
	require RDFStore::Parser::SiRPAC;
	require RDFStore::NodeFactory;
}

use integer;

sub new
{
	my $class = shift;
	$class = ref($class) || $class;
	bless { }, $class;
}

sub GetBaseURI
{
	my ($this) = @_;
	return $this->{baseuri};
}

sub Statement
{
	my ($expat, $st) = @_;

	#print STDERR $st->subject->getLabel . "\n";
	#print STDERR $st->predicate->getLabel . "\n";
	#print STDERR $st->object->getLabel . "\n\n";

	if ($expat->{__baseuri__}->{uri} eq '')
	{
		$expat->{__baseuri__}->{uri} = $st->subject->getLabel;
	}

	my ($sid, $pid, $oid) = map {
		my $uri = $_->getLabel;
		my $id = $expat->{__mburi__}{$uri};

		unless ($id)
		{
			$id = ++$expat->{_next_uri_id_};
			$expat->{__mburi__}{$uri} = $id;
			$expat->{__mburi2__}[$id] = $uri;
		}

		$id;
	} ($st->subject, $st->predicate, $st->object);

	push @{ $expat->{__mbtriples__}{$pid} }, [ $sid, $oid ];
	push @{ $expat->{__mbtriples1__}{$oid}{$pid} }, $sid;
}

sub Extract
{
	my ($this, $currentURI, $ordinal, $query) = @_;

	my $currentURIid = $this->{uri}{$currentURI}
		or return undef;

QUERY:
	for my $pred (split /\s/, $query)
	{
		if ($pred eq "[]")
		{
			$pred = "http://www.w3.org/1999/02/22-rdf-syntax-ns#_$ordinal";
		}

		my $pid = $this->{uri}{$pred}
			or return undef;

		my $refs = $this->{triples}{$pid}
			or return undef;

		foreach my $triple (@$refs)
		{
			$$triple[0] == $currentURIid
				or next;

			$currentURIid = $$triple[1];
			next QUERY;
		}

		return undef;
	}

	$this->{uri2}[$currentURIid];
}

sub FindNodeByType
{
 	my ($this, $object, $ordinal) = @_;
	$ordinal = 1 if not defined $ordinal;

	my $oid = $this->{uri}{$object}
		or return undef;
	my $pid = $this->{uri}{'http://www.w3.org/1999/02/22-rdf-syntax-ns#type'}
		or return undef;

	my $r = $this->{triples1}{$oid}{$pid}
		or return;
	my $sid = $r->[$ordinal-1]
		or return undef;

	$this->{uri2}[$sid];
}

sub Parse
{
	my ($this, $rdf) = @_;
	my (%uri, @uri, %triples, %triples1, %baseuri);

	$baseuri{uri} = "";

	my $parser = RDFStore::Parser::SiRPAC->new(
		NodeFactory => new RDFStore::NodeFactory(),
		Handlers => { Assert => \&Statement },
	);

	$parser->{_next_uri_id_} = 0;
	$parser->{__mburi__} = \%uri;
	$parser->{__mburi2__} = \@uri;
	$parser->{__mbtriples__} = \%triples;
	$parser->{__mbtriples1__} = \%triples1;
	$parser->{__baseuri__} = \%baseuri;

	unless (eval { $parser->parse($rdf); 1 })
	{
		$this->{error} = $@;
		# (my $err = $@) =~ s/\s+/ /g;
		# print STDERR "Parse failed: $err\n";
		return 0;
	}

	#print STDERR "Parsed ". scalar(keys %uri) . " unique URIs.\n";
	#print STDERR "Parsed ". scalar(@triples) . " triples.\n";

	$this->{uri} = \%uri;
	$this->{uri2} = \@uri;
	$this->{triples} = \%triples;
	$this->{triples1} = \%triples1;
	$this->{baseuri} = $baseuri{uri};

 	return 1;
}

1;
# vi: set ts=4 sw=4 :
