package MusicBrainz::Server::Edit::Release::EditBarcodes;
use Moose;
use namespace::autoclean;

use MusicBrainz::Server::Constants qw( $EDIT_RELEASE_EDIT_BARCODES );
use MusicBrainz::Server::Edit::Types qw( Nullable );
use MusicBrainz::Server::Entity::Util::JSON qw( to_json_object );
use MusicBrainz::Server::Translation qw( N_l );
use MooseX::Types::Moose qw( ArrayRef Int Str );
use MooseX::Types::Structured qw( Dict );

extends 'MusicBrainz::Server::Edit';
with 'MusicBrainz::Server::Edit::Release';
with 'MusicBrainz::Server::Edit::Release::RelatedEntities';
with 'MusicBrainz::Server::Edit::Role::NeverAutoEdit';

use aliased 'MusicBrainz::Server::Entity::Barcode';
use aliased 'MusicBrainz::Server::Entity::Release';

sub edit_name { N_l('Edit barcodes') }
sub edit_kind { 'edit' }
sub edit_type { $EDIT_RELEASE_EDIT_BARCODES }
sub edit_template { 'EditBarcodes' }

has '+data' => (
    isa => Dict[
        submissions => ArrayRef[Dict[
            release => Dict[
                id => Int,
                name => Str
            ],
            barcode => Str,
            old_barcode => Nullable[Str]
        ]],
        client_version => Nullable[Str]
    ]
);

sub release_ids { map { $_->{release}{id} } @{ shift->data->{submissions} } }

sub alter_edit_pending
{
    my $self = shift;
    return {
        Release => [ $self->release_ids ],
    }
}

sub foreign_keys
{
    my ($self) = @_;
    return {
        Release => { map { $_ => [ 'ArtistCredit' ] } $self->release_ids },
    };
}

sub build_display_data
{
    my ($self, $loaded) = @_;
    return {
        client_version => $self->data->{client_version},
        submissions => [
            map +{
                release => to_json_object($loaded->{Release}{ $_->{release}{id} } ||
                    Release->new( name => $_->{release}{name} )),
                new_barcode => $_->{barcode},
                exists $_->{old_barcode} ? (old_barcode => $_->{old_barcode}) : ()
            }, @{ $self->data->{submissions} }
        ]
    }
}

sub accept {
    my ($self) = @_;
    for my $submission (@{ $self->data->{submissions} }) {
        $self->c->model('Release')->update(
            $submission->{release}{id},
            { barcode => $submission->{barcode} }
        )
    }
}

sub initialize {
    my ($self, %opts) = @_;
    $opts{submissions} = [
        map +{
            release => {
                id => $_->{release}->id,
                name => $_->{release}->name,
            },
            barcode => $_->{barcode},
            old_barcode => $_->{release}->barcode->code
        }, @{ $opts{submissions} }
    ];
    $self->data(\%opts);
}

1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2010 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
