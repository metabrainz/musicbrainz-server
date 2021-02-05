package MusicBrainz::Server::Edit::Release::EditCoverArt;
use Moose;
use namespace::autoclean;

use MooseX::Types::Moose qw( ArrayRef Str Int );
use MooseX::Types::Structured qw( Dict Optional );

use MusicBrainz::Server::Constants qw( $EDIT_RELEASE_EDIT_COVER_ART );
use MusicBrainz::Server::Edit::Exceptions;
use MusicBrainz::Server::Edit::Utils qw( changed_display_data );
use MusicBrainz::Server::Translation qw( N_l );
use MusicBrainz::Server::Validation qw( normalise_strings );

use aliased 'MusicBrainz::Server::Entity::Release';
use aliased 'MusicBrainz::Server::Entity::Artwork';

extends 'MusicBrainz::Server::Edit::WithDifferences';
with 'MusicBrainz::Server::Edit::Release';
with 'MusicBrainz::Server::Edit::Release::RelatedEntities';
with 'MusicBrainz::Server::Edit::Role::CoverArt';
with 'MusicBrainz::Server::Edit::Role::AlwaysAutoEdit';

sub edit_name { N_l('Edit cover art') }
sub edit_kind { 'edit' }
sub edit_type { $EDIT_RELEASE_EDIT_COVER_ART }
sub release_ids { shift->data->{entity}{id} }
sub cover_art_id { shift->data->{id} }
sub edit_template_react { 'EditCoverArt' }

sub change_fields
{
    Dict[
        types => Optional[ArrayRef[Int]],
        comment => Optional[Str],
    ];
}

has '+data' => (
    isa => Dict[
        entity => Dict[
            id   => Int,
            name => Str,
            mbid => Str
        ],
        id => Int,
        old => change_fields(),
        new => change_fields(),
    ]
);

sub initialize {
    my ($self, %opts) = @_;
    my $release = $opts{release} or die 'Release missing';

    my %old = (
        types => $opts{old_types},
        comment => $opts{old_comment},,
    );

    my %new = (
        types => $opts{new_types},
        comment => $opts{new_comment},
        );

    $self->data({
        entity => {
            id => $release->id,
            name => $release->name,
            mbid => $release->gid
        },
        id => $opts{artwork_id},
        $self->_change_data(\%old, %new)
    });
}

sub accept {
    my $self = shift;

    my $release = $self->c->model('Release')->get_by_gid($self->data->{entity}{mbid})
        or MusicBrainz::Server::Edit::Exceptions::FailedDependency->throw(
            'This release no longer exists'
        );

    $self->c->model('CoverArtArchive')->exists($self->data->{id})
        or MusicBrainz::Server::Edit::Exceptions::FailedDependency->throw(
            'This cover art no longer exists'
        );

    $self->c->model('CoverArtArchive')->update_cover_art(
        $release->id,
        $self->data->{id},
        $self->data->{new}->{types},
        $self->data->{new}->{comment}
    );
}

sub allow_auto_edit {
    my $self = shift;
    return 0 if $self->data->{old}{types}
        && @{ $self->data->{old}{types} };
    my ($old_comment, $new_comment) = normalise_strings(
        $self->data->{old}{comment}, $self->data->{new}{comment});
    return 0 if $old_comment ne $new_comment;
    return 1;
}

sub foreign_keys {
    my ($self) = @_;

    my %fk;

    $fk{Release} = {
        $self->data->{entity}{id} => [ 'ArtistCredit' ]
    };

    $fk{Artwork} = {
        $self->data->{id} => [ 'Release' ]
    };

    $fk{CoverArtType} = [
        @{ $self->data->{new}->{types} },
        @{ $self->data->{old}->{types} }
    ] if defined $self->data->{new}->{types};

    return \%fk;
}

sub build_display_data {
    my ($self, $loaded) = @_;

    my %data;

    $data{release} = $loaded->{Release}{ $self->data->{entity}{id} } ||
        Release->new( name => $self->data->{entity}{name} );

    $data{artwork} = $loaded->{Artwork}{ $self->data->{id} } ||
        Artwork->new(release => $data{release},
                     id => $self->data->{id},
                     comment => $self->data->{new}->{comment} // '',
                     cover_art_types => [ map {
                         $loaded->{CoverArtType}{$_}
                     } @{ $self->data->{new}->{types} // [] }]
        );


    if ($self->data->{old}->{types})
    {
        $data{types} = {
            old => [ map { $loaded->{CoverArtType}{$_} } @{ $self->data->{old}->{types} // [] } ],
            new => [ map { $loaded->{CoverArtType}{$_} } @{ $self->data->{new}->{types} // [] } ],
        }
    }

    if (exists $self->data->{old}->{comment})
    {
        $data{comment} = {
            old => $self->data->{old}->{comment},
            new => $self->data->{new}->{comment}
        }
    }

    return \%data;
}

1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2012 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
