#____________________________________________________________________________
#
#   MusicBrainz -- the open internet music database
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

package TableBase;

use vars qw(@ISA @EXPORT);
@ISA    = @ISA    = '';
@EXPORT = @EXPORT = '';

use strict;
use DBI;
use DBDefs;
use Sql;
use UUID;
use Text::Unaccent;
use LocaleSaver;
use POSIX qw(:locale_h);
use Encode qw( decode );

use constant MAX_PAGE_INDEX_LEVELS => 6;
use constant NUM_BITS_PAGE_INDEX => 5;

sub new
{
    my ($type, $dbh) = @_;
    $type = ref($type) || $type;

    bless {
	DBH => $dbh,
	type => $type,
    }, $type;
}

sub _new_from_row
{
	my ($this, $row) = @_;
	$row or return undef;
	$row->{DBH} = $this->{DBH};
	bless $row, ref($this) || $this;
}

sub GetDBH
{
    return $_[0]->{DBH}; 
}

sub SetDBH
{
    $_[0]->{DBH} = $_[1]; 
}

sub GetId
{
   return $_[0]->{id};
}

sub SetId
{
   $_[0]->{id} = $_[1];
}

sub GetName
{
   return $_[0]->{name};
}

sub SetName
{
   $_[0]->{name} = $_[1];
}

sub GetMBId
{
   return $_[0]->{mbid};
}

sub SetMBId
{
   $_[0]->{mbid} = $_[1];
}

sub GetModPending
{
   return $_[0]->{modpending};
}

sub SetModPending
{
   $_[0]->{modpending} = $_[1];
}

sub GetNewInsert
{
   return $_[0]->{new_insert};
}

sub CreateNewGlobalId
{
    my ($this) = @_;
    my ($uuid, $id);

    UUID::generate($uuid);
    UUID::unparse($uuid, $id);

    return $id;
}  

sub CalculatePageIndex 
{
    my ($this, $string) = @_;
    my ($path, $ch, $base, @chars, $o, $wild);

    @chars = do
    {
	use locale;
	my $saver = new LocaleSaver(LC_CTYPE, "en_US.UTF-8");

	$string = unac_string('UTF-8', $string);
	$string = decode("utf-8", $string);
	$string =~ tr/A-Za-z /_/c;

	split //, uc($string);
    };

    $path = 0;
    $base = ord('A');

    my $endpath = 0;
    my $allbitsset = ((1 << NUM_BITS_PAGE_INDEX) - 1);

    for(0..MAX_PAGE_INDEX_LEVELS-1)
    {
	my ($start_ch, $end_ch) = (0, $allbitsset);

	if (defined(my $ch = $chars[$_]))
	{
		$start_ch = $end_ch
			= ($ch eq '_') ? 0
			: ($ch eq ' ') ? 1
			: ord($ch) - $base + 2;
	}

        $path |= $start_ch << (NUM_BITS_PAGE_INDEX * (MAX_PAGE_INDEX_LEVELS - $_ - 1));
        $endpath |= $end_ch << (NUM_BITS_PAGE_INDEX * (MAX_PAGE_INDEX_LEVELS - $_ - 1));
    }

    return ($path, $endpath) if wantarray;
    return $path;
}

1;
