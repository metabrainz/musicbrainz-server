package MusicBrainz::Server::Edit::Release::EditArtist;
use Moose;
use namespace::autoclean;

use MooseX::Types::Moose qw( Bool Int Str );
use MooseX::Types::Structured qw( Dict );
use MusicBrainz::Server::Constants qw(
    $EDIT_RELEASE_ARTIST
    $EDIT_RELEASE_CREATE
);
use MusicBrainz::Server::Edit::Exceptions;
use MusicBrainz::Server::Edit::Types qw( ArtistCreditDefinition );
use MusicBrainz::Server::Edit::Utils qw(
    artist_credit_from_loaded_definition
    load_artist_credit_definitions
);
use MusicBrainz::Server::Entity::Util::JSON qw( to_json_object );
use MusicBrainz::Server::Translation qw( N_l );

extends 'MusicBrainz::Server::Edit';
with 'MusicBrainz::Server::Edit::Role::Preview';
with 'MusicBrainz::Server::Edit::Release::RelatedEntities';
with 'MusicBrainz::Server::Edit::Release';
with 'MusicBrainz::Server::Edit::Role::AllowAmending' => {
    create_edit_type => $EDIT_RELEASE_CREATE,
    entity_type => 'release',
};

use aliased 'MusicBrainz::Server::Entity::Release';

sub edit_name { N_l('Edit release') }
sub edit_kind { 'edit' }
sub edit_type { $EDIT_RELEASE_ARTIST }
sub release_id { shift->data->{entity}{id} }
sub edit_template { 'EditRelease' }

has '+data' => (
    isa => Dict[
        entity => Dict[
            id => Int,
            name => Str
        ],
        update_tracklists => Bool,
        old_artist_credit => ArtistCreditDefinition,
        new_artist_credit => ArtistCreditDefinition
    ]
);

around allow_auto_edit => sub {
    my ($orig, $self, @args) = @_;

    return 1 if $self->can_amend($self->release_id);

    return $self->$orig(@args);
};

around _build_related_entities => sub {
    my ($orig, $self) = @_;

    my $related = $self->$orig;
    if (exists $self->data->{new_artist_credit}) {
        my %new = load_artist_credit_definitions($self->data->{new_artist_credit});
        my %old = load_artist_credit_definitions($self->data->{old_artist_credit});
        push @{ $related->{artist} }, keys(%new), keys(%old);
    }

    return $related;
};


sub foreign_keys {
    my ($self) = @_;
    my $relations = {};

    if (exists $self->data->{new_artist_credit}) {
        $relations->{Artist} = {
            map {
                load_artist_credit_definitions($self->data->{$_})
            } qw( new_artist_credit old_artist_credit )
        };
    }

    $relations->{Release} = {
        $self->data->{entity}{id} => [ 'ArtistCredit' ]
    };

    return $relations;
}

sub build_display_data {
    my ($self, $loaded) = @_;

    my $data = {};

    if (exists $self->data->{new_artist_credit}) {
        $data->{artist_credit} = {
            new => to_json_object(artist_credit_from_loaded_definition($loaded, $self->data->{new_artist_credit})),
            old => to_json_object(artist_credit_from_loaded_definition($loaded, $self->data->{old_artist_credit}))
        }
    }

    $data->{update_tracklists} = $self->data->{update_tracklists};
    $data->{release} = to_json_object(
        $loaded->{Release}{ $self->data->{entity}{id} }
        || Release->new( id => $self->data->{entity}{id}, name => $self->data->{entity}{name} )
    );

    return $data;
}

sub restore {
    my ($self, $data) = @_;

    $data->{entity} = delete $data->{release};

    $self->data($data);
}

1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2011 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
