package MusicBrainz::Server::Edit::Work;
use List::UtilsBy qw( partition_by );
use Moose::Role;
use namespace::autoclean;

use MusicBrainz::Server::Translation 'l';

sub edit_category { l('Work') }

sub grouped_attributes_by_type {
    my ($self, @attributes) = @_;

    return partition_by { $_->type->l_name }
        @{ $self->c->model('Work')->inflate_attributes(@attributes) };
}

1;
