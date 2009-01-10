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

use strict;
use DBDefs;
use Sql;
use Text::Unaccent;
use LocaleSaver;
use POSIX qw(:locale_h);
use Encode qw( decode );
use MusicBrainz::Server::Validation qw( unaccent );

use constant MAX_PAGE_INDEX_LEVELS => 6;
use constant NUM_BITS_PAGE_INDEX => 5;

use constant TABLE_RELEASE => 1;
use constant TABLE_ARTIST => 2;
use constant TABLE_TRACK => 3;
use constant TABLE_LABEL => 4;

sub entity_type
{
    my ($self, $new_type) = @_;

    if (defined $new_type) { $self->{_ent_type} = $new_type; }
    return $self->{_ent_type} || '';
}

sub new
{
    my ($class, $dbh) = @_;

    bless {
	DBH => $dbh,
    }, ref($class) || $class;
}

sub _new_from_row
{
	my ($this, $row) = @_;
	$row or return undef;
	$row->{DBH} = $this->dbh;
	bless $row, ref($this) || $this;
}

sub dbh
{
	my ($self, $new_value) = @_;
	
	if (defined $new_value) { $self->{DBH} = $new_value; }
	return $self->{DBH};
}

sub id
{
    my ($self, $new_id) = @_;

    if (defined $new_id) { $self->{id} = $new_id; }
    return $self->{id};
}

sub name
{
    my ($self, $new_name) = @_;

    if (defined $new_name) { $self->{name} = $new_name; }
    return $self->{name};
}

sub mbid
{
    my ($self, $new_mbid) = @_;
    
    if (defined $new_mbid) { $self->{mbid} = $new_mbid; }
    return $self->{mbid};
}

sub has_mod_pending
{
    my ($self, $new_pending) = @_;

    if (defined $new_pending) { $self->{modpending} = $new_pending; }
    return $self->{modpending};
}

sub GetNewInsert
{
   return $_[0]->{new_insert};
}

sub CreateNewGlobalId
{
    my ($this) = @_;

    require OSSP::uuid;
    my $uuid = new OSSP::uuid;
    $uuid->make("v4");
    return $uuid->export("str");
}  

sub CheckGlobalIdRedirect
{
    my ($this, $gid, $tbl) = @_;
    
    my $sql = Sql->new($this->dbh);
    return $sql->SelectSingleValue("SELECT newid FROM gid_redirect WHERE gid = ? AND tbl = ?", $gid, $tbl) or undef;
}

sub SetGlobalIdRedirect
{
    my ($this, $id, $gid, $newid, $tbl) = @_;
    
    my $sql = Sql->new($this->dbh);
    # Update existing redirects
    $sql->Do("UPDATE gid_redirect SET newid = ? WHERE newid = ? AND tbl = ?", $newid, $id, $tbl);
    # Add a new redirect
    $sql->Do("INSERT INTO gid_redirect (gid, newid, tbl) VALUES (?, ?, ?)", $gid, $newid, $tbl);
}

sub RemoveGlobalIdRedirect
{
    my ($this, $newid, $tbl) = @_;
    
    my $sql = Sql->new($this->dbh);
    # Remove existing redirects
    $sql->Do("DELETE FROM gid_redirect WHERE newid = ? AND tbl = ?", $newid, $tbl);
}

sub CalculatePageIndex 
{
    my ($this, $string) = @_;
    my ($path, $ch, $base, @chars, $o, $wild);

    @chars = do
    {
	use locale;
	my $saver = new LocaleSaver(LC_CTYPE, "en_US.UTF-8");

	$string = unaccent($string);
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
