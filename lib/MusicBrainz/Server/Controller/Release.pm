package MusicBrainz::Server::Controller::Release;

use strict;
use warnings;
use parent 'Catalyst::Controller';

use ModDefs;
use MusicBrainz;
use MusicBrainz::Server::Adapter::Relations;
use MusicBrainz::Server::CoverArt;
use MusicBrainz::Server::Release;
use MusicBrainz::Server::Tag;
use MusicBrainz::Server::Track;
use MusicBrainz::Server::Validation;

=head1 NAME

MusicBrainz::Server::Controller::Release - Catalyst Controller for
working with Release entities

=cut

=head1 DESCRIPTION

This controller handles user interaction, both read and write, with
L<MusicBrainz::Server::Release> objects. This includes displaying
releases, editing releases and creating new releases.

=head1 METHODS

=head2 releaseLinkRaw

Create stash data to link to a Release entity using root/components/entity-link.tt

=cut

sub releaseLinkRaw
{
    my ($name, $mbid) = @_;

    {
        name => $name,
        mbid => $mbid,
        link_type => 'release'
    };
}

=head2 show

Display a release to the user.

This loads a release from the database (given a valid MBID or database row
ID) and displays it in full, including a summary of advanced relations,
tags, tracklisting, release events, etc.

=cut

sub show : Path Local Args(1) {
    my ($self, $c, $mbid) = @_;

    # Load Release
    #
    my $release = MusicBrainz::Server::Release->new($c->mb->{DBH});

    unless (MusicBrainz::Server::Validation::IsGUID($mbid))
    {
        if (MusicBrainz::Server::Validation::IsNonNegInteger($mbid))
            { $release->SetId($mbid); }
        else
            { die "Not a valid GUID or row ID"; }
    }
    else { $release->SetMBId($mbid); }

    $release->LoadFromId(1)
        or die "Failed to load release";

    $c->stash->{release} = $release->ExportStash qw/ puids track_count quality language type /;


    # Load Release Relationships
    #
    my $link = MusicBrainz::Server::Link->new($c->mb->{DBH});
    my @arLinks = $link->FindLinkedEntities($release->GetId, 'album');

    MusicBrainz::Server::Adapter::Relations::NormaliseLinkDirections(\@arLinks, $release->GetId, 'album');
    @arLinks = MusicBrainz::Server::Adapter::Relations::SortLinks(\@arLinks);
    $c->stash->{relations} = MusicBrainz::Server::Adapter::Relations::ExportLinks(\@arLinks);


    # Load Artist
    #
    my $artist = MusicBrainz::Server::Artist->new($c->mb->{DBH});
    $artist->SetId($release->GetArtist);
    $artist->LoadFromId(1)
        or die "Failed to load the artist of this release";

    # Export enough to display the artist header
    $c->stash->{artist} = $artist->ExportStash qw/ name mbid type date quality
                                                   resolution /;
    

    # Tracks
    my $puid_counts = $release->LoadPUIDCount;
    my @tracks = $release->LoadTracks;

    $c->stash->{tracks} = [];

    for my $track (@tracks)
    {
        my @trackLinks = $link->FindLinkedEntities($track->GetId, 'track');
        MusicBrainz::Server::Adapter::Relations::NormaliseLinkDirections(\@trackLinks, $track->GetId, 'track');
        @trackLinks = MusicBrainz::Server::Adapter::Relations::SortLinks(\@trackLinks);

        push @{ $c->stash->{tracks} }, {
            number => $track->GetSequence,
            title => $track->GetName,
            puids => $puid_counts->{ $track->GetId },
            duration => MusicBrainz::Server::Track::FormatTrackLength($track->GetLength),
            relations => MusicBrainz::Server::Adapter::Relations::ExportLinks(\@trackLinks),
        };
    }


    # Tags
    my $t = MusicBrainz::Server::Tag->new($c->mb->{DBH});
    my $num = 5;
    my $tags = $t->GetTagHashForEntity('release', $release->GetId, $num + 1);

    $c->stash->{tags} = sort { $tags->{$b} <=> $tags->{$a}; } keys %{$tags};
    $c->stash->{more_tags} = scalar(keys %$tags) > $num;

    $c->stash->{template} = 'releases/show.tt';
}

=head1 LICENSE

This software is provided "as is", without warranty of any kind, express or
implied, including  but not limited  to the warranties of  merchantability,
fitness for a particular purpose and noninfringement. In no event shall the
authors or  copyright  holders be  liable for any claim,  damages or  other
liability, whether  in an  action of  contract, tort  or otherwise, arising
from,  out of  or in  connection with  the software or  the  use  or  other
dealings in the software.

GPL - The GNU General Public License    http://www.gnu.org/licenses/gpl.txt
Permits anyone the right to use and modify the software without limitations
as long as proper  credits are given  and the original  and modified source
code are included. Requires  that the final product, software derivate from
the original  source or any  software  utilizing a GPL  component, such  as
this, is also licensed under the GPL license.

=cut

1;
