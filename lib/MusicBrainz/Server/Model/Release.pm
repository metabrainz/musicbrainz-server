package MusicBrainz::Server::Model::Release;

use strict;
use warnings;

use base 'MusicBrainz::Server::Model::Base';

use Carp;
use Encode 'decode';
use MusicBrainz::Server::Adapter 'LoadEntity';
use MusicBrainz::Server::Country;
use MusicBrainz::Server::Facade::ReleaseEvent;
use MusicBrainz::Server::Link;
use MusicBrainz::Server::Release;
use MusicBrainz::Server::Validation;

sub load_events
{
    my ($self, $release) = @_;

    my @events = $release->get_release->ReleaseEvents(1);

    my $country_obj = MusicBrainz::Server::Country->new($self->dbh);
    my %county_names;

    return [ map {
        my $rel = MusicBrainz::Server::Facade::ReleaseEvent->new_from_event($_);

        my $cid = $rel->country;
        $rel->country(
            $county_names{$cid} ||= do {
                my $country = $country_obj->newFromId($cid);
                $country ? $country->name : "?";
            }
        );

        $rel;
    } @events ];

}

sub load
{
    my ($self, $id) = @_;

    my $release = MusicBrainz::Server::Release->new($self->dbh);
    LoadEntity($release, $id);

    return MusicBrainz::Server::Facade::Release->new_from_release($release);
}

sub load_for_label
{
    my ($self, $label) = @_;

    my @releases = $label->select_releases;

    for (@releases) { _build_sort_keys($_); }
    
    return [
        map {
            my $export = MusicBrainz::Server::Facade::Release->new_from_release($_);

            $export->{artist} = MusicBrainz::Server::Artist->new($label->{DBH});
	    $export->{artist}->name($_->{artistname});
	    $export->{artist}->mbid($_->artist);

            $export->{catalog_number} = $_->{catno};

            $export;
        }
        sort _sort_albums @releases 
    ];
}

sub load_for_artist
{
    my ($self, $artist, $show_all) = @_;

    my @releases = $artist->select_releases(!$show_all, 1);

    if (!$show_all)
    {
        my $onlyHasVAReleases = (scalar @releases) == 0;

        my @shortList;
        for my $release (@releases)
        {
            my ($type, $status) = $release->release_type_and_status;

            # Push onto our list of releases we are actually interested in
            push @shortList, $release
                if (defined $type && (
                    $type == MusicBrainz::Server::Release::RELEASE_ATTR_ALBUM ||
                    $type == MusicBrainz::Server::Release::RELEASE_ATTR_EP ||
                    $type == MusicBrainz::Server::Release::RELEASE_ATTR_COMPILATION ||
                    $type == MusicBrainz::Server::Release::RELEASE_ATTR_SINGLE));
        }

        @releases = scalar @shortList ? @shortList : @releases;

        if (scalar @releases == 0)
        {
            @releases = $artist->select_releases(0, 1, $onlyHasVAReleases);
        }
    }

    for my $release (@releases) { _build_sort_keys($release) }

    return [
        map { MusicBrainz::Server::Facade::Release->new_from_release($_) }
            sort _sort_albums @releases 
    ];
}

sub find_linked_albums
{
    my ($self, $entity) = @_;

    my $link         = new MusicBrainz::Server::Link($self->dbh);
    my @raw_releases = @{$link->FindLinkedAlbums($entity->entity_type, $entity->id)};

    for my $release (@raw_releases) { _build_sort_keys($release); }
    
    @raw_releases = sort {
        ($a->{linkphrase}  cmp $b->{linkphrase}) or
        ($a->{_sort_date_} cmp $b->{_sort_date_}) or
        ($a->{_name_sort_} cmp $b->{_name_sort_}) or
        ($a->{_disc_no_}   <=> $b->{_disc_no_})
    } @raw_releases;

    return [ map
    {
        my $stash_release = MusicBrainz::Server::Facade::Release->new({
            name         => $_->{name},
            id           => $_->{id},
            year         => substr($_->{date}, 0, 4) || '?',
            link_phrase  => $_->{linkphrase}, 
        });

        $stash_release->{artist} = {
            name => $_->{artist_name},
            id => $_->{artist_id},
        };

        $stash_release;
    } @raw_releases ];
}

sub _build_sort_keys
{
    my $release = shift;

    if(ref $release ne 'HASH')
    {
        my ($type, $status) = $release->release_type_and_status;

        $release->SetMultipleTrackArtists($release->artist != $release->id() ? 1 : 0);
        $release->{_firstreleasedate_} = ($release->GetFirstReleaseDate || "9999-99-99");
        $release->{_is_va_}       = ($release->artist == &ModDefs::VARTIST_ID) or
                                    ($release->artist != $release->id());
        $release->{_is_nonalbum_} = $type && $type == MusicBrainz::Server::Release::RELEASE_ATTR_NONALBUMTRACKS;
        $release->{_section_key_} = (defined $type ? $release->{_is_va_} . " " . $type : $release->{_is_va});
        $release->{_name_sort_}   = lc decode "utf-8", $release->name;
        $release->{_attr_type}    = $type;
        $release->{_attr_status}  = $status;

        for my $attr ($release->attributes)
        {
            $release->{_attr_type}   = $attr if ($attr >= MusicBrainz::Server::Release::RELEASE_ATTR_SECTION_TYPE_START &&
                                                 $attr <= MusicBrainz::Server::Release::RELEASE_ATTR_SECTION_TYPE_END);
            $release->{_attr_status} = $attr if ($attr >= MusicBrainz::Server::Release::RELEASE_ATTR_SECTION_STATUS_START &&
                                                 $attr <= MusicBrainz::Server::Release::RELEASE_ATTR_SECTION_STATUS_END);
            $release->{_attr_type}   = $attr if ($attr == MusicBrainz::Server::Release::RELEASE_ATTR_NONALBUMTRACKS);
        }

        $release->{_attr_type} = MusicBrainz::Server::Release::RELEASE_ATTR_SECTION_TYPE_END + 1
            unless defined $release->{_attr_type};

        $release->{_attr_status} = MusicBrainz::Server::Release::RELEASE_ATTR_SECTION_STATUS_END + 1
            unless defined $release->{_attr_status};
    }
    else
    {
        $release->{date}        = $release->{begindate};
        $release->{date}        =~ s/\s+//;
        $release->{date}        = $release->{firstreleasedate} if !$release->{date};
        $release->{_sort_date_} = $release->{date} || "9999-99-99";
        $release->{_name_sort_} = lc decode "utf-8", $release->{name};
    }

    $release->{_disc_max_}    = 0;
    $release->{_disc_no_}     = 0;

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
        $release->{_disc_no_}   = $2;
        $release->{_disc_max_}  = $3 || 0;
    }
}

=head2 _sort_albums

Sort a list of MusicBrainz::Server::Album objects into the order they
are displayed on the artist homepage

=cut

sub _sort_albums
{
    # I edited these out of one huge "or"ed conditional as it was a bitch to debug
    my @predicates = (
        ($a->{_is_va_}            <=> $b->{_is_va_}),
        ($b->{_is_nonalbum_}      <=> $a->{_is_nonalbum_}),
        ($a->{_attr_type}         <=> $b->{_attr_type}),
        ($a->{_firstreleasedate_} cmp $b->{_firstreleasedate_}),
        ($a->{_name_sort_}        cmp $b->{_name_sort_}),
        ($a->{_disc_max_}         <=> $b->{_disc_max_}),
        ($a->{_disc_no_}          <=> $b->{_disc_no_}),
        ($a->{_attr_status}       <=> $b->{_attr_status}),
        ($a->{trackcount}         cmp $b->{trackcount}),
        ($b->{trmidcount}         cmp $a->{trmidcount}),
        ($b->{puidcount}          cmp $a->{puidcount}),
        ($a->id                cmp $b->id),
    );
    
    for (@predicates) { return $_ if $_; }

    return 0;
}

1;
