#____________________________________________________________________________
#
#   CD Index - The Internet CD Index
#
#   Copyright (C) 2000 Robert Kaye
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
                                                                               
package RDF;

use strict;

BEGIN { require 5.003 }
use vars qw(@ISA @EXPORT);
@ISA    = @ISA    = '';
@EXPORT = @EXPORT = '';

sub new
{
    my $this;

    $this = {};
    bless $this;
    return $this;
}

sub BeginRDFObject 
{
    my ($this) = @_;

    $this->{level} = 1;

    return "<?xml version=\"1.0\" encoding=\"ISO-8859-1\"?>\n" . 
       "<rdf:RDF xmlns:rdf = \"http://w3.org/TR/1999/PR-rdf-syntax-19990105#\"\n".
       "         xmlns:DC = \"http://purl.org/DC#\"\n" . 
       "         xmlns:MM = \"http://cdindex.org/MM#\"\n" .
       "         xmlns:MQ = \"http://cdindex.org/MQ#\">\n\n";
}

sub EndRDFObject
{
    my ($this) = @_;

    die "Unbalanced RDF object.\n" unless $this->{level} == 1;
    return "</rdf:RDF>\n";
}

sub _indent
{
    my ($this) = @_;
    my ($i, $data);

    for($i = 0; $i < $this->{level}; $i++)
    {
       $data .= "  ";
    }

    return $data;
}

sub BeginDesc
{
    my ($this, $about) = @_;
    my $rdf;

    $rdf = $this->_indent() . "<rdf:Description";
    $rdf .= " about=\"$about\"" if (defined $about);
    $rdf .= ">\n";

    $this->{level}++;
 
    return $rdf;
}

sub EndDesc
{
    my ($this) = @_;

    $this->{level}--;

    return $this->_indent() . "</rdf:Description>\n";
}

sub Element
{
    my ($this, $name, $data, @attrs) = @_;
    my ($rdf, $key, $cols, $pair, $ind);

    $rdf = $this->_indent() . "<$name";
    $cols = length($rdf);

    for(;defined $attrs[0] && defined $attrs[1];)
    {
        $pair = " " . (shift @attrs) . "=\"" . (shift @attrs) . "\"";
        if (length($pair) + $cols > 80)
        {
            $ind = $this->_indent();
            $cols = length($ind);
            $rdf .= "\n$ind"; 
        }
        $rdf .= $pair;
        $cols += length($pair);
    }
    if (!defined $data || $data eq '')
    {
        $rdf .= "/>\n";
    }
    else
    {
        $rdf .= ">$data</$name>\n";
    }

    return $rdf;
}

sub BeginElement
{
    my ($this, $name, %attrs) = @_;
    my ($rdf, $key);

    $rdf = $this->_indent() . "<$name";
    foreach $key (keys %attrs)
    {
        $rdf .= " $key=\"" . $attrs{$key} . "\"";
    }
    $rdf .= ">\n";

    $this->{level}++;

    return $rdf;
}

sub EndElement
{
    my ($this, $name) = @_;
    my ($rdf);

    $this->{level}--;
    $rdf = $this->_indent() . "</$name>\n";

    return $rdf;
}

sub BeginSeq
{
    my ($this, $type) = @_;
    return BeginElement($this, "rdf:Seq");
}

sub EndSeq
{
    my ($this) = @_;
    return EndElement($this, "rdf:Seq");
}

sub BeginBag
{
    my ($this, $type) = @_;
    return BeginElement($this, "rdf:Bag");
}

sub EndBag
{
    my ($this) = @_;
    return EndElement($this, "rdf:Bag");
}

sub BeginAlt
{
    my ($this, $type) = @_;
    return BeginElement($this, "rdf:Alt");
}

sub EndAlt
{
    my ($this) = @_;
    return EndElement($this, "rdf:Alt");
}

sub Li
{
    my ($this, $data) = @_;

    return $this->_indent() . "<rdf:li>$data</rdf:li>\n";
}   

sub BeginLi
{
    my ($this, $about) = @_;
    my $rdf;

    $rdf = BeginElement($this, "rdf:li");
    $rdf .= BeginDesc($this, $about);
}

sub EndLi
{
    my ($this) = @_;
    my $rdf;

    $rdf = EndDesc($this);
    $rdf .= EndElement($this, "rdf:li");

    return $rdf;
}

##!/usr/bin/perl -w
#
#use RDF;
#
#$o = RDF::new();
#
#$rdf = $o->BeginRDFObject();
#$rdf .= $o->BeginDesc("http://moon/fuss");
#$rdf .=    $o->Element("DC:Creator", "Portishead");
#$rdf .=    $o->Element("DC:Title", "Strangers");
#$rdf .=    $o->Element("DC:Relation", "", track=>"3");
#$rdf .=    $o->Element("MM:Album", "Dummy");
#$rdf .=    $o->BeginElement("MM:SyncEvents");
#$rdf .=       $o->BeginSeq();
#$rdf .=          $o->BeginLi();
#$rdf .=            $o->Element("SyncText", "Hi there!", ts=>'14400');
#$rdf .=          $o->EndLi();
#$rdf .=       $o->EndSeq();
#$rdf .=       $o->BeginSeq();
#$rdf .=          $o->Li("Pussy!");
#$rdf .=       $o->EndSeq();
#$rdf .=    $o->EndElement("MM:Album");
#$rdf .= $o->EndDesc();
#$rdf .= $o->EndRDFObject();
#
#print $rdf;
