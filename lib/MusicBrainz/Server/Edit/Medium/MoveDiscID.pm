package MusicBrainz::Server::Edit::Medium::MoveDiscID;
use Moose;
use namespace::autoclean;

use MusicBrainz::Server::Constants qw( $EDIT_MEDIUM_MOVE_DISCID );
use MusicBrainz::Server::Edit::Exceptions;
use MusicBrainz::Server::Entity::Util::JSON qw( to_json_object );
use MusicBrainz::Server::Translation qw( N_l );
use MooseX::Types::Moose qw( Int Str );
use MooseX::Types::Structured qw( Dict );

extends 'MusicBrainz::Server::Edit';
with 'MusicBrainz::Server::Edit::Medium';
with 'MusicBrainz::Server::Edit::Role::AlwaysAutoEdit';

use aliased 'MusicBrainz::Server::Entity::CDTOC';
use aliased 'MusicBrainz::Server::Entity::MediumCDTOC';
use aliased 'MusicBrainz::Server::Entity::Release';
use aliased 'MusicBrainz::Server::Entity::Medium';

sub edit_name { N_l('Move disc ID') }
sub edit_kind { 'other' }
sub edit_type { $EDIT_MEDIUM_MOVE_DISCID }
sub edit_template { 'MoveDiscId' }

has '+data' => (
    isa => Dict[
        medium_cdtoc => Dict[
            id => Int,
            toc => Str
        ],
        old_medium => Dict[
            id => Int,
            release => Dict[
                name => Str,
                id => Int
            ]
        ],
        new_medium => Dict[
            id => Int,
            release => Dict[
                name => Str,
                id => Int
            ]
        ],
    ]
);

sub release_ids
{
    my $self = shift;
    return (
        $self->data->{old_medium}{release}{id},
        $self->data->{new_medium}{release}{id}
    );
}

sub alter_edit_pending
{
    my ($self) = @_;
    return {
        Release => [ $self->release_ids ],
        MediumCDTOC => [ $self->data->{medium_cdtoc}{id} ]
    };
}

sub _build_related_entities
{
    my $self = shift;
    my @releases = values %{
        $self->c->model('Release')->get_by_ids($self->release_ids)
    };
    $self->c->model('ReleaseGroup')->load(@releases);
    my @release_groups = map { $_->release_group } @releases;

    $self->c->model('ArtistCredit')->load(@releases, @release_groups);
    return {
        artist => [
            map { $_->artist_id } map { $_->artist_credit->all_names }
                @releases, @release_groups
        ],
        release_group => [ map { $_->id } @release_groups ],
        release => [ $self->release_ids ]
    }
}

sub foreign_keys
{
    my $self = shift;
    return {
        Release => { map { $_ => [ 'ArtistCredit' ] } $self->release_ids },
        MediumCDTOC => { $self->data->{medium_cdtoc}{id} => [ 'CDTOC' ] },
        Medium => { map { $self->data->{$_}{id} => [ 'MediumFormat', 'Release ArtistCredit' ] }
                    qw( new_medium old_medium ) },
    }
}

sub build_display_data
{
    my ($self, $loaded) = @_;
    return {
        medium_cdtoc => to_json_object(
            $loaded->{MediumCDTOC}{ $self->data->{medium_cdtoc}{id} } ||
            MediumCDTOC->new(
                cdtoc => CDTOC->new_from_toc($self->data->{medium_cdtoc}{toc})
            )
        ),
        map {
            $_ => to_json_object(
                $loaded->{Medium}{ $self->data->{$_}{id} } //
                Medium->new(
                    release_id => $self->data->{$_}{release}{id},
                    release => $loaded->{Release}{ $self->data->{$_}{release}{id} } //
                        Release->new(
                            id => $self->data->{$_}{release}{id},
                            name => $self->data->{$_}{release}{name},
                        ),
                )
            )
        } qw( new_medium old_medium ),
    }
}

sub initialize
{
    my ($self, %opts) = @_;
    my $new = $opts{new_medium} or die 'No new medium';
    my $medium_cdtoc = $opts{medium_cdtoc} or die 'No medium_cdtoc';

    unless ($medium_cdtoc->cdtoc) {
        $self->c->model('CDTOC')->load($medium_cdtoc);
    }

    MusicBrainz::Server::Edit::Exceptions::NoChanges->throw
        if $medium_cdtoc->medium->id == $new->id;

    $self->data({
        medium_cdtoc => {
            id => $medium_cdtoc->id,
            toc => $medium_cdtoc->cdtoc->toc
        },
        old_medium => {
            id => $medium_cdtoc->medium->id,
            release => {
                id => $medium_cdtoc->medium->release->id,
                name => $medium_cdtoc->medium->release->name,
            }
        },
        new_medium => {
            id => $new->id,
            release => {
                id => $new->release->id,
                name => $new->release->name
            }
        }
    });
}

sub accept
{
    my $self = shift;
    my $medium = $self->c->model('Medium')->get_by_id($self->data->{new_medium}{id})
        or MusicBrainz::Server::Edit::Exceptions::FailedDependency->throw(
            'The target medium no longer exists'
        );

    my $medium_cdtoc = $self->c->model('MediumCDTOC')->get_by_id($self->data->{medium_cdtoc}{id});
    $self->c->model('CDTOC')->load($medium_cdtoc);

    if (!$medium_cdtoc || !$medium_cdtoc->cdtoc) {
        MusicBrainz::Server::Edit::Exceptions::FailedDependency->throw(
            'This disc ID no longer exists'
        )
    }

    if ($self->data->{old_medium}{id} != $self->data->{new_medium}{id} &&
        $self->c->model('MediumCDTOC')->medium_has_cdtoc(
            $medium->id,
            $medium_cdtoc->cdtoc
    )) {
        $self->c->model('MediumCDTOC')->delete(
            $self->data->{medium_cdtoc}{id}
        );
    }
    else {
        $self->c->model('MediumCDTOC')->update(
            $self->data->{medium_cdtoc}{id},
            { medium_id => $medium->id  }
        )
    }
}

__PACKAGE__->meta->make_immutable;
1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2010 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
