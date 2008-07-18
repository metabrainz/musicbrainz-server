package MusicBrainz::Server::Controller::Artist;

use strict;
use warnings;
use parent 'Catalyst::Controller';

use Encode qw( decode );
use ModDefs;
use Moderation;
use MusicBrainz::Server::Annotation;
use MusicBrainz::Server::Alias;
use MusicBrainz::Server::Artist;
use MusicBrainz::Server::Link;
use MusicBrainz::Server::Release;
use MusicBrainz::Server::Tag;
use MusicBrainz::Server::URL;
use MusicBrainz::Server::Validation;
use MusicBrainz;

=head1 NAME

MusicBrainz::Server::Controller::Artist - Catalyst Controller for working
with Artist entities

=head1 DESCRIPTION

The artist controller is used for interacting with
L<MusicBrainz::Server::Artist> entities - both read and write. It provides
views to the artist data itself, and a means to navigate to a release
that is attributed to a certain artist.

=head1 METHODS

=head2 artistLinkRaw

Create stash data to link to an artist, but given the parameters explicity (rather than requiring an
Artist object)

=cut

sub artistLinkRaw
{
    my ($name, $mbid) = @_;

    {
        name => $name,
        mbid => $mbid,
        link_type => 'artist'
   };
}

=head2 relations

Shows all the entities (except track) that this artist is related to.

=cut

sub relations : Local Args(1) MyAction('ArtistPage')
{
    my ($self, $c, $mbid) = @_;

    my $artist = $c->stash->{_artist};
    my $links = LoadArtistARLinks ($c->mb->{DBH}, $artist);
    $c->stash->{relations} = MusicBrainz::Server::Adapter::Relations::ExportLinks($links);

    $c->stash->{template} = 'artist/relations.tt';
}

=head2 create

When given a GET request this displays a form allowing the user to enter
data, creating a new artist. If a POST request is received, the data
is validated and if validation succeeds, the artist is entered into the
MusicBrainz database.

The heavy work validating the form and entering data into the database
is done via L<MusicBrainz::Server::Form::Artist;

=cut

sub create : Local
{
    my ($self, $c) = @_;

    use MusicBrainz::Server::Form::Artist;

    my $form = new MusicBrainz::Server::Form::Artist;
    $form->context($c);

    $c->stash->{form} = $form;

    if ($c->form_posted)
    {
        if (my $mods = $form->update_from_form ($c->req->params))
        {
            $c->flash->{ok} = "Thanks! The artist has been added to the database, and we have redirected you to their landing page";
            (my $addmod) = grep { $_->Type eq ModDefs::MOD_ADD_ARTIST } @$mods;
            if ($addmod)
            {
                $c->detach('/artist/show', $addmod->GetRowId);
            }
        }
    }

    $c->stash->{template} = 'artist/create.tt';
}

=head2 edit

Allows users to edit the data about this artist.

When viewed with a GET request, the user is displayed a form filled with
the current artist data. When a POST request is received, the data is
validated and if it passed validation is the updated data is entered
into the MusicBrainz database.

=cut 

sub edit : Local Args(1) MyAction('ArtistPage')
{
    my ($self, $c, $mbid) = @_;
    my $artist = $c->stash->{_artist};

    use MusicBrainz::Server::Form::Artist;

    my $form = new MusicBrainz::Server::Form::Artist($artist->GetId);
    $form->context($c);
    $c->stash->{form} = $form;

    if($c->form_posted)
    {
        if ($form->update_from_form($c->req->params))
        {
            $c->flash->{ok} = "Thanks, your artist edit has been entered into the moderation queue";
            $c->detach('/artist/show', $mbid);
        }
    }

    $c->stash->{template} = 'artist/edit.tt';
}

=head2 appearances

Display a list of releases that an artist appears on via advanced
relations.

=cut

sub appearances : Local Args(1) MyAction('ArtistPage')
{
    my ($self, $c) = @_;
    my $artist = $c->stash->{_artist};
    my $mb = $c->mb;

    my $link = new MusicBrainz::Server::Link($mb->{DBH});
    my @rawReleases = @{$link->FindLinkedAlbums("artist", $artist->GetId)};

    for my $release (@rawReleases)
    {
        $release->{_name_sort_} = lc decode "utf-8", $release->{name};
        $release->{_disc_no_} = 0;

        # Attempt to sort "disc x" correctly
        if ($release->{_name_sort_} =~
            /^(.*)                              # $1 <main title>
                (?:[(]disc\ (\d+)               # $2 (disc x
                    (?::[^()]*                  #    [: <disc title>
                        (?:[(][^()]*[)][^()]*)* #     [<1 level of nested par.>]
                    )?                          #    ]
                    [)]                         #    )
                )
                (.*)$                           # $4 [<rest of main title>]
            /xi)
        {
            $release->{_name_sort_} = "$1 $3";
            $release->{_disc_no_} = $2;
        }

        $release->{date} = $release->{begindate};
        $release->{date} =~ s/\s+//;
        $release->{date} = $release->{firstreleasedate} if !$release->{date};
        $release->{_sort_date_} = ($release->{date} || "9999-99-99");
    }
    
    @rawReleases = sort {
        ($a->{linkphrase} cmp $b->{linkphrase}) or
        ($a->{_sort_date_} cmp $b->{_sort_date_}) or
        ($a->{_name_sort_} cmp $b->{_name_sort_}) or
        ($a->{_disc_no_} <=> $b->{_disc_no_})
    } @rawReleases;
   
    my @releaseGroups;
    my $group;
    for my $release (@rawReleases)
    {
        die "No release" unless defined $release;

        if(not defined $group or $release->{linkphrase} ne $group->{phrase})
        {
            $group = {
                phrase => $release->{linkphrase},
                releases => []
            };

            push @releaseGroups, $group;
        }

        my $stashRelease = {
            name => $release->{name},
            link_type => 'release',
            mbid => $release->{id}
        };

        $stashRelease->{artist} = {
            name => $release->{artist_name},
            link_type => 'artist',
            mbid => $release->{artist_id}
        };
        $stashRelease->{year} = substr($release->{date}, 0, 4) || '?';

        push @{$group->{releases}}, $stashRelease;
    }

    $c->stash->{release_groups} = \@releaseGroups;
    $c->stash->{template} = 'artist/appearances.tt';
}

=head2 perma

Display the perma-link for a given artist.

=cut

sub perma : Local Args(1) MyAction('ArtistPage')
{
    my ($self, $c) = @_;
    my $artist = $c->stash->{_artist};
    $c->stash->{template} = 'artist/perma.tt';
}

=head2 details

Display detailed information about a specific artist.

=cut

sub details : Local Args(1) MyAction('ArtistPage')
{
    my ($self, $c, $mbid) = @_;

    my $mb = new MusicBrainz;
    $mb->Login();

    my $artist = $c->stash->{_artist};
    $artist->{DBH} = $mb->{DBH};

    $c->stash->{details} = {
        subscriber_count => scalar $artist->GetSubscribers
    };

    $c->stash->{template} = 'artist/details.tt';
}

=head2 aliases

Display all aliases of an artist, along with usage information.

=cut

sub aliases : Local Args(1) MyAction('ArtistPage')
{
    my ($self, $c, $mbid) = @_;

    my $artist = $c->stash->{_artist};

    my $alias = MusicBrainz::Server::Alias->new($c->mb->{DBH}, "ArtistAlias");
    my @aliases = $alias->GetList($artist->GetId);

    my @prettyAliases = ();
    for my $alias (@aliases)
    {
        push @prettyAliases, {
            name => $alias->[1],
            useCount => $alias->[2],
            used => !($alias->[3] =~ /^1970-01-01/)
        }
    }

    $c->stash->{aliases} = \@prettyAliases;
    $c->stash->{template} = 'artist/aliases.tt';
}

=head2 show

Shows an artist's main landing page.

This page shows the main releases (by default) of an artist, along with a
summary of advanced relations this artist is involved in. It also shows
folksonomy information (tags).

=cut

sub show : Path Args(1) MyAction('ArtistPage')
{
    my ($self, $c, $mbid) = @_;

    # Load the artist
    my $mb = $c->mb;
    my $artist = $c->stash->{_artist};

    # Load data for the landing page
    my $annotation = LoadArtistAnnotation ($mb->{DBH}, $artist);
    my @tags = LoadArtistTags ($mb->{DBH}, 5, $artist);
    my $arLinks = LoadArtistARLinks ($mb->{DBH}, $artist); 
    my @releases = LoadArtistReleases ($artist);

    # Create data structures for the template
    # General artist data: {{{
    $c->stash->{artist_tags} = \@tags;
    $c->stash->{artist_relations} = MusicBrainz::Server::Adapter::Relations::ExportLinks($arLinks);
    # $c->stash->{annotation} = $annotation->GetTextAsHTML
    #    if defined $annotation;

    # }}}
    # Releases, sorted into "release groups": {{{
    $c->stash->{groups} = [];

    my $currentGroup;
    for my $release (@releases)
    {
        my ($type, $status) = $release->GetReleaseTypeAndStatus;

        # Releases should have sorted into groups, so if $type has changed, we need to create
        # a new "release group"
        if(not defined $currentGroup or $currentGroup->{type} != $type)
        {
            $currentGroup = {
                name => $release->GetAttributeNamePlural($type),
                releases => [],
                type => $type
            };

            push @{$c->stash->{groups}}, $currentGroup;
        }

        my $rel = $release->ExportStash qw/ language track_count disc_ids puids quality language status
                                            first_date attributes type/;

        push @{$currentGroup->{releases}}, $rel;
    }
    # }}}

    # Decide how to display the data
    $c->stash->{template} = $c->request->params->{full} ? 
                                'artist/full.tt' :
                                'artist/compact.tt';
}

sub LoadArtistAnnotation
{
    my ($dbh, $artist) = @_;

    my $annotation = MusicBrainz::Server::Annotation->new($dbh);
    $annotation->SetArtist($artist->GetId);
    return $annotation->GetLatestAnnotation;
}

sub LoadArtistTags
{
    my ($dbh, $tagCount, $artist) = @_;

    my $t = MusicBrainz::Server::Tag->new($dbh);
    my $tagHash = $t->GetTagHashForEntity('artist', $artist->GetId, $tagCount + 1);

    sort { $tagHash->{$b} <=> $tagHash->{$a}; } keys %{$tagHash};
}

sub LoadArtistARLinks
{
    my ($dbh, $artist) = @_;
    my @arLinks;

    my $link = MusicBrainz::Server::Link->new($dbh);
    @arLinks = $link->FindLinkedEntities($artist->GetId,
        'artist', to_type => ['label', 'url', 'artist']);

    MusicBrainz::Server::Adapter::Relations::NormaliseLinkDirections(\@arLinks, $artist->GetId, 'artist');
    @arLinks = MusicBrainz::Server::Adapter::Relations::SortLinks(\@arLinks);

    return \@arLinks;
}

sub LoadArtistReleases
{
    my $artist = shift;

    my @releases = $artist->GetReleases(1, 1);
    my $onlyHasVAReleases = (scalar @releases) == 0;

    my @shortList;

    for my $release (@releases)
    {
        my ($type, $status) = $release->GetReleaseTypeAndStatus;

        # Construct values to sort on
        $release->SetMultipleTrackArtists($release->GetArtist != $release->GetId() ? 1 : 0);
        $release->{_is_va_} = ($release->GetArtist == &ModDefs::VARTIST_ID or
                               $release->GetArtist != $release->GetId());
        $release->{_is_nonalbum_} = ($type && $type == MusicBrainz::Server::Release::RELEASE_ATTR_NONALBUMTRACKS);
        $release->{_section_key_} = (defined $type ? $release->{_is_va_} . " " . $type : $release->{_is_va});
        $release->{_name_sort_} = lc decode "utf-8", $release->GetName;
        $release->{_disc_max_} = 0;
        $release->{_disc_no_} = 0;
        $release->{_firstreleasedate_} = ($release->GetFirstReleaseDate || "9999-99-99");

        CheckAttributes($release);

        # Attempt to sort "disc x [of y]" correctly
        if ($release->{_name_sort_} =~
            /^(.*)                              # $1 <main title>
                (?:[(]disc\ (\d+)               # $2 (disc x
                    (?:\ of\ (\d+))?            # $3 [of y]
                    (?::[^()]*                  #    [: <disc title>
                        (?:[(][^()]*[)][^()]*)* #     [<1 level of nested par.>]
                    )?                          #    ]
                    [)]                         #    )
                )
                (.*)$                           # $4 [<rest of main title>]
            /xi)
        {
            $release->{_name_sort_} = "$1 $4";
            $release->{_disc_no_} = $2;
            $release->{_disc_max_} = $3 || 0;
        }

        # Push onto our list of releases we are actually interested in
        push @shortList, $release
            if (defined $type && (
                $type == MusicBrainz::Server::Release::RELEASE_ATTR_ALBUM ||
                $type == MusicBrainz::Server::Release::RELEASE_ATTR_EP ||
                $type == MusicBrainz::Server::Release::RELEASE_ATTR_COMPILATION ||
                $type == MusicBrainz::Server::Release::RELEASE_ATTR_SINGLE));
    }

    sort SortAlbums @shortList;
}

# Helpers:
#

sub CheckAttributes
{
    my ($a) = @_;

    for my $attr ($a->GetAttributes)
    {
        $a->{_attr_type} = $attr if ($attr >= MusicBrainz::Server::Release::RELEASE_ATTR_SECTION_TYPE_START &&
                                     $attr <= MusicBrainz::Server::Release::RELEASE_ATTR_SECTION_TYPE_END);
        $a->{_attr_status} = $attr if ($attr >= MusicBrainz::Server::Release::RELEASE_ATTR_SECTION_STATUS_START &&
                                       $attr <= MusicBrainz::Server::Release::RELEASE_ATTR_SECTION_STATUS_END);
        $a->{_attr_type} = $attr if ($attr == MusicBrainz::Server::Release::RELEASE_ATTR_NONALBUMTRACKS);
    }

    # The "actual values", used for display
    $a->{_actual_attr_type} = $a->{_attr_type};
    $a->{_actual_attr_status} = $a->{_attr_status};

    # Used for sorting
    $a->{_attr_type} = MusicBrainz::Server::Release::RELEASE_ATTR_SECTION_TYPE_END + 1
        if (not defined $a->{_attr_type});
    $a->{_attr_status} = MusicBrainz::Server::Release::RELEASE_ATTR_SECTION_STATUS_END + 1
        if (not defined $a->{_attr_status});
};

=head2 SortAlbums

Sort a list of MusicBrainz::Server::Album objects into the order they
are displayed on the artist homepage

=cut

sub SortAlbums
{
    # I edited these out of one huge "or"ed conditional as it was a bitch to debug
    my @predicates = (
        ($a->{_is_va_} <=> $b->{_is_va_}),
        ($b->{_is_nonalbum_} <=> $a->{_is_nonalbum_}),
        ($a->{_attr_type} <=> $b->{_attr_type}),
        ($a->{_firstreleasedate_} cmp $b->{_firstreleasedate_}),
        ($a->{_name_sort_} cmp $b->{_name_sort_}),
        ($a->{_disc_max_} <=> $b->{_disc_max_}),
        ($a->{_disc_no_} <=> $b->{_disc_no_}),
        ($a->{_attr_status} <=> $b->{_attr_status}),
        ($a->{trackcount} cmp $b->{trackcount}),
        ($b->{trmidcount} cmp $a->{trmidcount}),
        ($b->{puidcount} cmp $a->{puidcount}),
        ($a->GetId cmp $b->GetId)
    );
    

    for my $pred (@predicates)
    {
        return $pred if ($pred);
    }

    0;
};

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
