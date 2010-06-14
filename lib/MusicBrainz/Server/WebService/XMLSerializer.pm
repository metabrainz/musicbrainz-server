package MusicBrainz::Server::WebService::XMLSerializer;

use Moose;
use Scalar::Util 'reftype';
use Readonly;
use Switch;
use MusicBrainz::Server::WebService::Escape qw( xml_escape );
use MusicBrainz::Server::Entity::Relationship;
use MusicBrainz::Server::Validation;
use MusicBrainz::XML::Generator escape => 'always';

sub mime_type { 'application/xml' }

Readonly my $xml_decl_begin => '<?xml version="1.0" encoding="UTF-8"?><metadata xmlns="http://musicbrainz.org/ns/mmd-2.0#">';
Readonly my $xml_decl_end => '</metadata>';

sub _serialize_life_span
{
    my ($self, $data, $gen, $entity, $inc, $opts) = @_;

    my $has_begin_date = !$entity->begin_date->is_empty;
    my $has_end_date = !$entity->end_date->is_empty;
    if ($has_begin_date || $has_end_date) {
        my @span;
        push @span, $gen->begin($entity->begin_date->format) if $has_begin_date;
        push @span, $gen->end($entity->end_date->format) if $has_end_date;
        push @$data, $gen->life_span(@span);
    }
}

sub _serialize_text_representation
{
    my ($self, $data, $gen, $entity, $inc, $opts) = @_;

    if ($entity->language || $entity->script)
    {
        my @tr;
        push @tr, $gen->language($entity->language->iso_code_3t) if $entity->language;
        push @tr, $gen->script($entity->script->iso_code) if $entity->script;
        push @$data, $gen->text_representation(@tr);
    }
}

sub _serialize_alias
{
    my ($self, $data, $gen, $aliases, $inc, $opts) = @_;

    if (@$aliases)
    {
        my %attr = ( count => scalar(@$aliases) );
        my @alias_list;
        foreach my $al (@$aliases)
        {
            push @alias_list, $gen->alias($al->name);
        }
        push @$data, $gen->alias_list(\%attr, @alias_list);
    }
}

sub _serialize_artist
{
    my ($self, $data, $gen, $artist, $inc, $opts, $toplevel) = @_;

    my %attrs;
    $attrs{id} = $artist->gid;
    $attrs{type} = lc($artist->type->name) if ($artist->type);

    my @list;
    push @list, $gen->name($artist->name);
    push @list, $gen->sort_name($artist->sort_name) if ($artist->sort_name);
    push @list, $gen->disambiguation($artist->comment) if ($artist->comment);

    if ($toplevel)
    {
        push @list, $gen->gender(lc($artist->gender->name)) if ($artist->gender);
        push @list, $gen->country($artist->country->iso_code) if ($artist->country);

        $self->_serialize_life_span(\@list, $gen, $artist, $inc, $opts);
        $self->_serialize_alias(\@list, $gen, $opts->{aliases}, $inc, $opts) if ($inc->aliases);

        $self->_serialize_recording_list(\@list, $gen, $opts->{recordings}, $inc, $opts)
            if $inc->recordings;

        $self->_serialize_release_list(\@list, $gen, $opts->{releases}, $inc, $opts)
            if $inc->releases;

        $self->_serialize_release_group_list(\@list, $gen, $opts->{release_groups}, $inc, $opts)
            if $inc->release_groups;

        $self->_serialize_work_list(\@list, $gen, $opts->{works}, $inc, $opts)
            if $inc->works;
    }

    $self->_serialize_relation_lists($artist, \@list, $gen, $artist->relationships) if ($inc->has_rels);
#     $self->_serialize_tags_and_ratings(\@list, $gen, $inc, $opts);

    push @$data, $gen->artist(\%attrs, @list);
}

sub _serialize_artist_credit
{
    my ($self, $data, $gen, $artist_credit, $inc, $opts, $toplevel) = @_;

    my @ac;
    foreach my $name (@{$artist_credit->names})
    {
        my %artist_attr = ( id => $name->artist->gid );

        my %nc_attr;
        $nc_attr{joinphrase} = $name->join_phrase if ($name->join_phrase);

        my @nc;
        push @nc, $gen->name($name->name) if ($name->name ne $name->artist->name);

        $self->_serialize_artist(\@nc, $gen, $name->artist, $inc, $opts);
        push @ac, $gen->name_credit(\%nc_attr, @nc);
    }

    push @$data, $gen->artist_credit(@ac);
}

sub _serialize_release_group_list
{
    my ($self, $data, $gen, $release_groups, $inc, $opts) = @_;

    my @list;
    foreach my $rg (@$release_groups)
    {
        my $rel_opts = {};
        if ($opts->{releases}->{$rg->id})
        {
            $rel_opts->{releases} = $opts->{releases}->{$rg->id};
        }
        $self->_serialize_release_group(\@list, $gen, $rg, $inc, $rel_opts);
    }
    push @$data, $gen->release_group_list(
        { count => scalar @$release_groups }, @list);
}

sub _serialize_release_group
{
    my ($self, $data, $gen, $release_group, $inc, $opts, $toplevel) = @_;

    my %attr;
    $attr{id} = $release_group->gid;
    $attr{type} = lc($release_group->type->name) if $release_group->type;

    my @list;
    push @list, $gen->title($release_group->name);
    push @list, $gen->disambiguation($release_group->comment) if $release_group->comment;

    if ($toplevel)
    {
        $self->_serialize_artist_credit(\@list, $gen, $release_group->artist_credit, $inc, $opts, $inc->artists)
            if $inc->artists || $inc->artist_credits;

        $self->_serialize_release_list(\@list, $gen, $opts->{releases}, $inc, $opts)
            if $inc->releases;
    }
    else
    {
        $self->_serialize_artist_credit(\@list, $gen, $release_group->artist_credit, $inc, $opts)
            if $inc->artist_credits;
    }

    $self->_serialize_relation_lists($release_group, \@list, $gen, $release_group->relationships) if $inc->has_rels;
#     $self->_serialize_tags_and_ratings(\@list, $gen, $inc, $opts);

    push @$data, $gen->release_group(\%attr, @list);
}

sub _serialize_release_list
{
    my ($self, $data, $gen, $releases, $inc, $opts) = @_;

    my @list;
    foreach my $release (@$releases)
    {
        $self->_serialize_release(\@list, $gen, $release, $inc, $opts);
    }
    push @$data, $gen->release_list({ count => scalar @$releases }, @list);
}

sub _serialize_release
{
    my ($self, $data, $gen, $release, $inc, $opts, $toplevel) = @_;

    $inc = $inc->clone ( releases => 0 );

    my @list;
    
    push @list, $gen->title($release->name);
    push @list, $gen->status(lc($release->status->name)) if $release->status;
    push @list, $gen->disambiguation($release->comment) if $release->comment;
    push @list, $gen->packaging($release->packaging) if $release->packaging;

    $self->_serialize_text_representation(\@list, $gen, $release, $inc, $opts);

    if ($toplevel)
    {
        $self->_serialize_artist_credit(\@list, $gen, $release->artist_credit, $inc, $opts, $inc->artists)
            if $inc->artist_credits || $inc->artists;

        $self->_serialize_release_group(\@list, $gen, $release->release_group, $inc, $opts)
            if ($release->release_group && $inc->release_groups);
    }
    else
    {
        $self->_serialize_artist_credit(\@list, $gen, $release->artist_credit, $inc, $opts)
            if $inc->artist_credits;
    }

    push @list, $gen->date($release->date->format) if $release->date;
    push @list, $gen->country($release->country->iso_code) if $release->country;
    push @list, $gen->barcode($release->barcode) if $release->barcode;
    push @list, $gen->asin($release->amazon_asin) if $release->amazon_asin;

    if ($toplevel)
    {
        $self->_serialize_label_info_list(\@list, $gen, $release->labels, $inc, $opts)
            if ($release->labels && $inc->labels);

    }

    $self->_serialize_medium_list(\@list, $gen, $release->mediums, $inc, $opts)
        if ($release->mediums && ($inc->media || $inc->discids || $inc->recordings));

    $self->_serialize_relation_lists($release, \@list, $gen, $release->relationships) if ($inc->has_rels);

    push @$data, $gen->release({ id => $release->gid }, @list);
}

sub _serialize_work_list
{
    my ($self, $data, $gen, $works, $inc, $opts) = @_;

    my @list;
    foreach my $work (@$works)
    {
        $self->_serialize_work(\@list, $gen, $work, $inc, $opts);
    }
    push @$data, $gen->work_list({ count => scalar (@$works) }, @list);
}

sub _serialize_work
{
    my ($self, $data, $gen, $work, $inc, $opts, $toplevel) = @_;

    my $iswc = $work->iswc;
    $iswc =~ s/^\s+//;
    $iswc =~ s/\s+$//;

    my @list;
    push @list, $gen->iswc($iswc) if $iswc;
    push @list, $gen->title($work->name);
    push @list, $gen->length($work->length);
    push @list, $gen->disambiguation($work->comment) if ($work->comment);

    if ($toplevel)
    {
        $self->_serialize_artist_credit(\@list, $gen, $work->artist_credit, $inc, $opts, $inc->artists)
            if $inc->artists || $inc->artist_credits;
    }
    else
    {
        $self->_serialize_artist_credit(\@list, $gen, $work->artist_credit, $inc, $opts)
            if $inc->artist_credits;
    }

    push @$data, $gen->work({ id => $work->gid, type => $work->type->name }, @list);
}

sub _serialize_recording_list
{
    my ($self, $data, $gen, $recordings, $inc, $opts) = @_;

    my @list;
    foreach my $recording (@$recordings)
    {
        $self->_serialize_recording(\@list, $gen, $recording, $inc, $opts);
    }
    push @$data, $gen->recording_list({ count => scalar (@$recordings) }, @list);
}

sub _serialize_recording
{
    my ($self, $data, $gen, $recording, $inc, $opts, $toplevel) = @_;

    my @list;
    push @list, $gen->title($recording->name);
    push @list, $gen->length($recording->length);
    push @list, $gen->disambiguation($recording->comment) if ($recording->comment);

    if ($toplevel)
    {
        $self->_serialize_artist_credit(\@list, $gen, $recording->artist_credit, $inc, $opts, $inc->artists)
            if $inc->artists || $inc->artist_credits;

        $self->_serialize_release_list(\@list, $gen, $opts->{releases}, $inc, $opts)
            if $inc->releases;
    }
    else
    {
        $self->_serialize_artist_credit(\@list, $gen, $recording->artist_credit, $inc, $opts)
            if $inc->artist_credits;
    }

    $self->_serialize_puid_list(\@list, $gen, $opts->{puids}, $inc, {})
        if ($opts->{puids} && $inc->{puids});
    $self->_serialize_isrc_list(\@list, $gen, $opts->{isrcs}, $inc, {})
        if ($opts->{isrcs} && $inc->{isrcs});

#     $self->_serialize_tags_and_ratings(\@list, $gen, $inc, $opts);
    $self->_serialize_relation_lists($recording, \@list, $gen, $recording->relationships) if ($inc->has_rels);

    push @$data, $gen->recording({ id => $recording->gid }, @list);

}

sub _serialize_medium_list
{
    my ($self, $data, $gen, $mediums, $inc, $opts) = @_;

    my @list;
    foreach my $medium (@$mediums)
    {
        $self->_serialize_medium(\@list, $gen, $medium, $inc, $opts);
    }
    push @$data, $gen->medium_list({ count => scalar(@$mediums) }, @list);
}

sub _serialize_medium
{
    my ($self, $data, $gen, $medium, $inc, $opts) = @_;

    my @med;
    push @med, $gen->title($medium->name) if $medium->name;
    push @med, $gen->position($medium->position);
    push @med, $gen->format($medium->format->name) if ($medium->format);
    $self->_serialize_disc_list(\@med, $gen, $medium->cdtocs, $inc, $opts, 1) if ($inc->discids);
    $self->_serialize_track_list(\@med, $gen, $medium->tracklist, $inc, $opts);

    push @$data, $gen->medium(@med);
}

sub _serialize_track_list
{
    my ($self, $data, $gen, $tracklist, $inc, $opts) = @_;

#     use Data::Dumper;
#     local $Data::Dumper::Maxdepth = 3;
#     warn "tracklist: ".Dumper($tracklist)."\n";

    my @list;
    foreach my $track (@{$tracklist->tracks})
    {
        $self->_serialize_track(\@list, $gen, $track, $inc, $opts);
    }

    push @$data, $gen->track_list({ count => $tracklist->track_count }, @list);
}

sub _serialize_track
{
    my ($self, $data, $gen, $track, $inc, $opts) = @_;

    my @track;
    push @track, $gen->position($track->position);
    push @track, $gen->title($track->name) if ($track->name ne $track->recording->name);

    $self->_serialize_recording(\@track, $gen, $track->recording, $inc, $opts);

    push @$data, $gen->track(@track);
}

sub _serialize_disc_list
{
    my ($self, $data, $gen, $cdtoclist, $inc, $opts, $digest) = @_;

    my @list;
    foreach my $cdtoc (@$cdtoclist)
    {
        $self->_serialize_disc(\@list, $gen, $cdtoc->cdtoc, $inc, $opts, $digest);
    }
    push @$data, $gen->disc_list({ count => scalar(@$cdtoclist) }, @list);
}

sub _serialize_disc
{
    my ($self, $data, $gen, $cdtoc, $inc, $opts, $digest) = @_;

    my @list;
    push @list, $gen->sectors($cdtoc->leadout_offset);

    if (!$digest)
    {
        $self->_serialize_release_list(\@list, $gen, $opts->{releases}, $inc, $opts);
    }

    push @$data, $gen->disc({ id => $cdtoc->discid }, @list);
}

sub _serialize_label_info_list
{
    my ($self, $data, $gen, $rel_labels, $inc, $opts) = @_;

    my @list;
    foreach my $rel_label (@$rel_labels)
    {
        $self->_serialize_label_info(\@list, $gen, $rel_label, $inc, $opts);
    }
    push @$data, $gen->label_info_list({ count => scalar(@$rel_labels) }, @list);
}

sub _serialize_label_info
{
    my ($self, $data, $gen, $rel_label, $inc, $opts) = @_;

    my @list;
    push @list, $gen->catalog_number (lc($rel_label->catalog_number))
        if $rel_label->catalog_number;
    $self->_serialize_label(\@list, $gen, $rel_label->label, $inc, $opts);
    push @$data, $gen->label_info(@list);
}

sub _serialize_label_list
{
    my ($self, $data, $gen, $labels, $inc, $opts) = @_;

    if (@$labels)
    {
        my @list;
        foreach my $label (@$labels)
        {
            $self->_serialize_label(\@list, $gen, $label, $inc, $opts);
        }
        push @$data, $gen->label_list({ count => scalar(@$labels) }, @list);
    }
}

sub _serialize_label
{
    my ($self, $data, $gen, $label, $inc, $opts) = @_;

    my %attr;
    $attr{type} = lc($label->type->name) if $label->type;

    my @list;
    push @list, $gen->name($label->name);
    push @list, $gen->sort_name($label->sort_name) if $label->sort_name;
    push @list, $gen->label_code($label->label_code) if $label->label_code;
    push @list, $gen->country($label->country->iso_code) if $label->country;
    $self->_serialize_life_span(\@list, $gen, $label, $inc, $opts);
    $self->_serialize_alias(\@list, $gen, $opts->{aliases}, $inc, $opts) if ($inc->aliases);
    $self->_serialize_relation_lists($label, \@list, $gen, $label->relationships) if ($inc->has_rels);
#     $self->_serialize_tags_and_ratings(\@list, $gen, $inc, $opts);

    $self->_serialize_release_list(\@list, $gen, $opts->{releases}, $inc, $opts)
        if $inc->releases;

    push @$data, $gen->label(@list);
}

sub _serialize_relation_lists
{
    my ($self, $src_entity, $data, $gen, $rels) = @_;

    my %types = ();
    foreach my $rel (@$rels)
    {
        $types{$rel->target_type} = [] if !exists $types{$rel->target_type};
        push @{$types{$rel->target_type}}, $rel;
    }
    foreach my $type (keys %types)
    {
        my @list;
        foreach my $rel (@{$types{$type}})
        {
            $self->_serialize_relation($src_entity, \@list, $gen, $rel);
        }
        push @$data, $gen->relation_list({ 'target-type' => $type }, @list);
    }
}

sub _serialize_relation
{
    my ($self, $src_entity, $data, $gen, $rel) = @_;

    my @list;
    my $type = $rel->link->type->short_link_phrase;
    $type =~ s/ /_/g;

    push @list, $gen->target($rel->target_key);
    push @list, $gen->direction('backward') if ($rel->direction == $MusicBrainz::Server::Entity::Relationship::DIRECTION_BACKWARD);
    push @list, $gen->begin($rel->link->begin_date->format) unless $rel->link->begin_date->is_empty;
    push @list, $gen->end($rel->link->end_date->format) unless $rel->link->end_date->is_empty;

    unless ($rel->target_type eq 'url')
    {
        my $method =  "_serialize_" . $rel->target_type;
        $self->$method(\@list, $gen, $rel->target, MusicBrainz::Server::WebService::WebServiceInc->new(), {});
    }

    push @$data, $gen->relation({ type => $type }, @list);
}

sub _serialize_puid_list
{
    my ($self, $data, $gen, $puids, $inc, $opts) = @_;

    my @list;
    foreach my $puid (@$puids)
    {
        $self->_serialize_puid(\@list, $gen, $puid->puid, $inc, $opts);
    }
    push @$data, $gen->puid_list({ count => scalar(@$puids) }, @list);
}

sub _serialize_puid
{
    my ($self, $data, $gen, $puid, $inc, $opts, $toplevel) = @_;

    my @list;
    if ($toplevel)
    {
        $self->_serialize_recording_list(\@list, $gen, ${opts}->{recordings}, $inc, $opts)
            if (${opts}->{recordings});
    }
    push @$data, $gen->puid({ id => $puid->puid }, @list);
}

sub _serialize_isrc_list
{
    my ($self, $data, $gen, $isrcs, $inc, $opts) = @_;

    my %uniq_isrc;
    foreach (@$isrcs)
    {
        $uniq_isrc{$_->isrc} = [] unless $uniq_isrc{$_->isrc};
        push @{$uniq_isrc{$_->isrc}}, $_;
    }

    my @list;
    foreach my $k (keys %uniq_isrc)
    {
        $self->_serialize_isrc(\@list, $gen, $uniq_isrc{$k}, $inc, $opts);
    }
    push @$data, $gen->isrc_list({ count => scalar(keys %uniq_isrc) }, @list);
}

sub _serialize_isrc
{
    my ($self, $data, $gen, $isrcs, $inc, $opts) = @_;

    my @recordings = map { $_->recording } grep { $_->recording } @$isrcs;

    my @list;
    $self->_serialize_recording_list(\@list, $gen, \@recordings, $inc, $opts)
        if @recordings;
    push @$data, $gen->isrc({ id => $isrcs->[0]->isrc }, @list);
}

sub _serialize_tags_and_ratings
{
    my ($self, $data, $gen, $inc, $opts) = @_;

    $self->_serialize_tag_list($data, $gen, $inc, $opts)
        if ($opts->{tags} && $inc->{tags});
    $self->_serialize_user_tag_list($data, $gen, $inc, $opts)
        if ($opts->{usertags} && $inc->{usertags});
    $self->_serialize_rating($data, $gen, $inc, $opts)
        if ($opts->{ratings} && $inc->{ratings});
    $self->_serialize_user_rating($data, $gen, $inc, $opts)
        if ($opts->{userratings} && $inc->{userratings});
}

sub _serialize_tag_list
{
    my ($self, $data, $gen, $inc, $opts) = @_;

    my @list;
    foreach my $tag (@{$opts->{tags}})
    {
        $self->_serialize_tag(\@list, $gen, $tag, $inc, $opts);
    }
    push @$data, $gen->tag_list(@list);
}

sub _serialize_tag
{
    my ($self, $data, $gen, $tag, $inc, $opts) = @_;

    push @$data, $gen->tag({ count => $tag->count }, $tag->tag->name);
}

sub _serialize_user_tag_list
{
    my ($self, $data, $gen, $inc, $opts) = @_;

    my @list;
    foreach my $tag (@{$opts->{usertags}})
    {
        $self->_serialize_user_tag(\@list, $gen, $tag, $inc, $opts);
    }
    push @$data, $gen->user_tag_list(@list);
}

sub _serialize_user_tag
{
    my ($self, $data, $gen, $tag, $inc, $opts) = @_;

    push @$data, $gen->user_tag($tag->tag->name);
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

    push @$data, $gen->user_rating($opts->{userratings});
}

sub output_error
{
    my ($self, $err) = @_;

    my $gen = MusicBrainz::XML::Generator->new(':std');

    my $xml = $xml_decl_begin;
    $xml .= $gen->error($gen->text(
       $err . " For usage, please see: http://musicbrainz.org/development/mmd\015\012"));
    $xml .= $xml_decl_end;
    return $xml;
}

sub serialize
{
    my ($self, $type, $entity, $inc, $opts) = @_;
    $inc ||= 0;

    my $gen = MusicBrainz::XML::Generator->new(':std');

    my $method = $type . "_resource";
    $method =~ s/release-group/release_group/;
    my $xml = $xml_decl_begin;
    $xml .= $self->$method($gen, $entity, $inc, $opts);
    $xml .= $xml_decl_end;
    return $xml;
}

sub artist_resource
{
    my ($self, $gen, $artist, $inc, $opts) = @_;

    my $data = [];
    $self->_serialize_artist($data, $gen, $artist, $inc, $opts, 1);

    return $data->[0];
}

sub label_resource
{
    my ($self, $gen, $label, $inc, $opts) = @_;

    my $data = [];
    $self->_serialize_label($data, $gen, $label, $inc, $opts, 1);
    return $data->[0];
}

sub release_group_resource
{
    my ($self, $gen, $release_group, $inc, $opts) = @_;

    my $data = [];
    $self->_serialize_release_group($data, $gen, $release_group, $inc, $opts, 1);
    return $data->[0];
}

sub release_resource
{
    my ($self, $gen, $release, $inc, $opts) = @_;

    my $data = [];
    $self->_serialize_release($data, $gen, $release, $inc, $opts, 1);
    return $data->[0];
}

sub recording_resource
{
    my ($self, $gen, $recording, $inc, $opts) = @_;

    my $data = [];
    $self->_serialize_recording($data, $gen, $recording, $inc, $opts, 1);

    return $data->[0];
}

sub work_resource
{
    my ($self, $gen, $work, $inc, $opts) = @_;

    my $data = [];
    $self->_serialize_work($data, $gen, $work, $inc, $opts, 1);
    return $data->[0];
}

sub isrc_resource
{
    my ($self, $gen, $isrc, $inc, $opts) = @_;

    my $data = [];
    $self->_serialize_isrc_list($data, $gen, $isrc, $inc, $opts, 1);
    return $data->[0];
}

sub puid_resource
{
    my ($self, $gen, $puid, $inc, $opts) = @_;

    my $data = [];
    $self->_serialize_puid($data, $gen, $puid, $inc, $opts, 1);
    return $data->[0];
}

sub disc_resource
{
    my ($self, $gen, $cdtoc, $inc, $opts) = @_;

    my $data = [];
    $self->_serialize_disc($data, $gen, $cdtoc, $inc, $opts, 1);
    return $data->[0];
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
