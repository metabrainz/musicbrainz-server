package MusicBrainz::Server::Model::Artist;

use strict;
use warnings;

use base 'MusicBrainz::Server::Model';

use Carp;
use MusicBrainz::Server::Validation 'encode_entities';
use MusicBrainz::Server::Adapter 'LoadEntity';
use MusicBrainz::Server::Artist;
use SearchEngine;

=head2 load $id

Loads a new artist, given a specific GUID or database row id.

=cut

sub load
{
    my ($self, $id) = @_;

    my $artist = new MusicBrainz::Server::Artist($self->dbh);
    $artist = LoadEntity($artist, $id);

    return $artist;
}

=head2 search_by_name $name

Search for all artists with the exact name C<$name>.

=cut

sub search_by_name
{
    my ($self, $name) = @_;

    my $artist = MusicBrainz::Server::Artist->new($self->dbh);
    return $artist->find_artists_by_name($name);
}

=head2 create

Create an artist and enter a moderation in the moderation queue

=cut

sub create
{
    my ($self, $edit_note, %artist_opts) = @_;

    my ($begin, $end) =
    (
        [ map {$_ == '00' ? '' : $_} (split m/-/, $artist_opts{begin_date} || '') ],
        [ map {$_ == '00' ? '' : $_} (split m/-/, $artist_opts{end_date}   || '') ],
    );

    my @mods = $self->context->model('Moderation')->insert(
        $edit_note,

        type  => ModDefs::MOD_ADD_ARTIST,

        name              => $artist_opts{name},
        sortname          => $artist_opts{sort_name},
        mbid              => '',
        artist_type       => $artist_opts{type},
        artist_resolution => $artist_opts{resolution} || '',

        artist_begindate => $begin,
        artist_enddate   => $end,
    );

    my @add_mods = grep { $_->type eq ModDefs::MOD_ADD_ARTIST } @mods;

    if (scalar @add_mods) {
        my $mod = $add_mods[0];

        my $artist = MusicBrainz::Server::Artist->new($self->context->mb->{dbh});
        $artist->name($artist_opts{name});
        $artist->sort_name($artist_opts{sort_name});
        $artist->type($artist_opts{type});
        $artist->resolution($artist_opts{resolution});
        $artist->id($mod->row_id);

        return $artist;
    }
}

=head2 edit

Insert an edit artist moderation into the moderation queue

=cut

sub edit
{
    my ($self, $artist, $edit_note, %artist_opts) = @_;

    my ($begin, $end) =
    (
        [ map {$_ == '00' ? '' : $_} (split m/-/, $artist_opts{begin} || '') ],
        [ map {$_ == '00' ? '' : $_} (split m/-/, $artist_opts{end}   || '') ],
    );

    my @mods = $self->context->model('Moderation')->insert(
        $edit_note,

        type  => ModDefs::MOD_EDIT_ARTIST,

        artist => $artist,

        name              => $artist_opts{name},
        sortname          => $artist_opts{sort_name},
        artist_type       => $artist_opts{type},
        resolution        => $artist_opts{resolution} || '',
        begindate         => $begin,
        enddate           => $end,
    );
}

=head2 merge

Merge 2 artists into one, entering a moderation into the moderation queue

=cut

sub merge
{
    my ($self, $source, $target, $edit_note) = @_;

    my @mods = $self->context->model('Moderation')->insert(
        $edit_note,

        type  => ModDefs::MOD_MERGE_ARTIST,

        source => $source,
        target => $target,
    );
}

sub change_quality
{
    my ($self, $artist, $new_quality, $edit_note) = @_;

    $self->context->model('Moderation')->insert(
        $edit_note,

        type => ModDefs::MOD_CHANGE_ARTIST_QUALITY,

        artist  => $artist,
        quality => $new_quality,
    );
}

sub add_alias
{
    my ($self, $artist, $alias_name, $edit_note) = @_;

    $self->context->model('Moderation')->insert(
        $edit_note,

        type => ModDefs::MOD_ADD_ARTISTALIAS,

        artist   => $artist,
        newalias => $alias_name,
    );
}

sub remove_alias
{
    my ($self, $artist, $alias, $edit_note) = @_;

    $self->context->model('Moderation')->insert(
        $edit_note,

        type => ModDefs::MOD_REMOVE_ARTISTALIAS,

        artist => $artist,
        alias  => $alias,
    );
}

sub update_alias
{
    my ($self, $artist, $alias, $new_alias, $edit_note) = @_;

    $self->context->model('Moderation')->insert(
        $edit_note,

        type => ModDefs::MOD_EDIT_ARTISTALIAS,

        newname => $new_alias,
        artist  => $artist,
        alias   => $alias,
    );
}

sub find_similar_artists
{
    my ($self, $artist) = @_;

    croak "No artist was provided"
        unless ref $artist;

    my $similar_artists = $artist->relations;

    return [ map {
        +{
            artist => MusicBrainz::Server::Artist->new($self->dbh, $_),
            weight => $_->{weight},
        };
    } @$similar_artists ];
}

sub direct_search
{
    my ($self, $query) = @_;

    my $engine = new SearchEngine($self->context->mb->{dbh}, 'artist');
    $engine->Search(query => $query, limit => 0);

    return undef
        unless $engine->Result != &SearchEngine::SEARCHRESULT_NOQUERY;

    my @artists;

    while(my $row = $engine->NextRow)
    {
        my $artist = new MusicBrainz::Server::Artist($self->context->mb->{dbh});
        $artist->id($row->{artistid});
        $artist->mbid($row->{artistgid});
        $artist->name($row->{artistname});
        $artist->sort_name($row->{artistsortname});
        $artist->resolution($row->{artistresolution});

        push @artists, $artist;
    }

    return \@artists;
}

sub get_browse_selection
{
    my ($self, $index, $offset) = @_;

    my $ar = MusicBrainz::Server::Artist->new($self->dbh);
    my ($count, $artists) = $ar->artist_browse_selection($index, $offset);

    return ($count, $artists);
}

1;
