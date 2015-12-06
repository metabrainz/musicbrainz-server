package MusicBrainz::Server::Edit::Alias;
use Moose::Role;

use MusicBrainz::Server::Data::Utils qw( partial_date_to_hash non_empty );
use MusicBrainz::Server::Constants qw( %ENTITIES );

use aliased 'MusicBrainz::Server::Entity::PartialDate';

sub enforce_dependencies {
    my ($self, $opts) = @_;

    unless (non_empty($opts->{locale})) {
        # Alias without locale can't be primary
        $opts->{primary_for_locale} = 0;
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

=head1 COPYRIGHT

Copyright (C) 2015 Ulrich Klauer

This program is free software; you can redistribute it and/or
modify it under the terms of the GNU General Public License as
published by the Free Software Foundation; either version 2 of
the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program; if not, write to the Free Software
Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston,
MA 02110-1301, USA.

=cut
