package MusicBrainz::Server::WebService::XMLSerializer;

use IO::String;
use Moose;
use List::AllUtils qw( nsort_by sort_by );
use MusicBrainz::Server::Constants qw( :direction $VARTIST_ID :quality %ENTITIES );
use MusicBrainz::Server::Data::Utils qw( non_empty );
use MusicBrainz::Server::Entity::Relationship;
use MusicBrainz::Server::Validation;
use XML::LibXML;
use aliased 'MusicBrainz::Server::WebService::WebServiceInc';
use aliased 'MusicBrainz::Server::WebService::WebServiceStash';

sub mime_type { 'application/xml' }
sub fmt { 'xml' }

# Dynamically scoped variables for determined what data is displayed.
# Can change at runtime via 'local' shadowing
our $in_relation_node = 0;
our $show_aliases = 1;

sub add_type_elem {
    my ($parent_node, $name, $type) = @_;

    my $elem = $parent_node->addNewChild(undef, $name);
    $elem->_setAttribute('id', $type->gid);
    $elem->appendText($type->name);
    return $elem;
}

sub set_list_attributes
{
    my ($list_node, $list) = @_;

    $list_node->_setAttribute('count', $list->{total});
    $list_node->_setAttribute('offset', $list->{offset}) if $list->{offset};
}

sub _serialize_annotation
{
    my ($self, $parent_node, $entity, $inc, $opts) = @_;

    if ($inc->annotation &&
        defined $entity->latest_annotation &&
        $entity->latest_annotation->text)
    {
        my $annotation_node = $parent_node->addNewChild(undef, 'annotation');
        $annotation_node->appendTextChild('text', $entity->latest_annotation->text);
    }
}

sub _serialize_coordinates
{
    my ($self, $parent_node, $entity, $inc, $opts) = @_;

    my $elem = $parent_node->addNewChild(undef, 'coordinates');
    my $coordinates = $entity->coordinates;
    $elem->appendTextChild('latitude', $coordinates->latitude);
    $elem->appendTextChild('longitude', $coordinates->longitude);
}

sub _serialize_life_span
{
    my ($self, $parent_node, $entity, $inc, $opts) = @_;

    my $has_begin_date = !$entity->begin_date->is_empty;
    my $has_end_date = !$entity->end_date->is_empty;
    if ($has_begin_date || $has_end_date) {
        my $life_span_node = $parent_node->addNewChild(undef, 'life-span');
        $life_span_node->appendTextChild('begin', $entity->begin_date->format)
            if $has_begin_date;
        $life_span_node->appendTextChild('end', $entity->end_date->format)
            if $has_end_date;
        $life_span_node->appendTextChild('ended', 'true')
            if ($entity->ended && !$entity->isa('MusicBrainz::Server::Entity::Event'));
    }
}

sub _serialize_text_representation
{
    my ($self, $parent_node, $entity, $inc, $opts) = @_;

    if ($entity->language || $entity->script)
    {
        my $tr_node = $parent_node->addNewChild(undef, 'text-representation');
        $tr_node->appendTextChild('language', $entity->language->alpha_3_code)
            if $entity->language;
        $tr_node->appendTextChild('script', $entity->script->iso_code)
            if $entity->script;
    }
}

sub _serialize_alias_list
{
    my ($self, $parent_node, $aliases, $inc, $opts) = @_;

    if ($show_aliases && @$aliases) {
        my $alias_list_node = $parent_node->addNewChild(undef, 'alias-list');
        $alias_list_node->_setAttribute('count', scalar(@$aliases));

        foreach my $al (sort_by { $_->name } @$aliases) {
            my $alias_node = $alias_list_node->addNewChild(undef, 'alias');
            $alias_node->_setAttribute('locale', $al->locale) if $al->locale;
            $alias_node->_setAttribute('sort-name', $al->sort_name);

            if (my $type = $al->type) {
                $alias_node->_setAttribute('type', $type->name);
                $alias_node->_setAttribute('type-id', $type->gid);
            }

            $alias_node->_setAttribute('primary', 'primary') if $al->primary_for_locale;
            $alias_node->_setAttribute('begin-date', $al->begin_date->format)
                unless $al->begin_date->is_empty;
            $alias_node->_setAttribute('end-date', $al->end_date->format)
                unless $al->end_date->is_empty;

            $alias_node->appendText($al->name);
        }
    }
}

sub _serialize_artist_list
{
    my ($self, $parent_node, $list, $inc, $stash) = @_;

    if (my @artists = @{ $list->{items} }) {
        my $artist_list_node = $parent_node->addNewChild(undef, 'artist-list');
        foreach my $artist (@artists) {
            $self->_serialize_artist($artist_list_node, $artist, $inc, $stash, 1);
        }
        set_list_attributes($artist_list_node, $list);
    }
}

sub _serialize_artist
{
    my ($self, $parent_node, $artist, $inc, $stash, $toplevel) = @_;

    my $opts = $stash->store($artist);

    my $compact_display = $artist->id == $VARTIST_ID && !$toplevel;

    my $artist_node = $parent_node->addNewChild(undef, 'artist');
    $artist_node->_setAttribute('id', $artist->gid);

    my $type = $artist->type;
    if ($type) {
        $artist_node->_setAttribute('type', $type->name);
        $artist_node->_setAttribute('type-id', $type->gid);
    }

    $artist_node->appendTextChild('name', $artist->name);
    $artist_node->appendTextChild('sort-name', $artist->sort_name) if $artist->sort_name;

    $self->_serialize_annotation($artist_node, $artist, $inc, $opts) if $toplevel;

    $artist_node->appendTextChild('disambiguation', $artist->comment) if $artist->comment;
    $artist_node->appendTextChild('ipi', $artist->ipi_codes->[0]->ipi) if $artist->all_ipi_codes;

    if (my @ipi_codes = $artist->all_ipi_codes) {
        my $ipi_list_node = $artist_node->addNewChild(undef, 'ipi-list');
        $ipi_list_node->appendTextChild('ipi', $_->ipi) for @ipi_codes;
    }

    if (my @isni_codes = $artist->all_isni_codes) {
        my $isni_list_node = $artist_node->addNewChild(undef, 'isni-list');
        $isni_list_node->appendTextChild('isni', $_->isni) for @isni_codes;
    }

    if ($toplevel)
    {
        if (my $gender = $artist->gender) {
            add_type_elem($artist_node, 'gender', $gender);
        }

        if (my $area = $artist->area) {
            $artist_node->appendTextChild('country', $area->country_code) if $area->country_code;
            $self->_serialize_area($artist_node, $area, $inc, $stash, $toplevel);
        }

        $self->_serialize_begin_area($artist_node, $artist->begin_area, $inc, $stash, $toplevel) if $artist->begin_area;
        $self->_serialize_end_area($artist_node, $artist->end_area, $inc, $stash, $toplevel) if $artist->end_area;
        $self->_serialize_life_span($artist_node, $artist, $inc, $opts);
    }

    $self->_serialize_alias_list($artist_node, $opts->{aliases}, $inc, $opts)
        if ($inc->aliases && $opts->{aliases} && !$compact_display);

    if ($toplevel)
    {
        $self->_serialize_recording_list($artist_node, $opts->{recordings}, $inc, $stash)
            if $inc->recordings;

        $self->_serialize_release_list($artist_node, $opts->{releases}, $inc, $stash)
            if $inc->releases;

        $self->_serialize_release_group_list($artist_node, $opts->{release_groups}, $inc, $stash)
            if $inc->release_groups;

        $self->_serialize_work_list($artist_node, $opts->{works}, $inc, $stash)
            if $inc->works;
    }

    $self->_serialize_relation_lists($artist_node, $artist, $artist->relationships, $inc, $stash)
        if $inc->has_rels;
    $self->_serialize_tags_and_ratings($artist_node, $artist, $inc, $stash)
        if !$compact_display;
}

sub _serialize_artist_credit
{
    my ($self, $parent_node, $artist_credit, $inc, $stash, $toplevel) = @_;

    my $ac_node = $parent_node->addNewChild(undef, 'artist-credit');

    foreach my $name (@{$artist_credit->names})
    {
        my $acn_node = $ac_node->addNewChild(undef, 'name-credit');
        $acn_node->_setAttribute('joinphrase', $name->join_phrase) if $name->join_phrase;
        $acn_node->appendTextChild('name', $name->name) if $name->name ne $name->artist->name;
        $self->_serialize_artist($acn_node, $name->artist, $inc, $stash);
    }
}

sub _serialize_collection
{
    my ($self, $parent_node, $collection, $inc, $stash, $toplevel) = @_;

    my $opts = $stash->store($collection);
    my $type = $collection->type;
    my $entity_type = $collection->type->item_entity_type;

    my $col_node = $parent_node->addNewChild(undef, 'collection');
    $col_node->_setAttribute('id', $collection->gid);
    if ($type) {
        $col_node->_setAttribute('type', $type->name);
        $col_node->_setAttribute('entity-type', $entity_type);
    }

    $col_node->appendTextChild('name', $collection->name);
    $col_node->appendTextChild('editor', $collection->editor->name);

    my $props = $ENTITIES{$entity_type};
    my $list = $opts->{$props->{plural}};

    if ($toplevel && defined($list->{items}) && @{ $list->{items} }) {
        my $serialize = "_serialize_${entity_type}_list";
        $self->$serialize($col_node, $list, $inc, $stash);

    } elsif ($collection->loaded_entity_count) {
        my $list_node = $col_node->addNewChild(undef, $props->{url} . '-list');
        $list_node->_setAttribute('count', $collection->entity_count);
    }
}

sub _serialize_collection_list
{
    my ($self, $parent_node, $list, $inc, $stash, $toplevel) = @_;

    my $list_node = $parent_node->addNewChild(undef, 'collection-list');
    set_list_attributes($list_node, $list);

    foreach my $collection (@{ $list->{items} }) {
        $self->_serialize_collection($list_node, $collection, $inc, $stash, $toplevel);
    }
}

sub _serialize_release_group_list
{
    my ($self, $parent_node, $list, $inc, $stash, $toplevel) = @_;

    my $list_node = $parent_node->addNewChild(undef, 'release-group-list');
    set_list_attributes($list_node, $list);

    foreach my $rg (@{ $list->{items} })
    {
        $self->_serialize_release_group($list_node, $rg, $inc, $stash, $toplevel);
    }
}

my %rg_fallback_type_order = (
    Compilation => 0,
    Remix => 1,
    Soundtrack => 2,
    Live => 3,
    Spokenword => 4,
    Interview => 5
);

sub _serialize_release_group
{
    my ($self, $parent_node, $release_group, $inc, $stash, $toplevel) = @_;

    my $opts = $stash->store($release_group);
    my $primary_type = $release_group->primary_type;
    my @secondary_types = $release_group->all_secondary_types;

    my $rg_node = $parent_node->addNewChild(undef, 'release-group');
    $rg_node->_setAttribute('id', $release_group->gid);

    if ($primary_type && $primary_type->name eq 'Album') {
        my ($fallback) =
            nsort_by { $rg_fallback_type_order{$_->name} }
                grep { exists $rg_fallback_type_order{$_->name} }
                    @secondary_types;

        if ($fallback) {
            $rg_node->_setAttribute('type', $fallback->name);
            $rg_node->_setAttribute('type-id', $fallback->gid);
        } else {
            $rg_node->_setAttribute('type', $primary_type->name);
            $rg_node->_setAttribute('type-id', $primary_type->gid);
        }
    }
    elsif ($primary_type) {
        $rg_node->_setAttribute('type', $primary_type->name);
        $rg_node->_setAttribute('type-id', $primary_type->gid);
    }
    elsif (@secondary_types) {
        $rg_node->_setAttribute('type', $secondary_types[0]->name);
        $rg_node->_setAttribute('type-id', $secondary_types[0]->gid);
    }

    $rg_node->appendTextChild('title', $release_group->name);
    $rg_node->appendTextChild('disambiguation', $release_group->comment) if $release_group->comment;
    $self->_serialize_annotation($rg_node, $release_group, $inc, $opts) if $toplevel;
    $rg_node->appendTextChild('first-release-date', $release_group->first_release_date->format);

    add_type_elem($rg_node, 'primary-type', $primary_type)
        if $release_group->primary_type;

    if (@secondary_types) {
        my $sec_type_list_node = $rg_node->addNewChild(undef, 'secondary-type-list');
        add_type_elem($sec_type_list_node, 'secondary-type', $_) for @secondary_types;
    }

    if ($toplevel)
    {
        $self->_serialize_artist_credit($rg_node, $release_group->artist_credit, $inc, $stash, $inc->artists)
            if $inc->artists || $inc->artist_credits;

        $self->_serialize_release_list($rg_node, $opts->{releases}, $inc, $stash)
            if $inc->releases;
    }
    else
    {
        $self->_serialize_artist_credit($rg_node, $release_group->artist_credit, $inc, $stash)
            if $inc->artist_credits;
    }

    $self->_serialize_alias_list($rg_node, $opts->{aliases}, $inc, $opts)
        if ($inc->aliases && $opts->{aliases});

    $self->_serialize_relation_lists($rg_node, $release_group, $release_group->relationships, $inc, $stash) if $inc->has_rels;
    $self->_serialize_tags_and_ratings($rg_node, $release_group, $inc, $stash);
}

sub _serialize_release_list
{
    my ($self, $parent_node, $list, $inc, $stash, $toplevel) = @_;

    my $list_node = $parent_node->addNewChild(undef, 'release-list');
    set_list_attributes($list_node, $list);

    foreach my $release (@{ $list->{items} })
    {
        $self->_serialize_release($list_node, $release, $inc, $stash, $toplevel);
    }
}

my %quality_names = (
    $QUALITY_LOW => 'low',
    $QUALITY_NORMAL => 'normal',
    $QUALITY_HIGH => 'high'
);

sub _serialize_release_event {
    my ($self, $parent_node, $release_event, $inc, $stash, $toplevel, $include_country) = @_;

    if (my $date = $release_event->date) {
        $parent_node->appendTextChild('date', $date->format) unless $date->is_empty;
    }

    if (my $country = $release_event->country) {
        if ($include_country) {
            my $country_code = $country->country_code;
            $parent_node->appendTextChild('country', $country_code) if $country_code;
        } else {
            $self->_serialize_area($parent_node, $country, $inc, $stash, $toplevel);
        }
    }
}

sub _serialize_release
{
    my ($self, $parent_node, $release, $inc, $stash, $toplevel) = @_;

    my $opts = $stash->store($release);

    $inc = $inc->clone( releases => 0 );

    my $release_node = $parent_node->addNewChild(undef, 'release');
    $release_node->_setAttribute('id', $release->gid);

    $release_node->appendTextChild('title', $release->name);

    if (my $status = $release->status) {
        add_type_elem($release_node, 'status', $status);
    }

    my $quality = ($release->quality == $QUALITY_UNKNOWN
        ? $QUALITY_UNKNOWN_MAPPED
        : $release->quality);

    $release_node->appendTextChild('quality', $quality_names{$quality});
    $release_node->appendTextChild('disambiguation', $release->comment) if $release->comment;
    $self->_serialize_annotation($release_node, $release, $inc, $stash) if $toplevel;

    if (my $packaging = $release->packaging) {
        add_type_elem($release_node, 'packaging', $packaging);
    }

    $self->_serialize_text_representation($release_node, $release, $inc, $stash);

    if ($toplevel)
    {
        $self->_serialize_artist_credit($release_node, $release->artist_credit, $inc, $stash, $inc->artists)
            if $inc->artist_credits || $inc->artists;
    }
    else
    {
        $self->_serialize_artist_credit($release_node, $release->artist_credit, $inc, $stash)
            if $inc->artist_credits;
    }

    $self->_serialize_alias_list($release_node, $opts->{aliases}, $inc, $opts)
        if ($inc->aliases && $opts->{aliases});

    $self->_serialize_release_group($release_node, $release->release_group, $inc, $stash)
            if ($release->release_group && $inc->release_groups);

    if (my @release_events = $release->all_events) {
        my ($earliest_release_event) = @release_events;
        $self->_serialize_release_event($release_node, $earliest_release_event, $inc, $stash, $toplevel, 1);

        my $re_list_node = $release_node->addNewChild(undef, 'release-event-list');
        $re_list_node->_setAttribute('count', $release->event_count);

        for my $release_event (@release_events) {
            $self->_serialize_release_event(
                $re_list_node->addNewChild(undef, 'release-event'),
                $release_event, $inc, $stash, $toplevel, 0);
        }
    }

    $release_node->appendTextChild('barcode', $release->barcode->code) if defined $release->barcode->code;
    $release_node->appendTextChild('asin', $release->amazon_asin) if $release->amazon_asin;
    $self->_serialize_cover_art_archive($release_node, $release, $inc, $stash) if $release->cover_art_presence;

    if ($toplevel)
    {
        $self->_serialize_label_info_list($release_node, $release->labels, $inc, $stash)
            if ($release->labels && $inc->labels);

    }

    $self->_serialize_medium_list($release_node, $release->mediums, $inc, $stash)
        if ($release->mediums && ($inc->media || $inc->discids || $inc->recordings));

    $self->_serialize_relation_lists($release_node, $release, $release->relationships, $inc, $stash) if ($inc->has_rels);
    $self->_serialize_tags_and_ratings($release_node, $release, $inc, $stash);
    $self->_serialize_collection_list($release_node, $opts->{collections}, $inc, $stash, 0)
        if $opts->{collections} && @{ $opts->{collections}{items} };
        # MBS-8845: Don't output <collection-list count="0" />, since at breaks (at least) Picard.
}

sub _serialize_cover_art_archive
{
    my ($self, $parent_node, $release, $inc, $stash) = @_;

    my $coverart = $stash->store($release)->{'cover-art-archive'};

    my $caa_node = $parent_node->addNewChild(undef, 'cover-art-archive');

    $caa_node->appendTextChild('artwork', $release->cover_art_presence eq 'present' ? 'true' : 'false');
    $caa_node->appendTextChild('count', $coverart->{total} // 0);
    $caa_node->appendTextChild('front', $coverart->{front} ? 'true' : 'false');
    $caa_node->appendTextChild('back', $coverart->{back} ? 'true' : 'false');
    $caa_node->appendTextChild('darkened', 'true') if $release->cover_art_presence eq 'darkened';
}

sub _serialize_work_list
{
    my ($self, $parent_node, $list, $inc, $stash, $toplevel) = @_;

    my $list_node = $parent_node->addNewChild(undef, 'work-list');
    set_list_attributes($list_node, $list);

    foreach my $work (@{ $list->{items} })
    {
        $self->_serialize_work($list_node, $work, $inc, $stash, $toplevel);
    }
}

sub _serialize_work
{
    my ($self, $parent_node, $work, $inc, $stash, $toplevel) = @_;

    my $opts = $stash->store($work);

    my $work_node = $parent_node->addNewChild(undef, 'work');
    $work_node->_setAttribute('id', $work->gid);

    if (my $type = $work->type) {
        $work_node->_setAttribute('type', $type->name);
        $work_node->_setAttribute('type-id', $type->gid);
    }

    $work_node->appendTextChild('title', $work->name);

    if ($work->all_languages) {
        my @languages = map { $_->language->alpha_3_code } $work->all_languages;

        # Pre-MBS-5452 element.
        $work_node->appendTextChild('language', @languages > 1 ? 'mul' : $languages[0]);

        my $lang_list_node = $work_node->addNewChild(undef, 'language-list');
        $lang_list_node->appendTextChild('language', $_) for @languages;
    }

    if (my @iswcs = $work->all_iswcs) {
        $work_node->appendTextChild('iswc', $work->iswcs->[0]->iswc);
        my $iswc_list_node = $work_node->addNewChild(undef, 'iswc-list');
        $iswc_list_node->appendTextChild('iswc', $_->iswc) for @iswcs;
    }

    if (my @attributes = $work->all_attributes) {
        my $attr_list_node = $work_node->addNewChild(undef, 'attribute-list');
        for my $attr (@attributes) {
            my $attr_node = $attr_list_node->addNewChild(undef, 'attribute');
            $attr_node->appendText($attr->value);
            $attr_node->_setAttribute('value-id', $attr->value_gid) if defined $attr->value_gid;
            $attr_node->_setAttribute('type', $attr->type->name);
            $attr_node->_setAttribute('type-id', $attr->type->gid);
        }
    }

    $work_node->appendTextChild('disambiguation', $work->comment) if $work->comment;
    $self->_serialize_annotation($work_node, $work, $inc, $stash) if $toplevel;

    $self->_serialize_alias_list($work_node, $opts->{aliases}, $inc, $stash)
        if ($inc->aliases && $opts->{aliases});

    $self->_serialize_relation_lists($work_node, $work, $work->relationships, $inc, $stash) if $inc->has_rels;
    $self->_serialize_tags_and_ratings($work_node, $work, $inc, $stash);
}

sub _serialize_url
{
    my ($self, $parent_node, $url, $inc, $stash, $toplevel) = @_;

    $stash->store($url);

    my $url_node = $parent_node->addNewChild(undef, 'url');
    $url_node->_setAttribute('id', $url->gid);

    $url_node->appendTextChild('resource', $url->url);
    $self->_serialize_relation_lists($url_node, $url, $url->relationships, $inc, $stash) if $inc->has_rels;
}

sub _serialize_recording_list
{
    my ($self, $parent_node, $list, $inc, $stash, $toplevel) = @_;

    my $list_node = $parent_node->addNewChild(undef, 'recording-list');
    set_list_attributes($list_node, $list);

    foreach my $recording (@{ $list->{items} })
    {
        $self->_serialize_recording($list_node, $recording, $inc, $stash, $toplevel);
    }
}

sub _serialize_recording
{
    my ($self, $parent_node, $recording, $inc, $stash, $toplevel) = @_;

    my $opts = $stash->store($recording);

    my $rec_node = $parent_node->addNewChild(undef, 'recording');
    $rec_node->_setAttribute('id', $recording->gid);

    $rec_node->appendTextChild('title', $recording->name);
    $rec_node->appendTextChild('length', $recording->length) if $recording->length;
    $rec_node->appendTextChild('disambiguation', $recording->comment) if ($recording->comment);
    $rec_node->appendTextChild('video', 'true') if $recording->video;

    if ($toplevel)
    {
        $self->_serialize_annotation($rec_node, $recording, $inc, $stash);

        $self->_serialize_artist_credit($rec_node, $recording->artist_credit, $inc, $stash, $inc->artists)
            if $inc->artists || $inc->artist_credits;

        if (defined $recording->first_release_date) {
            $rec_node->appendTextChild('first-release-date', $recording->first_release_date->format);
        }

        $self->_serialize_release_list($rec_node, $opts->{releases}, $inc, $stash)
            if $inc->releases;
    }
    else
    {
        $self->_serialize_artist_credit($rec_node, $recording->artist_credit, $inc, $stash)
            if $inc->artist_credits;

        if (defined $recording->first_release_date) {
            $rec_node->appendTextChild('first-release-date', $recording->first_release_date->format);
        }
    }

    $self->_serialize_alias_list($rec_node, $opts->{aliases}, $inc, $opts)
        if ($inc->aliases && $opts->{aliases});

    $self->_serialize_isrc_list($rec_node, $opts->{isrcs}, $inc, $stash)
        if ($opts->{isrcs} && $inc->isrcs);

    $self->_serialize_relation_lists($rec_node, $recording, $recording->relationships, $inc, $stash) if ($inc->has_rels);
    $self->_serialize_tags_and_ratings($rec_node, $recording, $inc, $stash);

}

sub _serialize_medium_list
{
    my ($self, $parent_node, $mediums, $inc, $stash) = @_;

    my $list_node = $parent_node->addNewChild(undef, 'medium-list');
    $list_node->_setAttribute('count', scalar @$mediums);

    foreach my $medium (nsort_by { $_->position } @$mediums)
    {
        $self->_serialize_medium($list_node, $medium, $inc, $stash);
    }
}

sub _serialize_medium
{
    my ($self, $parent_node, $medium, $inc, $stash) = @_;

    my $med_node = $parent_node->addNewChild(undef, 'medium');

    $med_node->appendTextChild('title', $medium->name) if $medium->name;
    $med_node->appendTextChild('position', $medium->position);

    if (my $format = $medium->format) {
        add_type_elem($med_node, 'format', $format);
    }

    $self->_serialize_disc_list($med_node, $medium->cdtocs, $inc, $stash) if $inc->discids;
    $self->_serialize_tracks($med_node, $medium, $inc, $stash);
}

sub _serialize_tracks
{
    my ($self, $parent_node, $medium, $inc, $stash) = @_;

    # Not all tracks in the tracklists may have been loaded.  If not all
    # tracks have been loaded, only one them will have been loaded which
    # therefore can be represented as if a query had been performed with
    # limit = 1 and offset = track->position.

    my @tracks = nsort_by { $_->position } $medium->all_tracks;
    my $min = @tracks ? $tracks[0]->position : 0;

    if (@tracks && $medium->has_pregap) {
        $self->_serialize_track($parent_node, $tracks[0], $inc, $stash, 1);
    }

    my $track_list_node = $parent_node->addNewChild(undef, 'track-list');
    $track_list_node->_setAttribute('count', $medium->cdtoc_track_count);
    $track_list_node->_setAttribute('offset', $medium->has_pregap ? 0 : $min - 1) if @tracks;

    foreach my $track (@{ $medium->cdtoc_tracks }) {
        $min = $track->position if $track->position < $min;
        $self->_serialize_track($track_list_node, $track, $inc, $stash);
    }

    if (my @data_tracks = grep { $_->position > 0 && $_->is_data_track } @tracks) {
        my $data_track_list_node = $parent_node->addNewChild(undef, 'data-track-list');
        $data_track_list_node->_setAttribute('count', scalar @data_tracks);
        $self->_serialize_track($data_track_list_node, $_, $inc, $stash) for @data_tracks;
    }
}

sub _serialize_track
{
    my ($self, $parent_node, $track, $inc, $stash, $pregap) = @_;

    my $track_node = $parent_node->addNewChild(undef, $pregap ? 'pregap' : 'track');
    $track_node->_setAttribute('id', $track->gid);

    $track_node->appendTextChild('position', $track->position);
    $track_node->appendTextChild('number', $track->number);

    $track_node->appendTextChild('title', $track->name)
        if ($track->recording && $track->name ne $track->recording->name) ||
           (!$track->recording);

    $track_node->appendTextChild('length', $track->length) if $track->length;

    do {
        local $show_aliases = 1;
        $self->_serialize_artist_credit($track_node, $track->artist_credit, $inc, $stash)
            if $inc->artist_credits &&
                (
                    ($track->recording &&
                         $track->recording->artist_credit != $track->artist_credit)
                    || !$track->recording
                );
    };

    $self->_serialize_recording($track_node, $track->recording, $inc, $stash)
        if ($track->recording);
}

sub _serialize_disc_list
{
    my ($self, $parent_node, $cdtoclist, $inc, $stash) = @_;

    my $list_node = $parent_node->addNewChild(undef, 'disc-list');
    $list_node->_setAttribute('count', scalar @$cdtoclist);

    foreach my $cdtoc (sort_by { $_->cdtoc->discid } @$cdtoclist)
    {
        $self->_serialize_disc($list_node, $cdtoc->cdtoc, $inc, $stash);
    }
}

sub _serialize_disc
{
    my ($self, $parent_node, $cdtoc, $inc, $stash, $toplevel) = @_;

    my $opts = $stash->store($cdtoc);

    my $disc_node = $parent_node->addNewChild(undef, 'disc');
    $disc_node->_setAttribute('id', $cdtoc->discid);

    $disc_node->appendTextChild('sectors', $cdtoc->leadout_offset);

    $self->_serialize_disc_offsets($disc_node, $cdtoc, $inc, $stash);

    if ($toplevel) {
        $self->_serialize_release_list($disc_node, $opts->{releases}, $inc, $stash, $toplevel);
    }
}

sub _serialize_disc_offsets
{
    my ($self, $parent_node, $cdtoc, $inc, $stash) = @_;

    my $list_node = $parent_node->addNewChild(undef, 'offset-list');
    $list_node->_setAttribute('count', $cdtoc->track_count);

    foreach my $track (0 .. ($cdtoc->track_count - 1)) {
        my $offset_node = $list_node->addNewChild(undef, 'offset');
        $offset_node->appendText($cdtoc->track_offset->[$track]);
        $offset_node->_setAttribute('position', $track + 1);
    }
}

sub _serialize_cdstub
{
    my ($self, $parent_node, $cdstub, $inc, $stash, $toplevel) = @_;

    my $cdstub_node = $parent_node->addNewChild(undef, 'cdstub');
    $cdstub_node->_setAttribute('id', $cdstub->discid);

    $cdstub_node->appendTextChild('title', $cdstub->title);
    $cdstub_node->appendTextChild('artist', $cdstub->artist) if $cdstub->artist;
    $cdstub_node->appendTextChild('barcode', $cdstub->barcode) if $cdstub->barcode;
    $cdstub_node->appendTextChild('disambiguation', $cdstub->comment) if $cdstub->comment;

    my $track_list_node = $cdstub_node->addNewChild(undef, 'track-list');
    $track_list_node->_setAttribute('count', $cdstub->track_count);

    for my $track ($cdstub->all_tracks) {
        my $track_node = $track_list_node->addNewChild(undef, 'track');
        $track_node->appendTextChild('title', $track->title);
        $track_node->appendTextChild('artist', $track->artist) if $track->artist;
        $track_node->appendTextChild('length', $track->length);
    }
}

sub _serialize_label_info_list
{
    my ($self, $parent_node, $rel_labels, $inc, $stash) = @_;

    my $list_node = $parent_node->addNewChild(undef, 'label-info-list');
    $list_node->_setAttribute('count', scalar @$rel_labels);

    foreach my $rel_label (@$rel_labels)
    {
        $self->_serialize_label_info($list_node, $rel_label, $inc, $stash);
    }
}

sub _serialize_label_info
{
    my ($self, $parent_node, $rel_label, $inc, $stash) = @_;

    my $label_info_node = $parent_node->addNewChild(undef, 'label-info');

    $label_info_node->appendTextChild('catalog-number', $rel_label->catalog_number)
        if $rel_label->catalog_number;

    $self->_serialize_label($label_info_node, $rel_label->label, $inc, $stash)
        if $rel_label->label;
}

sub _serialize_label_list
{
    my ($self, $parent_node, $list, $inc, $stash, $toplevel) = @_;

    my $list_node = $parent_node->addNewChild(undef, 'label-list');
    set_list_attributes($list_node, $list);

    foreach my $label (@{ $list->{items} })
    {
        $self->_serialize_label($list_node, $label, $inc, $stash, $toplevel);
    }
}

sub _serialize_label
{
    my ($self, $parent_node, $label, $inc, $stash, $toplevel) = @_;

    my $opts = $stash->store($label);

    my $label_node = $parent_node->addNewChild(undef, 'label');
    $label_node->_setAttribute('id', $label->gid);

    if (my $type = $label->type) {
        $label_node->_setAttribute('type', $type->name);
        $label_node->_setAttribute('type-id', $type->gid);
    }

    $label_node->appendTextChild('name', $label->name);
    $label_node->appendTextChild('sort-name', $label->name);
    $label_node->appendTextChild('disambiguation', $label->comment) if $label->comment;
    $label_node->appendTextChild('label-code', $label->label_code) if $label->label_code;

    if (my @ipi_codes = $label->all_ipi_codes) {
        $label_node->appendTextChild('ipi', $ipi_codes[0]->ipi);
        my $ipi_list_node = $label_node->addNewChild(undef, 'ipi-list');
        $ipi_list_node->appendTextChild('ipi', $_->ipi) for @ipi_codes;
    }

    if (my @isni_codes = $label->all_isni_codes) {
        my $isni_list_node = $label_node->addNewChild(undef, 'isni-list');
        $isni_list_node->appendTextChild('isni', $_->isni) for @isni_codes;
    }

    if ($toplevel)
    {
        $self->_serialize_annotation($label_node, $label, $inc, $stash);

        if (my $area = $label->area) {
            my $country_code = $area->country_code;
            $label_node->appendTextChild('country', $country_code) if $country_code;
            $self->_serialize_area($label_node, $area, $inc, $stash, $toplevel);
        }

        $self->_serialize_life_span($label_node, $label, $inc, $stash);
    }

    $self->_serialize_alias_list($label_node, $opts->{aliases}, $inc, $stash)
        if ($inc->aliases && $opts->{aliases});

    if ($toplevel)
    {
        $self->_serialize_release_list($label_node, $opts->{releases}, $inc, $stash)
            if $inc->releases;
    }

    $self->_serialize_relation_lists($label_node, $label, $label->relationships, $inc, $stash) if ($inc->has_rels);
    $self->_serialize_tags_and_ratings($label_node, $label, $inc, $stash);
}

sub _serialize_area_list
{
    my ($self, $parent_node, $list, $inc, $stash, $toplevel) = @_;

    my $list_node = $parent_node->addNewChild(undef, 'area-list');
    set_list_attributes($list_node, $list);

    foreach my $area (@{ $list->{items} })
    {
        $self->_serialize_area($list_node, $area, $inc, $stash, $toplevel);
    }
}

sub _serialize_area_inner
{
    my ($self, $area_node, $area, $inc, $stash, $toplevel) = @_;

    my $opts = $stash->store($area);

    $area_node->_setAttribute('id', $area->gid);

    if (my $type = $area->type) {
        $area_node->_setAttribute('type', $type->name);
        $area_node->_setAttribute('type-id', $type->gid);
    }

    $area_node->appendTextChild('name', $area->name);
    $area_node->appendTextChild('sort-name', $area->name);
    $area_node->appendTextChild('disambiguation', $area->comment) if $area->comment;

    if (my @codes = $area->iso_3166_1_codes) {
        my $list_node = $area_node->addNewChild(undef ,'iso-3166-1-code-list');
        $list_node->appendTextChild('iso-3166-1-code', $_) for @codes;
    }

    if (my @codes = $area->iso_3166_2_codes) {
        my $list_node = $area_node->addNewChild(undef ,'iso-3166-2-code-list');
        $list_node->appendTextChild('iso-3166-2-code', $_) for @codes;
    }

    if (my @codes = $area->iso_3166_3_codes) {
        my $list_node = $area_node->addNewChild(undef ,'iso-3166-3-code-list');
        $list_node->appendTextChild('iso-3166-3-code', $_) for @codes;
    }

    if ($toplevel)
    {
        $self->_serialize_annotation($area_node, $area, $inc, $opts);
        $self->_serialize_life_span($area_node, $area, $inc, $opts);
    }

    $self->_serialize_alias_list($area_node, $opts->{aliases}, $inc, $opts)
        if ($inc->aliases && $opts->{aliases});

    $self->_serialize_relation_lists($area_node, $area, $area->relationships, $inc, $stash) if ($inc->has_rels);
    $self->_serialize_tags_and_ratings($area_node, $area, $inc, $stash);
}

sub _serialize_area
{
    my ($self, $parent_node, $area, $inc, $stash, $toplevel) = @_;

    my $area_node = $parent_node->addNewChild(undef, 'area');
    $self->_serialize_area_inner($area_node, $area, $inc, $stash, $toplevel);
}

sub _serialize_begin_area
{
    my ($self, $parent_node, $area, $inc, $stash, $toplevel) = @_;

    my $area_node = $parent_node->addNewChild(undef, 'begin-area');
    $self->_serialize_area_inner($area_node, $area, $inc, $stash, $toplevel);
}

sub _serialize_end_area
{
    my ($self, $parent_node, $area, $inc, $stash, $toplevel) = @_;

    my $area_node = $parent_node->addNewChild(undef, 'end-area');
    $self->_serialize_area_inner($area_node, $area, $inc, $stash, $toplevel);
}

sub _serialize_place_list
{
    my ($self, $parent_node, $list, $inc, $stash, $toplevel) = @_;

    my $list_node = $parent_node->addNewChild(undef, 'place-list');
    set_list_attributes($list_node, $list);

    foreach my $place (@{ $list->{items} })
    {
        $self->_serialize_place($list_node, $place, $inc, $stash, $toplevel);
    }
}

sub _serialize_place
{
    my ($self, $parent_node, $place, $inc, $stash, $toplevel) = @_;

    my $opts = $stash->store($place);

    my $place_node = $parent_node->addNewChild(undef, 'place');

    $place_node->_setAttribute('id', $place->gid);

    if (my $type = $place->type) {
        $place_node->_setAttribute('type', $type->name);
        $place_node->_setAttribute('type-id', $type->gid);
    }

    $place_node->appendTextChild('name', $place->name);
    $place_node->appendTextChild('disambiguation', $place->comment) if $place->comment;
    $place_node->appendTextChild('address', $place->address) if $place->address;
    $self->_serialize_coordinates($place_node, $place, $inc, $stash, $toplevel) if $place->coordinates;

    if ($toplevel)
    {
        $self->_serialize_annotation($place_node, $place, $inc, $stash);
        $self->_serialize_area($place_node, $place->area, $inc, $stash, $toplevel) if $place->area;
        $self->_serialize_life_span($place_node, $place, $inc, $stash);
    }

    $self->_serialize_alias_list($place_node, $opts->{aliases}, $inc, $stash)
        if ($inc->aliases && $opts->{aliases});

    $self->_serialize_relation_lists($place_node, $place, $place->relationships, $inc, $stash) if ($inc->has_rels);
    $self->_serialize_tags_and_ratings($place_node, $place, $inc, $stash);
}

sub _serialize_instrument_list {
    my ($self, $parent_node, $list, $inc, $stash, $toplevel) = @_;

    my $list_node = $parent_node->addNewChild(undef, 'instrument-list');
    set_list_attributes($list_node, $list);

    foreach my $instrument (@{ $list->{items} }) {
        $self->_serialize_instrument($list_node, $instrument, $inc, $stash, $toplevel);
    }
}

sub _serialize_instrument {
    my ($self, $parent_node, $instrument, $inc, $stash, $toplevel) = @_;

    my $opts = $stash->store($instrument);

    my $inst_node = $parent_node->addNewChild(undef, 'instrument');

    $inst_node->_setAttribute('id', $instrument->gid);

    if (my $type = $instrument->type) {
        $inst_node->_setAttribute('type', $type->name);
        $inst_node->_setAttribute('type-id', $type->gid);
    }

    $inst_node->appendTextChild('name', $instrument->name);
    $inst_node->appendTextChild('disambiguation', $instrument->comment) if $instrument->comment;
    $inst_node->appendTextChild('description', $instrument->description) if $instrument->description;

    if ($toplevel) {
        $self->_serialize_annotation($inst_node, $instrument, $inc, $stash);
    }

    $self->_serialize_alias_list($inst_node, $opts->{aliases}, $inc, $stash)
        if ($inc->aliases && $opts->{aliases});

    $self->_serialize_relation_lists($inst_node, $instrument, $instrument->relationships, $inc, $stash) if ($inc->has_rels);
    $self->_serialize_tags_and_ratings($inst_node, $instrument, $inc, $stash);
}

sub _serialize_relation_lists
{
    my ($self, $parent_node, $src_entity, $rels, $inc, $stash) = @_;

    my %types = ();

    foreach my $rel (@$rels)
    {
        $types{$rel->target_type} = [] if !exists $types{$rel->target_type};
        push @{$types{$rel->target_type}}, $rel;
    }
    foreach my $type (sort keys %types)
    {
        my $rel_list_node = $parent_node->addNewChild(undef, 'relation-list');
        $rel_list_node->_setAttribute('target-type', $type);

        foreach my $rel (@{$types{$type}}) {
            $self->_serialize_relation($rel_list_node, $src_entity, $rel, $inc, $stash);
        }
    }
}

sub _serialize_relation
{
    my ($self, $parent, $src_entity, $rel, $inc, $stash) = @_;

    my $target = $rel->target;
    my $target_type = $rel->target_type;
    my $link = $rel->link;
    my $link_type = $link->type;

    my $rel_node = $parent->addNewChild(undef, 'relation');
    $rel_node->_setAttribute('type', $link_type->name);
    $rel_node->_setAttribute('type-id', $link_type->gid);

    if ($target_type eq 'url') {
        my $target_node = $rel_node->addNewChild(undef, 'target');
        $target_node->_setAttribute('id', $target->gid);
        $target_node->appendText($target->url);
    } else {
        $rel_node->appendTextChild('target', $target->gid);
    }

    $rel_node->appendTextChild('ordering-key', $rel->link_order) if $rel->link_order;
    if ($rel->direction == $DIRECTION_BACKWARD) {
        $rel_node->appendTextChild('direction', 'backward');
    } else {
        $rel_node->appendTextChild('direction', 'forward');
    }

    my $begin_date = $link->begin_date;
    my $end_date = $link->end_date;

    $rel_node->appendTextChild('begin', $begin_date->format) unless $begin_date->is_empty;
    $rel_node->appendTextChild('end', $end_date->format) unless $end_date->is_empty;
    $rel_node->appendTextChild('ended', 'true') if $link->ended;

    if (my @attributes = $link->all_attributes) {
        my $attr_list_node = $rel_node->addNewChild(undef, 'attribute-list');

        for my $attr (@attributes) {
            my $attr_type = $attr->type;
            my $attr_elem = $attr_list_node->addNewChild(undef, 'attribute');
            $attr_elem->appendText($attr_type->name);
            $attr_elem->_setAttribute('type-id', $attr_type->gid);

            if (non_empty($attr->text_value)) {
                $attr_elem->_setAttribute('value', $attr->text_value);
            } elsif (non_empty($attr->credited_as)) {
                $attr_elem->_setAttribute('credited-as', $attr->credited_as);
            }
        }
    }

    unless ($target_type eq 'url')
    {
        my $method =  '_serialize_' . $target_type;

        local $in_relation_node = 1;
        local $show_aliases = 0;

        $self->$method($rel_node, $rel->target, $inc, $stash);
    }

    if (my $source_credit = $rel->source_credit) {
        $rel_node->appendTextChild('source-credit', $source_credit);
    }

    if (my $target_credit = $rel->target_credit) {
        $rel_node->appendTextChild('target-credit', $target_credit);
    }
}

sub _serialize_series_list
{
    my ($self, $parent_node, $list, $inc, $stash, $toplevel) = @_;

    my $list_node = $parent_node->addNewChild(undef, 'series-list');
    set_list_attributes($list_node, $list);

    foreach my $series (@{ $list->{items} })
    {
        $self->_serialize_series($list_node, $series, $inc, $stash, $toplevel);
    }
}

sub _serialize_series
{
    my ($self, $parent_node, $series, $inc, $stash, $toplevel) = @_;

    my $opts = $stash->store($series);

    my $series_node = $parent_node->addNewChild(undef, 'series');

    $series_node->_setAttribute('id', $series->gid);

    if (my $type = $series->type) {
        $series_node->_setAttribute('type', $type->name);
        $series_node->_setAttribute('type-id', $type->gid);
    }

    $series_node->appendTextChild('name', $series->name);
    $series_node->appendTextChild('disambiguation', $series->comment) if $series->comment;

    if ($toplevel) {
        $self->_serialize_annotation($series_node, $series, $inc, $stash);
    }

    $self->_serialize_alias_list($series_node, $opts->{aliases}, $inc, $stash)
        if ($inc->aliases && $opts->{aliases});

    $self->_serialize_relation_lists($series_node, $series, $series->relationships, $inc, $stash) if ($inc->has_rels);
    $self->_serialize_tags_and_ratings($series_node, $series, $inc, $stash);
}

sub _serialize_event_list
{
    my ($self, $parent_node, $list, $inc, $stash, $toplevel) = @_;

    my $list_node = $parent_node->addNewChild(undef, 'event-list');
    set_list_attributes($list_node, $list);

    foreach my $event (@{ $list->{items} })
    {
        $self->_serialize_event($list_node, $event, $inc, $stash, $toplevel);
    }
}

sub _serialize_event
{
    my ($self, $parent_node, $event, $inc, $stash, $toplevel) = @_;

    my $opts = $stash->store($event);

    my $event_node = $parent_node->addNewChild(undef, 'event');
    $event_node->_setAttribute('id', $event->gid);

    if (my $type = $event->type) {
        $event_node->_setAttribute('type', $type->name);
        $event_node->_setAttribute('type-id', $type->gid);
    }

    $event_node->appendTextChild('name', $event->name);
    $event_node->appendTextChild('disambiguation', $event->comment) if $event->comment;

    $event_node->appendTextChild('cancelled', 'true') if $event->cancelled;

    $self->_serialize_life_span($event_node, $event, $inc, $stash);

    if (my $time = $event->formatted_time) {
        $event_node->appendTextChild('time', $time);
    }

    $event_node->appendTextChild('setlist', $event->setlist) if $event->setlist;

    $self->_serialize_annotation($event_node, $event, $inc, $stash) if $toplevel;

    $self->_serialize_alias_list($event_node, $opts->{aliases}, $inc, $stash)
        if ($inc->aliases && $opts->{aliases});

    $self->_serialize_relation_lists($event_node, $event, $event->relationships, $inc, $stash)
        if $inc->has_rels;
    $self->_serialize_tags_and_ratings($event_node, $event, $inc, $stash);
}

sub _serialize_isrc_list
{
    my ($self, $parent_node, $isrcs, $inc, $stash, $toplevel) = @_;

    my $list_node = $parent_node->addNewChild(undef, 'isrc-list');
    $list_node->_setAttribute('count', scalar @$isrcs);

    foreach my $isrc (sort_by { $_->isrc } @{$isrcs})
    {
        $self->_serialize_isrc($list_node, $isrc, $inc, $stash, $toplevel);
    }
}

sub _serialize_isrc
{
    my ($self, $parent_node, $isrc, $inc, $stash, $toplevel) = @_;

    my $isrc_node = $parent_node->addNewChild(undef, 'isrc');
    $isrc_node->_setAttribute('id', $isrc->isrc);

    if ($toplevel) {
        my $opts = $stash->store($isrc);
        my @recordings = @{ $opts->{recordings}{items} // [] };

        if (@recordings) {
            my $recordings = {
                items => \@recordings,
                total => scalar @recordings,
            };
            $self->_serialize_recording_list($isrc_node, $recordings, $inc, $stash, $toplevel)
        }
    }
}

sub _serialize_tags_and_ratings
{
    my ($self, $parent_node, $entity, $inc, $stash) = @_;

    my $opts = $stash->store($entity);

    $self->_serialize_tag_list($parent_node, $entity, $inc, $stash)
        if $opts->{tags} && $inc->{tags};
    $self->_serialize_user_tag_list($parent_node, $entity, $inc, $stash)
        if $opts->{user_tags} && $inc->{user_tags};
    if ($opts->{genres} && $inc->{genres}) {
        my @genre_tags = sort_by { $_->tag->name } @{$opts->{genres}};
        my $genres = [map {$_->tag->genre} @genre_tags];
        # Total is not used here for parity with tag-list
        my $genre_hash = {items => $genres};
        my %genre_counts = map { $_->tag->genre_id => $_->count } @genre_tags;
        $self->_serialize_genre_list(
            $parent_node,
            $genre_hash,
            $inc,
            $stash,
            0,
            \%genre_counts,
        );
    }
    $self->_serialize_user_genre_list($parent_node, $entity, $inc, $stash)
        if $opts->{user_genres} && $inc->{user_genres};
    $self->_serialize_rating($parent_node, $entity, $inc, $stash)
        if $opts->{ratings} && $inc->{ratings};
    $self->_serialize_user_rating($parent_node, $entity, $inc, $stash)
        if $opts->{user_ratings} && $inc->{user_ratings};
}

sub _serialize_tag_list
{
    my ($self, $parent_node, $entity, $inc, $stash) = @_;
    return if $in_relation_node;

    my $opts = $stash->store($entity);
    my $list_node = $parent_node->addNewChild(undef, 'tag-list');

    foreach my $tag (sort_by { $_->tag->name } @{$opts->{tags}})
    {
        $self->_serialize_tag($list_node, $tag);
    }
}

sub _serialize_tag
{
    my ($self, $parent_node, $tag) = @_;

    my $genre_node = $parent_node->addNewChild(undef, 'tag');
    $genre_node->_setAttribute('count', $tag->count);
    $genre_node->appendTextChild('name', $tag->tag->name);
}

sub _serialize_genre_list
{
    my (
        $self,
        $parent_node,
        $list,
        $inc,
        $stash,
        $toplevel,
        $genre_counts
    ) = @_;

    return if $in_relation_node;

    my $list_node = $parent_node->addNewChild(undef, 'genre-list');

    if ($toplevel) {
        set_list_attributes($list_node, $list);
    }

    foreach my $genre (@{ $list->{items} })
    {
        $self->_serialize_genre(
            $list_node,
            $genre,
            $inc,
            $stash,
            $toplevel,
            $genre_counts->{$genre->id}
        );
    }
}

sub _serialize_genre
{
    my ($self, $parent_node, $genre, $inc, $stash, $toplevel, $use_count) = @_;

    my $genre_node = $parent_node->addNewChild(undef, 'genre');
    $genre_node->_setAttribute('count', $use_count) if defined $use_count;
    $genre_node->_setAttribute('id', $genre->gid);
    $genre_node->appendTextChild('name', $genre->name);
    $genre_node->appendTextChild('disambiguation', $genre->comment) if $genre->comment;
}

sub _serialize_user_tag_list
{
    my ($self, $parent_node, $entity, $inc, $stash) = @_;

    my $opts = $stash->store($entity);
    my $list_node = $parent_node->addNewChild(undef, 'user-tag-list');

    foreach my $tag (sort_by { $_->tag->name } @{$opts->{user_tags}})
    {
        $self->_serialize_user_tag($list_node, $tag);
    }
}

sub _serialize_user_tag
{
    my ($self, $parent_node, $tag) = @_;

    if ($tag->is_upvote) {
        $parent_node->addNewChild(undef, 'user-tag')->appendTextChild('name', $tag->tag->name);
    }
}

sub _serialize_user_genre_list
{
    my ($self, $parent_node, $entity, $inc, $stash) = @_;

    my $opts = $stash->store($entity);
    my $list_node = $parent_node->addNewChild(undef, 'user-genre-list');

    foreach my $tag (sort_by { $_->tag->name } @{$opts->{user_genres}})
    {
        $self->_serialize_user_genre($list_node, $tag);
    }
}

sub _serialize_user_genre
{
    my ($self, $parent_node, $tag) = @_;

    if ($tag->is_upvote) {
        my $genre_node = $parent_node->addNewChild(undef, 'user-genre');
        $genre_node->_setAttribute('id', $tag->tag->genre->gid);
        $genre_node->appendTextChild('name', $tag->tag->name);
    }
}

sub _serialize_rating
{
    my ($self, $parent_node, $entity, $inc, $stash) = @_;

    my $opts = $stash->store($entity);
    my $count = $opts->{ratings}{count};
    my $rating = $opts->{ratings}{rating};

    my $rating_node = $parent_node->addNewChild(undef, 'rating');
    $rating_node->appendText($rating);
    $rating_node->_setAttribute('votes-count', $count);
}

sub _serialize_user_rating
{
    my ($self, $parent_node, $entity, $inc, $stash) = @_;

    my $opts = $stash->store($entity);

    return '' unless $opts->{user_ratings};

    $parent_node->appendTextChild('user-rating', $opts->{user_ratings});
}

sub _create_metadata_node {
    my ($dom) = @_;

    my $metadata = $dom->createElement('metadata');
    $metadata->setAttribute('xmlns', 'http://musicbrainz.org/ns/mmd-2.0#');
    $dom->setDocumentElement($metadata);
    return $metadata;
}

sub output_error
{
    my ($self, $err) = @_;

    my $dom = XML::LibXML::Document->createDocument('1.0', 'UTF-8');
    my $error_node = $dom->createElement('error');
    $dom->setDocumentElement($error_node);

    $error_node->appendTextChild('text', $err);
    $error_node->appendTextChild('text', 'For usage, please see: https://musicbrainz.org/development/mmd');

    return IO::String->new($dom->toString());
}

sub output_success
{
    my ($self, $msg) = @_;

    $msg ||= 'OK';

    my $dom = XML::LibXML::Document->createDocument('1.0', 'UTF-8');
    my $metadata = _create_metadata_node($dom);

    my $msg_node = $metadata->addNewChild(undef, 'message');
    $msg_node->appendTextChild('text', $msg);

    return IO::String->new($dom->toString());
}

sub serialize
{
    my ($self, $type, $entity, $inc, $stash) = @_;
    $inc ||= 0;

    my $dom = XML::LibXML::Document->createDocument('1.0', 'UTF-8');

    my $metadata = $dom->createElement('metadata');
    $metadata->setAttribute('xmlns', 'http://musicbrainz.org/ns/mmd-2.0#');
    $dom->setDocumentElement($metadata);

    my $method = '_serialize_' . ($type =~ tr/-/_/r);
    $self->$method($metadata, $entity, $inc, $stash, 1);

    # $dom->toString() produces an encoded byte string. Wrapping it in an
    # IO::String prevents Catalyst from double-encoding the request body.
    return IO::String->new($dom->toString());
}

__PACKAGE__->meta->make_immutable;
no Moose;
1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2010-2013 MetaBrainz Foundation
Copyright (C) 2009 Lukas Lalinsky
Copyright (C) 2004, 2010 Robert Kaye

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
