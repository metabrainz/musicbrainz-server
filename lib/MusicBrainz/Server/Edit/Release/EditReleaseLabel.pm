package MusicBrainz::Server::Edit::Release::EditReleaseLabel;
use Moose;

use Moose::Util::TypeConstraints qw( find_type_constraint subtype as );
use MooseX::Types::Moose qw( Int Str );
use MooseX::Types::Structured qw( Dict );
use MusicBrainz::Server::Constants qw( $EDIT_RELEASE_EDITRELEASELABEL );
use MusicBrainz::Server::Edit::Types qw( Nullable );

extends 'MusicBrainz::Server::Edit::WithDifferences';

sub edit_name { 'Edit release label' }
sub edit_type { $EDIT_RELEASE_EDITRELEASELABEL }

sub alter_edit_pending { { Release => [ shift->release_id ] } }
sub related_entities { { release => [ shift->release_id ] } }

subtype 'ReleaseLabelHash'
    => as Dict[
        label_id => Nullable[Int],
        catalog_number => Nullable[Str]
    ];

has '+data' => (
    isa => Dict[
        release_label_id => Int,
        release_id => Int,
        new => find_type_constraint('ReleaseLabelHash'),
        old => find_type_constraint('ReleaseLabelHash')
    ]
);

sub release_id { shift->data->{release_id} }
sub release_label_id { shift->data->{release_label_id} }

sub foreign_keys
{
    my $self = shift;

    my $keys = { Release => { $self->release_id => [] } };

    $keys->{Label}->{ $self->data->{old}{label_id} } = [];
    $keys->{Label}->{ $self->data->{new}{label_id} } = [];

    return $keys;
};

sub build_display_data
{
    my ($self, $loaded) = @_;

    return {
        release => $loaded->{Release}->{ $self->release_id },
        label => {
            new => $loaded->{Label}->{ $self->data->{new}{label_id} },
            old => $loaded->{Label}->{ $self->data->{old}{label_id} },
        },
        catalog_number => {
            new => $self->data->{new}{catalog_number},
            old => $self->data->{old}{catalog_number},
        },
    };
}



sub initialize
{
    my ($self, %opts) = @_;
    my $release_label = delete $opts{release_label};
    die "You must specify the release label object to edit"
        unless defined $release_label;

    $self->data({
        release_label_id => $release_label->id,
        release_id => $release_label->release_id,
        $self->_change_data($release_label, %opts),
    });
};

sub accept
{
    my $self = shift;
    $self->c->model('ReleaseLabel')->update($self->release_label_id, $self->data->{new});
}

__PACKAGE__->meta->make_immutable;
no Moose;
1;

=head1 COPYRIGHT

Copyright (C) 2010 MetaBrainz Foundation

This program is free software; you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation; either version 2 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program; if not, write to the Free Software
Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.

=cut
