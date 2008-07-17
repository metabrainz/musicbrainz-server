package MusicBrainz::Server::Adapter::Relations;

use strict;
use warnings;

use MusicBrainz::Server::CoverArt;

=head1 NAME

MusicBrainz::Server::Adapter::Relations - Adapt data from
L<MusicBrainz::Server::Link> to a form suitable for use with Template
Toolkit.

=head1 DESCRIPTION

This adapter allows users to easily manipulate advanced relations
(ARs) and produce data that can be easily displayed by Template Toolkit
components

=head1 METHODS

=cut

# NormaliseLinkDirections {{{

=head2 NormaliseLinkDirections \@links, $id, $type

Takes an array ref of L<MusicBrainz::Server::Link>s (C<\@links>) and
re-arranges them such that link0 is always the same entity (the entity
with the same id as C<$id>). $type should be either 'artist', 'album',
'label' or 'track'.

=cut

sub NormaliseLinkDirections
{
    my ($arLinks, $id, $type) = @_;

    foreach my $link (@$arLinks)
    {
        if($link->{link0_id} != $id || $link->{link0_type} ne $type)
        {
            @$link{qw(
                link0_type			link1_type
                link0_id			link1_id
                link0_name			link1_name
                link0_sortname		link1_sortname
                link0_resolution	link1_resolution
                link0_mbid          link1_mbid
                link_phrase			rlink_phrase
			)} = @$link{qw(
                link1_type			link0_type
                link1_id			link0_id
                link1_name			link0_name
                link1_sortname		link0_sortname
                link1_resolution	link0_resolution
                link1_mbid          link0_mbid
                rlink_phrase		link_phrase
			)};
        }
    }

    return $arLinks;
}
# }}}
# SortLinks {{{

=head2 SortLinks \@links

Sort a list of L<MusicBrainz::Server::Link>s (given by the array reference
C<\@links>) into order by the type of AR, followed by the date period
the AR occured in, and finally the name of the link.

=cut

sub SortLinks
{
    my $links = shift;

    sort
    {
        my $c = $a->{link_phrase} cmp $b->{link_phrase};
        return $c if ($c);
        
        if (defined $a->{enddate} || defined $b->{enddate})
        {
            $c = $a->{enddate} cmp $b->{enddate};
            return $c if ($c);
        }

        if (defined $a->{begindate} || $b->{begindate})
        {
            $c = $a->{begindate} cmp $b->{begindate};
            return $c if ($c);
        }
		
        return $a->{link1_name} cmp $b->{link1_name};
    } @$links;
}
# }}}
# ExportLink {{{

=head2 ExportLink $link, [$index]

Export either end of this link as stash data that can be used with
entity-link.tt

C<$link >is a hash reference to a AR link (which can be created with
L<MusicBrainz::Server::Link::FindLinkedEntities>, along with other
functions in this module). C<$index> must be either link0 or link1 and
represents which end of the link to export. If not passed as a parameter,
this will default to "link1" (as this is usually the destination of
the AR).

=cut

sub ExportLink
{
    my ($link, $linkType) = @_;

    croak ("No link passed")
        unless defined $link and ref $link eq 'HASH';

    $linkType ||= "link1";

    my $name = $link->{"${linkType}_name"};
    my $url = $name;

    if($link->{link_name} eq "wikipedia")
    {
        $name =~ s/^http:\/\/(\w{2,})\.wikipedia\.org\/wiki\/(.*)$/$1: $2/o;
        $name =~ tr/_/ /;

        # We have to decode the URL now to display in text form
        $name =~ s/\%([\dA-Fa-f]{2})/pack('C', hex($1))/oeg;

        use Encode;
        my $decoded_name = $name;
        eval { Encode::decode_utf8($decoded_name, Encode::FB_CROAK); };
        $name = $decoded_name unless $@;
    }

    return {
        name => $name,
        url => $url,
        link_type => $link->{"${linkType}_type"},
        mbid => $link->{"${linkType}_mbid"},
        resolution => $link->{"${linkType}_resolution"},
    };
}
# }}}
# ExportLinks {{{

=head2 ExportLinks \@links

Exports an array of AR links to an array reference that can be stored in the stash,
and displayed using the C<components/relations.tt> component.

C<\@links> is an array reference to a list of links to export.

=cut
sub ExportLinks
{
    my $links = shift;
    
    my @stashData;
    my $currentGroup = undef;
    for my $link (@$links)
    {
        if(not defined $currentGroup or $currentGroup->{connector} ne $link->{link_phrase})
        {
            $currentGroup = {
                connector => $link->{link_phrase},
                type => $link->{link_type},
                entities => []
            };
            push @stashData, $currentGroup;
        }

        # Export enough information to link to *any* entity.
        my $stashLink = ExportLink($link, "link1");

        # Special treatment for certain urls {{{
        use Switch;
        switch($link->{link_name})
        {
            case("amazon asin") {
                my ($asin) = MusicBrainz::Server::CoverArt->ParseAmazonURL($link->{link1_name});
                $stashLink->{name} = $asin;
            }

            case("purchase for mail-order") { next; }
            case("purchase for download") { next; }
            case("download for free") { next; }
            case("creative commons licensed download") { next; }
            case("cover art link") {
                my ($name, $coverurl, $url) = MusicBrainz::Server::CoverArt->ParseCoverArtURL($link->{link1_name});

                $stashLink->{name} = $name
                    if $name;

                $stashLink->{url} = $url
                    if $url;
            }
        }
        # }}}

        push @{$currentGroup->{entities}}, $stashLink;
    }

    return \@stashData;
}
# }}}

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
