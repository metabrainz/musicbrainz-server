package MusicBrainz::Server::Edit::Label::Merge;
use Moose;

use MusicBrainz::Server::Constants qw( $EDIT_LABEL_MERGE );
use MusicBrainz::Server::Translation qw ( N_l );

extends 'MusicBrainz::Server::Edit::Generic::Merge';
with 'MusicBrainz::Server::Edit::Role::MergeSubscription';
with 'MusicBrainz::Server::Edit::Label';

sub edit_type { $EDIT_LABEL_MERGE }
sub edit_name { N_l('Merge labels') }

sub _merge_model { 'Label' }
sub subscription_model { shift->c->model('Label')->subscription }

sub label_ids { @{ shift->_entity_ids } }

sub foreign_keys
{
    my $self = shift;
    return {
        Label => {
            map {
                $_ => [ 'LabelType' ]
            } (
                $self->data->{new_entity}{id},
                map { $_->{id} } @{ $self->data->{old_entities} },
            )
        }
    }
}

before build_display_data => sub {
    my ($self, $loaded) = @_;

    my @labels = grep defined, map { $loaded->{Label}{$_} } $self->label_ids;
    $self->c->model('LabelType')->load(@labels);
    $self->c->model('Area')->load(@labels);
};

__PACKAGE__->meta->make_immutable;
no Moose;

1;
