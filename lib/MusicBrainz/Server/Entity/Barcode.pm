package MusicBrainz::Server::Entity::Barcode;
use Moose;
use MusicBrainz::Server::Translation qw( l );

has 'code' => (
    is => 'rw',
    isa => 'Maybe[Str]',
);

use overload '""' => sub { shift->code }, fallback => 1;

sub type {
    my ($self) = @_;
    return 'EAN' if length($self->code) == 8;
    return 'UPC' if length($self->code) == 12;
    return 'EAN' if length($self->code) == 13;
}

sub format
{
    my $self = shift;

    return '' unless defined $self->code;

    return $self->code eq '' ? l('[none]') : $self->code;
}

around BUILDARGS => sub {
    my $orig = shift;
    my $class = shift;

    if ( @_ == 1 && ! ref $_[0] ) {
        return $class->$orig(code => $_[0]);
    }
    else {
        return $class->$orig(@_);
    }
};

sub new_from_row {
    my ($class, $row, $prefix) = @_;
    return $class->new($row->{$prefix."barcode"});
}

__PACKAGE__->meta->make_immutable;
no Moose;
1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2011 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
