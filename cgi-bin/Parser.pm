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
use QuerySupport;
use TaggerSupport;
use DBI;
use DBDefs;
use MM_2_1;
use Apache;
use RDFStore::Parser::SiRPAC;
use RDFStore::NodeFactory;

use Data::Dumper;
use integer;

sub new
{
    my ($type) = @_;
    my $this = {};

    $this->{type} = $type;

    bless $this;
    return $this;
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

	push @{$expat->{__mbtriples__}{$pid}}, [ $sid, $oid ]; 
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

		for my $triple (@$refs)
		{
			$this->{uri}->{$$triple[0]} == $currentURIid
				or next;

			$currentURIid = $this->{uri}->{$$triple[1]};
			next QUERY;
		}

		return undef;
    }

    $this->{url2}[$currentURIid];
}

sub FindNodeByType
{
 	my ($this, $type, $ordinal) = @_;

	my $pid = $this->{uri}{$type}
		or return undef;

	$ordinal = 1 if not defined $ordinal;

	my $r = $this->{triples}{$pid}
		or return;
	$r->[$ordinal-1];
}

sub Parse
{
   my ($this, $rdf) = @_;
   my (%data, %uri, @uri, @triples, $ref, %baseuri);

   $baseuri{uri} = "";
   my $parser=new RDFStore::Parser::SiRPAC( 
                   NodeFactory => new RDFStore::NodeFactory(),
                   Handlers => { Assert  => \&Statement });
   eval
   {
		$parser->{_next_uri_id_} = 0;
       $parser->{__mburi__} = \%uri;
       $parser->{__mburi2__} = \@uri;
       $parser->{__mbtriples__} = \@triples;
       $parser->{__baseuri__} = \%baseuri;
       $parser->parse($rdf);
   };
   if ($@)
   {
       $this->{error} = $@;
       print STDERR "Parse failed: $@\n";
       return 0;
   }

   #print STDERR "Parsed ". scalar(keys %uri) . " unique URIs.\n";
   #print STDERR "Parsed ". scalar(@triples) . " triples.\n";

   $this->{uri} = \%uri;
   $this->{uri2} = \@uri;
   $this->{triples} = \@triples;
   $this->{baseuri} = $baseuri{uri};

   return 1;
}

1;
# vi: set ts=4 sw=4 :
