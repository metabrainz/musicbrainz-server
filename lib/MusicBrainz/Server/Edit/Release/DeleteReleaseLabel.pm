package MusicBrainz::Server::Edit::Release::DeleteReleaseLabel;
use Moose;

use MooseX::Types::Moose qw( Int Str );
use MooseX::Types::Structured qw( Dict );
use MusicBrainz::Server::Constants qw( $EDIT_RELEASE_DELETERELEASELABEL );
use MusicBrainz::Server::Translation qw( l ln );
use MusicBrainz::Server::Edit::Types qw( Nullable );

extends 'MusicBrainz::Server::Edit';
with 'MusicBrainz::Server::Edit::Role::Preview';
with 'MusicBrainz::Server::Edit::Release';

sub edit_name { l('Remove release label') }
sub edit_type { $EDIT_RELEASE_DELETERELEASELABEL }

sub alter_edit_pending { { Release => [ shift->release_id ] } }
sub models { [qw( Release ReleaseLabel )] }

has '+data' => (
    isa => Dict[
        release_label_id => Int,
        release_id => Int,
        label_id => Nullable[Int],
        catalog_number => Nullable[Str]
    ]
);

has 'release_id' => (
    isa => Int,
    is => 'rw',
    lazy => 1,
    default => sub { shift->data->{release_id} }
);

with 'MusicBrainz::Server::Edit::Release::RelatedEntities';

around 'related_entities' => sub {
    my $orig = shift;
    my $self = shift;
    my $related = $self->$orig;

    $related->{label} = [ $self->data->{label_id} ],

    return $related;
};

has 'release' => (
    isa => 'Release',
    is => 'rw',
);

has 'release_label_id' => (
    isa => 'Int',
    is => 'rw',
    lazy => 1,
    default => sub { shift->data->{release_label_id} }
);

has 'release_label' => (
    isa => 'ReleaseLabel',
    is => 'rw',
);

sub foreign_keys
{
    my $self = shift;

    return {
        Release => { $self->release_id => [] },
        Label => [ $self->data->{label_id} ]
    };
};

sub build_display_data
{
    my ($self, $loaded) = @_;
    my $label = $loaded->{Label}->{ $self->data->{label_id} };

    return {
        release => $loaded->{Release}->{ $self->data->{release_id} },
        catalog_number => $self->data->{catalog_number},
        label => ($label || $self->data->{catalog_number})
    };
}

sub initialize
{
    my ($self, %opts) = @_;
    my $release_label = delete $opts{release_label};
    die "You must specify the release label object to delete"
        unless defined $release_label;

    $self->data({
        release_label_id => $release_label->id,
        catalog_number => $release_label->catalog_number,
        label_id => $release_label->label_id,
        release_id => $release_label->release_id,
    });
};

sub accept
{
    my $self = shift;
    $self->c->model('ReleaseLabel')->delete($self->release_label_id);
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
