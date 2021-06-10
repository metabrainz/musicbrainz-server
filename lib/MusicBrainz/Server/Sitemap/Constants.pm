package MusicBrainz::Server::Sitemap::Constants;

use base 'Exporter';
use MusicBrainz::Server::Constants qw(
    %ENTITIES
    @RELATABLE_ENTITIES
    $MAX_INITIAL_MEDIUMS
    $MAX_INITIAL_TRACKS
);
use MusicBrainz::Server::Data::Relationship;
use Readonly;

our @EXPORT_OK = qw(
    $MAX_SITEMAP_SIZE
    %SITEMAP_SUFFIX_INFO
);

Readonly our $MAX_SITEMAP_SIZE          => 50000.0;
Readonly our $DEFAULT_PAGE_PRIORITY     => 0.5;
Readonly our $EMPTY_PAGE_PRIORITY       => 0.1;
Readonly our $SECONDARY_PAGE_PRIORITY   => 0.3;

sub priority_by_count {
    my ($count_prop) = @_;
    sub {
        my (%opts) = @_;
        return $SECONDARY_PAGE_PRIORITY if $opts{$count_prop} > 0;
        return $EMPTY_PAGE_PRIORITY;
    };
}

# %SITEMAP_SUFFIX_INFO
# Stores information about URL suffixes and their associated SQL and priorities.

our Readonly %SITEMAP_SUFFIX_INFO = map {
    my $entity_type = $_;
    my $entity_properties = $ENTITIES{$entity_type};

    my $suffix_info = {
        base => {
            jsonld_markup => ($entity_properties->{sitemaps_lastmod_table} ? 1 : 0),
        }
    };

    if ($entity_type eq 'artist') {
        $suffix_info->{base}{extra_sql} = {
            columns => "(SELECT count(rg) FROM tmp_sitemaps_artist_direct_rgs tsadr WHERE tsadr.artist = artist.id AND is_official) official_rg_count",
        };
        $suffix_info->{base}{paginated} = "official_rg_count";
        $suffix_info->{all} = {
            extra_sql => {columns => "(SELECT count(rg) FROM tmp_sitemaps_artist_direct_rgs tsadr WHERE tsadr.artist = artist.id) all_rg_count"},
            paginated => "all_rg_count",
            suffix => 'all=1',
            filename_suffix => 'all',
            suffix_delimiter => '?'
        };
        $suffix_info->{va} = {
            extra_sql => {columns => "(SELECT count(rg) FROM tmp_sitemaps_artist_va_rgs tsavr WHERE tsavr.artist = artist.id AND is_official) official_va_rg_count"},
            paginated => "official_va_rg_count",
            suffix => 'va=1',
            filename_suffix => 'va',
            suffix_delimiter => '?',
            priority => priority_by_count('official_va_rg_count'),
        };
        $suffix_info->{all_va} = {
            extra_sql => {columns => "(SELECT count(rg) FROM tmp_sitemaps_artist_va_rgs tsavr WHERE tsavr.artist = artist.id) all_va_rg_count"},
            paginated => "all_va_rg_count",
            suffix => 'va=1&all=1',
            filename_suffix => 'va-all',
            suffix_delimiter => '?',
            priority => priority_by_count('all_va_rg_count'),
        };
        $suffix_info->{releases} = {
            extra_sql => {columns => "(SELECT count(release) FROM tmp_sitemaps_artist_direct_releases tsadre WHERE tsadre.artist = artist.id) direct_release_count"},
            paginated => "direct_release_count",
            suffix => 'releases',
            priority => priority_by_count('direct_release_count'),
        };
        $suffix_info->{releases_va} = {
            extra_sql => {columns => "(SELECT count(release) FROM tmp_sitemaps_artist_va_releases tsavre WHERE tsavre.artist = artist.id) va_release_count"},
            paginated => "va_release_count",
            suffix => 'releases?va=1',
            filename_suffix => 'releases-va',
            priority => priority_by_count('va_release_count'),
        };
        $suffix_info->{recordings} = {
            extra_sql => {columns => "(SELECT count(recording) FROM tmp_sitemaps_artist_recordings tsar WHERE tsar.artist = artist.id) recording_count"},
            paginated => "recording_count",
            suffix => 'recordings',
            priority => priority_by_count('recording_count'),
            jsonld_markup => 1,
        };
        $suffix_info->{recordings_video} = {
            extra_sql => {columns => "(SELECT count(recording) FROM tmp_sitemaps_artist_recordings tsar WHERE tsar.artist = artist.id AND is_video) video_count"},
            paginated => "video_count",
            suffix => 'recordings?video=1',
            filename_suffix => 'recordings-video',
            priority => priority_by_count('video_count'),
            jsonld_markup => 1,
        };
        $suffix_info->{recordings_standalone} = {
            extra_sql => {columns => "(SELECT count(recording) FROM tmp_sitemaps_artist_recordings tsar WHERE tsar.artist = artist.id AND is_standalone) standalone_count"},
            paginated => "standalone_count",
            suffix => 'recordings?standalone=1',
            filename_suffix => 'recordings-standalone',
            priority => priority_by_count('standalone_count'),
            jsonld_markup => 1,
        };
        $suffix_info->{works} = {
            extra_sql => {columns => "(SELECT count(work) FROM tmp_sitemaps_artist_works tsaw WHERE tsaw.artist = artist.id) work_count"},
            paginated => "work_count",
            suffix => 'works',
            priority => priority_by_count('work_count'),
        };
        $suffix_info->{events} = {
            # NOTE: no temporary table needed, since this can really probably just hit l_artist_event directly, no need to join or union. Can revisit if performance is an issue.
            extra_sql => {columns => "(SELECT count(DISTINCT entity1) FROM l_artist_event WHERE entity0 = artist.id) event_count"},
            paginated => "event_count",
            suffix => 'events',
            priority => priority_by_count('event_count'),
        };
    }

    if ($entity_type eq 'instrument') {
        $suffix_info->{recordings} = {
            extra_sql => {columns => "(SELECT count(recording) FROM tmp_sitemaps_instrument_recordings tsir where tsir.instrument = instrument.id) recording_count"},
            paginated => "recording_count",
            suffix => 'recordings',
            priority => priority_by_count('recording_count'),
        };
        $suffix_info->{releases} = {
            extra_sql => {columns => "(SELECT count(release) FROM tmp_sitemaps_instrument_releases tsir where tsir.instrument = instrument.id) release_count"},
            paginated => "release_count",
            suffix => 'releases',
            priority => priority_by_count('release_count'),
        };
    }

    if ($entity_type eq 'label') {
        $suffix_info->{base}{extra_sql} = {
            columns => "(SELECT count(DISTINCT release) FROM release_label WHERE release_label.label = label.id) release_count"
        };
        $suffix_info->{base}{paginated} = "release_count";
    }

    if ($entity_type eq 'place') {
        $suffix_info->{events} = {
            # NOTE: no temporary table needed, since this can really probably just hit l_event_place directly, no need to join or union. Can revisit if performance is an issue.
            extra_sql => {columns => "(SELECT count(DISTINCT entity0) FROM l_event_place WHERE entity1 = place.id) event_count"},
            paginated => "event_count",
            suffix => 'events',
            priority => priority_by_count('event_count'),
        };
    }

    if ($entity_type eq 'release') {
        $suffix_info->{'cover-art'} = {
            suffix => 'cover-art',
            priority => sub {
                my (%opts) = @_;
                return $SECONDARY_PAGE_PRIORITY if ($opts{cover_art_presence} // '') eq 'present';
                return $EMPTY_PAGE_PRIORITY;
            },
            extra_sql => {join => 'release_meta ON release.id = release_meta.id',
                          columns => 'cover_art_presence'},
            jsonld_markup => 1,
        };

        $suffix_info->{'disc'} = {
            extra_sql => {
                columns => '(SELECT array_agg(array[position, track_count] ORDER BY position) FROM medium WHERE medium.release = release.id) AS medium_track_counts',
            },
            filename_suffix => 'disc',
            url_constructor => sub {
                my ($self, $c, $entity_type, $ids, %opts) = @_;

                my @paginated_urls;
                for my $id_info (@$ids) {
                    my $id = $id_info->{main_id};
                    my $url_base = $self->build_page_url($entity_type, $id);
                    my $medium_track_counts = $id_info->{medium_track_counts};
                    my $medium_counter = 0;
                    my $track_counter = 0;

                    # Please keep this logic in sync with
                    # Controller::Release::show such that we're only
                    # paging discs that aren't shown on the initial page.
                    for my $medium (@$medium_track_counts) {
                        my ($position, $track_count) = @$medium;

                        $medium_counter += 1;
                        $track_counter += $track_count;

                        if (
                            $medium_counter > $MAX_INITIAL_MEDIUMS ||
                            $track_counter > $MAX_INITIAL_TRACKS
                        ) {
                            push @paginated_urls, $self->create_url_opts(
                                $c,
                                'release',
                                "$url_base/disc/$position",
                                \%opts,
                                $id_info,
                            );
                        }
                    }
                }
                return {base => [], paginated => \@paginated_urls};
            },
        }
    }

    if ($entity_type eq 'release_group') {
        $suffix_info->{base}{extra_sql} = {
            columns => "(SELECT count(DISTINCT release.id) FROM release WHERE release.release_group = release_group.id) release_count"
        };
        $suffix_info->{base}{paginated} = "release_count";
    }

    if ($entity_type eq 'work') {
        $suffix_info->{recordings} = {
            extra_sql => {columns => "(SELECT recordings_count FROM tmp_sitemaps_work_recordings_count WHERE work = work.id) recordings_count"},
            paginated => "recordings_count",
            suffix => 'direction=2&link_type_id=278',
            suffix_delimiter => '?',
            filename_suffix => 'recordings',
            priority => priority_by_count('recordings_count'),
        };
    }

    if ($entity_properties->{aliases}) {
        $suffix_info->{aliases} = {
            suffix => 'aliases',
            priority => sub {
                my (%opts) = @_;
                return $SECONDARY_PAGE_PRIORITY if $opts{has_aliases};
                return $EMPTY_PAGE_PRIORITY;
            },
            extra_sql => {columns => "EXISTS (SELECT TRUE FROM ${entity_type}_alias a WHERE a.$entity_type = ${entity_type}.id) AS has_aliases"},
            jsonld_markup => ($entity_properties->{sitemaps_lastmod_table} ? 1 : 0),
        };
    }

    if ($entity_properties->{mbid}) {
        if ($entity_properties->{mbid}{indexable}) {
            # These pages are nearly worthless, so can really just be ignored.
            $suffix_info->{details} = {
                suffix => 'details',
                priority => $EMPTY_PAGE_PRIORITY,
            };
        }

        if ($entity_properties->{mbid}{relatable} eq 'dedicated') {
            my @tables = MusicBrainz::Server::Data::Relationship->generate_table_list(
                $entity_type,
                grep { $_ ne 'url' } @RELATABLE_ENTITIES
            );

            my $select = join(' UNION ALL ', map {
                my ($table, $column) = @{$_};

                "SELECT TRUE FROM $table WHERE $column = $entity_type.id"
            } @tables);

            $suffix_info->{relationships} = {
                suffix => 'relationships',
                priority => sub {
                    my %opts = @_;
                    return $SECONDARY_PAGE_PRIORITY if $opts{has_non_url_rels};
                    return $EMPTY_PAGE_PRIORITY;
                },
                extra_sql => {columns => "EXISTS ($select) AS has_non_url_rels"},
                jsonld_markup => ($entity_type eq 'artist' ? 1 : 0),
            };
        }
    }

    if ($entity_properties->{custom_tabs}) {
        my %tabs = map { $_ => 1 } @{ $entity_properties->{custom_tabs} };

        for my $tab (qw( events releases recordings works performances map discids )) {
            # XXX: discids, performances should have extra sql for priority
            # XXX: pagination, priority based on counts for paginated things
            if ($tabs{$tab} && !$suffix_info->{$tab}) {
                $suffix_info->{$tab} = {
                    suffix => $tab,
                    priority => sub { return $SECONDARY_PAGE_PRIORITY }
                };
            }
        }
    }

    ($entity_type => $suffix_info);
} keys %ENTITIES;

1;
