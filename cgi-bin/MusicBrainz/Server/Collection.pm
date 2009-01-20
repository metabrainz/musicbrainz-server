#!/usr/bin/perl -w
#____________________________________________________________________________
#
#       MusicBrainz -- the open music metadata database
#
#       Copyright (C) 2001 Robert Kaye
#
#       This program is free software; you can redistribute it and/or modify
#       it under the terms of the GNU General Public License as published by
#       the Free Software Foundation; either version 2 of the License, or
#       (at your option) any later version.
#
#       This program is distributed in the hope that it will be useful,
#       but WITHOUT ANY WARRANTY; without even the implied warranty of
#       MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#       GNU General Public License for more details.
#
#       You should have received a copy of the GNU General Public License
#       along with this program; if not, write to the Free Software
#       Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
#
#       $id: $
#____________________________________________________________________________

package MusicBrainz::Server::Collection;

use strict;
use warnings;

use base qw/TableBase Exporter/;

our @ISA = qw(Exporter);
our @EXPORT_OK = qw(addtracks removetracks);

use Carp qw( cluck );

=head1 NAME

MusicBrainz::Server::Collection - Manipulate collection

=head1 DESCRIPTION

Has functions for adding and removing releases in collection.

=head1 METHODS

=head2 new $rodbh, $rawdbh, $collectionId

Create a Collection object for the collection with id C<$collectionId>.

=cut

sub new
{
    my($this, $rodbh, $rawdbh, $collectionId) = @_;

    bless {
        RODBH                        => $rodbh,
        RAWDBH                       => $rawdbh,
        collectionId                 => $collectionId,
    }, $this;
}

=head2 addAlbums @albums

Add the albums with MBIDs in C<@albums> to this collection.

=cut

sub AddAlbums
{
    my ($this, @albums) = @_;

    # Iterate over the album MBID's to be added
    $this->{addAlbum} = 1;
    map { $this->AddRelease($_) } @albums;

    return 1;
}

=head2 removeAlbums @albums

Remove the albums in C<@albums> from this collection.

=cut

sub RemoveAlbums
{
    my ($this, @albums) = @_;

    $this->{removeAlbum} = 1;
    map { $this->RemoveRelease($_) } @albums;
}

=head2 addRelease $mbid

Add the release with MBId C<$mbid> to collection.

=cut

sub AddRelease
{
    my ($this, $mbid) = @_;

    my $rosql  = Sql->new($this->{RODBH});
    my $rawsql = Sql->new($this->{RAWDBH});

    # make sure this is valid format for a mbid
    if(MusicBrainz::Server::Validation::IsGUID($mbid))
    {
        my $releaseId;

        # get album id
        $releaseId = $rosql->SelectSingleValue("SELECT id FROM album WHERE gid = ?", $mbid);

        eval
        {
            $rawsql->Begin();

            # add MBID to the collection
            $rawsql->Quiet(1);
            $rawsql->Do('INSERT INTO collection_has_release_join (collection_info, album) VALUES (?, ?)',
                        $this->{collectionId}, $releaseId);

            # increase add count
            $this->{addAlbum_insertCount}++;

            # add to list of MBIds
            push(@{$this->{MBIdArray}}, $mbid);
        };

        if($@)
        {
            if($@ =~ /duplicate/) # it is a duplicate... add it to the array of duplicates
            {
                push(@{$this->{addAlbum_duplicateArray}}, $mbid);
            }
            else
            {
                $this->{invalidMBIdCount}++;
            }

            $rawsql->Rollback();
        }
        else
        {
            $rawsql->Commit();
        }
    }
    else
    {
        $this->{addAlbum_invalidMBIDCount}++; # increase invalid mbid count
    }
}

# static
sub AddReleaseWithId
{
    my($releaseId, $collectionId, $rawdbh) = @_;

    my $rawsql=Sql->new($rawdbh);
    eval
    {
        $rawsql->Begin();
        $rawsql->Quiet(1);

        # add MBID to the collection
        $rawsql->Do('INSERT INTO collection_has_release_join (collection_info, album) VALUES (?, ?)', $collectionId, $releaseId);
    };

    if($@)
    {
        # Error occured, but it's not about duplicates...
        unless ($@ =~ /duplicate/)
        {
            die $@;
        }

        $rawsql->Rollback();
    }
    else
    {
        $rawsql->Commit();
    }
}

=head2 removeRelease $mbid

Remove realease with MBId C<$mbid> from collection

=cut

# TO DO: call RemoveReleaseWithId after getting id.
# do this for AddRelease as well
sub RemoveRelease
{
    my ($this, $mbid) = @_;

    # make sure this is valid format for a mbid
    if(MusicBrainz::Server::Validation::IsGUID($mbid))
    {
        my $rawsql = Sql->new($this->{RAWDBH});
        my $rosql  = Sql->new($this->{RODBH});

        # get id for realease with specified mbid
        my $albumId = $rosql->SelectSingleValue("SELECT id FROM album WHERE gid = ?", $mbid);
        eval
        {
            $rawsql->Begin();

            # make sure there is a release with the mbid in the database
            my $deleteResult = $rawsql->Do("DELETE FROM collection_has_release_join
                                                  WHERE album = ? AND collection_info = ?",
                                           $albumId, $this->{collectionId});
            if($deleteResult == 1) # successfully deleted
            {
                # increase remove count
                $this->{removeAlbum_removeCount}++;

                # add MBId to array
                push(@{$this->{MBIdArray}}, $mbid);
            }
        };

        if($@)
        {
            $rawsql->Rollback();
            croak($@);
        }
        else
        {
            $rawsql->Commit();
        }
    }
    else
    {
        $this->{removeAlbum_invalidMBIDCount}++; # increase invalid mbid count
    }
}

sub RemoveReleaseWithId
{
    my ($rawdbh, $releaseId, $collectionId) = @_;

    my $rawsql = Sql->new($rawdbh);
    eval
    {
        $rawsql->Begin();

        # make sure there is a release with the mbid in the database
        my $deleteResult = $rawsql->Do("DELETE FROM collection_has_release_join
                                              WHERE album = ? AND collection_info = ?",
                                       $releaseId, $collectionId);
    };

    if($@)
    {
        $rawsql->Rollback();
        croak($@);
    }
    else
    {
        $rawsql->Commit();
        return 1;
    }
}

# This function is called from Moderation when changes are applied to the DB
sub RemoveArtistFromCollections
{
    my ($artistid) = @_;

    my $rawdb = $Moderation::DBConnections{RAWDATA};
    $rawdb->Do("DELETE FROM collection_watch_artist_join WHERE artist = ?", $artistid);
    $rawdb->Do("DELETE FROM collection_discography_artist_join WHERE artist = ?", $artistid);
}

# This function is called from Moderation when changes are applied to the DB
sub RemoveReleaseFromCollections
{
    my ($releaseid) = @_;

    my $rawdb = $Moderation::DBConnections{RAWDATA};
    $rawdb->Do("DELETE FROM collection_has_release_join WHERE album = ?", $releaseid);
    $rawdb->Do("DELETE FROM collection_ignore_release_join WHERE album = ?", $releaseid);
}

# This function is called from Moderation when changes are applied to the DB
sub MergeArtists
{
    my ($old, $new) = @_;

    my $rawdb = $Moderation::DBConnections{RAWDATA};
    $rawdb->Do("UPDATE collection_watch_artist_join SET artist = ? WHERE artist = ?", $new, $old);
    $rawdb->Do("UPDATE collection_discography_artist_join SET artist = ? WHERE artist = ?", $new, $old);
}

# This function is called from Moderation when changes are applied to the DB
sub MergeReleases
{
    my ($old, $new) = @_;

    my $rawdb = $Moderation::DBConnections{RAWDATA};
    $rawdb->Do("UPDATE collection_has_release_join SET album = ? WHERE album = ?", $new, $old);
    $rawdb->Do("UPDATE collection_ignore_release_join SET album = ? WHERE album = ?", $new, $old);
}

1;
# vi: set ts=4 sw=4 :
