#____________________________________________________________________________
#
#   MusicBrainz -- the open internet music database
#
#   Copyright (C) 2002 Robert Kaye
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
                                                                               
package Style;

BEGIN { require 5.6.1 }
use vars qw(@ISA @EXPORT);
@ISA    = @ISA    = '';
@EXPORT = @EXPORT = '';

use strict;

sub new
{
    my ($type) = @_;
    my $this = {};

    $this->{type} = $type;

    bless $this;
    return $this;
}  

sub UpperLowercaseCheck
{
    my ($this, $textarg) = @_;
    my ($len, $temp, $lccount, $uccount, $text, $numspaces, $ok);

    $ok = 1;
    $numspaces = $textarg =~ tr/ //;
    $text = $textarg;
    $text =~ tr/\n\t\r //d;
    $len = length($text);

    $temp = $text;
    $temp =~ tr/A-Z//d;
    $lccount = 100 * ($temp =~ tr/a-z//);
    $lccount = int($lccount / $len);

    $temp = $text;
    $temp =~ tr/a-z//d;
    $uccount = 100 * ($temp =~ tr/A-Z//);
    $uccount = int($uccount / $len);

    if ($numspaces == 0 && $uccount == 100 && length($textarg) <= 3)
    {
        $ok = 1;
    }
    elsif ($numspaces == 0 && ($uccount == 100 || $lccount == 100))
    {
        $ok = 0;
    }
    elsif ($numspaces > 0 && ($lccount > 90 || $uccount > 90))
    {
        $ok = 0;
    }
    #print STDERR "$textarg: $lccount $uccount --> $ok\n";

    return $ok;
}

sub MakeDefaultSortname
{
    my ($this, $name) = @_;

    if ($name =~ /^the (.*)$/i) 
    {
        return "$1, The";
    }
    if ($name =~ /^dj (.*)$/i) 
    {
        return "$1, DJ";
    }
    return $name;
}
