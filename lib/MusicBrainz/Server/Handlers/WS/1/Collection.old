#!/usr/bin/perl -w
# vi: set ts=4 sw=4 :
#____________________________________________________________________________
#
#   MusicBrainz -- the open music metadata database
#
#   Copyright (C) 2001 Robert Kaye
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
#   $id: $
#____________________________________________________________________________

use strict;

package MusicBrainz::Server::Handlers::WS::1::Collection;

use HTTP::Status qw(RC_OK RC_NOT_FOUND RC_BAD_REQUEST RC_INTERNAL_SERVER_ERROR RC_FORBIDDEN RC_SERVICE_UNAVAILABLE);
use MusicBrainz::Server::Collection;
use MusicBrainz::Server::CollectionInfo;
use MusicBrainz::Server::Handlers::WS::1::Common;

sub handler
{
    # URLs are of the form:
    # POST http://server/ws/1/collection/?addalbums=<comma separated list of mbids>&removealbums=<comma separated list of mbids>
    my $c = shift;
    my $r = $c->req;
   
    my @addAlbums=split(/, |,/, $r->params->{'addAlbums'} || $r->params->{add} || '');
    my @removeAlbums=split(/, |,/, $r->params->{'removeAlbums'} || $r->params->{remove} || '');
    if ($r->method ne "POST" && (scalar(@addAlbums) || scalar(@removeAlbums)))
    {   
        return bad_req($c, "Only POST method is acceptable when adding or removing releases.")
    }
    my $type = $r->params->{type};
    if (!defined($type) || $type ne 'xml')
    {
        return bad_req($c, "Invalid content type. Must be set to xml.");
    }
    
    require MusicBrainz;
    require Sql;
    
    my $mbro = MusicBrainz->new();
    $mbro->Login();
    
    my $mbraw = MusicBrainz->new();
    $mbraw->Login(db => 'RAWDATA');
    
    my $sqlraw = Sql->new($mbraw->{dbh});
    my $sqlro = Sql->new($mbro->{dbh});
    
    my $userId = $c->user->id;
    
    # make sure the user has a collection_info tuple
    MusicBrainz::Server::CollectionInfo::AssureCollectionIdForUser($userId, $mbraw->{dbh});
    
    # get collection_info id
    my $collectionId = MusicBrainz::Server::CollectionInfo::GetCollectionIdForUser($userId, $mbraw->{dbh});
    
    # instantiate Collection object
    my $collection = MusicBrainz::Server::Collection->new($mbro->{dbh}, $mbraw->{dbh}, $collectionId);
    
    
    # only allow one at a time. return a 400 error if both are used
    my $printer;
    if(@addAlbums && @removeAlbums)
    {
        return bad_req($c, "Adding and removing releases must be done one at a time.");
    }
    elsif(!@addAlbums && !@removeAlbums)
    {
        $printer = sub {
            print_collection_xml($collectionId, $mbro->{dbh}, $mbraw->{dbh});
        };
    }
    elsif(@addAlbums){
        $collection->AddAlbums(@addAlbums);
        
        $printer = sub {
            print_manipulate_xml($collection);
        };
    }
    elsif(@removeAlbums){
        $collection->RemoveAlbums(@removeAlbums);
        $printer = sub {
            print_manipulate_xml($collection);
        };
    }
    
    send_response($c, $printer);
    return RC_OK;   
}

sub print_manipulate_xml
{
    my ($collection) = @_;
    
    print '<?xml version="1.0" encoding="UTF-8"?>';
    print '<metadata xmlns="http://musicbrainz.org/ns/mmd-1.0#">';
    
    if($collection->{addAlbum}==1 || $collection->{removeAlbum}==1)
    {
        print '<response-list>';
        for my $mbid (@{$collection->{MBIdArray}})
        {
            print '<release id="' . $mbid . '"/>';
        }
        print '</response-list>';
    }
    
    print '</metadata>';
}

sub print_collection_xml
{
    my ($collectionId, $rodbh, $rawdbh) = @_;
    
    my $collectionInfo = MusicBrainz::Server::CollectionInfo->new($collectionId, $rodbh, $rawdbh, undef);
    
    print '<?xml version="1.0" encoding="UTF-8"?>';
    print '<metadata xmlns="http://musicbrainz.org/ns/mmd-1.0#">';
    print '<release-list>';
        
    for my $mbid (@{$collectionInfo->GetHasMBIDs()})
    {
        print '<release id="' . $mbid . '"/>';
    }
    
    print '</release-list>';
    print '</metadata>';
}

1;
