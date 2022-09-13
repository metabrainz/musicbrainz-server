package MusicBrainz::Server::Edit::Label::Merge;
use Moose;

use MusicBrainz::Server::Constants qw( $EDIT_LABEL_MERGE );
use MusicBrainz::Server::Translation qw( N_l );

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
                $_ => [ 'LabelType', 'Area' ]
            } (
                $self->data->{new_entity}{id},
                map { $_->{id} } @{ $self->data->{old_entities} },
            )
        }
    }
}

sub edit_template { 'MergeLabels' };

__PACKAGE__->meta->make_immutable;
no Moose;

1;
