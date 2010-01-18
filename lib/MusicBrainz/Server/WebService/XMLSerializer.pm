package MusicBrainz::Server::WebService::XMLSerializer;

use Moose;
use MusicBrainz::Server::WebService::Escape qw( xml_escape );
use Scalar::Util 'reftype';
use Readonly;

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

    if ($aliases)
    {
        my @alias_list;
        push @alias_list, [ '@count', length(@{$aliases}) ];
        foreach my $al (@{$aliases})
        {
            push @alias_list, [ 'alias', $al->name ];
        }
        push @{$data}, { 'alias-list' => \@alias_list };
    }
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

    $self->_serialize_release_list(\@rg, $opts->{releases}, $inc, $opts)
        if ($opts->{releases} && $inc->{releases});

# TODO: relation list

    push @{$data}, { 'release-group', \@rg };
}

sub _serialize_release_list
{
    my ($self, $data, $releases, $inc, $opts) = @_;

    my @list;
    push @list, [ '@count', length(@{$releases}) ];
    foreach my $release (@{$releases})
    {
        $self->_serialize_release(\@list, $release, $inc, $opts);
    }
    push @{$data}, { 'release-list', \@list};
}

sub _serialize_release
{
    my ($self, $data, $release, $inc, $opts) = @_;
    my @rel;

    push @rel, [ '@id', $release->gid ];
    push @rel, [ 'title', $release->name ];
    push @rel, [ 'status', lc($release->status->name) ] if ($release->status);
    push @rel, [ 'disambiguation', $release->comment ] if ($release->comment);
    push @rel, [ 'packaging', $release->packaging ] if ($release->packaging);

    $self->_serialize_text_representation(\@rel, $release, $inc, $opts);

    $self->_serialize_artist_credit(\@rel, $release->artist_credit, $inc, $opts)
        if ($release->artist_credit && $inc->{artists});

    $self->_serialize_release_group(\@rel, $release->release_group, $inc, $opts)
        if ($release->release_group && $inc->releasegroups);

    push @rel, [ 'date', $release->date->format ] if ($release->date);
    push @rel, [ 'country', $release->country->iso_code ] if ($release->country);
    push @rel, [ 'barcode', $release->barcode ] if ($release->barcode);
    push @rel, [ 'asin', $release->amazon_asin ] if ($release->amazon_asin);

    $self->_serialize_label_info_list(\@rel, $release->labels, $inc, $opts)
        if ($release->labels && $inc->labels);

    $self->_serialize_medium_list(\@rel, $release->mediums, $inc, $opts)
        if ($release->mediums && $inc->recordings);

    push @{$data}, { 'release', \@rel };
}

sub _serialize_recording
{
    my ($self, $data, $recording, $inc, $opts) = @_;
    my @rg;

    push @rg, [ '@id', $recording->gid ];
    push @rg, [ 'title', $recording->name ];
    push @rg, [ 'length', MusicBrainz::Server::Track::FormatTrackLength($recording->length) ];
    push @rg, [ 'disambiguation', $recording->comment ] if ($recording->comment);
    # TODO: ISRC list

    $self->_serialize_artist_credit(\@rg, $recording->artist_credit, $inc, $opts)
        if ($recording->artist_credit && $inc->{artists});

    $self->_serialize_release_list(\@rg, $opts->{releases}, $inc, $opts)
        if ($opts->{releases} && $inc->{releases});

# TODO: release list
# TODO: PUID list
# TODO: relation list

    push @{$data}, { 'recording', \@rg };
}

sub _serialize_medium_list
{
    my ($self, $data, $mediums, $inc, $opts) = @_;

    my @list;
    push @list, [ '@count', length(@{$mediums}) ];
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
    $self->_serialize_track_list(\@med, $medium->tracklist, $inc, $opts);
    push @{$data}, { 'medium', \@med };
}

sub _serialize_track_list
{
    my ($self, $data, $tracklist, $inc, $opts) = @_;

    my @list;
    push @list, [ '@count', length(@{$tracklist->tracks}) ];
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
    $self->_serialize_recording(\@track, $track->recording, MusicBrainz::Server::WebService::WebServiceInc->new(),  {});
    push @{$data}, { 'track', \@track};
}

sub _serialize_label_info_list
{
    my ($self, $data, $rel_labels, $inc, $opts) = @_;

    my @list;
    push @list, [ '@count', length(@{$rel_labels}) ];
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

    my @list;
    push @list, [ '@count', length(@{$labels}) ];
    foreach my $label (@{$labels})
    {
        $self->_serialize_label(\@list, $label, $inc, $opts);
    }
    push @{$data}, { 'label-list', \@list};
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
    my ($self, $entity, $data, $rels, $inc, $opts) = @_;

    my %types = ();
    foreach my $rel (@{$rels})
    {
        if ($rel->{entity0_id} eq $entity->id && ref($rel->{entity0}) eq ref($entity))
        {
            my $type = ref($rel->{entity1});
            $type =~ s/MusicBrainz::Server::Entity:://;
            $types{$type} = 1;
        }
        if ($rel->{entity1_id} eq $entity->id && ref($rel->{entity1}) eq ref($entity))
        {
            my $type = ref($rel->{entity0});
            $type =~ s/MusicBrainz::Server::Entity:://;
            $types{$type} = 1;
        }
    }
    my @list;
    foreach my $type (keys %types)
    {
        push @list, [ '@target-type', $type ];
        foreach my $rel(@{$rels})
        {
            $self->_serialize_relation(\@list, $rel, $inc, $opts);
        }
    }
    push @{$data}, { 'release-list', \@list};
}

sub _serialize_relation
{
    my ($self, $data, $rels, $inc, $opts) = @_;

}

sub output_error
{
    my ($self, $err) = @_;

    my $xml = $xml_decl_begin;
    $xml .= _output_xml($self, { error => [ [ 'text', $err ] ]});
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

    my $data = { 
         artist => [
             [ '@id', $artist->gid],
         ]
    };

    push @{$data->{artist}}, [ '@type', lc($artist->type->name) ] if ($artist->type);
    push @{$data->{artist}}, [ 'name', $artist->name ];
    push @{$data->{artist}}, [ 'sort-name', $artist->sort_name ] if ($artist->sort_name);
    push @{$data->{artist}}, [ 'gender', lc($artist->gender->name) ] if ($artist->gender);
    push @{$data->{artist}}, [ 'country', lc($artist->country->iso_code) ] if ($artist->country);
    push @{$data->{artist}}, [ 'disambiguation', $artist->comment ] if ($artist->comment);

    $self->_serialize_life_span($data->{artist}, $artist, $inc, $opts);
    $self->_serialize_alias($data->{artist}, $opts->{aliases}, $inc, $opts) if ($inc->aliases);

    if ($inc->rg_type)
    {
        my $rg_data = [];
        push @{$rg_data}, [ '@count', length(@{$opts->{release_groups}}) ];
        foreach my $rg (@{$opts->{release_groups}})
        {
            $self->_serialize_release_group($rg_data, $rg, $inc, $opts) 
        }
        push @{$data->{artist}}, { 'release-group-list' => $rg_data };
    }

    $self->_serialize_label_list($data->{artist}, $opts->{labels}, $inc, $opts) if ($inc->labels);

#    $self->_serialize_relation_lists($artist, $data->{artist}, $artist->relationships, $inc, $opts)
#        if ($inc->has_rels);

    return $self->_output_xml($data);
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
