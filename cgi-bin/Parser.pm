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
use String::CRC32;

use Data::Dumper;

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
   my ($sid, $pid, $oid, $ordinal);

   if ($st->predicate->getLabel =~ m/_(\d+)$/)
   {
       $ordinal = $1;
   }

   $sid = crc32($st->subject->getLabel);
   $pid = crc32($st->predicate->getLabel);
   $oid = crc32($st->object->getLabel);

   #print STDERR $st->subject->getLabel . "\n";
   #print STDERR $st->predicate->getLabel . "\n";
   #print STDERR $st->object->getLabel . "\n\n";

   if ($expat->{__baseuri__}->{uri} eq '')
   {
       $expat->{__baseuri__}->{uri} = $st->subject->getLabel;
   }

   if (!exists $expat->{__mburi__}->{$sid})
   {
       $expat->{__mburi__}->{$sid} = $st->subject->getLabel;
   }
   if (!exists $expat->{__mburi__}->{$pid})
   {
       $expat->{__mburi__}->{$pid} = $st->predicate->getLabel;
   }
   if (!exists $expat->{__mburi__}->{$oid})
   {
       $expat->{__mburi__}->{$oid} = $st->object->getLabel;
   }
   if (!exists $expat->{__mbindex__}->{$sid})
   {
       $expat->{__mbindex__}->{$sid} = [];
   }
   push @{$expat->{__mbindex__}->{$pid}}, scalar(@{$expat->{__mbtriples__}});
   push @{$expat->{__mbtriples__}}, [ $sid, $pid, $oid, $ordinal ]; 
}

sub Extract
{
   my ($this, $currentURI, $ordinal, $query) = @_;
   my ($triple, $pid, $found, @querylist, $pred, $refs, $tref);
   my ($triples);

   $triples = $this->{triples};
   @querylist = split /\s/, $query;
   foreach $pred (@querylist)
   {
       $found = 0;

       if ($pred eq "[]")
       {
          $pred = "http://www.w3.org/1999/02/22-rdf-syntax-ns#_$ordinal";
       }
       $pid = crc32($pred);

       $refs = $this->{index}->{$pid};
       return undef if (!defined $refs);

           #print "predicate $pred: [$currentURI]\n";
       foreach $tref (@{$refs})
       {
           $triple = $$triples[$tref]; 
           #print "$this->{uri}->{$$triple[0]}\n";
           #print "$this->{uri}->{$$triple[1]}\n";
           #print "$this->{uri}->{$$triple[2]}\n";
           if ($this->{uri}->{$$triple[0]} eq $currentURI)
           {
              #print "Match!\n\n";
              $currentURI = $this->{uri}->{$$triple[2]};
              $found = 1;
              last;
           }
           #print "\n";
       }
       return undef if (not $found);
   }
   return $this->{uri}->{$$triple[2]};
}

sub Parse
{
   my ($this, $rdf) = @_;
   my (%data, %uri, %index, @triples, $ref, %baseuri);

   $baseuri{uri} = "";
   my $parser=new RDFStore::Parser::SiRPAC( 
                   NodeFactory => new RDFStore::NodeFactory(),
                   Handlers => { Assert  => \&Statement });
   eval
   {
       $parser->{__mburi__} = \%uri;
       $parser->{__mbtriples__} = \@triples;
       $parser->{__mbindex__} = \%index;
       $parser->{__baseuri__} = \%baseuri;
       $parser->parse($rdf);
   };
   if ($@)
   {
       print STDERR "Parse failed: $@\n";
       return 0;
   }

   #print STDERR "Parsed ". scalar(keys %uri) . " unique URIs.\n";
   #print STDERR "Parsed ". scalar(@triples) . " triples.\n";

   $this->{uri} = \%uri;
   $this->{index} = \%index;
   $this->{triples} = \@triples;
   $this->{baseuri} = $baseuri{uri};

   return 1;
}

1;
