#____________________________________________________________________________
#
#   MusicBrainz -- the open internet music database
#
#   Copyright (C) 1998 Robert Kaye
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

package SearchEngine;

use vars qw(@ISA @EXPORT);
@ISA    = @ISA    = '';
@EXPORT = @EXPORT = '';

use strict;
use DBDefs;
use DBI;
use Text::Unaccent;
use locale;
use POSIX qw(locale_h);

sub new
{
    my $class = shift;
    my $self = shift || {};
    bless $self, $class;
    $self->{DBH}          = DBDefs->Connect || die "Cannot connect to database";
    $self->{STH}          = undef;
    $self->{ValidTables}  = ['Album','Artist','Track'];
    $self->{Table}      ||= 'Artist';
    $self->{AllWords}   ||= 0;
    $self->{Limit}      ||= 0;
    $self->{BGColor}    ||= "#ffffff";
    return $self;
}

sub Table
{
    my ($self,$table) = @_;
    $self->{Table} = $table if defined $table;
    return $self->{Table};
}

sub AllWords
{
    my ($self,$allwords) = @_;
    $self->{AllWords} = $allwords if defined $allwords;
    return $self->{AllWords};
}

sub Limit
{
    my ($self,$limit) = @_;
    $self->{Limit} = $limit if defined $limit;
    return $self->{Limit};
}


sub DESTROY
{
    my $self = shift;
    if (defined $self->{STH})
    {
        $self->{STH}->finish;
    }
}


sub Tokenize
{
    my $self  = shift;
    my @words = split /\s/, shift;
		
		# we set the locale here to a known quantity
		# so that accented characters are considered
		# "word characters" (\w)

		my $old_locale = setlocale(LC_CTYPE);
		setlocale( LC_CTYPE, "en_US.ISO_8859-1" )
			  or die "Couldn't change locale.";

	  my %seen = 	();
    foreach (@words) 
    {
        s/\W//g; # strip non words
				$_ = unac_string('ISO-8859-1',$_);
				$seen{$_}++;
    }

		#switch it back, just to be polite
		setlocale( LC_CTYPE, $old_locale );
		
		#uniqify the word list
		@words = keys %seen;

    return @words;
}

sub AddWord
{
    my $self = shift;
    my $word = shift;
    my $sth = $self->{DBH}->prepare_cached ( qq|
        INSERT into WordList (Word)
        VALUES (?)
        |);

    eval { $sth->execute($word) };
    if ($@)
    {
        if ( $@ =~ /Duplicate/ ) 
        {
            my $lookup_sth = $self->{DBH}->prepare_cached ( qq|
                SELECT Id 
                FROM WordList 
                WHERE Word = ?
                |);
            $lookup_sth->execute($word);
            if (my $row = $lookup_sth->fetch)
            {
                $lookup_sth->finish;
                return $row->[0];
            }
            else { die "Can't find duplicate word in database!" }
        }
        else
        {
            die $@; # Jump ship if it's not a duplicate key error.
        }
    }
    else {
        return $sth->{mysql_insertid};
    }
}

sub AddWordRefs {
    my $self = shift;
    my ($object_id,$name) = @_;
    my @words = $self->Tokenize($name);
    foreach (@words)
    {
        my $word_id = $self->AddWord ($_);
        my $sth = $self->{DBH}->prepare_cached ( qq|
            INSERT into $self->{Table}Words ($self->{Table}id, Wordid)
            VALUES(?,?)
            |);
        eval { $sth->execute($object_id,$word_id) };
        if ($@ && !($@ =~ /Duplicate/) ) 
        {
            print STDERR "Attempt to insert duplicate word ref.\n";
        }
    }
}

sub RemoveObjectRefs
{
    my $self = shift;
    my ($object_id) = @_;

    my $query;

    $query = "delete from " . $self->{Table} . "Words where " .
             $self->{Table} . "id = $object_id";
    $self->{DBH}->do($query);
}

sub GetQuery
{
    my $self = shift;
    my $search = shift;
    my ($query, $conditions);
    my @words = $self->Tokenize($search);

    my $where_clause = $self->GetWhereClause(@words);
    
    $conditions .= ("HAVING num_matches = " . (scalar @words)) if $self->AllWords;

    if ($self->{Table} eq 'Album')
    {
        $query = "
        SELECT Album.id, Album.name, Artist.id, Artist.name, count(WordList.Id) as num_matches
        FROM Album, AlbumWords, WordList, Artist
        WHERE $where_clause
        and AlbumWords.Wordid = WordList.Id
        and AlbumWords.Albumid = Album.Id
        and Artist.Id = Album.Artist
        GROUP BY Album.Id 
        $conditions
        ORDER BY num_matches desc, Album.name";
    }
    elsif ($self->{Table} eq 'Artist')
    {
        $query = "
        SELECT Artist.id, Artist.name, Artist.sortname, count(WordList.Id) as num_matches
        FROM Artist, ArtistWords, WordList
        WHERE $where_clause
        and ArtistWords.Wordid = WordList.Id
        and ArtistWords.Artistid = Artist.Id
        GROUP BY Artist.Id 
        $conditions
        ORDER BY num_matches desc, Artist.sortname";
    }
    elsif ($self->{Table} eq 'Track')
    {
        $query = "
        SELECT Track.id, Track.name, Artist.id, Artist.name, AlbumJoin.album, count(WordList.Id) as num_matches
        FROM Track, TrackWords, WordList, Artist, AlbumJoin
        WHERE $where_clause
        and TrackWords.Wordid = WordList.Id
        and TrackWords.Trackid = Track.Id
        and Track.Artist = Artist.id
        and AlbumJoin.Track = Track.Id
        GROUP BY Track.Id 
        $conditions
        ORDER BY num_matches desc, Track.name";
    }
    $query .= (" LIMIT " . $self->Limit) if  $self->Limit;
    return $query;
}
        
sub Search {
    my $self = shift;
    my $search = shift;

    my $query = $self->GetQuery($search);

    $self->{DBH}->do('SET SQL_BIG_TABLES=1');

    $self->{STH} = $self->{DBH}->prepare_cached ( $query );

    $self->{STH}->execute or print STDERR "Search query failed: $search\n";
    
    $self->{DBH}->do('SET SQL_BIG_TABLES=0');
}

sub GetWhereClause
{
    my $self = shift;
    my @words = @_;
    my $where_clause = "WordList.Word ";
    if (scalar @words == 1)
    {
        $where_clause .= " = '" . $words[0] . "'";
    }
    else
    {
        $where_clause .= "IN ( '" . (join "','", @words) . "')";
    }
    return $where_clause;
}

sub RebuildIndex
{
    my $self = shift;
    
    $self->{DBH}->do("delete from " . $self->{Table} . "Words");
    my $sth = $self->{DBH}->prepare_cached( qq|
        SELECT Id, Name
        FROM $self->{Table}
        |);

    $sth->execute;

    while ( my $row = $sth->fetch )
    {
        print STDERR "Adding words for $self->{Table} $row->[0]: $row->[1]\n";
        $self->AddWordRefs(@$row);
    }
    $sth->finish;
}

sub RebuildAllIndices
{
    my $self = shift;
    my $orig_table = $self->{Table};
    
    $self->{DBH}->do("delete from WordList");
    foreach my $table ( @{$self->{ValidTables}} )
    {
        $self->{'Table'} = $table;
        $self->RebuildIndex;
    }
    $self->{'Table'} = $orig_table;
}


sub Finish
{
    my $self = shift;
    $self->{STH}->finish;
    $self->{STH} = undef;
}

sub Rows
{
    my $self = shift;
    $self->{STH}->rows;
}

sub NextRow
{
    my $self = shift;
    return $self->{STH}->fetch;
}

1;
