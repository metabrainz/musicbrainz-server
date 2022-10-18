package MusicBrainz::Server::Edit::Alias;
use Moose::Role;
use namespace::autoclean;

use MusicBrainz::Server::Data::Utils qw( partial_date_to_hash non_empty );
use MusicBrainz::Server::Constants qw( %ENTITIES );

use aliased 'MusicBrainz::Server::Entity::PartialDate';

sub enforce_dependencies {
    my ($self, $opts) = @_;

    unless (non_empty($opts->{locale})) {
        # Alias without locale can't be primary
        $opts->{primary_for_locale} = 0;
    }

    unless (non_empty($opts->{sort_name})) {
        # Sortname defaults to the name
        $opts->{sort_name} = $opts->{name};
    }

    my $search_hint_type = $ENTITIES{$self->_alias_model->type}->{aliases}{search_hint_type};
    my $type = $opts->{type_id};
    if (defined $type && $type == $search_hint_type) {
        # Search hints can't have any other data
        $opts->{sort_name} = $opts->{name};
        $opts->{locale} = undef;
        @$opts{qw( begin_date end_date )} = (partial_date_to_hash(PartialDate->new)) x 2;
        @$opts{qw( ended primary_for_locale )} = (0) x 2;
    }
}

1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2015 Ulrich Klauer

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
