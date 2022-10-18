package MusicBrainz::Server::Edit::Release::ChangeQuality;
use Moose;
use namespace::autoclean;
use Method::Signatures::Simple;
use MooseX::Types::Moose qw( Int Str );
use MooseX::Types::Structured qw( Dict );
use MusicBrainz::Server::Constants qw(
    $EDIT_RELEASE_CHANGE_QUALITY
    $EDIT_RELEASE_CREATE
    $QUALITY_HIGH
);
use MusicBrainz::Server::Edit::Exceptions;
use MusicBrainz::Server::Entity::Util::JSON qw( to_json_object );
use MusicBrainz::Server::Translation qw( N_l );

extends 'MusicBrainz::Server::Edit';
with 'MusicBrainz::Server::Edit::Release::RelatedEntities';
with 'MusicBrainz::Server::Edit::Release';
with 'MusicBrainz::Server::Edit::Role::AllowAmending' => {
    create_edit_type => $EDIT_RELEASE_CREATE,
    entity_type => 'release',
};

use aliased 'MusicBrainz::Server::Entity::Release';

sub edit_name { N_l('Change release data quality') }
sub edit_kind { 'other' }
sub edit_type { $EDIT_RELEASE_CHANGE_QUALITY }
sub release_id { shift->data->{release}{id} }
sub edit_template { 'ChangeReleaseQuality' }

method alter_edit_pending
{
    return {
        Release => [ $self->release_id ],
    }
}

sub change_fields
{
    return Dict[
        quality => Int,
    ]
}

has '+data' => (
    isa => Dict[
        release => Dict[
            id => Int,
            name => Str
        ],
        old     => change_fields(),
        new     => change_fields()
    ]
);

method foreign_keys
{
    return {
        Release => { $self->release_id => ['ArtistCredit'] },
    }
}

method build_display_data ($loaded)
{
    return {
        release => to_json_object(
            $loaded->{Release}{ $self->release_id } ||
            Release->new(
                id => $self->release_id,
                name => $self->data->{release}{name},
            ),
        ),
        quality => {
            old => $self->data->{old}{quality} + 0,
            new => $self->data->{new}{quality} + 0,
        }
    }
}

method initialize (%opts)
{
    my $release = $opts{to_edit} or die 'Need a release to change quality';

    MusicBrainz::Server::Edit::Exceptions::NoChanges->throw
          if $release->quality == $opts{quality};

    $self->data({
        release => {
            id => $release->id,
            name => $release->name
        },
        old => { quality => $release->quality },
        new => { quality => $opts{quality} + 0 },
    });
}


method accept
{
    $self->c->model('Release')->update(
        $self->release_id,
        { quality => $self->data->{new}{quality} }
    );
}

sub allow_auto_edit
{
    my $self = shift;
    return $self->data->{new}{quality} != $QUALITY_HIGH && $self->can_amend($self->release_id);
}

__PACKAGE__->meta->make_immutable;
