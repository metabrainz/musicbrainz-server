package MusicBrainz::Server::WebService::XMLSerializer;
use Moose;
use 5.10.0;

use Scalar::Util 'reftype';
use Readonly;
use List::UtilsBy qw( nsort_by sort_by );
use MusicBrainz::Server::Constants qw( :quality );
use MusicBrainz::Server::WebService::Escape qw( xml_escape );
use MusicBrainz::Server::Entity::Relationship;
use MusicBrainz::Server::Validation;
use XML::Genx::Simple;

use aliased 'MusicBrainz::Server::WebService::WebServiceInc';
use aliased 'MusicBrainz::Server::WebService::WebServiceStash';

sub mime_type { 'application/xml' }
sub fmt { 'xml' }

sub _list_attributes
{
    my ($self, $list, $gen) = @_;

    $gen->_DeclaredAttribute('count')->AddAttribute($list->{total})
        if defined $list->{total};

    $gen->_DeclaredAttribute('offset')->AddAttribute($list->{offset})
        if $list->{offset};
}

sub _serialize_life_span
{
    my ($self, $gen, $entity, $inc, $opts) = @_;

    my $has_begin_date = !$entity->begin_date->is_empty;
    my $has_end_date = !$entity->end_date->is_empty;
    if ($has_begin_date || $has_end_date || $entity->ended) {
        $gen->_DeclaredElement('life-span')->StartElement;
        $gen->Element(begin => $entity->begin_date->format) if $has_begin_date;
        $gen->Element(end => $entity->end_date->format) if $has_end_date;
        $gen->Element(ended => 'true') if $entity->ended;
        $gen->EndElement;
    }
}

sub _serialize_text_representation
{
    my ($self, $gen, $entity, $inc, $opts) = @_;

    if ($entity->language || $entity->script)
    {
        $gen->_DeclaredElement('text-representation')->StartElement;
        $gen->Element(language => $entity->language->iso_code_3 // $entity->language->iso_code_2t)
            if $entity->language;
        $gen->Element(script => $entity->script->iso_code) if $entity->script;
        $gen->EndElement;
    }
}

sub _serialize_alias
{
    my ($self, $gen, $aliases, $inc, $opts) = @_;

    if (@$aliases)
    {
        $gen->_DeclaredElement('alias-list')->StartElement;
        $gen->_DeclaredAttribute('count')->AddAttribute(scalar(@$aliases));

        for my $al (sort_by { $_->name } @$aliases) {
            $gen->Element(
                alias => $al->name,
                $al->locale ? ( locale => $al->locale ) : (),
                'sort-name' => $al->sort_name,
                $al->type ? ( type => $al->type_name ) : (),
                $al->primary_for_locale ? (primary => 'primary') : (),
                !$al->begin_date->is_empty ? ( 'begin-date' => $al->begin_date->format ) : (),
                !$al->end_date->is_empty ? ( 'end-date' => $al->end_date->format ) : ()
            );
        }

        $gen->EndElement;
    }
}

sub _serialize_artist_list
{
    my ($self, $gen, $list, $inc, $stash) = @_;

    if (@{ $list->{items} }) {
        $gen->_DeclaredElement('artist-list')->StartElement;
        $self->_list_attributes ($list, $gen);

        for my $artist (sort_by { $_->gid } @{ $list->{items} }) {
            $self->_serialize_artist($gen, $artist, $inc, $stash, 1);
        }

        $gen->EndElement;
    }
}

sub _serialize_artist
{
    my ($self, $gen, $artist, $inc, $stash, $toplevel) = @_;

    my $opts = $stash->store ($artist);

    $gen->_DeclaredElement('artist')->StartElement;
    $gen->_DeclaredAttribute('id')->AddAttribute($artist->gid);
    $gen->_DeclaredAttribute('type')->AddAttribute($artist->type->name) if ($artist->type);

    $gen->Element(name => $artist->name);
    $gen->Element('sort-name' => $artist->sort_name) if ($artist->sort_name);
    $gen->Element(disambiguation => $artist->comment) if ($artist->comment);
    $gen->Element(ipi => $artist->ipi_codes->[0]->ipi) if ($artist->all_ipi_codes);

    if ($artist->all_ipi_codes) {
        $gen->_DeclaredElement('ipi-list')->StartElement;
        for my $ipi ($artist->all_ipi_codes) {
            $gen->Element(ipi => $ipi->ipi);
        }
        $gen->EndElement;
    }

    if ($toplevel) {
        $gen->Element(gender => $artist->gender->name) if ($artist->gender);
        $gen->Element(country => $artist->country->iso_code) if ($artist->country);

        $self->_serialize_life_span($gen, $artist, $inc, $opts);
    }

    $self->_serialize_alias($gen, $opts->{aliases}, $inc, $opts)
        if ($inc->aliases && $opts->{aliases});

    if ($toplevel)
    {
        $self->_serialize_recording_list($gen, $opts->{recordings}, $inc, $stash)
            if $inc->recordings;

        $self->_serialize_release_list($gen, $opts->{releases}, $inc, $stash)
            if $inc->releases;

        $self->_serialize_release_group_list($gen, $opts->{release_groups}, $inc, $stash)
            if $inc->release_groups;

        $self->_serialize_work_list($gen, $opts->{works}, $inc, $stash)
            if $inc->works;
    }

    $self->_serialize_relation_lists($artist, $gen, $artist->relationships, $inc, $stash) if ($inc->has_rels);
    $self->_serialize_tags_and_ratings($gen, $inc, $opts);

    $gen->EndElement;
}

sub _serialize_artist_credit
{
    my ($self, $gen, $artist_credit, $inc, $stash, $toplevel) = @_;

    $gen->_DeclaredElement('artist-credit')->StartElement;

    for my $name (@{$artist_credit->names}) {
        $gen->_DeclaredElement('name-credit')->StartElement;
        $gen->_DeclaredAttribute('joinphrase')->AddAttribute($name->join_phrase)
            if ($name->join_phrase);

        $gen->Element(name => $name->name) if ($name->name ne $name->artist->name);
        $self->_serialize_artist($gen, $name->artist, $inc, $stash);

        $gen->EndElement;
    }

    $gen->EndElement;
}

sub _serialize_collection
{
    my ($self, $gen, $collection, $inc, $stash, $toplevel) = @_;

    my $opts = $stash->store ($collection);

    $gen->_DeclaredElement('collection')->StartElement;
    $gen->_DeclaredAttribute('id')->AddAttribute($collection->gid);

    $gen->Element(name => $collection->name);
    $gen->Element(editor => $collection->editor->name);

    if ($toplevel)
    {
        $self->_serialize_release_list($gen, $opts->{releases}, $inc, $stash);
    }
    elsif ($collection->loaded_release_count) {
        $gen->Element('release-list' => '', count => $collection->release_count);
    }

    $gen->EndElement;
}

sub _serialize_collection_list
{
    my ($self, $gen, $collections, $inc, $stash, $toplevel) = @_;

    $gen->_DeclaredElement('collection-list')->StartElement;

    $self->_serialize_collection($gen, $_, $inc, $stash, 0)
        for sort_by { $_->gid } @$collections;

    $gen->EndElement;
}

sub _serialize_release_group_list
{
    my ($self, $gen, $list, $inc, $stash, $toplevel) = @_;

    $gen->_DeclaredElement('release-group-list')->StartElement;
    $self->_list_attributes ($list, $gen);

    for my $rg (sort_by { $_->gid } @{ $list->{items} })
    {
        $self->_serialize_release_group($gen, $rg, $inc, $stash, $toplevel);
    }

    $gen->EndElement;
}

sub _serialize_release_group
{
    my ($self, $gen, $release_group, $inc, $stash, $toplevel) = @_;

    my $opts = $stash->store ($release_group);

    my $type;
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

        $type = $fallback || $release_group->primary_type->name;
    }
    elsif ($release_group->primary_type) {
        $type = $release_group->primary_type->name;
    }
    elsif ($release_group->all_secondary_types) {
        $type = $release_group->secondary_types->[0]->name;
    }

    $gen->_DeclaredElement('release-group')->StartElement;
    $gen->_DeclaredAttribute('id')->AddAttribute($release_group->gid);
    $gen->_DeclaredAttribute('type')->AddAttribute($type) if $type;

    $gen->Element(title => $release_group->name);
    $gen->Element(disambiguation => $release_group->comment) if $release_group->comment;
    $gen->Element('first-release-date' => $release_group->first_release_date->format);

    $gen->Element('primary-type' => $release_group->primary_type->name)
        if $release_group->primary_type;

    if ($release_group->all_secondary_types) {
        $gen->_DeclaredElement('secondary-type-list')->StartElement;
        $gen->Element('secondary-type' => $_->name) for $release_group->all_secondary_types;
        $gen->EndElement;
    }

    if ($toplevel) {
        $self->_serialize_artist_credit($gen, $release_group->artist_credit, $inc, $stash, $inc->artists)
            if $inc->artists || $inc->artist_credits;

        $self->_serialize_release_list($gen, $opts->{releases}, $inc, $stash)
            if $inc->releases;
    }
    else
    {
        $self->_serialize_artist_credit($gen, $release_group->artist_credit, $inc, $stash)
            if $inc->artist_credits;
    }

    $self->_serialize_relation_lists($release_group, $gen, $release_group->relationships, $inc, $stash) if $inc->has_rels;
    $self->_serialize_tags_and_ratings($gen, $inc, $opts);

    $gen->EndElement;
}

sub _serialize_release_list
{
    my ($self, $gen, $list, $inc, $stash, $toplevel) = @_;

    $gen->_DeclaredElement('release-list')->StartElement;
    $self->_list_attributes ($list, $gen);

    foreach my $release (sort_by { $_->gid } @{ $list->{items} })
    {
        $self->_serialize_release($gen, $release, $inc, $stash, $toplevel);
    }

    $gen->EndElement;
}

sub _serialize_quality
{
    my ($self, $gen, $release, $inc) = @_;
    my %quality_names = (
        $QUALITY_LOW => 'low',
        $QUALITY_NORMAL => 'normal',
        $QUALITY_HIGH => 'high'
    );

    my $quality =
        $release->quality == $QUALITY_UNKNOWN ? $QUALITY_UNKNOWN_MAPPED
                                              : $release->quality;

    $gen->Element(quality => $quality_names{$quality});
}

sub _serialize_release
{
    my ($self, $gen, $release, $inc, $stash, $toplevel) = @_;

    my $opts = $stash->store ($release);

    $inc = $inc->clone ( releases => 0 );

    $gen->_DeclaredElement('release')->StartElement;
    $gen->_DeclaredAttribute('id')->AddAttribute($release->gid);

    $gen->Element(title => $release->name);
    $gen->Element(status => $release->status->name) if $release->status;
    $gen->Element(disambiguation => $release->comment) if $release->comment;
    $gen->Element(packaging => $release->packaging->name) if $release->packaging;

    $self->_serialize_quality($gen, $release, $inc, $opts);
    $self->_serialize_text_representation($gen, $release, $inc, $opts);

    if ($toplevel)
    {
        $self->_serialize_artist_credit($gen, $release->artist_credit, $inc, $stash, $inc->artists)
            if $inc->artist_credits || $inc->artists;
    }
    else
    {
        $self->_serialize_artist_credit($gen, $release->artist_credit, $inc, $stash)
            if $inc->artist_credits;
    }

    $self->_serialize_release_group($gen, $release->release_group, $inc, $stash)
            if ($release->release_group && $inc->release_groups);

    $gen->Element(date => $release->date->format) if $release->date && !$release->date->is_empty;
    $gen->Element(country => $release->country->iso_code) if $release->country;
    $gen->Element(barcode => $release->barcode) if $release->barcode;
    $gen->Element(asin => $release->amazon_asin) if $release->amazon_asin;

    if ($toplevel)
    {
        $self->_serialize_label_info_list($gen, $release->labels, $inc, $stash)
            if ($release->labels && $inc->labels);

    }

    $self->_serialize_medium_list($gen, $release->mediums, $inc, $stash)
        if ($release->mediums && ($inc->media || $inc->discids || $inc->recordings));

    $self->_serialize_relation_lists($release, $gen, $release->relationships, $inc, $stash) if ($inc->has_rels);
    $self->_serialize_tags_and_ratings($gen, $inc, $opts);
    $self->_serialize_collection_list($gen, $opts->{collections}, $inc, $stash, 0)
        if ($opts->{collections} && @{ $opts->{collections} });

    $gen->EndElement;
}

sub _serialize_work_list
{
    my ($self, $gen, $list, $inc, $stash, $toplevel) = @_;

    $gen->_DeclaredElement('work-list')->StartElement;
    $self->_list_attributes ($list, $gen);

    foreach my $work (sort_by { $_->gid } @{ $list->{items} })
    {
        $self->_serialize_work($gen, $work, $inc, $stash, $toplevel);
    }

    $gen->EndElement;
}

sub _serialize_work
{
    my ($self, $gen, $work, $inc, $stash, $toplevel) = @_;

    my $opts = $stash->store ($work);

    $gen->_DeclaredElement('work')->StartElement;
    $gen->_DeclaredAttribute('id')->AddAttribute($work->gid);
    $gen->_DeclaredAttribute('type')->AddAttribute($work->type->name) if ($work->type);

    $gen->Element(title => $work->name);
    $gen->Element(language => $work->language->iso_code_3 // $work->language->iso_code_2t) if $work->language;

    if ($work->all_iswcs) {
        $gen->Element(iswc => $work->iswcs->[0]->iswc);
        $gen->_DeclaredElement('iswc-list')->StartElement;
        $gen->Element(iswc => $_->iswc) for $work->all_iswcs;
        $gen->EndElement;
    }

    $gen->Element(disambiguation => $work->comment) if ($work->comment);

    $self->_serialize_alias($gen, $opts->{aliases}, $inc, $opts)
        if ($inc->aliases && $opts->{aliases});

    $self->_serialize_relation_lists($work, $gen, $work->relationships, $inc, $stash) if $inc->has_rels;
    $self->_serialize_tags_and_ratings($gen, $inc, $opts);

    $gen->EndElement;
}

sub _serialize_recording_list
{
    my ($self, $gen, $list, $inc, $stash, $toplevel) = @_;

    $gen->_DeclaredElement('recording-list')->StartElement;
    $self->_list_attributes ($list, $gen);

    for my $recording (sort_by { $_->gid } @{ $list->{items} }) {
        $self->_serialize_recording($gen, $recording, $inc, $stash, $toplevel);
    }

    $gen->EndElement;
}

sub _serialize_recording
{
    my ($self, $gen, $recording, $inc, $stash, $toplevel) = @_;

    my $opts = $stash->store ($recording);

    $gen->_DeclaredElement('recording')->StartElement;
    $gen->_DeclaredAttribute('id')->AddAttribute($recording->gid);

    $gen->Element(title => $recording->name);
    $gen->Element(length => $recording->length) if $recording->length;
    $gen->Element(disambiguation => $recording->comment) if ($recording->comment);

    if ($toplevel)
    {
        $self->_serialize_artist_credit($gen, $recording->artist_credit, $inc, $stash, $inc->artists)
            if $inc->artists || $inc->artist_credits;

        $self->_serialize_release_list($gen, $opts->{releases}, $inc, $stash)
            if $inc->releases;
    }
    else
    {
        $self->_serialize_artist_credit($gen, $recording->artist_credit, $inc, $stash)
            if $inc->artist_credits;
    }

    $self->_serialize_puid_list($gen, $opts->{puids}, $inc, $stash)
        if ($opts->{puids} && $inc->puids);
    $self->_serialize_isrc_list($gen, $opts->{isrcs}, $inc, $stash)
        if ($opts->{isrcs} && $inc->isrcs);

    $self->_serialize_relation_lists($recording, $gen, $recording->relationships, $inc, $stash) if ($inc->has_rels);
    $self->_serialize_tags_and_ratings($gen, $inc, $opts);

    $gen->EndElement;

}

sub _serialize_medium_list
{
    my ($self, $gen, $mediums, $inc, $stash) = @_;

    $gen->_DeclaredElement('medium-list')->StartElement;
    $gen->_DeclaredAttribute('count')->AddAttribute(scalar(@$mediums));
    for my $medium (nsort_by { $_->position } @$mediums) {
        $self->_serialize_medium($gen, $medium, $inc, $stash);
    }
    $gen->EndElement;
}

sub _serialize_medium
{
    my ($self, $gen, $medium, $inc, $stash) = @_;

    $gen->_DeclaredElement('medium')->StartElement;

    $gen->Element(title => $medium->name) if $medium->name;
    $gen->Element(position => $medium->position);
    $gen->Element(format => $medium->format->name) if ($medium->format);
    $self->_serialize_disc_list($gen, $medium->cdtocs, $inc, $stash) if ($inc->discids);

    $self->_serialize_track_list($gen, $medium->tracklist, $inc, $stash);

    $gen->EndElement;
}

sub _serialize_track_list
{
    my ($self, $gen, $tracklist, $inc, $stash) = @_;

    # Not all tracks in the tracklists may have been loaded.  If not all
    # tracks have been loaded, only one them will have been loaded which
    # therefore can be represented as if a query had been performed with
    # limit = 1 and offset = track->position.

    my $min = @{$tracklist->tracks} ? $tracklist->tracks->[0]->position : 0;

    foreach my $track (nsort_by { $_->position } @{$tracklist->tracks}) {
        $min = $track->position if $track->position < $min;
    }

    $gen->_DeclaredElement('track-list')->StartElement;
    $gen->_DeclaredAttribute('count')->AddAttribute($tracklist->track_count);
    $gen->_DeclaredAttribute('offset')->AddAttribute($min - 1)
        if $min > 0;

    foreach my $track (nsort_by { $_->position } @{$tracklist->tracks}) {
        $self->_serialize_track($gen, $track, $inc, $stash);
    }

    $gen->EndElement;
}

sub _serialize_track
{
    my ($self, $gen, $track, $inc, $stash) = @_;

    $gen->_DeclaredElement('track')->StartElement;

    $gen->Element(position => $track->position);
    $gen->Element(number => $track->number);

    $gen->Element(title => $track->name)
        if ($track->recording && $track->name ne $track->recording->name) ||
           (!$track->recording);

    $gen->Element(length => $track->length)
        if $track->length;

    $self->_serialize_artist_credit($gen, $track->artist_credit, $inc, $stash)
        if $inc->artist_credits &&
            (
                ($track->recording &&
                     $track->recording->artist_credit != $track->artist_credit)
                || !$track->recording
            );

    $self->_serialize_recording($gen, $track->recording, $inc, $stash)
        if ($track->recording);

    $gen->EndElement;
}

sub _serialize_disc_list
{
    my ($self, $gen, $cdtoclist, $inc, $stash) = @_;

    $gen->_DeclaredElement('disc-list')->StartElement;
    $gen->_DeclaredAttribute('count')->AddAttribute(scalar(@$cdtoclist));
    foreach my $cdtoc (sort_by { $_->cdtoc->discid } @$cdtoclist)
    {
        $self->_serialize_disc($gen, $cdtoc->cdtoc, $inc, $stash);
    }
    $gen->EndElement;
}

sub _serialize_disc
{
    my ($self, $gen, $cdtoc, $inc, $stash, $toplevel) = @_;

    my $opts = $stash->store ($cdtoc);

    $gen->_DeclaredElement('disc')->StartElement;
    $gen->_DeclaredAttribute('id')->AddAttribute($cdtoc->discid);

    $gen->Element(sectors => $cdtoc->leadout_offset);

    if ($toplevel)
    {
        $self->_serialize_release_list($gen, $opts->{releases}, $inc, $stash, $toplevel);
    }

    $gen->EndElement;
}

sub _serialize_cdstub
{
    my ($self, $gen, $toc, $inc, $stash, $toplevel) = @_;

    my $cdstub = $toc->cdstub;

    $gen->_DeclaredElement('cdstub')->StartElement;
    $gen->_DeclaredAttribute('id')->AddAttribute($toc->discid);

    $gen->Element(title => $cdstub->title);
    $gen->Element(artist => $cdstub->artist);
    $gen->Element(barcode => $cdstub->barcode)
        if $cdstub->barcode;
    $gen->Element(disambiguation => $cdstub->comment)
        if $cdstub->comment;

    $gen->_DeclaredElement('track-list')->StartElement;
    $gen->_DeclaredAttribute('count')->AddAttribute($cdstub->track_count);

    for my $track ($cdstub->all_tracks) {
        $gen->_DeclaredElement('track')->StartElement;

        $gen->Element(title => $_->title);
        $gen->Element(artist => $_->artist)
            if $_->artist;
        $gen->Element(length => $_->length);

        $gen->EndElement;
    }

    $gen->EndElement;
    $gen->EndElement;
}

sub _serialize_label_info_list
{
    my ($self, $gen, $rel_labels, $inc, $stash) = @_;

    $gen->_DeclaredElement('label-info-list')->StartElement;
    $gen->_DeclaredAttribute('count')->AddAttribute(scalar(@$rel_labels));

    for my $rel_label (@$rel_labels) {
        $self->_serialize_label_info($gen, $rel_label, $inc, $stash);
    }

    $gen->EndElement;
}

sub _serialize_label_info
{
    my ($self, $gen, $rel_label, $inc, $stash) = @_;

    $gen->_DeclaredElement('label-info')->StartElement;

    $gen->Element('catalog-number' => $rel_label->catalog_number)
        if $rel_label->catalog_number;
    $self->_serialize_label($gen, $rel_label->label, $inc, $stash)
        if $rel_label->label;

    $gen->EndElement;
}

sub _serialize_label_list
{
    my ($self, $gen, $list, $inc, $stash, $toplevel) = @_;

    if (@{ $list->{items} })
    {
        $gen->_DeclaredElement('label-list')->StartElement;
        $self->_list_attributes ($list, $gen);

        foreach my $label (sort_by { $_->gid } @{ $list->{items} }) {
            $self->_serialize_label($gen, $label, $inc, $stash, $toplevel);
        }

        $gen->EndElement;
    }
}

sub _serialize_label
{
    my ($self, $gen, $label, $inc, $stash, $toplevel) = @_;

    my $opts = $stash->store ($label);

    $gen->_DeclaredElement('label')->StartElement;
    $gen->_DeclaredAttribute('id')->AddAttribute($label->gid);
    $gen->_DeclaredAttribute('type')->AddAttribute($label->type->name)
        if $label->type;

    $gen->Element(name => $label->name);
    $gen->Element('sort-name' => $label->sort_name) if $label->sort_name;
    $gen->Element(disambiguation => $label->comment) if $label->comment;
    $gen->Element('label-code' => $label->label_code) if $label->label_code;
    $gen->Element(ipi => $label->ipi_codes->[0]->ipi) if ($label->all_ipi_codes);

    if ($label->all_ipi_codes) {
        $gen->_DeclaredElement('ipi-list')->StartElement;
        $gen->Element(ipi => $_->ipi) for $label->all_ipi_codes;
        $gen->EndElement;
    }

    if ($toplevel)
    {
        $gen->Element(country => $label->country->iso_code) if $label->country;
        $self->_serialize_life_span($gen, $label, $inc, $opts);
    }

    $self->_serialize_alias($gen, $opts->{aliases}, $inc, $opts)
        if ($inc->aliases && $opts->{aliases});

    if ($toplevel)
    {
        $self->_serialize_release_list($gen, $opts->{releases}, $inc, $stash)
            if $inc->releases;
    }

    $self->_serialize_relation_lists($label, $gen, $label->relationships, $inc, $stash) if ($inc->has_rels);
    $self->_serialize_tags_and_ratings($gen, $inc, $opts);

    $gen->EndElement;
}

sub _serialize_relation_lists
{
    my ($self, $src_entity, $gen, $rels, $inc, $stash) = @_;

    my %types = ();
    foreach my $rel (@$rels)
    {
        $types{$rel->target_type} = [] if !exists $types{$rel->target_type};
        push @{$types{$rel->target_type}}, $rel;
    }
    foreach my $type (sort keys %types)
    {
        $gen->_DeclaredElement('relation-list')->StartElement;
        $gen->_DeclaredAttribute('target-type')->AddAttribute($type);

        for my $rel (sort_by { $_->target_key . $_->link->type->name } @{$types{$type}}) {
            $self->_serialize_relation($src_entity, $gen, $rel, $inc, $stash);
        }

        $gen->EndElement;
    }
}

sub _serialize_relation
{
    my ($self, $src_entity, $gen, $rel, $inc, $stash) = @_;

    my $type = $rel->link->type->name;

    $gen->_DeclaredElement('relation')->StartElement;
    $gen->_DeclaredAttribute('type')->AddAttribute($type);

    $gen->Element(target => $rel->target_key);
    $gen->Element(direction => 'backward') if ($rel->direction == $MusicBrainz::Server::Entity::Relationship::DIRECTION_BACKWARD);
    $gen->Element(begin => $rel->link->begin_date->format) unless $rel->link->begin_date->is_empty;
    $gen->Element(end => $rel->link->end_date->format) unless $rel->link->end_date->is_empty;
    $gen->Element(ended => 'true') if $rel->link->ended;

    if ($rel->link->all_attributes) {
        $gen->_DeclaredElement('attribute-list')->StartElement;
        $gen->Element(attribute => $_->name) for $rel->link->all_attributes;
        $gen->EndElement;
    }

    unless ($rel->target_type eq 'url') {
        my $method =  "_serialize_" . $rel->target_type;
        $self->$method($gen, $rel->target, $inc, $stash);
    }

    $gen->EndElement;
}

sub _serialize_puid_list
{
    my ($self, $gen, $puids, $inc, $stash) = @_;

    $gen->_DeclaredElement('puid-list')->StartElement;
    $gen->_DeclaredAttribute('count')->AddAttribute(scalar(@$puids));
    for my $puid (sort_by { $_->puid->puid } @$puids)
    {
        $self->_serialize_puid($gen, $puid->puid, $inc, $stash);
    }
    $gen->EndElement;
}

sub _serialize_puid
{
    my ($self, $gen, $puid, $inc, $stash, $toplevel) = @_;

    my $opts = $stash->store ($puid);

    $gen->_DeclaredElement('puid')->StartElement;
    $gen->_DeclaredAttribute('id')->AddAttribute($puid->puid);

    if ($toplevel)
    {
        $self->_serialize_recording_list($gen, ${opts}->{recordings}, $inc, $stash, $toplevel)
            if ${opts}->{recordings};
    }

    $gen->EndElement;
}

sub _serialize_isrc_list
{
    my ($self, $gen, $isrcs, $inc, $stash, $toplevel) = @_;

    my %uniq_isrc;
    foreach (@$isrcs)
    {
        $uniq_isrc{$_->isrc} = [] unless $uniq_isrc{$_->isrc};
        push @{$uniq_isrc{$_->isrc}}, $_;
    }

    $gen->_DeclaredElement('isrc-list')->StartElement;
    $gen->_DeclaredAttribute('count')->AddAttribute(scalar(keys %uniq_isrc));
    foreach my $k (sort keys %uniq_isrc)
    {
        $self->_serialize_isrc($gen, $uniq_isrc{$k}, $inc, $stash, $toplevel);
    }

    $gen->EndElement;
}

sub _serialize_isrc
{
    my ($self, $gen, $isrcs, $inc, $stash, $toplevel) = @_;

    my @recordings = map { $_->recording } grep { $_->recording } @$isrcs;
    my $recordings = {
        items => \@recordings,
        total => scalar @recordings,
    };

    $gen->_DeclaredElement('isrc')->StartElement;
    $gen->_DeclaredAttribute('id')->AddAttribute($isrcs->[0]->isrc);

    $self->_serialize_recording_list($gen, $recordings, $inc, $stash, $toplevel)
        if @recordings;

    $gen->EndElement;
}

sub _serialize_tags_and_ratings
{
    my ($self, $gen, $inc, $opts) = @_;

    $self->_serialize_tag_list($gen, $inc, $opts)
        if $opts->{tags} && $inc->{tags};
    $self->_serialize_user_tag_list($gen, $inc, $opts)
        if $opts->{user_tags} && $inc->{user_tags};
    $self->_serialize_rating($gen, $inc, $opts)
        if $opts->{ratings} && $inc->{ratings};
    $self->_serialize_user_rating($gen, $inc, $opts)
        if $opts->{user_ratings} && $inc->{user_ratings};
}

sub _serialize_tag_list
{
    my ($self, $gen, $inc, $opts) = @_;

    $gen->_DeclaredElement('tag-list')->StartElement;

    foreach my $tag (sort_by { $_->tag->name } @{$opts->{tags}})
    {
        $self->_serialize_tag($gen, $tag, $inc, $opts);
    }
    $gen->EndElement;
}

sub _serialize_tag
{
    my ($self, $gen, $tag, $inc, $opts, $modelname, $entity) = @_;

    $gen->_DeclaredElement('tag')->StartElement;
    $gen->_DeclaredAttribute('count')->AddAttribute($tag->count);
    $gen->Element(name => $tag->tag->name);
    $gen->EndElement;
}

sub _serialize_user_tag_list
{
    my ($self, $gen, $inc, $opts, $modelname, $entity) = @_;

    $gen->_DeclaredElement('user-tag-list')->StartElement;
    foreach my $tag (sort_by { $_->tag->name } @{$opts->{user_tags}})
    {
        $self->_serialize_user_tag($gen, $tag, $inc, $opts, $modelname, $entity);
    }
    $gen->EndElement;
}

sub _serialize_user_tag
{
    my ($self, $gen, $tag, $inc, $opts, $modelname, $entity) = @_;

    $gen->_DeclaredElement('user-tag')->StartElement;
    $gen->Element(name => $tag->tag->name);
    $gen->EndElement;
}

sub _serialize_rating
{
    my ($self, $gen, $inc, $opts) = @_;

    my $count = $opts->{ratings}->{count};
    my $rating = $opts->{ratings}->{rating};

    $gen->Element(rating => $rating, 'votes-count' => $count);
}

sub _serialize_user_rating
{
    my ($self, $gen, $inc, $opts) = @_;
    $gen->Element('user-rating' => $opts->{user_ratings});
}

sub output_error
{
    my ($self, $err) = @_;

    $self->_bracket_xml(sub {
        my $gen = shift;
        $gen->_DeclaredElement('error')->StartElement;

        $gen->_DeclaredElement('text')->StartElement;
        $gen->AddText($err);
        $gen->EndElement;

        $gen->_DeclaredElement('text')->StartElement;
        $gen->AddText("For usage, please see: http://musicbrainz.org/development/mmd");
        $gen->EndElement;

        $gen->EndElement;
    });
}

sub output_success
{
    my ($self, $msg) = @_;
    $msg ||= 'OK';

    $self->_bracket_xml(sub {
        my $gen = shift;
        $gen->_DeclaredElement('message')->StartElement;
        $gen->Element(text => $msg);
        $gen->EndElement
    });
}

sub serialize
{
    my ($self, $type, $entity, $inc, $stash) = @_;
    $inc ||= 0;

    $self->_bracket_metadata(sub {
        my $gen = shift;

        $type =~ s/-/_/g;
        my $method = "${type}_resource";
        if (!$self->can($method)) {
            $method = "_serialize_$type";
        }

        $self->$method($gen, $entity, $inc, $stash, 1);
    });
}

sub _bracket_xml {
    my ($self, $f) = @_;

    state $gen = XML::Genx::Simple->new();
    $gen->StartDocString;

    $f->($gen);

    $gen->EndDocument;

    return $gen->GetDocString;
}

sub _bracket_metadata {
    my ($self, $f) = @_;

    $self->_bracket_xml(sub {
        my $gen = shift;
        $gen->StartElementLiteral('metadata');

        # Yes, genx can do namespaces properly, but that would mean threading a
        # namespace object through every single call. Because we only ever use the
        # default namespace, I'm just hacking it in.
        $gen->AddAttributeLiteral('xmlns' => 'http://musicbrainz.org/ns/mmd-2.0#');

        $f->($gen);

        $gen->EndElement;
    });
}

sub rating_resource
{
    my ($self, $gen, $entity, $inc, $stash) = @_;

    my $opts = $stash->store ($entity);

    return '' unless $opts->{user_ratings};
    return $self->_serialize_user_rating($gen, $inc, $opts);
}

sub tag_list_resource
{
    my ($self, $gen, $entity, $inc, $stash) = @_;

    my $opts = $stash->store ($entity);
    return $self->_serialize_user_tag_list($gen, $inc, $opts);
}

__PACKAGE__->meta->make_immutable;
no Moose;
1;

=head1 COPYRIGHT

Copyright (C) 2010 MetaBrainz Foundation
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
