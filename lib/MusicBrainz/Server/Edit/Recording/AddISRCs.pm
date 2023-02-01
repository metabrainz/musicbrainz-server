package MusicBrainz::Server::Edit::Recording::AddISRCs;
use Moose;
use MooseX::Types::Structured qw( Dict );
use MooseX::Types::Moose qw( ArrayRef Str Int );
use List::AllUtils qw( any uniq );
use MusicBrainz::Server::Constants qw( $EDIT_RECORDING_ADD_ISRCS );
use MusicBrainz::Server::Edit::Types qw( Nullable );
use MusicBrainz::Server::Entity::Util::JSON qw( to_json_object );
use MusicBrainz::Server::Translation qw( N_l );
use MusicBrainz::Server::Edit::Exceptions;

extends 'MusicBrainz::Server::Edit';
with 'MusicBrainz::Server::Edit::Recording::RelatedEntities' => {
    -excludes => 'recording_ids'
};
with 'MusicBrainz::Server::Edit::Recording';
with 'MusicBrainz::Server::Edit::Role::AlwaysAutoEdit';

use aliased 'MusicBrainz::Server::Entity::Recording';
use aliased 'MusicBrainz::Server::Entity::ISRC';

sub edit_type { $EDIT_RECORDING_ADD_ISRCS }
sub edit_name { N_l('Add ISRCs') }
sub edit_kind { 'add' }
sub edit_template { 'AddIsrcs' }

sub recording_ids { map { $_->{recording}{id} } @{ shift->data->{isrcs} } }

has '+data' => (
    isa => Dict[
        isrcs => ArrayRef[Dict[
            isrc      => Str,
            recording => Dict[
                id => Int,
                name => Str
            ],
            source    => Nullable[Int],
        ]],
        client_version => Nullable[Str]
    ]
);

sub initialize
{
    my ($self, %opts) = @_;
    my @isrcs = $self->c->model('ISRC')->filter_additions(@{ $opts{isrcs} });

    if (@isrcs == 0) {
        MusicBrainz::Server::Edit::Exceptions::NoChanges->throw;
    }
    else {
        $self->data({
            isrcs => \@isrcs,
            client_version => $opts{client_version}
        });
    }
}

sub _build_related_entities
{
    my $self = shift;
    return {
        recording => [ uniq map {
            $_->{recording}{id}
        } @{ $self->data->{isrcs} } ]
    }
}

sub foreign_keys
{
    my $self = shift;
    return {
        Recording => { map {
            $_->{recording}{id} => ['ArtistCredit']
        } @{ $self->data->{isrcs} } }
    }
}

sub build_display_data
{
    my ($self, $loaded) = @_;
    return {
        additions => [
            map { +{
                recording => to_json_object(
                    $loaded->{Recording}{ $_->{recording}{id} } ||
                    Recording->new( id => $_->{recording}{id}, name => $_->{recording}{name} )
                ),
                isrc      => to_json_object(ISRC->new( isrc => $_->{isrc} )),
                source    => $_->{source}
            } } @{ $self->data->{isrcs} }
        ],
        client_version => $self->data->{client_version},

    }
}

sub accept
{
    my $self = shift;
    my $recordings = $self->c->model('Recording')->get_by_ids(map { $_->{recording}{id} } @{ $self->data->{isrcs} });
    $self->c->model('ISRC')->load_for_recordings(values %{ $recordings });

    my @new_isrcs = grep {
           my $data = $_;
           $recordings->{$data->{recording_id}} && !any { $_->isrc eq $data->{isrc} } $recordings->{$data->{recording_id}}->all_isrcs
        } map +{
            recording_id => $_->{recording}{id},
            isrc => $_->{isrc},
            source => $_->{source}
        }, @{ $self->data->{isrcs} };

    $self->c->model('ISRC')->insert(@new_isrcs) if @new_isrcs;
}

no Moose;
__PACKAGE__->meta->make_immutable;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2010 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
