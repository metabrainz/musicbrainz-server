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
                                                                               
package RDF2;

use strict;

BEGIN { require 5.6.1 }
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

sub escape 
{
   $_[0] =~ s/&/&amp;/g;
   $_[0] =~ s/</&lt;/g;
   $_[0] =~ s/>/&gt;/g;
   return $_[0];
}

sub BeginRDFObject 
{
    my ($this, $skipxmldecl) = @_;
    my $out;

    $this->{level} = 1;

    if (!defined $skipxmldecl || $skipxmldecl != 1)
    {
       $out = "<?xml version=\"1.0\" encoding=\"ISO-8859-1\"?>\n";
    }

    $out .=  "<rdf:RDF xmlns:rdf = \"http://www.w3.org/1999/02/22-rdf-syntax-ns#\"\n".
      "         xmlns:dc  = \"http://purl.org/dc/elements/1.1/\"\n".
      "         xmlns:mq  = \"http://musicbrainz.org/mm/mq-1.0#\"\n".
      "         xmlns:mm  = \"http://musicbrainz.org/mm/mm-2.0#\">\n";

    return $out;
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
    my ($this, $name, $about) = @_;
    my $rdf;

    $rdf = $this->_indent() . "<$name";
    $rdf .= " rdf:about=\"$about\"" if (defined $about);
    $rdf .= ">\n";

    $this->{level}++;
 
    return $rdf;
}

sub EndDesc
{
    my ($this, $name) = @_;

    $this->{level}--;

    return $this->_indent() . "</$name>\n";
}

sub Element
{
    my ($this, $name, $data, @attrs) = @_;
    my ($rdf, $key, $cols, $pair, $ind);

    return "" if ((!defined $data || $data eq "") && not defined $attrs[0]);

    $rdf = $this->_indent() . "<$name";
    $cols = length($rdf);

    for(;defined $attrs[0] && defined $attrs[1];)
    {
        $pair = " " . (shift @attrs) . "=\"" . (shift @attrs) . "\"";
#        print "$pair\n";
#        if (length($pair) + $cols > 80)
#        {
#            $ind = $this->_indent();
#            $cols = length($ind);
#            $rdf .= "\n$ind"; 
#        }
        $rdf .= $pair;
        $cols += length($pair);
    }
    if (!defined $data || $data eq '')
    {
        $rdf .= "/>\n";
    }
    else
    {
        $rdf .= ">" . escape($data) . "</$name>\n";
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
    my ($this, $res) = @_;

    return $this->_indent() . "<rdf:li rdf:resource=\"$res\"/>\n";
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
