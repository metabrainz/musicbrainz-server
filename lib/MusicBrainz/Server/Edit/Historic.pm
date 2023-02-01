package MusicBrainz::Server::Edit::Historic;
use Moose;
use MooseX::Types::Moose qw( Int HashRef Maybe Object Str );

use MusicBrainz::Server::Translation qw( l );

extends 'MusicBrainz::Server::Edit';

sub historic_type { shift->edit_type }
sub edit_category { l('Historic') }

has 'migration' => (
    isa     => Object,
    is      => 'ro',
    handles => [qw(
        album_release_ids
        find_release_group_id
        link_attribute_from_name
        resolve_album_id
        resolve_url_id
        resolve_release_id
        resolve_recording_id
        artist_name
        label_id_from_alias
        resolve_annotation_id
    )]
);

has [qw( artist_id row_id )] => (
    isa => Int,
    is  => 'ro',
);

has [qw( table column )] => (
    isa => Str,
    is  => 'ro'
);

has [qw( new_value previous_value )] => (
    isa => Maybe[HashRef | Str],
    is  => 'rw',
);

sub _build_related_entities { return {} }

sub deserialize
{
    my ($self, $serialized) = @_;
    return {} unless $serialized;

    my %kv;
    for my $line (split /\n/, $serialized) {
        my ($k, $v) = split /=/, $line, 2;
        return undef unless defined $v;
        $kv{$k} = $self->_decode_value($v);
    }

    return \%kv;
}

sub _decode_value
{
    my ($self, $value) = @_;
    my ($scheme, $data) = $value =~ /\A\x1B(\w+);(.*)\z/s
        or return $value;

    return uri_unescape($data) if $scheme eq 'URI';
    die "Unknown encoding scheme '$scheme'";
}

sub deserialize_previous_value { shift->deserialize(shift) }
sub deserialize_new_value      { shift->deserialize(shift) }

no Moose;
__PACKAGE__->meta->make_immutable;
1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2010 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
