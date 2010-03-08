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

use strict;

use Encode qw( encode decode );

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

    $textarg = decode "utf-8", $textarg;
    $ok = 1;

    # TODO should use classes: space, upper, lower, etc.
    $numspaces = $textarg =~ tr/ //;
    $text = $textarg;
    $text =~ tr/\n\t\r //d;
    $len = length($text);
    return 0 if ($len == 0);

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
    encode "utf-8",
        $this->MakeDefaultSortname_unicode(decode "utf-8", $name);
}

sub MakeDefaultSortname_unicode
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

sub NormalizeDiscNumbers
{
    my ($this, $name) = @_;
    my ($new, $disc);

    $name = decode "utf-8", $name;

    # TODO use [0-9] instead of \d?
    # TODO undef warnings come from here
    no warnings;
    if ($name =~ /^(.*)(\(|\[)\s*(disk|disc|cd)\s*(\d+|one|two|three|four)(\)|\])$/i)
    {
        $new = $1;
        $disc = $4;
    }
    elsif ($name =~ /^(.*)(disk|disc|cd)\s*(\d+|one|two|three|four)$/i)
    {
        $new = $1;
        $disc = $3;
    }
    use warnings;

    if (defined $new && defined $disc)
    {
        $disc = 1 if ($disc =~ /one/i);
        $disc = 2 if ($disc =~ /two/i);
        $disc = 3 if ($disc =~ /three/i);
        $disc = 4 if ($disc =~ /four/i);
        if ($disc > 0 && $disc < 100)
        {
            $disc =~ s/^0+//g;
            $new =~ s/\s*[(\/|:,-]*\s*$//;
            $new .= " (disc $disc)";
    
        $new = encode "utf-8", $new;
            return $new;
        }
    }

    $name = encode "utf-8", $name;
    return $name;
}

1;
