package MusicBrainz::Server::Data::EditMigration;
use Moose;

use Memoize;
use Module::Pluggable::Object;
use URI::Escape qw( uri_escape uri_unescape );

memoize(qw(
    artist_name
    find_release_group_id
    resolve_album_id
    resolve_recording_id
    resolve_release_id
));

extends 'MusicBrainz::Server::Data::Entity';

has 'edit_mapping' => (
    isa        => 'HashRef',
    is         => 'ro',
    traits     => [ 'Hash' ],
    lazy_build => 1,
    handles    => {
        class_for_type => 'get',
    }
);

sub _build_edit_mapping
{
    my $mpo = Module::Pluggable::Object->new(
        search_path => 'MusicBrainz::Server::Edit::Historic',
        require     => 1
    );

    return {
        map { $_->edit_type => $_ } grep { $_->can('edit_type') } $mpo->plugins
    };
}

sub _table { 'public.edit_all' }

sub _columns {
    return 'id, artist, moderator, tab, col, type, status, rowid, prevvalue, newvalue, '.
        'yesvotes, novotes, depmod, automod, opentime, closetime, expiretime, language';
}

sub _new_from_row
{
    my ($self, $row) = @_;

    my $class = $self->class_for_type($row->{type});

    if (!$class) {
        warn 'No handler for ' . $row->{type};
        return;
    }

    my %args = (
        id             => $row->{id},
        editor_id      => $row->{moderator},
        table          => $row->{tab},
        column         => $row->{col},
        row_id         => $row->{rowid},
        previous_value => $class->deserialize_previous_value ? $self->deserialize($row->{prevvalue}) : $row->{prevvalue},
        new_value      => $class->deserialize_new_value      ? $self->deserialize($row->{newvalue})  : $row->{newvalue},
        created_time   => $row->{opentime},
        expires_time   => $row->{expiretime},
        close_time     => $row->{closetime},
        yes_votes      => $row->{yesvotes},
        no_votes       => $row->{novotes},
        auto_edit      => $row->{automod},
        c              => $self->c,
        migration      => $self
    );

    # Some edits do not set an artist ID
    $args{artist_id} = $row->{artist} if $row->{artist};

    return $class->new(%args);
}

# Maps release to release groups
sub find_release_group_id
{
    my ($self, $id) = @_;
    return $self->sql->select_single_value(q{
        SELECT release_group FROM release WHERE id = ?
    }, $id);
}

sub resolve_recording_id
{
    my ($self, $id) = @_;
    $self->sql->select_single_value(q{
        SELECT new_rec FROM tmp_recording_merge
         WHERE old_rec = ?
    }, $id) || $id;
}

sub resolve_release_id
{
    my ($self, $id) = @_;
    $self->sql->select_single_value(q{
        SELECT new_rel FROM tmp_release_merge
         WHERE old_rel = ?
    }, $id) || $id;
}

sub resolve_album_id
{
    my ($self, $id) = @_;
    return $self->sql->select_single_value(q{
        SELECT release FROM tmp_release_album
         WHERE album = ?
    }, $id);
}

sub artist_name
{
    my ($self, $id) = @_;
    return $self->sql->select_single_value(q{
        SELECT name.name FROM artist
          JOIN artist_name name ON artist.name=name.id
         WHERE artist.id = ?
    }, $id) || sprintf '[ Artist #%d ]', $id;
}

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

    return uri_unescape($data) if $scheme eq "URI";
    die "Unknown encoding scheme '$scheme'";
}

no Moose;
__PACKAGE__->meta->make_immutable;

