package MusicBrainz::Server::Data::EditMigration;
use Moose;
use namespace::autoclean;

use DateTime::Format::Pg;
use IO::All;
use Memoize;
use Module::Pluggable::Object;

extends 'MusicBrainz::Server::Data::Entity';

my %edit_mapping;

sub BUILD
{
    my $class = shift;
    my $mpo = Module::Pluggable::Object->new(
        search_path => 'MusicBrainz::Server::Edit::Historic',
        require     => 1,
        except      => [qw(
                              MusicBrainz::Server::Edit::Historic::Fast
                              MusicBrainz::Server::Edit::Historic::Base
                              MusicBrainz::Server::Edit::Historic::NGSMigration
                              MusicBrainz::Server::Edit::Historic::Artist
                              MusicBrainz::Server::Edit::Historic::Label
                              MusicBrainz::Server::Edit::Historic::Utils
                              MusicBrainz::Server::Edit::Historic::Relationship
                       )]
    );

    %edit_mapping = (
        map { $_->historic_type => $_ }
            grep { $_->can('historic_type') && $_->historic_type }
                $mpo->plugins
    );
}

sub _table { 'public.edit_all' }

sub _columns {
    return 'id, artist, moderator, tab, col, type, status, rowid, prevvalue, newvalue, '.
        'yesvotes, novotes, depmod, automod, opentime, closetime, expiretime, language';
}

sub _new_from_row
{
    my ($self, $row) = @_;

    my $class = $edit_mapping{$row->{type}};

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
        created_time   => $row->{opentime},
        expires_time   => $row->{expiretime},
        close_time     => $row->{closetime},
        yes_votes      => $row->{yesvotes},
        no_votes       => $row->{novotes},
        auto_edit      => $row->{automod},
        status         => $row->{status},
        c              => $self->c,
        migration      => $self
    );

    # Some edits do not set an artist ID
    $args{artist_id} = $row->{artist} if $row->{artist};

    my $edit = $class->new(\%args);

    $edit->previous_value($edit->deserialize_previous_value($row->{prevvalue}));
    $edit->new_value($edit->deserialize_new_value($row->{newvalue}));

    return $edit;
}

sub _list_to_map {
    my ($self, $list, $old, $new) = @_;
    return { map {
        $_->{$old} => $_->{$new}
    } @$list };
}

sub construct_map
{
    my ($self, $table, $old, $new) = @_;

    $self->_list_to_map(
        $self->sql->select_list_of_hashes("
           SELECT $old, $new FROM $table
        "), $old, $new
    );
}

# Maps release to release groups
my $release_groups;
sub find_release_group_id
{
    my ($self, $id) = @_;
    $release_groups ||=
        $self->construct_map('release', 'id' => 'release_group');

    return $release_groups->{id};
}

my $tmp_recording_merge;
sub resolve_recording_id
{
    my ($self, $id) = @_;
    return 0 unless $id;
    $tmp_recording_merge ||=
        $self->construct_map('tmp_recording_merge',
                             'old_rec' => 'new_rec');

    return $tmp_recording_merge->{$id} || $id;
}

my $tmp_release_merge;
sub resolve_release_id
{
    my ($self, $id) = @_;
    return 0 unless $id;
    $tmp_release_merge ||=
        $self->construct_map('tmp_release_merge',
                             'old_rel' => 'new_rel');

    return $tmp_release_merge->{$id} || $id;
}

my $tmp_url_merge;
sub resolve_url_id
{
    my ($self, $id) = @_;
    $tmp_url_merge ||=
        $self->construct_map('tmp_url_merge',
                             'old_url' => 'new_url');

    return $tmp_url_merge->{$id} || $id;
}

my $tmp_release_album;
sub resolve_album_id
{
    my ($self, $id) = @_;
    $tmp_release_album ||=
        $self->construct_map('tmp_release_album',
                             'album' => 'release');

    return $tmp_release_album->{$id} || $id;
}

my $tmp_work_merge;
sub resolve_work_id
{
    my ($self, $id) = @_;
    $tmp_work_merge ||=
        $self->construct_map('tmp_work_merge',
                             'old_work' => 'new_work');

    return $tmp_work_merge->{$id} || $id;
}

my $public_annotations;
sub resolve_annotation_id
{
    my ($self, $id) = @_;
    $public_annotations ||=
        $self->construct_map('public.annotation',
                             'moderation' => 'id');
    return $public_annotations->{$id};
}

my $artist_name;
sub artist_name
{
    my ($self, $id) = @_;
    $artist_name ||= $self->_list_to_map(
        $self->sql->select_list_of_hashes(q{
            SELECT artist.id, name.name FROM artist
              JOIN artist_name name ON artist.name=name.id
        }), 'id' => 'name');

    return $artist_name->{$id} || sprintf '[ Artist #%d ]', $id;
}

my $label_alias;
sub label_id_from_alias
{
    my ($self, $id) = @_;
    $label_alias ||=
        $self->construct_map('public.labelalias', 'id' => 'ref');

    return $label_alias->{id};
}

my $track_album;
sub track_to_album
{
    my ($self, $id) = @_;
    return $self->c->sql->select_single_value('SELECT album FROM public.albumjoin WHERE track = ?', $id);
}

my $album_release_ids;
sub album_release_ids
{
    my ($self, $album_id) = @_;
    return [] unless $album_id;

    $album_release_ids ||= do {

        my $query = q{
        SELECT rels.album, COALESCE(new_rel, rels.release) AS release
          FROM tmp_release_merge
    RIGHT JOIN (
            SELECT release,album FROM tmp_release_album
         UNION
            SELECT id,album FROM public.release) rels ON rels.release = old_rel
        };

        my $maps = $self->sql->select_list_of_hashes($query);
        my $mapping = {};
        for my $assoc (@$maps) {
            my ($album, $release) = ( $assoc->{album}, $assoc->{release} );
            $mapping->{$album} ||= [];
            push @{ $mapping->{$album} }, $release;
        }

        $mapping;
    };

    return $album_release_ids->{$album_id} || [];
}

sub link_attribute_from_name
{
    my ($self, $name) = @_;
    return $self->sql->select_single_value(q{
        SELECT id FROM link_attribute_type
         WHERE name = ?
         LIMIT 1
    }, $name);
}

no Moose;
__PACKAGE__->meta->make_immutable;

