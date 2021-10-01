package MusicBrainz::Server::Edit::Historic::Relationship;

use MusicBrainz::Server::Edit::Historic::Base;

use MusicBrainz::Server::Constants qw( :direction );
use MusicBrainz::Server::Data::Utils qw( type_to_model );
use MusicBrainz::Server::Edit::Historic::Utils qw( upgrade_type );
use MusicBrainz::Server::Entity::Util::JSON qw( to_json_object );

use aliased 'MusicBrainz::Server::Entity::Link';
use aliased 'MusicBrainz::Server::Entity::LinkType';
use aliased 'MusicBrainz::Server::Entity::PartialDate';
use aliased 'MusicBrainz::Server::Entity::Relationship';

sub _build_related_entities
{
    my $self = shift;
    my %rel;

    for my $link ($self->_links) {
        $rel{ $link->{entity0_type} } ||= [];
        push @{ $rel{ $link->{entity0_type} } }, $link->{entity0_id};

        $rel{ $link->{entity1_type} } ||= [];
        push @{ $rel{ $link->{entity1_type} } }, $link->{entity1_id};
    }

    return \%rel;
}

sub foreign_keys
{
    my $self = shift;
    my %fk;

    for my $link ($self->_links) {
        my $k0 = type_to_model($link->{entity0_type});
        $fk{ $k0  } ||= [];
        push @{ $fk{ $k0 } }, $link->{entity0_id};

        my $k1 = type_to_model($link->{entity1_type});
        $fk{ $k1  } ||= [];
        push @{ $fk{ $k1 } }, $link->{entity1_id};
    }

    return \%fk;
}

# Maps a relationship of a certain type to one (or more) relationships
my %end_point_map = (
# Example:
# Link type id 5 for artist-recording relationships is migrated as
# artist-recording and artist-work
# artist => {
#    recording => {
#        5 => [
#              type_0    type_1
#            [ 'artist', 'recording' ]
#            [ 'artist', 'work'      ]
#        ]
#    }
# }
 'album' => {
    'album' => {
        13 => [ [ 'release_group', 'release_group' ] ], # cover
        11 => [ [ 'release_group', 'release_group' ] ], # live performance
        8  => [ [ 'release_group', 'release_group' ] ], # compilations
        9  => [ [ 'release_group', 'release_group' ] ], # DJ-mix
        4  => [ [ 'release_group', 'release_group' ] ], # remixes
        7  => [ [ 'release_group', 'release_group' ] ], # remix
        5  => [ [ 'release_group', 'release_group' ] ], # mash-up
        18 => [ [ 'release_group', 'release_group' ] ], # single from
    },
    'artist' => {
        44 => [ [ 'artist', 'release_group' ] ], # tribute
        28 => [ [ 'artist', 'release_group' ] ], # artists and repertoire
        29 => [ [ 'artist', 'release_group' ] ], # creative direction
        34 => [ [ 'artist', 'release_group' ] ], # travel
    },
    'url' => {
        25 => [ [ 'release_group', 'url' ] ], # musicmoz
        16 => [ [ 'release_group', 'url' ] ], # discography
        23 => [ [ 'release_group', 'url' ] ], # wikipedia
        17 => [ [ 'release_group', 'url' ] ], # review
        36 => [ [ 'release_group', 'url' ] ], # ibdb
        37 => [ [ 'release_group', 'url' ] ], # iobdb
        27 => [ [ 'release_group', 'url' ] ], # IMDb
        38 => [ [ 'release_group', 'url' ] ], # lyrics
        41 => [ [ 'release_group', 'url' ] ], # recording studio
        42 => [ [ 'release_group', 'url' ] ], # score
    },
 },
 'artist' => {
    'track' => {
        13 => [ [ 'artist', 'work' ] ], # composition
        14 => [ [ 'artist', 'work' ] ], # composer
        16 => [ [ 'artist', 'work' ] ], # lyricist
        43 => [ [ 'artist', 'work' ] ], # instrumentator
        44 => [ [ 'artist', 'work' ] ], # orchestrator
        51 => [ [ 'artist', 'work' ] ], # librettist
        53 => [ [ 'artist', 'work' ] ], # writer
    },
 },
 'track' => {
    'track' => {
        4  => [ [ 'work', 'work' ] ],      # other version
# FIXME:
        5  => [                            # cover
            [ 'recording', 'work' ],
            [ 'work', 'work'      ],
        ],
        14 => [ [ 'recording', 'work' ] ], # medley
    },
    'url' => {
        18 => [ [ 'work', 'url' ] ], # other databases
        23 => [ [ 'work', 'url' ] ], # ibdb
        24 => [ [ 'work', 'url' ] ], # iobdb
        25 => [ [ 'work', 'url' ] ], # lyrics
        26 => [ [ 'work', 'url' ] ], # score
    },
 },
);

# ArtistID -> [ ArtistID ]
sub artist_ids        { shift; return ( shift ) }

# LabelID -> [ LabelID ]
sub label_ids         { shift; return ( shift ) }

# TrackID -> [ RecordingID ]
sub recording_ids     {
    my $self = shift;
    return ( $self->resolve_recording_id(shift) );
}

# AlbumID -> [ ReleaseID ]
sub release_ids       {
    my $self = shift;
    return @{ $self->album_release_ids(shift) };
}

# AlbumID -> [ ReleaseGroupID ]
sub release_group_ids {
    my $self = shift;
    return $self->find_release_group_id(
        $self->resolve_album_id(shift));
}

# UrlID -> [ UrlID ]
sub url_ids           { my $self = shift; return ( $self->resolve_url_id(shift) ) }

# TrackID -> [ WorkID ]
sub work_ids          { my $self = shift; return ( $self->resolve_work_id(shift) ) }

sub _expand_relationships {
    my ($self, $link_type_id,
        $entity0_type, $entity0_id, $entity0_name,
        $entity1_type, $entity1_id, $entity1_name,
        $link_type_phrase) = @_;

    my $mappings = $end_point_map{$entity0_type}{$entity1_type}{$link_type_id} ||
        [ [
            upgrade_type($entity0_type),
            upgrade_type($entity1_type)
        ] ];

    if ($entity0_type eq 'track' && $entity1_type eq 'track' && $link_type_id == 5) {
        if ($link_type_phrase =~ /translated/ || $link_type_phrase =~ /parody/) {
            $mappings = [
                [ 'work', 'work' ]
            ];
            ($entity0_id, $entity1_id) = ($entity1_id, $entity0_id);

            if ($link_type_phrase =~ /translated/ && $link_type_phrase =~ /parody/) {
                $link_type_phrase = 'later translated parody versions';
            }
            elsif ($link_type_phrase =~ /translated/) {
                $link_type_phrase = 'later translated versions';
            }
            elsif ($link_type_phrase =~ /parody/) {
                $link_type_phrase = 'later parody versions';
            }
        }
        else {
            $mappings = [
                [ 'recording', 'work' ]
            ];
        }
    }

    return map {
        my ($mapped_type0, $mapped_type1) = @$_;
        my $map_0 = $mapped_type0 . '_ids';
        my $map_1 = $mapped_type1 . '_ids';
        map {
            my $mapped0_id = $_;
            map {
                my $mapped1_id = $_;
                +{
                    entity0_id       => $mapped0_id,
                    entity1_id       => $mapped1_id,
                    entity0_type     => $mapped_type0,
                    entity1_type     => $mapped_type1,
                    entity0_name     => $entity0_name,
                    entity1_name     => $entity1_name,
                    link_type_phrase => $link_type_phrase
                }
            } $self->$map_1($entity1_id)
        } $self->$map_0($entity0_id)
    } @$mappings;
}

# To access entities missing an ID via linkedEntities later on
my $fake_entity_id = 1000000000;

sub _display_relationships {
    my ($self, $data, $loaded) = @_;

    # Since the link phrase with attributes to display is hacked
    # onto the link type phrase, we need to pass them separately
    # to linkedEntities.
    my $link_type_id = $fake_entity_id++;

    return [
        map {
            my $entity0_type = $_->{entity0_type};
            my $entity1_type = $_->{entity1_type};
            my $model0 = type_to_model( $_->{entity0_type} );
            my $model1 = type_to_model( $_->{entity1_type} );
            my $entity0_id = $_->{entity0_id} // $fake_entity_id++;
            my $entity1_id = $_->{entity1_id} // $fake_entity_id++;
            my $entity0 = $loaded->{ $model0 }{ $entity0_id } ||
                $self->c->model($model0)->_entity_class->new(
                    id => $entity0_id,
                    name => $_->{entity0_name}
                );
            MusicBrainz::Server::Entity::Relationship->link_entity($entity0_type, $entity0_id, $entity0);
            my $entity1 = $loaded->{ $model1 }{ $entity1_id } ||
                $self->c->model($model1)->_entity_class->new(
                    id => $entity1_id,
                    name => $_->{entity1_name},
                );

            to_json_object(Relationship->new(
                entity0_id => $entity0_id,
                entity1_id => $entity1_id,
                source => $entity0,
                target => $entity1,
                link    => Link->new(
                    id         => $data->{link_id},
                    begin_date => PartialDate->new($data->{begin_date}),
                    end_date   => PartialDate->new($data->{end_date}),
                    type_id    => $link_type_id,
                    type       => LinkType->new(
                        entity0_type => $entity0_type,
                        entity1_type => $entity1_type,
                        id           => $link_type_id,
                        link_phrase  => $_->{link_type_phrase}
                    )
                ),
                direction => $DIRECTION_FORWARD,
            ));
        } @{ $data->{links} }
    ];
}

1;
