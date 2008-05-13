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
use integer;

sub new
{
	my $class = shift;
	$class = ref($class) || $class;

    eval {
        # Normally these modules generate warnings as they compile.  We suppress those
        # warnings.
        local $^W = 0;
        require RDFStore::Parser::SiRPAC;
        require RDFStore::NodeFactory;
    };
    return undef if (my $err = $@);

	bless { }, $class;
}

sub Parse
{
	my ($this, $rdf) = @_;

	# Each URI seen is assigned an integer ID.
	$this->{_last_uri_id_} = 0;
	$this->{uri_to_id} = {};
	$this->{id_to_uri} = [];

	# This stores the triples, using the IDs not the URIs
	$this->{object_by_subject_predicate} = {};

	# Base URI (subject of first triple)
	$this->{baseuri} = undef;

	my $parser = RDFStore::Parser::SiRPAC->new(
		NodeFactory => new RDFStore::NodeFactory(),
		Handlers => {
			Assert => sub { $this->_assert($_[1]) },
		},
	);

	unless (eval { $parser->parse($rdf); 1 })
	{
		$this->{error} = $@;
		# (my $err = $@) =~ s/\s+/ /g;
		# print STDERR "Parse failed: $err\n";
		return 0;
	}

	#print STDERR "Parsed ". scalar(keys %uri) . " unique URIs.\n";
	#print STDERR "Parsed ". scalar(@triples) . " triples.\n";

 	return 1;
}

sub _assert
{
	my ($this, $st) = @_;

	#print STDERR $st->subject->getLabel . "\n";
	#print STDERR $st->predicate->getLabel . "\n";
	#print STDERR $st->object->getLabel . "\n\n";

	if (not defined $this->{baseuri})
	{
		$this->{baseuri} = $st->subject->getLabel;
	}

	# Get the labels of the subject, predicate and object.  Give each unique
	# label an ID.
	my ($sid, $pid, $oid) = map {
		my $uri = $_->getLabel;
		my $id = $this->{uri_to_id}{$uri};

		unless ($id)
		{
			$id = ++$this->{_last_uri_id_};
			$this->{uri_to_id}{$uri} = $id;
			$this->{id_to_uri}[$id] = $uri;
		}

		$id;
	} ($st->subject, $st->predicate, $st->object);

	# Store the triple using the label IDs
	$this->{object_by_subject_predicate}{"$sid $pid"} = $oid;
}

sub GetBaseURI
{
	my ($this) = @_;
	return $this->{baseuri};
}

sub Extract
{
	my ($this, $currentURI, $query) = @_;

	my $currentURIid = $this->{uri_to_id}{$currentURI}
		or return undef;

	for my $pred (split /\s/, $query)
	{
		if ($pred =~ /^\[(\d+)\]$/)
		{
			$pred = "http://www.w3.org/1999/02/22-rdf-syntax-ns#_$1";
		}

		my $pid = $this->{uri_to_id}{$pred}
			or return undef;

		my $oid = $this->{object_by_subject_predicate}{"$currentURIid $pid"}
			or return undef;

		$currentURIid = $oid;
	}

	$this->{id_to_uri}[$currentURIid];
}

1;
# vi: set ts=4 sw=4 :
