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
use MusicBrainz;
use Sql;
use Text::Unaccent;
use Encode qw( encode decode );

sub new
{
    my $class = shift;
    my $dbh = shift;
    my $self = shift || {};
    bless $self, $class;

    $self->{DBH}          = $dbh;
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

sub Tokenize
{
    my $self  = shift;
    my $str = shift;

    # This used to be "use locale", apparently so that '\w' et al
    # would translate to known things.  But is "use locale" actually
    # required here?
    
    $str = unac_string('UTF-8', $str);
    $str = decode("utf-8", $str);

    my @words = split /\s/, $str;

    my %seen =  ();
    foreach (@words) 
    {
        s/[^a-zA-Z]//g; # strip non words
        tr/A-Z/a-z/;
        next if $_ eq '';

        $seen{$_}++;
    }

    #uniqify the word list
    @words = keys %seen;

    @words = map { encode("utf-8", $_) } @words;

    return @words;
}

sub AddWord
{
    my $self = shift;
    my $word = shift;

    my $sql = Sql->new($self->{DBH});
    if ($sql->Select(qq|SELECT Id FROM WordList WHERE Word = '$word'|))
    {
        my @row;
        
        if (@row = $sql->NextRow())
        {
            $sql->Finish();
            return $row[0];
        }
        return undef;
    }
    else
    {
        $sql->Do(qq|INSERT into WordList (Word) VALUES ('$word')|);
        return $sql->GetLastInsertId('WordList');
    }
}

sub AddWordRefs 
{
    my $self = shift;
    my ($object_id,$name) = @_;
    my @words = $self->Tokenize($name);

    foreach (@words)
    {
        my $word_id = $self->AddWord ($_);
        next if not defined $word_id;

        my $sql = Sql->new($self->{DBH});
        if ($sql->GetSingleColumn("$self->{Table}Words", "Wordid", 
                                  ["$self->{Table}id", $object_id,
                                   "Wordid", $word_id]))
        {
            $sql->Finish();
        }
        else
        {
            $sql->Do(qq|INSERT into $self->{Table}Words ($self->{Table}id, Wordid) 
                        VALUES($object_id,$word_id)|);
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
    my $sql = Sql->new($self->{DBH});
    $sql->Do($query);
}

sub GetQuery
{
    my $self = shift;
    my $search = shift;
    my ($query, $conditions);
    my @words = $self->Tokenize($search);

    my $where_clause = $self->GetWhereClause(@words);
    
    $conditions .= ("HAVING count(WordList.Id) = " . (scalar @words)) if $self->AllWords;

    if ($self->{Table} eq 'Album')
    {
        $query = "
        SELECT Album.id, Album.name, Artist.id, Artist.name, Album.gid, 
               count(WordList.Id), lower(Album.name)
        FROM Album, AlbumWords, WordList, Artist
        WHERE $where_clause
        and AlbumWords.Wordid = WordList.Id
        and AlbumWords.Albumid = Album.Id
        and Artist.Id = Album.Artist
        GROUP BY Album.Id, Album.name, Artist.id, Artist.name, Album.gid
        $conditions
        ORDER BY count(WordList.Id) desc, lower(Album.name), Album.name";
    }
    elsif ($self->{Table} eq 'Artist')
    {
        $query = "
        SELECT Artist.id, Artist.name, Artist.sortname, Artist.gid, 
               count(WordList.Id), lower(Artist.sortname)
        FROM Artist, ArtistWords, WordList
        WHERE $where_clause
        and ArtistWords.Wordid = WordList.Id
        and ArtistWords.Artistid = Artist.Id
        GROUP BY Artist.id, Artist.name, Artist.sortname, Artist.gid
        $conditions
        ORDER BY count(WordList.Id) desc, lower(Artist.sortname), Artist.sortname";
    }
    elsif ($self->{Table} eq 'Track')
    {
        $query = "
        SELECT Track.id, Track.name, Artist.id, Artist.name, AlbumJoin.album, 
               Track.gid, count(WordList.Id), lower(Track.name)
        FROM Track, TrackWords, WordList, Artist, AlbumJoin
        WHERE $where_clause
        and TrackWords.Wordid = WordList.Id
        and TrackWords.Trackid = Track.Id
        and Track.Artist = Artist.id
        and AlbumJoin.Track = Track.Id
        GROUP BY Track.Id, Track.name, Artist.id, Artist.name, AlbumJoin.album, Track.gid
        $conditions
        ORDER BY count(WordList.Id) desc, lower(Track.name), Track.name";
    }
    $query .= (" LIMIT " . $self->Limit) if  $self->Limit;
    return $query;
}
        
sub Search {
    my $self = shift;
    my $search = shift;

    $search =~ s/^\s+//;

    my $query = $self->GetQuery($search);

    $self->{STH} = Sql->new($self->{DBH});
    $self->{STH}->Select($query);
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
    my ($count, $written, $query, $total_rows, $start_time);
    
    my $sql = Sql->new($self->{DBH});
    $sql->Begin();
    $sql->Do("delete from " . $self->{Table} . "Words");
    $sql->Commit();

    # Make postgres analyze its foo to speed up the insertion
    $sql->AutoCommit();
    $sql->Do("vacuum analyze " . $self->{Table} . "Words");

    ($total_rows) = $sql->GetSingleColumn($self->{Table}, "count(*)", []);

    my $block_size = 1000;
    for($count = 0;; $count += $block_size)
    {

        $written = 0;
        # Start a transaction
        eval
        {
            print STDERR "Start transaction for $count -> " . ($count + $block_size) . "\n";
            $sql->Begin;
       
            $query = qq|SELECT Id, Name FROM $self->{Table} |;
            if ($self->{Table} eq 'Artist')
            {
                  $query .= qq|union select artistalias.ref, artistalias.name 
                                       from ArtistAlias |;
            }
            $query .= qq|LIMIT $block_size OFFSET $count|;

            $start_time = time();
            if ($sql->Select($query))
            {
                while ( my $row = $sql->NextRowRef)
                {
                    #print STDERR "Adding words for $self->{Table} $row->[0]: $row->[1]\n";
                    $self->AddWordRefs(@$row);

                    if ($written > 0 && time() > $start_time &&
                       ($written % 100) == 0)
                    {
                         print STDERR $self->{Table} . " index added " . 
                              ($written + $count) . " of $total_rows. (".
                              int(($written + $count) * 100 / $total_rows) . 
                              "%, " .  int($written / (time() - $start_time)) . 
                              " rows/sec)                \r";
                    }

                    $written++;
                }
                $sql->Finish;
            }

            print STDERR $self->{Table} . " index added " . 
                         ($written + $count) . " of $total_rows. (".
                         int(($written + $count) * 100 / $total_rows) . 
                         "%, " .  int($written / (time() - $start_time)) . 
                         " rows/sec)                \r";

            # And commit all the changes
            $sql->Commit;
            print STDERR "\nCommit transaction\n";
        };
        if ($@)
        {
            my $err = $@;
            $sql->Rollback;
            print STDERR "\nIndex insert: $err";
        }

        # Make postgres analyze its foo to speed up the insertion
        print STDERR "Postgres: vacuum analyze WordList\n";
        $sql->AutoCommit();
        $sql->Do("vacuum analyze WordList");

        print STDERR "Postgres: vacuum analyze " . $self->{Table} . "Words\n";
        $sql->AutoCommit();
        $sql->Do("vacuum analyze " . $self->{Table} . "Words");

        if ($written < $block_size)
        {
            last;
        }
    }
}

sub RebuildAllIndices
{
    my $self = shift;
    my $orig_table = $self->{Table};
   
    $| = 1;
    my $sql = Sql->new($self->{DBH});
    $sql->Begin();
    $sql->Do("delete from WordList");
    $sql->Commit();

    # Make postgres analyze its foo to speed up the insertion
    print STDERR "Postgres: vacuum analyze\n";
    $sql->AutoCommit();
    $sql->Do("vacuum analyze");

    foreach my $table ( @{$self->{ValidTables}} )
    {
        $self->{'Table'} = $table;
        $self->RebuildIndex;
    }
    $self->{'Table'} = $orig_table;
    $| = 0;
}

sub Finish
{
    my $self = shift;
    $self->{STH}->Finish;
    $self->{STH} = undef;
}

sub Rows
{
    my $self = shift;
    $self->{STH}->Rows;
}

sub NextRow
{
    my $self = shift;
    return $self->{STH}->NextRowRef;
}

1;
