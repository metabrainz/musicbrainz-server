package MusicBrainz::Server::Edit::Work::AddISWCs;
use Moose;
use MooseX::Types::Structured qw( Dict );
use MooseX::Types::Moose qw( ArrayRef Str Int );
use MusicBrainz::Server::Constants qw(
    $EDIT_WORK_ADD_ISWCS
    $EDIT_WORK_CREATE
);
use MusicBrainz::Server::Translation qw( N_l );
use MusicBrainz::Server::Edit::Exceptions;
use MusicBrainz::Server::Entity::Util::JSON qw( to_json_object );

extends 'MusicBrainz::Server::Edit';
with 'MusicBrainz::Server::Edit::Work::RelatedEntities' => {
    -excludes => 'work_ids'
};
with 'MusicBrainz::Server::Edit::Work';
with 'MusicBrainz::Server::Edit::Role::AlwaysAutoEdit';

use aliased 'MusicBrainz::Server::Entity::Work';
use aliased 'MusicBrainz::Server::Entity::ISWC';

sub edit_type { $EDIT_WORK_ADD_ISWCS }
sub edit_name { N_l('Add ISWCs') }
sub edit_kind { 'add' }
sub edit_template_react { 'AddIswcs' }

sub work_ids { map { $_->{work}{id} } @{ shift->data->{iswcs} } }

has '+data' => (
    isa => Dict[
        iswcs => ArrayRef[Dict[
            iswc      => Str,
            work => Dict[
                id => Int,
                name => Str
            ]
        ]]
    ]
);

sub initialize
{
    my ($self, %opts) = @_;
    my @iswcs = $self->c->model('ISWC')->filter_additions(@{ $opts{iswcs} });

    if (@iswcs == 0) {
        MusicBrainz::Server::Edit::Exceptions::NoChanges->throw;
    }
    else {
        $self->data({
            iswcs => \@iswcs
        });
    }
}

sub _build_related_entities
{
    my $self = shift;
    return {
        work => [ $self->work_ids ]
    }
}

sub foreign_keys
{
    my $self = shift;
    return {
        Work => [ $self->work_ids ],
    }
}

sub build_display_data
{
    my ($self, $loaded) = @_;
    return {
        additions => [
            map { +{
                work => to_json_object(
                    $loaded->{Work}{ $_->{work}{id} } ||
                    Work->new( id => $_->{work}{id}, name => $_->{work}{name} )
                ),
                iswc => to_json_object(ISWC->new( iswc => $_->{iswc} )),
            } } @{ $self->data->{iswcs} }
        ]
    }
}

sub accept {
    my $self = shift;

    my @iswcs = $self->c->model('ISWC')->filter_additions(@{ $self->data->{iswcs} });

    if (@iswcs == 0) {
        MusicBrainz::Server::Edit::Exceptions::NoLongerApplicable->throw(
            'This edit no longer changes anything, either because all the ' .
            'works are deleted, or all the ISWCs are already present.'
        );
    } else {
        $self->c->model('ISWC')->insert(
            map +{
                work_id => $_->{work}{id},
                iswc => $_->{iswc}
            }, @iswcs
        );
    }
}

no Moose;
__PACKAGE__->meta->make_immutable;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2012 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
