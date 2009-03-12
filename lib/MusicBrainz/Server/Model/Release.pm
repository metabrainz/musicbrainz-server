package MusicBrainz::Server::Model::Release;

use strict;
use warnings;

use base 'MusicBrainz::Server::Model';

use Carp;
use Encode 'decode';
use MusicBrainz::Server::Adapter 'LoadEntity';
use MusicBrainz::Server::Country;
use MusicBrainz::Server::Link;
use MusicBrainz::Server::Release;
use MusicBrainz::Server::Validation;

sub change_quality
{
    my ($self, $release, $new_quality, $edit_note) = @_;

    $self->context->model('Moderation')->insert(
        $edit_note,

        type => ModDefs::MOD_CHANGE_RELEASE_QUALITY,

        releases => [ $release ],
        quality  => $new_quality,
    );
}

sub edit_title
{
    my ($self, $release, $new_title, $edit_note) = @_;

    $self->context->model('Moderation')->insert(
        $edit_note,

        type => ModDefs::MOD_EDIT_RELEASE_NAME,

        album   => $release,
        newname => $new_title,
    );
}

sub change_artist
{
    my $self = shift;
    my ($release, $old_artist, $new_artist, $edit_note, %opts) = @_;

    $self->context->model('Moderation')->insert(
        $edit_note,

        type => ModDefs::MOD_MOVE_RELEASE,

        album          => $release,
        oldartist      => $old_artist,
        artistname     => $new_artist->name,
        artistsortname => $new_artist->sort_name,
        artistid       => $new_artist->id,
        movetracks     => $opts{change_track_artist} || 0,
    );
}

sub remove
{
    my ($self, $release, $edit_note) = @_;

    $self->context->model('Moderation')->insert(
        $edit_note,
        
        type => ModDefs::MOD_REMOVE_RELEASE,

        album => $release
    );
}

sub update_language
{
    my ($self, $release, $language, $script, $edit_note) = @_;

    if ($release->language->id != $language ||
        $release->script->id   != $script)
    {
        $self->context->model('Moderation')->insert(
            $edit_note,
        
            type => ModDefs::MOD_EDIT_RELEASE_LANGUAGE,
            
            albums   => [ $release ],
            language => $language,
            script   => $script,
        );
    }
}

sub update_attributes
{
    my ($self, $release, $release_type, $release_status, $edit_note) = @_;

    if ($release->release_type   != $release_type ||
        $release->release_status != $release_status)
    {
        $self->context->model('Moderation')->insert(
            $edit_note,
            
            type      => ModDefs::MOD_EDIT_RELEASE_ATTRS,

            albums      => [ $release ],
            attr_type   => $release_type,
            attr_status => $release_status,
        );
    }
}

sub convert
{
    my ($self, $release, $new_artist, $edit_note) = @_;

    $self->context->model('Moderation')->insert(
        $edit_note,

        type => ModDefs::MOD_MAC_TO_SAC,

        album          => $release,
        artistsortname => $new_artist->sort_name,
        artistname     => $new_artist->name,
        artistid       => $new_artist->id,
        movetracks     => 1,
    );
}

sub find_similar_releases
{
    my ($self, $artist, $release_title, $track_count) = @_;

    $artist->dbh($self->dbh);
    my @possible = $artist->has_release($release_title, .8);
    my @similar  = grep {
        $_->LoadFromId;
        $_->track_count == $track_count;
    } @possible;

    return \@similar;
  }

sub load_events
{
    my ($self, $release) = @_;

    my @events = $release->ReleaseEvents(1);

    my $country_obj = MusicBrainz::Server::Country->new($self->dbh);
    my %county_names;

    return [ map {
        my $cid = $_->country;
        $_->country(
            $county_names{$cid} ||= do {
                my $country = $country_obj->newFromId($cid);
                $country ? $country->name : "?";
            }
        );

        $_;
    } @events ];

}

sub load
{
    my ($self, $id) = @_;

    my $release = MusicBrainz::Server::Release->new($self->dbh);
    LoadEntity($release, $id);

    return $release;
}

sub load_for_label
{
    my ($self, $label) = @_;

    my @releases = $label->releases;

    for (@releases) { _build_sort_keys($_); }
    
    return [
        map {
            my $export = $_;

            my $artist = MusicBrainz::Server::Artist->new($label->{dbh});
	    $artist->name($_->{artistname});
	    $artist->mbid($_->{artist});
            $export->artist($artist);

            $export->{catalog_number} = $_->{catno};

            $export;
        }
        sort _sort_albums @releases 
    ];
}

sub load_for_artist
{
    my ($self, $artist, $show_all) = @_;

    my @releases = $artist->releases(!$show_all, 1);

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
            @releases = $artist->releases(0, 1, $onlyHasVAReleases);
        }
    }

    for my $release (@releases) { _build_sort_keys($release) }

    return [ sort _sort_albums @releases ];
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
        my $stash_release = MusicBrainz::Server::Release->new(undef);
        $stash_release->name($_->{name});
        $stash_release->id($_->{id});

        my $stash_artist = MusicBrainz::Server::Artist->new;
        $stash_artist->id($_->{artist});
        $stash_artist->name($_->{artist_name});

        {
            release => $stash_release,
            year    => (substr $_->{date}, 0, 4) || '',
            artist  => $stash_artist,
            link    => $_->{linkphrase},
        };
    } @raw_releases ];
}

sub nat_release
{
    my ($self, $artist) = @_;

    my $rel = MusicBrainz::Server::Release->new($self->dbh);
    my @nat = $rel->FindNonAlbum($artist->id);

    return $nat[0];
}

sub get_browse_selection
{
    my ($self, $index, $offset, $artist) = @_;

    my $ar = MusicBrainz::Server::Release->new($self->dbh);
    my ($count, $rels) = $ar->browse_selection($index, $offset, $artist);

    return ($count, $rels);
}

sub _build_sort_keys
{
    my $release = shift;

    if(ref $release ne 'HASH')
    {
        my ($type, $status) = $release->release_type_and_status;

        $release->SetMultipleTrackArtists($release->artist != $release->id() ? 1 : 0);
        $release->{_is_va_}       = ($release->artist == &ModDefs::VARTIST_ID);
        $release->{_is_nonalbum_} = defined $type && $type == MusicBrainz::Server::Release::RELEASE_ATTR_NONALBUMTRACKS;
        $release->{_section_key_} = (defined $type ? $release->{_is_va_} . " " . $type : $release->{_is_va});
        $release->{_name_sort_}   = lc decode "utf-8", $release->name;
        $release->{_attr_type}    = $type   || MusicBrainz::Server::Release::RELEASE_ATTR_SECTION_TYPE_END + 1;
        $release->{_attr_status}  = $status || MusicBrainz::Server::Release::RELEASE_ATTR_SECTION_STATUS_END + 1;
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
        ($a->first_release_date   cmp $b->first_release_date),
        ($a->{_name_sort_}        cmp $b->{_name_sort_}),
        ($a->{_disc_max_}         <=> $b->{_disc_max_}),
        ($a->{_disc_no_}          <=> $b->{_disc_no_}),
        ($a->{_attr_status}       <=> $b->{_attr_status}),
        ($a->track_count          cmp $b->track_count),
        ($b->puid_count           cmp $a->puid_count),
        ($a->id                   cmp $b->id),
    );
    
    for (@predicates) { return $_ if $_; }

    return 0;
}

1;
