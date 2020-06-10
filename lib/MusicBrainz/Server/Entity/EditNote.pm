package MusicBrainz::Server::Entity::EditNote;

use 5.18.2;

use JSON::XS;
use Moose;
use namespace::autoclean;

use MusicBrainz::Server::Constants qw( $EDITOR_MODBOT );
use MusicBrainz::Server::Entity::Types;
use MusicBrainz::Server::Filters qw( format_editnote );
use MusicBrainz::Server::Translation qw( l );
use MusicBrainz::Server::Types qw( DateTime );

has 'editor_id' => (
    isa => 'Int',
    is => 'rw',
);

has 'editor' => (
    isa => 'Editor',
    is => 'rw'
);

has 'edit_id' => (
    isa => 'Int',
    is => 'rw',
);

has 'edit' => (
    isa => 'Edit',
    is => 'rw',
    weak_ref => 1
);

has 'text' => (
    isa => 'Str',
    is => 'rw',
);

has 'post_time' => (
    isa => DateTime,
    is => 'rw',
    coerce => 1
);

sub _localize_text {
    my ($text, $depth) = @_;

    state $json = JSON::XS->new->utf8(0);

    if (my ($source) = ($text =~ m/^localize:(.+)$/)) {
        $source = $json->decode($source);

        my $source_args = $source->{args} // {};
        my %args = map {
            my $value = $source_args->{$_};
            $_ => (ref($value) ? $value : _localize_text($value // '', $depth + 1))
        } keys %{$source_args};

        $text = l($source->{message} // '', \%args);
    } elsif ($depth == 0) {
        # Otherwise, assume this message uses edit note syntax.
        $text = format_editnote($text);
    }

    return $text;
}

sub localize {
    my ($self) = @_;

    my $text = $self->text;

    if ($self->editor_id == $EDITOR_MODBOT) {
        return _localize_text($text, 0);
    }

    return $text;
}

no Moose;
__PACKAGE__->meta->make_immutable;
1;

=head1 COPYRIGHT

Copyright (C) 2009 Oliver Charles

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
