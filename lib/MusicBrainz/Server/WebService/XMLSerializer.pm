package MusicBrainz::Server::WebService::XMLSerializer;

use Moose;
use Scalar::Util 'reftype';
use Readonly;
use Switch;
use MusicBrainz::Server::WebService::Escape qw( xml_escape );
use MusicBrainz::Server::Entity::Relationship;
use MusicBrainz::Server::Validation;

sub mime_type { 'application/xml' }

Readonly my $xml_decl_begin => '<?xml version="1.0" encoding="UTF-8"?><metadata xmlns="http://musicbrainz.org/ns/mmd-2.0#">';
Readonly my $xml_decl_end => '</metadata>';

# This could also be done by something like XML::Generator
sub _output_xml
{
    my ($self, $data) = @_;

    my $root = (keys %{$data})[0];
    my $xml = "<$root";
    my $in_attrs = 1;
    foreach my $item (@{$data->{$root}})
    {
        if (reftype $item eq 'HASH')
        {
            if ($in_attrs)
            {
                $in_attrs = 0;
                $xml .= ">";
            }
            $xml .= _output_xml($self, $item);
        }
        else
        {
            if ($in_attrs && (($item->[0] eq 'HASH') || !($item->[0] =~ /^@/)))
            {
                $in_attrs = 0;
                $xml .= ">";
            }
            if ($in_attrs)
            {
                $xml .= " " . substr($item->[0], 1) . '="' . xml_escape($item->[1]) . '"';
            }
            else
            {
                $xml .= "<" . $item->[0] . ">" . xml_escape($item->[1]) . "</" . $item->[0] . ">";
            }
        }
    }
    $xml .= ">" if ($in_attrs);
    $xml .= "</$root>";

    return $xml;
}

sub _serialize_life_span
{
    my ($self, $data, $entity, $inc, $opts) = @_;
    my $has_begin_date = !$entity->begin_date->is_empty;
    my $has_end_date = !$entity->end_date->is_empty;
    if ($has_begin_date || $has_end_date) {
        my @span;
        push @span, [ 'begin', $entity->begin_date->format ] if $has_begin_date;
        push @span, [ 'end', $entity->end_date->format ] if $has_end_date;
        push @{$data}, { 'life-span' => \@span }; 
    }
}

sub _serialize_text_representation
{
    my ($self, $data, $entity, $inc, $opts) = @_;

    if ($entity->language || $entity->script)
    {
        my @tr;
        push @tr, [ 'language', $entity->language->iso_code_3t ] if $entity->language;
        push @tr, [ 'script', $entity->script->iso_code ] if $entity->script;
        push @{$data}, { 'text-representation' => \@tr }; 
    }
}

sub _serialize_alias
{
    my ($self, $data, $aliases, $inc, $opts) = @_;

    if (@{$aliases})
    {
        my @alias_list;
        push @alias_list, [ '@count', scalar(@{$aliases}) ];
        foreach my $al (@{$aliases})
        {
            push @alias_list, [ 'alias', $al->name ];
        }
        push @{$data}, { 'alias-list' => \@alias_list };
    }
}

sub _serialize_artist
{
    my ($self, $data, $artist, $inc, $opts) = @_;

    my @list;
    push @list, [ '@id', $artist->gid ];
    push @list, [ '@type', lc($artist->type->name) ] if ($artist->type);
    push @list, [ 'name', $artist->name ];
    push @list, [ 'sort-name', $artist->sort_name ] if ($artist->sort_name);
    push @list, [ 'gender', lc($artist->gender->name) ] if ($artist->gender);
    push @list, [ 'country', lc($artist->country->iso_code) ] if ($artist->country);
    push @list, [ 'disambiguation', $artist->comment ] if ($artist->comment);

    $self->_serialize_life_span(\@list, $artist, $inc, $opts);
    $self->_serialize_alias(\@list, $opts->{aliases}, $inc, $opts) if ($inc->aliases);
    $self->_serialize_release_group_list(\@list, $opts->{release_groups}, $inc, $opts) if ($inc->rg_type);
    $self->_serialize_label_list(\@list, $opts->{labels}, $inc, $opts) if ($inc->labels);
    $self->_serialize_relation_lists($artist, \@list, $artist->relationships) if ($inc->has_rels);

    push @{$data}, { 'artist', \@list };
}

sub _serialize_artist_credit
{
    my ($self, $data, $artist_credit, $inc, $opts) = @_;

    my @ac;
    foreach my $name (@{$artist_credit->names}) 
    {
        my @nc;
        push @nc, [ '@joinphrase', $name->join_phrase ] if ($name->join_phrase);
        push @nc, [ 'name', $name->name ] if ($name->name ne $name->artist->name);

        my @artist;
        push @artist, [ '@id', $name->artist->gid ];
        push @artist, [ 'name', $name->artist->name ];

        push @nc, { 'artist', \@artist };
        push @ac, { 'name-credit', \@nc };
    }
    push @{$data}, { 'artist-credit', \@ac };
}

sub _serialize_release_group_list
{
    my ($self, $data, $release_groups, $inc, $opts) = @_;

    my @list;
    push @list, [ '@count', scalar(@{$release_groups}) ];
    foreach my $rg (@{$release_groups})
    {
        my $rel_opts = {};
        if ($opts->{releases}->{$rg->id})
        {
            $rel_opts->{releases} = $opts->{releases}->{$rg->id};
        }
        $self->_serialize_release_group(\@list, $rg, $inc, $rel_opts);
    }
    push @{$data}, { 'release-group-list', \@list};
}

sub _serialize_release_group
{
    my ($self, $data, $release_group, $inc, $opts) = @_;
    my @rg;

    push @rg, [ '@id', $release_group->gid ];
    push @rg, [ '@type', lc($release_group->type->name) ] if ($release_group->type);
    push @rg, [ 'title', $release_group->name ];
    push @rg, [ 'disambiguation', $release_group->comment ] if ($release_group->comment) ;

    $self->_serialize_artist_credit(\@rg, $release_group->artist_credit, $inc, $opts)
        if ($release_group->artist_credit && $inc->{artists});

    $self->_serialize_release_list(\@rg, $opts->{releases}, $inc, {})
        if ($opts->{releases} && $inc->{releases});

    $self->_serialize_relation_lists($release_group, \@rg, $release_group->relationships) if ($inc->has_rels);

    push @{$data}, { 'release-group', \@rg };
}

sub _serialize_release_list
{
    my ($self, $data, $releases, $inc, $opts) = @_;

    my @list;
    push @list, [ '@count', scalar(@{$releases}) ];
    foreach my $release (@{$releases})
    {
        $self->_serialize_release(\@list, $release, $inc, $opts);
    }
    push @{$data}, { 'release-list', \@list};
}

sub _serialize_release
{
    my ($self, $data, $release, $inc, $opts) = @_;

    my @list;
    push @list, [ '@id', $release->gid ];
    push @list, [ 'title', $release->name ];
    push @list, [ 'status', lc($release->status->name) ] if ($release->status);
    push @list, [ 'disambiguation', $release->comment ] if ($release->comment);
    push @list, [ 'packaging', $release->packaging ] if ($release->packaging);

    $self->_serialize_text_representation(\@list, $release, $inc, $opts);

    $self->_serialize_artist_credit(\@list, $release->artist_credit, $inc, $opts)
        if ($release->artist_credit && $inc->{artists});

    $self->_serialize_release_group(\@list, $release->release_group, $inc, {})
        if ($release->release_group && $inc->releasegroups);

    push @list, [ 'date', $release->date->format ] if ($release->date);
    push @list, [ 'country', $release->country->iso_code ] if ($release->country);
    push @list, [ 'barcode', $release->barcode ] if ($release->barcode);
    push @list, [ 'asin', $release->amazon_asin ] if ($release->amazon_asin);

    $self->_serialize_label_info_list(\@list, $release->labels, $inc, $opts)
        if ($release->labels && $inc->labels);

    $self->_serialize_medium_list(\@list, $release->mediums, $inc, $opts)
        if ($release->mediums && ($inc->recordings || $inc->discs));

    $self->_serialize_relation_lists($release, \@list, $release->relationships) if ($inc->has_rels);

    push @{$data}, { 'release', \@list };
}

sub _serialize_recording_list
{
    my ($self, $data, $recordings, $inc, $opts) = @_;

    my @list;
    push @list, [ '@count', scalar(@{$recordings}) ];
    foreach my $recording (@{$recordings})
    {
        $self->_serialize_recording(\@list, $recording, $inc, $opts);
    }
    push @{$data}, { 'recording-list', \@list};
}

sub _serialize_recording
{
    my ($self, $data, $recording, $inc, $opts) = @_;
    my @list;

    push @list, [ '@id', $recording->gid ];
    push @list, [ 'title', $recording->name ];
    push @list, [ 'length', $recording->length ];
    push @list, [ 'disambiguation', $recording->comment ] if ($recording->comment);

    $self->_serialize_artist_credit(\@list, $recording->artist_credit, $inc, $opts)
        if ($recording->artist_credit && $inc->{artists});
    $self->_serialize_release_list(\@list, $opts->{releases}, $inc, $opts)
        if ($opts->{releases} && $inc->{releases});
    $self->_serialize_puid_list(\@list, $opts->{puids}, $inc, {})
        if ($opts->{puids} && $inc->{puids});
    $self->_serialize_isrc_list(\@list, $opts->{isrcs}, $inc, {})
        if ($opts->{isrcs} && $inc->{isrcs});

    $self->_serialize_relation_lists($recording, \@list, $recording->relationships) if ($inc->has_rels);

    push @{$data}, { 'recording', \@list };
}

sub _serialize_medium_list
{
    my ($self, $data, $mediums, $inc, $opts) = @_;

    my @list;
    push @list, [ '@count', scalar(@{$mediums}) ];
    foreach my $medium (@{$mediums})
    {
        $self->_serialize_medium(\@list, $medium, $inc, $opts);
    }
    push @{$data}, { 'medium-list', \@list};
}

sub _serialize_medium
{
    my ($self, $data, $medium, $inc, $opts) = @_;

    my @med;
    push @med, [ 'title', $medium->name ] if ($medium->name);
    push @med, [ 'position', $medium->position ];
    push @med, [ 'format', $medium->format->name ] if ($medium->format);
    $self->_serialize_disc_list(\@med, $medium->cdtocs, $inc, $opts, 1) if ($inc->discs);
    $self->_serialize_track_list(\@med, $medium->tracklist, $inc, $opts) if ($inc->recordings);
    push @{$data}, { 'medium', \@med };
}

sub _serialize_track_list
{
    my ($self, $data, $tracklist, $inc, $opts) = @_;

    my @list;
    push @list, [ '@count', scalar(@{$tracklist->tracks}) ];
    foreach my $track (@{$tracklist->tracks})
    {
        $self->_serialize_track(\@list, $track, $inc, $opts);
    }
    push @{$data}, { 'track-list', \@list};
}

sub _serialize_track
{
    my ($self, $data, $track, $inc, $opts) = @_;

    my @track;
    push @track, [ 'title', $track->name ] if ($track->name ne $track->recording->name);
    push @track, [ 'position', $track->position ];

    # Save the current state of the releases inc setting, and don't pass it to the 
    # recording serializer to avoid it from outputing releases.
    my $saved = $inc->releases;
    $inc->releases(0);
    $self->_serialize_recording(\@track, $track->recording, $inc, $opts);
   
    # Now restore the inc setting
    $inc->releases($saved);

    push @{$data}, { 'track', \@track};
}

sub _serialize_disc_list
{
    my ($self, $data, $cdtoclist, $inc, $opts, $digest) = @_;

    my @list;
    push @list, [ '@count', scalar(@{$cdtoclist}) ];
    foreach my $cdtoc (@{$cdtoclist})
    {
        $self->_serialize_disc(\@list, $cdtoc->cdtoc, $inc, $opts, $digest);
    }
    push @{$data}, { 'disc-list', \@list};
}

sub _serialize_disc
{
    my ($self, $data, $cdtoc, $inc, $opts, $digest) = @_;

    my @list;
    push @list, [ '@id', $cdtoc->discid ];
    push @list, [ 'sectors', $cdtoc->leadout_offset ];

    if (!$digest)
    {
        $self->_serialize_release_list(\@list, $opts->{releases}, $inc, $opts);
    }

    push @{$data}, { 'disc', \@list};
}

sub _serialize_label_info_list
{
    my ($self, $data, $rel_labels, $inc, $opts) = @_;

    my @list;
    push @list, [ '@count', scalar(@{$rel_labels}) ];
    foreach my $rel_label (@{$rel_labels})
    {
        $self->_serialize_label_info(\@list, $rel_label, $inc, $opts);
    }
    push @{$data}, { 'label-info-list', \@list};
}

sub _serialize_label_info
{
    my ($self, $data, $rel_label, $inc, $opts) = @_;

    my @list;
    push @list, [ 'catalog-number', lc($rel_label->catalog_number) ] if ($rel_label->catalog_number);
    $self->_serialize_label(\@list, $rel_label->label, $inc, $opts);
    push @{$data}, { 'label-info', \@list};
}

sub _serialize_label_list
{
    my ($self, $data, $labels, $inc, $opts) = @_;

    if (@{$labels})
    {
        my @list;
        push @list, [ '@count', scalar(@{$labels}) ];
        foreach my $label (@{$labels})
        {
            $self->_serialize_label(\@list, $label, $inc, $opts);
        }
        push @{$data}, { 'label-list', \@list};
    }
}

sub _serialize_label
{
    my ($self, $data, $label, $inc, $opts) = @_;

    my @list;
    push @list, [ '@type', lc($label->type->name) ] if ($label->type);
    push @list, [ 'name', $label->name ];
    push @list, [ 'sort-name', $label->sort_name ] if ($label->sort_name);
    push @list, [ 'label-code', $label->label_code ] if ($label->label_code);
    push @list, [ 'country', $label->country ] if ($label->country);
    $self->_serialize_life_span(\@list, $label, $inc, $opts);
    $self->_serialize_alias(\@list, $opts->{aliases}, $inc, $opts) if ($inc->aliases);
    $self->_serialize_relation_lists($label, \@list, $label->relationships) if ($inc->has_rels);
    push @{$data}, { 'label', \@list};
}

sub _serialize_work
{
    my ($self, $data, $work, $inc, $opts) = @_;
    my @rg;

    push @rg, [ '@id', $work->gid ];
    push @rg, [ '@type', $work->type->name ];
    push @rg, [ 'title', $work->name ];
    push @rg, [ 'iswc', $work->iswc ] if ($work->iswc ne '               ');

    $self->_serialize_artist_credit(\@rg, $work->artist_credit, $inc, $opts)
        if ($work->artist_credit && $inc->{artists});

    push @rg, [ 'disambiguation', $work->comment ] if ($work->comment);

    push @{$data}, { 'work', \@rg };
}

sub _serialize_relation_lists
{
    my ($self, $src_entity, $data, $rels) = @_;

    my %types = ();
    foreach my $rel (@{$rels})
    {
        $types{$rel->target_type} = [] if !exists $types{$rel->target_type};
        push @{$types{$rel->target_type}}, $rel;
    }
    foreach my $type (keys %types)
    {
        my @list;
        push @list, [ '@target-type', $type ];
        foreach my $rel (@{$types{$type}})
        {
            $self->_serialize_relation($src_entity, \@list, $rel);
        }
        push @{$data}, { 'relation-list', \@list};
    }
}

sub _serialize_relation
{
    my ($self, $src_entity, $data, $rel) = @_;

    my @list;
    my $type = $rel->link->type->short_link_phrase;
    $type =~ s/ /_/g;
    push @list, [ '@type', $type ];

    push @list, [ 'target', $rel->target_key ];
    push @list, [ 'direction', 'backward' ] if ($rel->direction == $MusicBrainz::Server::Entity::Relationship::DIRECTION_BACKWARD);
    push @list, [ 'begin', $rel->link->begin_date->format ] unless $rel->link->begin_date->is_empty;
    push @list, [ 'end', $rel->link->end_date->format ] unless $rel->link->end_date->is_empty;

    unless ($rel->target_type eq 'url')
    {
        my $method =  "_serialize_" . $rel->target_type;
        $self->$method(\@list, $rel->target, MusicBrainz::Server::WebService::WebServiceInc->new(), {});
    }

    push @{$data}, { 'relation', \@list };
}

sub _serialize_puid_list
{
    my ($self, $data, $puids, $inc, $opts) = @_;

    my @list;
    push @list, [ '@count', scalar(@{$puids}) ];
    foreach my $puid (@{$puids})
    {
        $self->_serialize_puid(\@list, $puid->puid, $inc, $opts);
    }
    push @{$data}, { 'isrc-list', \@list};
}

sub _serialize_puid
{
    my ($self, $data, $puid, $inc, $opts) = @_;

    my @list;
    push @list, [ '@id', $puid->puid ];
    $self->_serialize_recording_list(\@list, ${opts}->{recordings}, $inc, $opts)
         if (${opts}->{recordings});
    push @{$data}, { 'puid', \@list };
}

sub _serialize_isrc_list
{
    my ($self, $data, $isrcs, $inc, $opts) = @_;

    my @list;
    my %uniq_isrc;
    map { $uniq_isrc{$_->isrc} = $_ } @{$isrcs}; 
    push @list, [ '@count', scalar(keys %uniq_isrc) ];
    foreach my $k (keys %uniq_isrc)
    {
        $self->_serialize_isrc(\@list, $uniq_isrc{$k}, $inc, $opts);
    }
    push @{$data}, { 'isrc-list', \@list};
}

sub _serialize_isrc
{
    my ($self, $data, $isrc, $inc, $opts) = @_;

    my @list;
    push @list, [ '@id', $isrc->isrc ];
    $self->_serialize_recording(\@list, $isrc->recording, $inc, $opts)
        if ($isrc->recording);
    push @{$data}, { 'isrc', \@list };
}

sub output_error
{
    my ($self, $err) = @_;

    my $xml = $xml_decl_begin;
    $xml .= _output_xml($self, { error => [ [ 'text', $err . " For usage, please see: http://musicbrainz.org/development/mmd\015\012" ] ]});
    $xml .= $xml_decl_end;
    return $xml;
}

sub serialize
{
    my ($self, $type, $entity, $inc, $opts) = @_;
    $inc ||= 0;
    my $method = $type . "_resource";
    $method =~ s/release-group/release_group/;
    my $xml = $xml_decl_begin;
    $xml .= $self->$method($entity, $inc, $opts);
    $xml .= $xml_decl_end;
    return $xml;
}

sub artist_resource
{
    my ($self, $artist, $inc, $opts) = @_;

    my $data = [];
    $self->_serialize_artist($data, $artist, $inc, $opts);
    return $self->_output_xml($data->[0]);
}

sub label_resource
{
    my ($self, $label, $inc, $opts) = @_;

    my $data = [];
    $self->_serialize_label($data, $label, $inc, $opts);
    return $self->_output_xml($data->[0]);
}

sub release_group_resource
{
    my ($self, $release_group, $inc, $opts) = @_;
    
    my $data = [];
    $self->_serialize_release_group($data, $release_group, $inc, $opts);
    return $self->_output_xml($data->[0]);
}

sub release_resource
{
    my ($self, $release, $inc, $opts) = @_;

    my $data = [];
    $self->_serialize_release($data, $release, $inc, $opts);
    return $self->_output_xml($data->[0]);
}

sub recording_resource
{
    my ($self, $recording, $inc, $opts) = @_;

    my $data = [];
    $self->_serialize_recording($data, $recording, $inc, $opts);
    return $self->_output_xml($data->[0]);
}

sub work_resource
{
    my ($self, $work, $inc, $opts) = @_;

    my $data = [];
    $self->_serialize_work($data, $work, $inc, $opts);
    return $self->_output_xml($data->[0]);
}

sub isrc_resource
{
    my ($self, $isrc, $inc, $opts) = @_;

    my $data = [];
    $self->_serialize_isrc_list($data, $isrc, $inc, $opts);
    return $self->_output_xml($data->[0]);
}

sub puid_resource
{
    my ($self, $puid, $inc, $opts) = @_;

    my $data = [];
    $self->_serialize_puid($data, $puid, $inc, $opts);
    return $self->_output_xml($data->[0]);
}

sub disc_resource
{
    my ($self, $cdtoc, $inc, $opts) = @_;

    my $data = [];
    $self->_serialize_disc($data, $cdtoc, $inc, $opts);
    return $self->_output_xml($data->[0]);
}

__PACKAGE__->meta->make_immutable;
no Moose;
1;

=head1 COPYRIGHT

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
