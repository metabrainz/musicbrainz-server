package MusicBrainz::Server::Entity::Area;

use Moose;
use MusicBrainz::Server::Translation::Countries qw( l );
use MusicBrainz::Server::Entity::PartialDate;
use MusicBrainz::Server::Entity::Types;
use MusicBrainz::Server::Entity::Util::JSON qw( to_json_array );
use List::AllUtils qw( first );

extends 'MusicBrainz::Server::Entity::CoreEntity';
with 'MusicBrainz::Server::Entity::Role::Taggable';
with 'MusicBrainz::Server::Entity::Role::Annotation';
with 'MusicBrainz::Server::Entity::Role::LastUpdate';
with 'MusicBrainz::Server::Entity::Role::DatePeriod';
with 'MusicBrainz::Server::Entity::Role::Comment';
with 'MusicBrainz::Server::Entity::Role::Type' => { model => 'AreaType' };

sub entity_type { 'area' }

sub l_name {
    my $self = shift;
    # Areas with iso_3166_1 codes are the ones we export for translation
    # in the countries domain. See po/extract_pot_db.
    if (scalar $self->iso_3166_1_codes > 0) {
        return l($self->name);
    } else {
        return $self->name;
    }
}

has 'containment' => (
    is => 'rw',
    isa => 'Maybe[ArrayRef[Area]]',
);

has 'iso_3166_1' => (
    traits => [ 'Array' ],
    is => 'ro',
    isa => 'ArrayRef[Str]',
    default => sub { [] },
    handles => {
        add_iso_3166_1 => 'push',
        iso_3166_1_codes => 'elements',
    }
);

has 'iso_3166_2' => (
    traits => [ 'Array' ],
    is => 'ro',
    isa => 'ArrayRef[Str]',
    default => sub { [] },
    handles => {
        add_iso_3166_2 => 'push',
        iso_3166_2_codes => 'elements',
    }
);

has 'iso_3166_3' => (
    traits => [ 'Array' ],
    is => 'ro',
    isa => 'ArrayRef[Str]',
    default => sub { [] },
    handles => {
        add_iso_3166_3 => 'push',
        iso_3166_3_codes => 'elements',
    }
);

sub primary_code
{
    my ($self) = @_;
    if (scalar $self->iso_3166_1_codes == 1) {
        return first { defined($_) } $self->iso_3166_1_codes;
    }
    elsif (scalar $self->iso_3166_2_codes == 1) {
        return first { defined($_) } $self->iso_3166_2_codes;
    }
    elsif (scalar $self->iso_3166_3_codes == 1) {
        return first { defined($_) } $self->iso_3166_3_codes;
    }
    else {
        return undef;
    }
}

=head2 country_code

This function returns a country (ISO-3166-1) code only. For now, it will only return intrinsic ones;
in the future it may make sense to use the first two characters of an iso-3166-2 code as well.

=cut

sub country_code
{
    my ($self) = @_;
    if (scalar $self->iso_3166_1_codes) {
        return first { defined($_) } $self->iso_3166_1_codes;
    }
}

around TO_JSON => sub {
    my ($orig, $self) = @_;

    my $json = {
        %{ $self->$orig },
        country_code => $self->country_code,
        iso_3166_1_codes => [$self->iso_3166_1_codes],
        iso_3166_2_codes => [$self->iso_3166_2_codes],
        iso_3166_3_codes => [$self->iso_3166_3_codes],
        primary_code     => $self->primary_code,
    };

    my $containment = $self->containment;
    if (defined $containment) {
        $json->{containment} = to_json_array($containment);
    }

    return $json;
};

__PACKAGE__->meta->make_immutable;
no Moose;
1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2013 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
