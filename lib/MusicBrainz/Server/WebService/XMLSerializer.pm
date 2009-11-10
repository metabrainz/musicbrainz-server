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
    my ($self, $entity, $data) = @_;
    my $has_begin_date = !$entity->begin_date->is_empty;
    my $has_end_date = !$entity->end_date->is_empty;
    if ($has_begin_date || $has_end_date) {
        my @span;
        push @span, [ 'begin', $entity->begin_date->format ] if $has_begin_date;
        push @span, [ 'end', $entity->end_date->format ] if $has_end_date;
        push @{$data}, { 'life-span' => \@span }; 
    }
}

sub _serialize_alias
{
    my ($self, $data, $aliases) = @_;

    if ($aliases)
    {
        my @alias_list;

        foreach my $al (@{$aliases})
        {
            push @alias_list, [ 'alias', $al->name ];
        }
        push @{$data}, { 'alias-list' => \@alias_list };
    }
}

sub _serialize_artist_credit
{
    my ($self, $data, $artist_credit) = @_;

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
    my $method = "serialize_$type";
    my $xml = $xml_decl_begin;
    $xml .= $self->$method($entity, $inc, $opts);
    $xml .= $xml_decl_end;
    return $xml;
}

sub serialize_artist
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

    $self->_serialize_life_span($artist, $data->{artist});
    $self->_serialize_alias($data->{artist}, $opts->{aliases}) if ($inc->aliases);

    if ($inc->rg_type)
    {
        my $rg_data = [];
        foreach my $rg (@{$opts->{release_groups}})
        {
            $self->serialize_release_group($rg, $rg_data) 
        }
        push @{$data->{artist}}, { 'release-group-list' => $rg_data };
    }

    return $self->_output_xml($data);
}

sub serialize_release_group
{
    my ($self, $release_group, $data, $inc) = @_;
    my @rg;

    push @rg, [ '@id', $release_group->gid ];
    push @rg, [ '@type', lc($release_group->type->name) ] if ($release_group->type);
    push @rg, [ 'title', $release_group->name ];

    $self->_serialize_artist_credit(\@rg, $release_group->artist_credit);
    push @rg, [ 'disambiguation', $release_group->comment ] if ($release_group->comment) ;
    push @{$data}, { "release-group", \@rg };
}

# DO NOT REVIEW PAST HERE
sub serialize_release
{
    my ($self, $release, $data, $inc) = @_;

    my @rel;

    push @rel, [ '@id', $release->gid ];
    push @rel, [ 'name', $release->name ];

#    $out .= $self->serialize_artist_credit($release->artist_credit);
#    if ($release->comment) {
#        $out .= '<disambiguation>' . xml_escape($release->comment) . '</disambiguation>';
#    }
#    if ($release->barcode) {
#        $out .= '<barcode>' . xml_escape($release->barcode) . '</barcode>';
#    }
    push @{$data}, { 'release' => \@rel }; 
}

sub serialize_label
{
    my ($self, $label, $inc) = @_;
    my $out = '<label id="' .$label->gid . '"';
    if ($label->type) {
        $out .= ' type="' . xml_escape(lc($label->type->name)) . '"';
    }
    $out .= '>';
    $out .= '<name>' . xml_escape($label->name) . '</name>';
    $out .= '<sort-name>' . xml_escape($label->sort_name) . '</sort-name>';
    $out .= $self->_serialize_life_span($label);
    if ($label->comment) {
        $out .= '<disambiguation>' . xml_escape($label->comment) . '</disambiguation>';
    }
    if ($label->country) {
        $out .= '<country>' . xml_escape($label->country->iso_code) . '</country>';
    }
    $out .= '</label>';

    return $out;
}

sub serialize_work
{
    my ($self, $work, $inc) = @_;
    my $out = '<work id="' .$work->gid . '"';
    if ($work->type) {
        $out .= ' type="' . xml_escape(lc($work->type->name)) . '"';
    }
    $out .= '>';
    $out .= '<name>' . xml_escape($work->name) . '</name>';
    $out .= $self->serialize_artist_credit($work->artist_credit);
    if ($work->comment) {
        $out .= '<disambiguation>' . xml_escape($work->comment) . '</disambiguation>';
    }
    if ($work->iswc) {
        $out .= '<iswc>' . xml_escape($work->iswc) . '</iswc>';
    }
    $out .= '</work>';
    return $out;
}

sub serialize_recording
{
    my ($self, $recording, $inc) = @_;
    my $out = '';
    $out .= '<recording id="' .$recording->gid . '">';
    $out .= '<name>' . xml_escape($recording->name) . '</name>';
    $out .= $self->serialize_artist_credit($recording->artist_credit);
    if ($recording->comment) {
        $out .= '<disambiguation>' . xml_escape($recording->comment) . '</disambiguation>';
    }
    if ($recording->length) {
        $out .= '<length>' . $recording->length . '</length>';
    }
    $out .= '</recording>';
    return $out;
}

__PACKAGE__->meta->make_immutable;
no Moose;
1;

=head1 COPYRIGHT

Copyright (C) 2009 Lukas Lalinsky
Copyright (C) 2004 Robert Kaye

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
