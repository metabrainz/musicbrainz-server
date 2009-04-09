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

package MusicBrainz::Server::CollectionInfo;

use strict;
use warnings;

use Sql;

# TODO:
# look up when use/require should be used
# get some stuff from the CollectionPreference object instead of doing new queries in here

=head2 new $userId, $rodbh, $rawdbh, $preferences

Create a CollectionInfo object for user with id C<$collectionId>.

=cut

sub new
{
    my ($self, $collectionId, $rodbh, $rawdbh, $preferences) = @_;

    my $sql    = Sql->new($rawdbh);
    my $result = $sql->SelectSingleRowHash("SELECT * FROM collection_info WHERE id=?", $collectionId);

    bless {
        RODBH           => $rodbh,        # read only database
        RAWDBH          => $rawdbh,       # raw database
        preferences     => $preferences,
        collectionId    => $result->{id},
        hasReleases     => undef,         # lets see if this and missingReleases will be used
        missingReleases => undef
    }, $self;
}

=head2 GetHasReleaseIds $artistId

Returns a reference to an array containing id's of all releases in collection.

=cut

sub GetHasReleaseIds
{
    my ($self) = @_;

    my $rawsql = Sql->new($self->{RAWDBH});

    my $hasReleaseIds = $rawsql->SelectSingleColumnArray(
        'SELECT album
           FROM collection_has_release_join
          WHERE collection_info = ?',
        $self->{collectionId}
    );

    return $hasReleaseIds;
}

=head2 GetHasMBIDs $artistId

Returns MBIds of all releases in collection.

=cut

sub GetHasMBIDs
{
    my ($self) = @_;

    # create Sql objects
    my $rosql  = Sql->new($self->{RODBH});
    my $rawsql = Sql->new($self->{RAWDBH});

    # get id's of all releases in collection
    my $result = $rawsql->SelectSingleColumnArray('SELECT album
                                                     FROM collection_has_release_join 
                                                    WHERE collection_info = ?', $self->{collectionId});

    my @ids;
    if(scalar @$result > 0)
    {
        # get MBID's for all releases in collection
        my $releaseQuery='SELECT album.gid
                            FROM album INNER JOIN artist ON (album.artist = artist.id) 
                           WHERE album.id IN(' . join(',', @$result) . ') ORDER BY artist.name, album.name';

        @ids = @{ $rosql->SelectSingleColumnArray($releaseQuery) };
    }

    return \@ids;
}

=head2 GetHasReleases

Returns all releases in collection as objects MusicBrainz::Server::Release.

=cut

sub GetHasReleases
{
    my ($self) = @_;

    # create Sql objects
    my $rosql  = Sql->new($self->{RODBH});
    my $rawsql = Sql->new($self->{RAWDBH});

    # get id's of all releases in collection
    my $releaseids = $rawsql->SelectSingleColumnArray('SELECT album
                                                         FROM collection_has_release_join
                                                        WHERE collection_info = ?', $self->{collectionId});
print STDERR "Foo!\n";
    my @releases;
    if(scalar @$releaseids > 0)
    {
        my $releaseQuery = 'SELECT album.id, album.gid, album.name, album.artist,
                                   attributes, album.modpending, language, script,
                                   modpending_lang, album.quality, album.modpending_qual,
                                   tracks as trackcount, firstreleasedate, rating, rating_count
                              FROM album
                        INNER JOIN artist ON (album.artist = artist.id)
                         LEFT JOIN albummeta ON (album.id = albummeta.id)
                             WHERE album.id IN(' . join(',', @{$releaseids}) . ')
                          ORDER BY artist.sortname, album.name';

        my $rows = $rosql->SelectListOfHashes($releaseQuery);
        for my $row (@$rows)
        {
            my $release = MusicBrainz::Server::Release->new($self->{RODBH});
            $release->LoadFromRow($row);

            push @releases, $release;
        }
    }
use Data::Dumper;
	print STDERR Dumper(\@releases);
    return \@releases;
}

=head2 GetShowMissingArtists

Returns a list of artist ids

=cut

sub GetShowMissingArtists
{
    my ($self) = @_;

    my $rawsql = Sql->new($self->{RAWDBH});

    my $displayMissingOfArtists = $rawsql->SelectSingleColumnArray('SELECT artist
                                                                      FROM collection_discography_artist_join
                                                                     WHERE collection_info = ?', $self->{collectionId});

    return $displayMissingOfArtists;
}

=head2 GetWatchArtists

Returns a reference to an array containing id's of

=cut

sub GetWatchArtists
{
    my ($self) = @_;

    my $rawsql = Sql->new($self->{RAWDBH});

    my $watchArtists = $rawsql->SelectSingleColumnArray('SELECT artist
                                                           FROM collection_watch_artist_join
                                                          WHERE collection_info = ?', $self->{collectionId});

    return $watchArtists;
}

# Should missing releases of specified artist be displayed to specified user?
sub ShowMissingOfArtistToUser
{
    my ($artistId, $collectionId, $rawdbh) = @_;

    return unless defined $collectionId;

    # Check if the user has selected to see missing releases of the artist
    my $rawsql = Sql->new($rawdbh);

    my $result = $rawsql->SelectSingleValue('SELECT artist
                                               FROM collection_discography_artist_join
                                              WHERE collection_info = ?AND artist = ?', $collectionId, $artistId);
	return (defined $result);
}

# Should the user be notified about new releases from this artist?
sub NotifyUserAboutNewFromArtist
{
    my ($artistId, $collectionId, $rawdbh) = @_;

    return 0 unless defined $collectionId;

    # Check if the user has selected to be notified about new releases from this artist
    my $rawsql = Sql->new($rawdbh);

    my $result = $rawsql->SelectSingleValue('SELECT artist
                                               FROM collection_watch_artist_join
                                              WHERE collection_info = ?
                                                AND artist = ?', $collectionId, $artistId);

	return (defined $result);
}

sub GetMissingMBIDs
{
    my ($self) = @_;

    my $rosql  = Sql->new($self->{RODBH});
    my $rawsql = Sql->new($self->{RAWDBH});

    my $displayMissingOfArtists = $self->GetShowMissingArtists();

    my $count = scalar @$displayMissingOfArtists;

    if(scalar @$displayMissingOfArtists > 0)
    {
        my $hasReleaseIds = $self->GetHasReleaseIds();
        my $showTypes     = [ $self->{preferences}->GetShowTypes() ];

        my $hasIdsQueryString;
        for my $attribute (@$showTypes)
        {
            $hasIdsQueryString .= ' AND ' . $attribute . ' <> ALL (album.attributes[2:5])';
        }

        if(@$hasReleaseIds)
        {
            $hasIdsQueryString .= ' AND album.id NOT IN (' . join(',', @{$hasReleaseIds}) . ')
                                    AND album.id NOT IN
                                        (SELECT id FROM album WHERE name IN
                                             (SELECT name FROM album WHERE id IN (' . join(',', @{$hasReleaseIds}) . '))
                                    AND artist IN
                                        (SELECT artist FROM album WHERE id IN(' . join(',', @{$hasReleaseIds}) . ')))';
        }

        if(@{$displayMissingOfArtists} && @$showTypes)
        {
            my $query = "SELECT DISTINCT ON (artist.name, album.name) album.gid
                                       FROM album
                                 INNER JOIN albummeta ON (album.id = albummeta.id)
                                 INNER JOIN artist ON (album.artist = artist.id)
                                      WHERE album.artist IN (". join(',', @{$displayMissingOfArtists}).") " . $hasIdsQueryString . "
                                        AND album.name != '[non-album tracks]'
                                   ORDER BY artist.name, album.name, albummeta.firstreleasedate DESC";
            return $rosql->SelectSingleColumnArray($query);
        }
    }
	return [];
}

sub GetMissingMBIDsForArtist
{
    my ($self, $artistId) = @_;

    my $rosql = Sql->new($self->{RODBH});

    return $rosql->SelectListOfHashes("SELECT gid FROM album WHERE artist=", $artistId);
}

sub GetNewReleases
{
    my ($self) = @_;

    my $rosql = Sql->new($self->{RODBH});

    my $lastCheck    = $self->GetLastCheck();
    my $watchArtists = $self->GetWatchArtists();

    my $newReleases = [];

    if(@$watchArtists)
    {
        # We want to know about future releases, and things that have
        # just been released, but not things that were released
        # ages_ago (even if they've only just been added to MB).

        my $ages_ago = "CURRENT_TIMESTAMP - '7 days'::INTERVAL";

        $newReleases = $rosql->SelectSingleColumnArray("
            SELECT album.id 
              FROM album INNER JOIN albummeta ON (album.id = albummeta.id)
             WHERE album.artist IN (" . join(',', @{$watchArtists}) . ") 
               AND to_timestamp(albummeta.firstreleasedate, 'YYYY-MM-DD') > ($ages_ago)
               AND albummeta.dateadded > ?
            ", $self->GetLastCheck());
    }

    return $newReleases;
}

sub GetLastCheck
{
    my ($self) = @_;

    my $rawsql = Sql->new($self->{RAWDBH});

    return $rawsql->SelectSingleValue('SELECT lastcheck FROM collection_info WHERE id = ?', $self->{collectionId});
}

sub UpdateLastCheck
{
    my ($self) = @_;

    my $rawsql = Sql->new($self->{RAWDBH});

    eval
    {
        $rawsql->Begin();
        $rawsql->Do('UPDATE collection_info SET lastcheck = CURRENT_TIMESTAMP WHERE id = ?', $self->{collectionId});
    };

    if($@)
    {
        $rawsql->Rollback();
        die($@);
    }
    else
    {
        $rawsql->Commit();
    }
}

#----------------------------
# static subs
#----------------------------

=head2 CreateCollection $userId, $rawdbh

Create a collection_info tuple for the specified user.

=cut

sub CreateCollection
{
    my ($userId, $rawdbh) = @_;

    my $rawsql = Sql->new($rawdbh);
    my $id;

    eval
    {
        $rawsql->Begin();
        $rawsql->Do("INSERT INTO collection_info (moderator, publiccollection, emailnotifications) VALUES (?, TRUE, TRUE)", $userId);
        $id = $rawsql->GetLastInsertId('collection_info');
    };
    if($@)
    {
		# This is a hack -- this should never happen, but it does. The entire collections code needs a thorough review. :-(
		if($@ =~ /duplicate/)
		{
			$rawsql->Rollback();
			return GetCollectionIdForUser($userId, $rawdbh);
		}
		else
		{
			$rawsql->Rollback();
			die($@);
		}
    }
    else
    {
        $rawsql->Commit();
    }

    return $id;
}

sub AssureCollectionIdForUser
{
    my ($userId, $rawdbh) = @_;

    my $collectionId = GetCollectionIdForUser($userId, $rawdbh) or
                       CreateCollection($userId, $rawdbh);

    return $collectionId;
}

=head2 GetCollectionIdForUser $userId, $rawdbh

Get the id of the collection_info tuple corresponding to the specified user.

=cut

sub GetCollectionIdForUser
{
    my ($userId, $rawdbh) = @_;

    my $rawsql = Sql->new($rawdbh);

    return $rawsql->SelectSingleValue("SELECT id FROM collection_info WHERE moderator=?", $userId);
}

sub GetUserIdForCollection
{
    my ($collectionId, $rawdbh) = @_;

    my $sqlraw = Sql->new($rawdbh);

    return $sqlraw->SelectSingleValue('SELECT moderator FROM collection_info WHERE id = ?', $collectionId);
}

sub HasRelease
{
    my ($rawdbh, $collectionId, $releaseId) = @_;

    return 0 unless defined $collectionId;

    my $rawsql = Sql->new($rawdbh);

    my $count = $rawsql->SelectSingleValue('SELECT COUNT(*)
                                           FROM collection_has_release_join
                                          WHERE collection_info = ? 
                                            AND album = ?', $collectionId, $releaseId);

    return $count > 0;
}

1;
# vi: set ts=4 sw=4 :
