package MusicBrainz::Server::Controller::Artist;

use strict;
use warnings;
use parent 'Catalyst::Controller';

=head1 NAME

MusicBrainz::Server::Controller::Artist - Catalyst Controller for working with Artist entities

=head1 DESCRIPTION

=head1 METHODS

=cut


=head2 show

Shows an artist's main landing page, showing all of the releases that are attributed to them

=cut

sub show : Path Args(1)
{
    my ($self, $c, $mbid) = @_;

    use Encode qw( decode );
    use MusicBrainz::Server::Artist;
    use MusicBrainz::Server::Release;
    use MusicBrainz::Server::Validation;
    use MusicBrainz;
    use ModDefs;

    if($mbid ne "")
    {
        MusicBrainz::Server::Validation::IsGUID($mbid) or $c->error("Not a valid GUID");
    }

    # Load the artist
    my $mb = new MusicBrainz;
    $mb->Login();

    my $artist = MusicBrainz::Server::Artist->new($mb->{DBH});
    $artist->SetMBId($mbid);
    $artist->LoadFromId(1) or $c->error("Failed to load artist");

    # Load releases
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
        $release->{_is_nonalbum_} = ($type == MusicBrainz::Server::Release::RELEASE_ATTR_NONALBUMTRACKS);
        $release->{_section_key_} = ($release->{_is_va_} . " " . $type);
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
            if ($type == MusicBrainz::Server::Release::RELEASE_ATTR_ALBUM ||
                $type == MusicBrainz::Server::Release::RELEASE_ATTR_EP ||
                $type == MusicBrainz::Server::Release::RELEASE_ATTR_COMPILATION ||
                $type == MusicBrainz::Server::Release::RELEASE_ATTR_SINGLE);
    }

    if(scalar @shortList)
    {
        @releases = @shortList;
        @releases = sort SortAlbums @releases;
    }
    else
    {
        $c->error("No releases to show");
    }

    # Create data structures for the template
    #
    # Artist:
    $c->stash->{artist} = {
        name => $artist->GetName,
        type => MusicBrainz::Server::Artist::GetTypeName($artist->GetType),
        datespan => {
            start => $artist->GetBeginDate,
            end => $artist->GetEndDate
        },
        quality => ModDefs::GetQualityText($artist->GetQuality),
        resolution => $artist->GetResolution,
    };

    # Releases, sorted into "release groups":
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

        my $language = {};
        $language->{script} = defined $release->GetScript ? $release->GetScript->GetName : "";
        $language->{language} = defined $release->GetLanguage ? $release->GetLanguage->GetName : "";
        $language->{shortLanguage} = defined $release->GetLanguage ? $release->GetLanguage->GetISOCode3T : "";

        my $rel = {
            title => $release->GetName,
            id => $release->GetMBId,
            trackCount => $release->GetTrackCount,
            discIds => $release->GetDiscidCount,
            puids => $release->GetPuidCount,
            quality => ModDefs::GetQualityText($release->GetQuality),
            language => $language,
#           releaseDate => ,
        };

        $rel->{attributes} = [];
        my $attributes = $release->GetAttributes;

        for my $attr ($attributes)
        {
            push @{$rel->{attributes}}, $release->GetAttributeName($attr);
        }

        push @{$currentGroup->{releases}}, $rel;
    }

    # Decide how to display the data
    if ($c->request->params->{full})
    {
        $c->stash->{template} = 'artist/full.tt';
    }
    else
    {
        $c->stash->{template} = 'artist/compact.tt';
    }
}

sub CheckAttributes
{
    use MusicBrainz::Server::Release;

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

Sort a list of MusicBrainz::Server::Album objects into the order they are displayed on the
artist homepage

=cut

sub SortAlbums
{
    use MusicBrainz::Server::Release;

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

=head1 AUTHOR

Oliver Charles <oliver.g.charles@googlemail.com>

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
