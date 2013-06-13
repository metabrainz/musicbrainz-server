package MusicBrainz::Server::WebService::XMLSerializer;

use Moose;
use Scalar::Util 'reftype';
use Readonly;
use List::UtilsBy qw( nsort_by sort_by );
use MusicBrainz::Server::Constants qw( :quality );
use MusicBrainz::Server::WebService::Escape qw( xml_escape );
use MusicBrainz::Server::Entity::Relationship;
use MusicBrainz::Server::Validation;
use MusicBrainz::XML;
use aliased 'MusicBrainz::Server::WebService::WebServiceInc';
use aliased 'MusicBrainz::Server::WebService::WebServiceStash';

sub mime_type { 'application/xml' }
sub fmt { 'xml' }

Readonly my $xml_decl_begin => '<?xml version="1.0" encoding="UTF-8"?><metadata xmlns="http://musicbrainz.org/ns/mmd-2.0#">';
Readonly my $xml_decl_end => '</metadata>';

our $in_relation_node = 0;

sub _list_attributes
{
    my ($self, $list) = @_;

    my %attrs = ( count => $list->{total} );

    $attrs{offset} = $list->{offset} if $list->{offset};

    return \%attrs;
}

sub _serialize_annotation
{
    my ($self, $data, $gen, $entity, $inc, $opts) = @_;

    if ($inc->annotation &&
        defined $entity->latest_annotation &&
        $entity->latest_annotation->text)
    {
        push @$data, $gen->annotation($gen->text ($entity->latest_annotation->text));
    }
}

sub _serialize_life_span
{
    my ($self, $data, $gen, $entity, $inc, $opts) = @_;

    my $has_begin_date = !$entity->begin_date->is_empty;
    my $has_end_date = !$entity->end_date->is_empty;
    if ($has_begin_date || $has_end_date) {
        my @span;
        push @span, $gen->begin($entity->begin_date->format) if $has_begin_date;
        push @span, $gen->end($entity->end_date->format) if $has_end_date;
        push @span, $gen->ended('true') if $entity->ended;
        push @$data, $gen->life_span(@span);
    }
}

sub _serialize_text_representation
{
    my ($self, $data, $gen, $entity, $inc, $opts) = @_;

    if ($entity->language || $entity->script)
    {
        my @tr;
        push @tr, $gen->language($entity->language->iso_code_3 // $entity->language->iso_code_2t)
            if $entity->language;
        push @tr, $gen->script($entity->script->iso_code) if $entity->script;
        push @$data, $gen->text_representation(@tr);
    }
}

sub _serialize_alias
{
    my ($self, $data, $gen, $aliases, $inc, $opts) = @_;

    if (!$in_relation_node && @$aliases)
    {
        my %attr = ( count => scalar(@$aliases) );
        my @alias_list;
        foreach my $al (sort_by { $_->name } @$aliases)
        {
            push @alias_list, $gen->alias({
                $al->locale ? ( locale => $al->locale ) : (),
                'sort-name' => $al->sort_name,
                $al->type ? ( type => $al->type_name ) : (),
                $al->primary_for_locale ? (primary => 'primary') : (),
                !$al->begin_date->is_empty ? ( 'begin-date' => $al->begin_date->format ) : (),
                !$al->end_date->is_empty ? ( 'end-date' => $al->end_date->format ) : ()
            }, $al->name);
        }
        push @$data, $gen->alias_list(\%attr, @alias_list);
    }
}

sub _serialize_artist_list
{
    my ($self, $data, $gen, $list, $inc, $stash) = @_;

    if (@{ $list->{items} })
    {
        my @list;
        foreach my $artist (sort_by { $_->gid } @{ $list->{items} })
        {
            $self->_serialize_artist(\@list, $gen, $artist, $inc, $stash, 1);
        }
        push @$data, $gen->artist_list($self->_list_attributes ($list), @list);
    }
}

sub _serialize_artist
{
    my ($self, $data, $gen, $artist, $inc, $stash, $toplevel) = @_;

    my $opts = $stash->store ($artist);

    my %attrs;
    $attrs{id} = $artist->gid;
    $attrs{type} = $artist->type->name if ($artist->type);

    my @list;
    push @list, $gen->name($artist->name);
    push @list, $gen->sort_name($artist->sort_name) if ($artist->sort_name);
    $self->_serialize_annotation(\@list, $gen, $artist, $inc, $opts) if $toplevel;
    push @list, $gen->disambiguation($artist->comment) if ($artist->comment);
    push @list, $gen->ipi($artist->ipi_codes->[0]->ipi) if ($artist->all_ipi_codes);
    push @list, $gen->ipi_list(
        map { $gen->ipi($_->ipi) } $artist->all_ipi_codes
    ) if ($artist->all_ipi_codes);

    push @list, $gen->isni_list(
        map { $gen->isni($_->isni) } $artist->all_isni_codes
    ) if ($artist->all_isni_codes);

    if ($toplevel)
    {
        push @list, $gen->gender($artist->gender->name) if ($artist->gender);
        push @list, $gen->country($artist->area->country_code) if $artist->area && $artist->area->country_code;
        $self->_serialize_area(\@list, $gen, $artist->area, $inc, $stash, $toplevel) if $artist->area;
        $self->_serialize_begin_area(\@list, $gen, $artist->begin_area, $inc, $stash, $toplevel) if $artist->begin_area;
        $self->_serialize_end_area(\@list, $gen, $artist->end_area, $inc, $stash, $toplevel) if $artist->end_area;

        $self->_serialize_life_span(\@list, $gen, $artist, $inc, $opts);
    }

    $self->_serialize_alias(\@list, $gen, $opts->{aliases}, $inc, $opts)
        if ($inc->aliases && $opts->{aliases});

    if ($toplevel)
    {
        $self->_serialize_recording_list(\@list, $gen, $opts->{recordings}, $inc, $stash)
            if $inc->recordings;

        $self->_serialize_release_list(\@list, $gen, $opts->{releases}, $inc, $stash)
            if $inc->releases;

        $self->_serialize_release_group_list(\@list, $gen, $opts->{release_groups}, $inc, $stash)
            if $inc->release_groups;

        $self->_serialize_work_list(\@list, $gen, $opts->{works}, $inc, $stash)
            if $inc->works;
    }

    $self->_serialize_relation_lists($artist, \@list, $gen, $artist->relationships, $inc, $stash) if ($inc->has_rels);
    $self->_serialize_tags_and_ratings(\@list, $gen, $inc, $opts);

    push @$data, $gen->artist(\%attrs, @list);
}

sub _serialize_artist_credit
{
    my ($self, $data, $gen, $artist_credit, $inc, $stash, $toplevel) = @_;

    my @ac;
    foreach my $name (@{$artist_credit->names})
    {
        my %artist_attr = ( id => $name->artist->gid );

        my %nc_attr;
        $nc_attr{joinphrase} = $name->join_phrase if ($name->join_phrase);

        my @nc;
        push @nc, $gen->name($name->name) if ($name->name ne $name->artist->name);

        $self->_serialize_artist(\@nc, $gen, $name->artist, $inc, $stash);
        push @ac, $gen->name_credit(\%nc_attr, @nc);
    }

    push @$data, $gen->artist_credit(@ac);
}

sub _serialize_collection
{
    my ($self, $data, $gen, $collection, $inc, $stash, $toplevel) = @_;

    my $opts = $stash->store ($collection);

    my %attrs;
    $attrs{id} = $collection->gid;

    my @collection;
    push @collection, $gen->name($collection->name);
    push @collection, $gen->editor($collection->editor->name);

    if ($toplevel)
    {
        $self->_serialize_release_list(\@collection, $gen, $opts->{releases}, $inc, $stash);
    }
    elsif ($collection->loaded_release_count) {
        push @collection, $gen->release_list({ count => $collection->release_count });
    }

    push @$data, $gen->collection(\%attrs, @collection);
}

sub _serialize_collection_list
{
    my ($self, $data, $gen, $collections, $inc, $stash, $toplevel) = @_;

    my @list;
    map { $self->_serialize_collection(\@list, $gen, $_, $inc, $stash, 0) }
        sort_by { $_->gid } @$collections;

    push @$data, $gen->collection_list(@list);
}

sub _serialize_release_group_list
{
    my ($self, $data, $gen, $list, $inc, $stash, $toplevel) = @_;

    my @list;
    foreach my $rg (sort_by { $_->gid } @{ $list->{items} })
    {
        $self->_serialize_release_group(\@list, $gen, $rg, $inc, $stash, $toplevel);
    }
    push @$data, $gen->release_group_list($self->_list_attributes ($list), @list);
}

sub _serialize_release_group
{
    my ($self, $data, $gen, $release_group, $inc, $stash, $toplevel) = @_;

    my $opts = $stash->store ($release_group);

    my %attr;
    $attr{id} = $release_group->gid;

    if ($release_group->primary_type && $release_group->primary_type->name eq 'Album') {
        my %fallback_type_order = (
            Compilation => 0,
            Remix => 1,
            Soundtrack => 2,
            Live => 3,
            Spokenword => 4,
            Interview => 5
        );

        my ($fallback) =
            nsort_by { $fallback_type_order{$_} }
                grep { exists $fallback_type_order{$_} }
                    map { $_->name }
                        $release_group->all_secondary_types;

        $attr{type} = $fallback || $release_group->primary_type->name;
    }
    elsif ($release_group->primary_type) {
        $attr{type} = $release_group->primary_type->name;
    }
    elsif ($release_group->all_secondary_types) {
        $attr{type} = $release_group->secondary_types->[0]->name;
    }

    my @list;
    push @list, $gen->title($release_group->name);
    push @list, $gen->disambiguation($release_group->comment) if $release_group->comment;
    $self->_serialize_annotation(\@list, $gen, $release_group, $inc, $opts) if $toplevel;
    push @list, $gen->first_release_date($release_group->first_release_date->format);

    push @list, $gen->primary_type($release_group->primary_type->name)
        if $release_group->primary_type;
    push @list, $gen->secondary_type_list(
        map {
            $gen->secondary_type($_->name)
        } $release_group->all_secondary_types
    ) if $release_group->all_secondary_types;

    if ($toplevel)
    {
        $self->_serialize_artist_credit(\@list, $gen, $release_group->artist_credit, $inc, $stash, $inc->artists)
            if $inc->artists || $inc->artist_credits;

        $self->_serialize_release_list(\@list, $gen, $opts->{releases}, $inc, $stash)
            if $inc->releases;
    }
    else
    {
        $self->_serialize_artist_credit(\@list, $gen, $release_group->artist_credit, $inc, $stash)
            if $inc->artist_credits;
    }

    $self->_serialize_relation_lists($release_group, \@list, $gen, $release_group->relationships, $inc, $stash) if $inc->has_rels;
    $self->_serialize_tags_and_ratings(\@list, $gen, $inc, $opts);

    push @$data, $gen->release_group(\%attr, @list);
}

sub _serialize_release_list
{
    my ($self, $data, $gen, $list, $inc, $stash, $toplevel) = @_;

    my @list;
    foreach my $release (sort_by { $_->gid } @{ $list->{items} })
    {
        $self->_serialize_release(\@list, $gen, $release, $inc, $stash, $toplevel);
    }
    push @$data, $gen->release_list($self->_list_attributes ($list), @list);
}

sub _serialize_quality
{
    my ($self, $data, $gen, $release, $inc) = @_;
    my %quality_names = (
        $QUALITY_LOW => 'low',
        $QUALITY_NORMAL => 'normal',
        $QUALITY_HIGH => 'high'
    );

    my $quality =
        $release->quality == $QUALITY_UNKNOWN ? $QUALITY_UNKNOWN_MAPPED
                                              : $release->quality;

    push @$data, $gen->quality(
        $quality_names{$quality}
    );
}

sub _serialize_release
{
    my ($self, $data, $gen, $release, $inc, $stash, $toplevel) = @_;

    my $opts = $stash->store ($release);

    $inc = $inc->clone ( releases => 0 );

    my @list;

    push @list, $gen->title($release->name);
    push @list, $gen->status($release->status->name) if $release->status;
    $self->_serialize_quality(\@list, $gen, $release, $inc, $opts);
    push @list, $gen->disambiguation($release->comment) if $release->comment;
    $self->_serialize_annotation(\@list, $gen, $release, $inc, $opts) if $toplevel;
    push @list, $gen->packaging($release->packaging->name) if $release->packaging;

    $self->_serialize_text_representation(\@list, $gen, $release, $inc, $opts);

    if ($toplevel)
    {
        $self->_serialize_artist_credit(\@list, $gen, $release->artist_credit, $inc, $stash, $inc->artists)
            if $inc->artist_credits || $inc->artists;
    }
    else
    {
        $self->_serialize_artist_credit(\@list, $gen, $release->artist_credit, $inc, $stash)
            if $inc->artist_credits;
    }

    $self->_serialize_release_group(\@list, $gen, $release->release_group, $inc, $stash)
            if ($release->release_group && $inc->release_groups);

    if (my ($earliest_release_event) = $release->all_events) {
        my $serialize_release_event = sub {
            my ($event, $include_country) = @_;
            my @r = ();

            push @r, $gen->date($event->date->format)
                if $event->date && !$event->date->is_empty;

            if ($include_country) {
                push @r, $gen->country($event->country->country_code) if $event->country && $event->country->country_code;
            } else {
                $self->_serialize_area(\@r, $gen, $event->country, $inc, $stash, $toplevel) if $event->country;
            }

            return @r;
        };

        push @list, $serialize_release_event->($earliest_release_event, 1);
        push @list, $gen->release_event_list(
            $self->_list_attributes({ total => $release->event_count }),
            map { $gen->release_event($serialize_release_event->($_)) }
                $release->all_events
        )
    }

    push @list, $gen->barcode($release->barcode->code) if defined $release->barcode->code;
    push @list, $gen->asin($release->amazon_asin) if $release->amazon_asin;
    $self->_serialize_cover_art_archive(\@list, $gen, $release, $inc, $stash) if $release->cover_art_presence;

    if ($toplevel)
    {
        $self->_serialize_label_info_list(\@list, $gen, $release->labels, $inc, $stash)
            if ($release->labels && $inc->labels);

    }

    $self->_serialize_medium_list(\@list, $gen, $release->mediums, $inc, $stash)
        if ($release->mediums && ($inc->media || $inc->discids || $inc->recordings));

    $self->_serialize_relation_lists($release, \@list, $gen, $release->relationships, $inc, $stash) if ($inc->has_rels);
    $self->_serialize_tags_and_ratings(\@list, $gen, $inc, $opts);
    $self->_serialize_collection_list(\@list, $gen, $opts->{collections}, $inc, $stash, 0)
        if ($opts->{collections} && @{ $opts->{collections} });

    push @$data, $gen->release({ id => $release->gid }, @list);
}

sub _serialize_cover_art_archive
{
    my ($self, $data, $gen, $release, $inc, $stash) = @_;
    my $coverart = $stash->store($release)->{'cover-art-archive'};

    my @list;
    push @list, $gen->artwork($release->cover_art_presence eq 'present' ? 'true' : 'false');
    push @list, $gen->count($coverart->{total});
    push @list, $gen->front($coverart->{front} ? 'true' : 'false');
    push @list, $gen->back($coverart->{back} ? 'true' : 'false');
    push @list, $gen->darkened('true') if $release->cover_art_presence eq 'darkened';

    push @$data, $gen->cover_art_archive(@list);
}

sub _serialize_work_list
{
    my ($self, $data, $gen, $list, $inc, $stash, $toplevel) = @_;

    my @list;
    foreach my $work (sort_by { $_->gid } @{ $list->{items} })
    {
        $self->_serialize_work(\@list, $gen, $work, $inc, $stash, $toplevel);
    }
    push @$data, $gen->work_list($self->_list_attributes ($list), @list);
}

sub _serialize_work
{
    my ($self, $data, $gen, $work, $inc, $stash, $toplevel) = @_;

    my $opts = $stash->store ($work);

    my %attrs;
    $attrs{id} = $work->gid;
    $attrs{type} = $work->type->name if ($work->type);

    my @list;
    push @list, $gen->title($work->name);
    push @list, $gen->language($work->language->iso_code_3 // $work->language->iso_code_2t) if $work->language;

    if ($work->all_iswcs) {
        push @list, $gen->iswc($work->iswcs->[0]->iswc);
        push @list, $gen->iswc_list(map {
            $gen->iswc($_->iswc);
        } $work->all_iswcs);
    }

    push @list, $gen->disambiguation($work->comment) if ($work->comment);
    $self->_serialize_annotation(\@list, $gen, $work, $inc, $opts) if $toplevel;

    $self->_serialize_alias(\@list, $gen, $opts->{aliases}, $inc, $opts)
        if ($inc->aliases && $opts->{aliases});

    $self->_serialize_relation_lists($work, \@list, $gen, $work->relationships, $inc, $stash) if $inc->has_rels;
    $self->_serialize_tags_and_ratings(\@list, $gen, $inc, $opts);

    push @$data, $gen->work(\%attrs, @list);
}

sub _serialize_url
{
    my ($self, $data, $gen, $url, $inc, $stash, $toplevel) = @_;

    my $opts = $stash->store ($url);

    my %attrs;
    $attrs{id} = $url->gid;

    my @list;
    push @list, $gen->resource($url->url);
    $self->_serialize_relation_lists($url, \@list, $gen, $url->relationships, $inc, $stash) if ($inc->has_rels);

    push @$data, $gen->url(\%attrs, @list);
}

sub _serialize_recording_list
{
    my ($self, $data, $gen, $list, $inc, $stash, $toplevel) = @_;

    my @list;
    foreach my $recording (sort_by { $_->gid } @{ $list->{items} })
    {
        $self->_serialize_recording(\@list, $gen, $recording, $inc, $stash, $toplevel);
    }

    push @$data, $gen->recording_list($self->_list_attributes ($list), @list);
}

sub _serialize_recording
{
    my ($self, $data, $gen, $recording, $inc, $stash, $toplevel) = @_;

    my $opts = $stash->store ($recording);

    my @list;
    push @list, $gen->title($recording->name);
    push @list, $gen->length($recording->length) if $recording->length;
    push @list, $gen->disambiguation($recording->comment) if ($recording->comment);

    if ($toplevel)
    {
        $self->_serialize_annotation(\@list, $gen, $recording, $inc, $opts);

        $self->_serialize_artist_credit(\@list, $gen, $recording->artist_credit, $inc, $stash, $inc->artists)
            if $inc->artists || $inc->artist_credits;

        $self->_serialize_release_list(\@list, $gen, $opts->{releases}, $inc, $stash)
            if $inc->releases;
    }
    else
    {
        $self->_serialize_artist_credit(\@list, $gen, $recording->artist_credit, $inc, $stash)
            if $inc->artist_credits;
    }

    $self->_serialize_puid_list(\@list, $gen, $opts->{puids}, $inc, $stash)
        if ($opts->{puids} && $inc->puids);
    $self->_serialize_isrc_list(\@list, $gen, $opts->{isrcs}, $inc, $stash)
        if ($opts->{isrcs} && $inc->isrcs);

    $self->_serialize_relation_lists($recording, \@list, $gen, $recording->relationships, $inc, $stash) if ($inc->has_rels);
    $self->_serialize_tags_and_ratings(\@list, $gen, $inc, $opts);

    push @$data, $gen->recording({ id => $recording->gid }, @list);

}

sub _serialize_medium_list
{
    my ($self, $data, $gen, $mediums, $inc, $stash) = @_;

    my @list;
    foreach my $medium (nsort_by { $_->position } @$mediums)
    {
        $self->_serialize_medium(\@list, $gen, $medium, $inc, $stash);
    }
    push @$data, $gen->medium_list({ count => scalar(@$mediums) }, @list);
}

sub _serialize_medium
{
    my ($self, $data, $gen, $medium, $inc, $stash) = @_;

    my @med;
    push @med, $gen->title($medium->name) if $medium->name;
    push @med, $gen->position($medium->position);
    push @med, $gen->format($medium->format->name) if ($medium->format);
    $self->_serialize_disc_list(\@med, $gen, $medium->cdtocs, $inc, $stash) if ($inc->discids);

    $self->_serialize_tracks(\@med, $gen, $medium, $inc, $stash);

    push @$data, $gen->medium(@med);
}

sub _serialize_tracks
{
    my ($self, $data, $gen, $medium, $inc, $stash) = @_;

    # Not all tracks in the tracklists may have been loaded.  If not all
    # tracks have been loaded, only one them will have been loaded which
    # therefore can be represented as if a query had been performed with
    # limit = 1 and offset = track->position.

    my $min = @{$medium->tracks} ? $medium->tracks->[0]->position : 0;
    my @list;
    foreach my $track (nsort_by { $_->position } @{$medium->tracks})
    {
        $min = $track->position if $track->position < $min;
        $self->_serialize_track(\@list, $gen, $track, $inc, $stash);
    }

    my %attr = ( count => $medium->track_count );
    $attr{offset} = $min - 1 if $min > 0;

    push @$data, $gen->track_list(\%attr, @list);
}

sub _serialize_track
{
    my ($self, $data, $gen, $track, $inc, $stash) = @_;

    my @track;
    push @track, $gen->position($track->position);
    push @track, $gen->number($track->number);

    push @track, $gen->title($track->name)
        if ($track->recording && $track->name ne $track->recording->name) ||
           (!$track->recording);

    push @track, $gen->length($track->length)
        if $track->length;

    $self->_serialize_artist_credit(\@track, $gen, $track->artist_credit, $inc, $stash)
        if $inc->artist_credits &&
            (
                ($track->recording &&
                     $track->recording->artist_credit != $track->artist_credit)
                || !$track->recording
            );

    $self->_serialize_recording(\@track, $gen, $track->recording, $inc, $stash)
        if ($track->recording);

    push @$data, $gen->track({ id => $track->gid }, @track);
}

sub _serialize_disc_list
{
    my ($self, $data, $gen, $cdtoclist, $inc, $stash) = @_;

    my @list;
    foreach my $cdtoc (sort_by { $_->cdtoc->discid } @$cdtoclist)
    {
        $self->_serialize_disc(\@list, $gen, $cdtoc->cdtoc, $inc, $stash);
    }
    push @$data, $gen->disc_list({ count => scalar(@$cdtoclist) }, @list);
}

sub _serialize_disc
{
    my ($self, $data, $gen, $cdtoc, $inc, $stash, $toplevel) = @_;

    my $opts = $stash->store ($cdtoc);

    my @list;
    push @list, $gen->sectors($cdtoc->leadout_offset);

    if ($toplevel)
    {
        $self->_serialize_release_list(\@list, $gen, $opts->{releases}, $inc, $stash, $toplevel);
    }

    push @$data, $gen->disc({ id => $cdtoc->discid }, @list);
}

sub _serialize_cdstub
{
    my ($self, $data, $gen, $toc, $inc, $stash, $toplevel) = @_;

    my $cdstub = $toc->cdstub;

    my @contents = (
        $gen->title($cdstub->title),
        $gen->artist($cdstub->artist),
    );
    push @contents, $gen->barcode($cdstub->barcode)
        if $cdstub->barcode;
    push @contents, $gen->disambiguation($cdstub->comment)
        if $cdstub->comment;

    my @tracks = map {
        my @track = ( $gen->title($_->title) );
        push @track, $gen->artist($_->artist)
            if $_->artist;
        push @track, $gen->length($_->length);

        $gen->track(@track);
    } $cdstub->all_tracks;

    push @contents, $gen->track_list({ count => $cdstub->track_count }, @tracks);

    push @$data, $gen->cdstub({ id => $toc->discid }, @contents);
}

sub _serialize_label_info_list
{
    my ($self, $data, $gen, $rel_labels, $inc, $stash) = @_;

    my @list;
    foreach my $rel_label (@$rel_labels)
    {
        $self->_serialize_label_info(\@list, $gen, $rel_label, $inc, $stash);
    }
    push @$data, $gen->label_info_list({ count => scalar(@$rel_labels) }, @list);
}

sub _serialize_label_info
{
    my ($self, $data, $gen, $rel_label, $inc, $stash) = @_;

    my @list;
    push @list, $gen->catalog_number ($rel_label->catalog_number)
        if $rel_label->catalog_number;
    $self->_serialize_label(\@list, $gen, $rel_label->label, $inc, $stash)
        if $rel_label->label;
    push @$data, $gen->label_info(@list);
}

sub _serialize_label_list
{
    my ($self, $data, $gen, $list, $inc, $stash, $toplevel) = @_;

    if (@{ $list->{items} })
    {
        my @list;
        foreach my $label (sort_by { $_->gid } @{ $list->{items} })
        {
            $self->_serialize_label(\@list, $gen, $label, $inc, $stash, $toplevel);
        }
        push @$data, $gen->label_list($self->_list_attributes ($list), @list);
    }
}

sub _serialize_label
{
    my ($self, $data, $gen, $label, $inc, $stash, $toplevel) = @_;

    my $opts = $stash->store ($label);

    my %attrs;
    $attrs{id} = $label->gid;
    $attrs{type} = $label->type->name if $label->type;

    my @list;
    push @list, $gen->name($label->name);
    push @list, $gen->sort_name($label->sort_name) if $label->sort_name;
    push @list, $gen->disambiguation($label->comment) if $label->comment;
    push @list, $gen->label_code($label->label_code) if $label->label_code;
    push @list, $gen->ipi($label->ipi_codes->[0]->ipi) if ($label->all_ipi_codes);
    push @list, $gen->ipi_list(
        map { $gen->ipi($_->ipi) } $label->all_ipi_codes
    ) if ($label->all_ipi_codes);

    push @list, $gen->isni_list(
        map { $gen->isni($_->isni) } $label->all_isni_codes
    ) if ($label->all_isni_codes);

    if ($toplevel)
    {
        $self->_serialize_annotation(\@list, $gen, $label, $inc, $opts);
        push @list, $gen->country($label->area->country_code) if $label->area && $label->area->country_code;
        $self->_serialize_area(\@list, $gen, $label->area, $inc, $stash, $toplevel) if $label->area;
        $self->_serialize_life_span(\@list, $gen, $label, $inc, $opts);
    }

    $self->_serialize_alias(\@list, $gen, $opts->{aliases}, $inc, $opts)
        if ($inc->aliases && $opts->{aliases});

    if ($toplevel)
    {
        $self->_serialize_release_list(\@list, $gen, $opts->{releases}, $inc, $stash)
            if $inc->releases;
    }

    $self->_serialize_relation_lists($label, \@list, $gen, $label->relationships, $inc, $stash) if ($inc->has_rels);
    $self->_serialize_tags_and_ratings(\@list, $gen, $inc, $opts);

    push @$data, $gen->label(\%attrs, @list);
}

sub _serialize_area_list
{
    my ($self, $data, $gen, $list, $inc, $stash, $toplevel) = @_;

    if (@{ $list->{items} })
    {
        my @list;
        foreach my $area (sort_by { $_->gid } @{ $list->{items} })
        {
            $self->_serialize_area(\@list, $gen, $area, $inc, $stash, $toplevel);
        }
        push @$data, $gen->area_list($self->_list_attributes ($list), @list);
    }
}

sub _serialize_area_inner
{
    my ($self, $data, $gen, $area, $inc, $stash, $toplevel) = @_;

    my $opts = $stash->store ($area);

    my %attrs;
    $attrs{id} = $area->gid;
    $attrs{type} = $area->type->name if $area->type;

    my @list;
    push @list, $gen->name($area->name);
    push @list, $gen->sort_name($area->sort_name) if $area->sort_name;
    if ($area->iso_3166_1_codes) {
        push @list, $gen->iso_3166_1_code_list(map {
           $gen->iso_3166_1_code($_);
        } $area->iso_3166_1_codes);
    }
    if ($area->iso_3166_2_codes) {
        push @list, $gen->iso_3166_2_code_list(map {
           $gen->iso_3166_2_code($_);
        } $area->iso_3166_2_codes);
    }
    if ($area->iso_3166_3_codes) {
        push @list, $gen->iso_3166_3_code_list(map {
           $gen->iso_3166_3_code($_);
        } $area->iso_3166_3_codes);
    }
    if ($toplevel)
    {
        $self->_serialize_annotation(\@list, $gen, $area, $inc, $opts);
        $self->_serialize_life_span(\@list, $gen, $area, $inc, $opts);
    }

    $self->_serialize_alias(\@list, $gen, $opts->{aliases}, $inc, $opts)
        if ($inc->aliases && $opts->{aliases});

    $self->_serialize_relation_lists($area, \@list, $gen, $area->relationships, $inc, $stash) if ($inc->has_rels);
    $self->_serialize_tags_and_ratings(\@list, $gen, $inc, $opts);

    return (\%attrs, @list);
}

sub _serialize_area
{
    my ($self, $data, $gen, $area, $inc, $stash, $toplevel) = @_;

    my ($attrs, @list) = $self->_serialize_area_inner($data, $gen, $area, $inc, $stash, $toplevel);

    push @$data, $gen->area($attrs, @list);
}

sub _serialize_begin_area
{
    my ($self, $data, $gen, $area, $inc, $stash, $toplevel) = @_;

    my ($attrs, @list) = $self->_serialize_area_inner($data, $gen, $area, $inc, $stash, $toplevel);

    push @$data, $gen->begin_area($attrs, @list);
}

sub _serialize_end_area
{
    my ($self, $data, $gen, $area, $inc, $stash, $toplevel) = @_;

    my ($attrs, @list) = $self->_serialize_area_inner($data, $gen, $area, $inc, $stash, $toplevel);

    push @$data, $gen->end_area($attrs, @list);
}

sub _serialize_relation_lists
{
    my ($self, $src_entity, $data, $gen, $rels, $inc, $stash) = @_;

    my %types = ();
    foreach my $rel (@$rels)
    {
        $types{$rel->target_type} = [] if !exists $types{$rel->target_type};
        push @{$types{$rel->target_type}}, $rel;
    }
    foreach my $type (sort keys %types)
    {
        my @list;
        foreach my $rel (sort_by { $_->target_key . $_->link->type->name } @{$types{$type}})
        {
            $self->_serialize_relation($src_entity, \@list, $gen, $rel, $inc, $stash);
        }
        push @$data, $gen->relation_list({ 'target-type' => $type }, @list);
    }
}

sub _serialize_relation
{
    my ($self, $src_entity, $data, $gen, $rel, $inc, $stash) = @_;

    my @list;
    my $type = $rel->link->type->name;
    my $type_id = $rel->link->type->gid;

    if ($rel->target_type eq 'url') {
        push @list, $gen->target({ 'id' => $rel->target->gid }, $rel->target_key);
    } else {
        push @list, $gen->target($rel->target_key);
    }

    push @list, $gen->direction('backward') if ($rel->direction == $MusicBrainz::Server::Entity::Relationship::DIRECTION_BACKWARD);
    push @list, $gen->begin($rel->link->begin_date->format) unless $rel->link->begin_date->is_empty;
    push @list, $gen->end($rel->link->end_date->format) unless $rel->link->end_date->is_empty;
    push @list, $gen->ended('true') if $rel->link->ended;

    push @list, $gen->attribute_list(
        map { $gen->attribute($_->name) }
            $rel->link->all_attributes
    ) if ($rel->link->all_attributes);

    unless ($rel->target_type eq 'url')
    {
        my $method =  "_serialize_" . $rel->target_type;
        local $in_relation_node = 1;
        $self->$method(\@list, $gen, $rel->target, $inc, $stash);
    }

    push @$data, $gen->relation({ type => $type, "type-id" => $type_id }, @list);
}

sub _serialize_puid_list
{
    my ($self, $data, $gen, $puids, $inc, $stash) = @_;

    my @list;
    foreach my $puid (sort_by { $_->puid->puid } @$puids)
    {
        $self->_serialize_puid(\@list, $gen, $puid->puid, $inc, $stash);
    }
    push @$data, $gen->puid_list({ count => scalar(@$puids) }, @list);
}

sub _serialize_puid
{
    my ($self, $data, $gen, $puid, $inc, $stash, $toplevel) = @_;

    my $opts = $stash->store ($puid);

    my @list;
    if ($toplevel)
    {
        $self->_serialize_recording_list(\@list, $gen, ${opts}->{recordings}, $inc, $stash, $toplevel)
            if ${opts}->{recordings};
    }
    push @$data, $gen->puid({ id => $puid->puid }, @list);
}

sub _serialize_isrc_list
{
    my ($self, $data, $gen, $isrcs, $inc, $stash, $toplevel) = @_;

    my %uniq_isrc;
    foreach (@$isrcs)
    {
        $uniq_isrc{$_->isrc} = [] unless $uniq_isrc{$_->isrc};
        push @{$uniq_isrc{$_->isrc}}, $_;
    }

    my @list;
    foreach my $k (sort keys %uniq_isrc)
    {
        $self->_serialize_isrc(\@list, $gen, $uniq_isrc{$k}, $inc, $stash, $toplevel);
    }
    push @$data, $gen->isrc_list({ count => scalar(keys %uniq_isrc) }, @list);
}

sub _serialize_isrc
{
    my ($self, $data, $gen, $isrcs, $inc, $stash, $toplevel) = @_;

    my @recordings = map { $_->recording } grep { $_->recording } @$isrcs;
    my $recordings = {
        items => \@recordings,
        total => scalar @recordings,
    };

    my @list;
    $self->_serialize_recording_list(\@list, $gen, $recordings, $inc, $stash, $toplevel)
        if @recordings;

    push @$data, $gen->isrc({ id => $isrcs->[0]->isrc }, @list);
}

sub _serialize_tags_and_ratings
{
    my ($self, $data, $gen, $inc, $opts) = @_;

    $self->_serialize_tag_list($data, $gen, $inc, $opts)
        if $opts->{tags} && $inc->{tags};
    $self->_serialize_user_tag_list($data, $gen, $inc, $opts)
        if $opts->{user_tags} && $inc->{user_tags};
    $self->_serialize_rating($data, $gen, $inc, $opts)
        if $opts->{ratings} && $inc->{ratings};
    $self->_serialize_user_rating($data, $gen, $inc, $opts)
        if $opts->{user_ratings} && $inc->{user_ratings};
}

sub _serialize_tag_list
{
    my ($self, $data, $gen, $inc, $opts) = @_;
    return if $in_relation_node;

    my @list;
    foreach my $tag (sort_by { $_->tag->name } @{$opts->{tags}})
    {
        $self->_serialize_tag(\@list, $gen, $tag, $inc, $opts);
    }
    push @$data, $gen->tag_list(@list);
}

sub _serialize_tag
{
    my ($self, $data, $gen, $tag, $inc, $opts, $modelname, $entity) = @_;

    push @$data, $gen->tag({ count => $tag->count }, $gen->name ($tag->tag->name));
}

sub _serialize_user_tag_list
{
    my ($self, $data, $gen, $inc, $opts, $modelname, $entity) = @_;

    my @list;
    foreach my $tag (sort_by { $_->tag->name } @{$opts->{user_tags}})
    {
        $self->_serialize_user_tag(\@list, $gen, $tag, $inc, $opts, $modelname, $entity);
    }
    push @$data, $gen->user_tag_list(@list);
}

sub _serialize_user_tag
{
    my ($self, $data, $gen, $tag, $inc, $opts, $modelname, $entity) = @_;

    push @$data, $gen->user_tag($gen->name($tag->tag->name));
}

sub _serialize_rating
{
    my ($self, $data, $gen, $inc, $opts) = @_;

    my $count = $opts->{ratings}->{count};
    my $rating = $opts->{ratings}->{rating};

    push @$data, $gen->rating({ 'votes-count' => $count }, $rating);
}

sub _serialize_user_rating
{
    my ($self, $data, $gen, $inc, $opts) = @_;

    push @$data, $gen->user_rating($opts->{user_ratings});
}

sub output_error
{
    my ($self, $err) = @_;

    my $gen = MusicBrainz::XML->new;

    return '<?xml version="1.0" encoding="UTF-8"?>' .
        $gen->error($gen->text($err), $gen->text(
           "For usage, please see: http://musicbrainz.org/development/mmd"));
}

sub output_success
{
    my ($self, $msg) = @_;

    my $gen = MusicBrainz::XML->new();

    $msg ||= 'OK';

    my $xml = $xml_decl_begin;
    $xml .= $gen->message($gen->text($msg));
    $xml .= $xml_decl_end;
    return $xml;
}

sub serialize
{
    my ($self, $type, $entity, $inc, $stash) = @_;
    $inc ||= 0;

    my $gen = MusicBrainz::XML->new();

    my $method = $type . "_resource";
    $method =~ s/-/_/g;
    my $xml = $xml_decl_begin;
    $xml .= $self->$method($gen, $entity, $inc, $stash);
    $xml .= $xml_decl_end;
    return $xml;
}

sub artist_resource
{
    my ($self, $gen, $artist, $inc, $stash) = @_;

    my $data = [];
    $self->_serialize_artist($data, $gen, $artist, $inc, $stash, 1);

    return $data->[0];
}

sub collection_resource
{
    my ($self, $gen, $collection, $inc, $stash) = @_;

    my $data = [];
    $self->_serialize_collection($data, $gen, $collection, $inc, $stash, 1);

    return $data->[0];
}

sub collection_list_resource
{
    my ($self, $gen, $collections, $inc, $stash) = @_;

    my $data = [];
    $self->_serialize_collection_list($data, $gen, $collections, $inc, $stash, 1);

    return $data->[0];
}

sub label_resource
{
    my ($self, $gen, $label, $inc, $stash) = @_;

    my $data = [];
    $self->_serialize_label($data, $gen, $label, $inc, $stash, 1);
    return $data->[0];
}

sub release_group_resource
{
    my ($self, $gen, $release_group, $inc, $stash) = @_;

    my $data = [];
    $self->_serialize_release_group($data, $gen, $release_group, $inc, $stash, 1);
    return $data->[0];
}

sub release_resource
{
    my ($self, $gen, $release, $inc, $stash) = @_;

    my $data = [];
    $self->_serialize_release($data, $gen, $release, $inc, $stash, 1);
    return $data->[0];
}

sub recording_resource
{
    my ($self, $gen, $recording, $inc, $stash) = @_;

    my $data = [];
    $self->_serialize_recording($data, $gen, $recording, $inc, $stash, 1);

    return $data->[0];
}

sub work_resource
{
    my ($self, $gen, $work, $inc, $stash) = @_;

    my $data = [];
    $self->_serialize_work($data, $gen, $work, $inc, $stash, 1);
    return $data->[0];
}

sub area_resource
{
    my ($self, $gen, $area, $inc, $stash) = @_;

    my $data = [];
    $self->_serialize_area($data, $gen, $area, $inc, $stash, 1);
    return $data->[0];
}

sub url_resource
{
    my ($self, $gen, $url, $inc, $stash) = @_;

    my $data = [];
    $self->_serialize_url($data, $gen, $url, $inc, $stash, 1);

    return $data->[0];
}

sub isrc_resource
{
    my ($self, $gen, $isrc, $inc, $stash) = @_;

    my $data = [];
    $self->_serialize_isrc($data, $gen, $isrc, $inc, $stash, 1);
    return $data->[0];
}

sub puid_resource
{
    my ($self, $gen, $puid, $inc, $stash) = @_;

    my $data = [];
    $self->_serialize_puid($data, $gen, $puid, $inc, $stash, 1);
    return $data->[0];
}

sub discid_resource
{
    my ($self, $gen, $cdtoc, $inc, $stash) = @_;

    my $data = [];
    $self->_serialize_disc($data, $gen, $cdtoc, $inc, $stash, 1);
    return $data->[0];
}

sub cdstub_resource
{
    my ($self, $gen, $cdtoc, $inc, $stash) = @_;

    my $data = [];
    $self->_serialize_cdstub($data, $gen, $cdtoc, $inc, $stash, 1);
    return $data->[0];
}

sub artist_list_resource
{
    my ($self, $gen, $artists, $inc, $stash) = @_;

    my $data = [];
    $self->_serialize_artist_list($data, $gen, $artists, $inc, $stash, 1);

    return $data->[0];
}

sub label_list_resource
{
    my ($self, $gen, $labels, $inc, $stash) = @_;

    my $data = [];
    $self->_serialize_label_list($data, $gen, $labels, $inc, $stash, 1);

    return $data->[0];
}

sub recording_list_resource
{
    my ($self, $gen, $recordings, $inc, $stash) = @_;

    my $data = [];
    $self->_serialize_recording_list($data, $gen, $recordings, $inc, $stash, 1);

    return $data->[0];
}

sub release_list_resource
{
    my ($self, $gen, $releases, $inc, $stash) = @_;

    my $data = [];
    $self->_serialize_release_list($data, $gen, $releases, $inc, $stash, 1);

    return $data->[0];
}

sub release_group_list_resource
{
    my ($self, $gen, $rgs, $inc, $stash) = @_;

    my $data = [];
    $self->_serialize_release_group_list($data, $gen, $rgs, $inc, $stash, 1);

    return $data->[0];
}

sub work_list_resource
{
    my ($self, $gen, $works, $inc, $stash) = @_;

    my $data = [];
    $self->_serialize_work_list($data, $gen, $works, $inc, $stash, 1);

    return $data->[0];
}

sub area_list_resource
{
    my ($self, $gen, $areas, $inc, $stash) = @_;

    my $data = [];
    $self->_serialize_area_list($data, $gen, $areas, $inc, $stash, 1);

    return $data->[0];
}

sub rating_resource
{
    my ($self, $gen, $entity, $inc, $stash) = @_;

    my $opts = $stash->store ($entity);

    return '' unless $opts->{user_ratings};

    my $data = [];
    $self->_serialize_user_rating($data, $gen, $inc, $opts);

    return $data->[0];
}

sub tag_list_resource
{
    my ($self, $gen, $entity, $inc, $stash) = @_;

    my $opts = $stash->store ($entity);

    my $data = [];
    $self->_serialize_user_tag_list($data, $gen, $inc, $opts);

    return $data->[0];
}

__PACKAGE__->meta->make_immutable;
no Moose;
1;

=head1 COPYRIGHT

Copyright (C) 2010-2013 MetaBrainz Foundation
Copyright (C) 2009 Lukas Lalinsky
Copyright (C) 2004, 2010 Robert Kaye

This program is free software; you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation; either version 2 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program; if not, write to the Free Software
Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.

=cut
