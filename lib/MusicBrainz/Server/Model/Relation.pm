package MusicBrainz::Server::Model::Relation;

use strict;
use warnings;

use base 'MusicBrainz::Server::Model::Base';

use MusicBrainz::Server::Facade::Link;
use MusicBrainz::Server::Facade::Release;
use MusicBrainz::Server::Link;

sub load_relations
{
    my ($self, $entity, %opts) = @_;

    my $type = $entity->entity_type;
    if ($type eq 'release') { $type = 'album' }

    my $link  = MusicBrainz::Server::Link->new($self->{_dbh});
    my @links = $link->FindLinkedEntities($entity->id, $type, %opts);

    # Make sure every link is in the same direction
    foreach my $link (@links)
    {
        if($link->{link0_id} != $entity->id || $link->{link0_type} ne $type)
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

    @links = sort {
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
    } @links;

    my @grouped_relations;
    my $current_group = undef;
    for my $link (@links)
    {
        if (not defined $current_group or
            $current_group->{connector}  ne $link->{link_phrase} or
            $current_group->{start_date} ne $link->{begindate}   or
            $current_group->{end_date}   ne $link->{enddate})
        {
            $link->{begindate} =~ s/\s+$//g;
            $link->{enddate  } =~ s/\s+$//g;

            $current_group = {
                connector  => $link->{link_phrase},
                type       => $link->{link_type},
                start_date => $link->{begindate},
                end_date   => $link->{enddate},
                entities   => [],
            };
            push @grouped_relations, $current_group;
        }

        push @{$current_group->{entities}}, _export_link($link, "link1", $entity);
    }

    return \@grouped_relations;
}

=head2 INTERNAL METHODS

=head2 _export_link $link, [$index]

Export either end of this link as stash data that can be used with
entity-link.tt

C<$link >is a hash reference to a AR link (which can be created with
L<MusicBrainz::Server::Link::FindLinkedEntities>, along with other
functions in this module). C<$index> must be either link0 or link1 and
represents which end of the link to export. If not passed as a parameter,
this will default to "link1" (as this is usually the destination of
the AR).

=cut

sub _export_link
{
    my ($link, $linkType, $entity) = @_;

    croak ("No link passed")
        unless defined $link and ref $link eq 'HASH';

    $linkType ||= "link1";

    my $name = $link->{"${linkType}_name"};
    my $url  = $name;

    # Special treatment for certain urls:
    if ($link->{"${linkType}_type"} eq 'url')
    {
        use Switch;
        switch($link->{link_name})
        {
            case("amazon asin")
            {
                my ($asin) =
                MusicBrainz::Server::CoverArt->ParseAmazonURL($link->{link1_name}, $entity->get_release);
                $name = $asin;
            }

            case("purchase for mail-order") { next; }
            case("purchase for download") { next; }
            case("download for free") { next; }
            case("creative commons licensed download") { next; }

            case("cover art link")
            {
                my ($new_name, $coverurl, $new_url) =
                MusicBrainz::Server::CoverArt->ParseCoverArtURL($link->{link1_name}, $entity->get_release);
                
                $name = $new_name
                    if $new_name;

                $url = $new_url
                    if $new_url;
            }

            case("wikipedia")
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
        }
    }

    # Old terminology...
    my $type = $link->{"${linkType}_type"};
    $type = 'release' if $type eq 'album';

    return MusicBrainz::Server::Facade::Link->new({
        name        => $name,
        entity_type => $type,
        mbid        => $link->{"${linkType}_mbid"},
        url         => $url,
        resolution  => $link->{"${linkType}_resolution"},
    });
}

1;
