package MusicBrainz::Server::Form::Field::ArtistCredit;
use HTML::FormHandler::Moose;
use Scalar::Util qw( looks_like_number );
use Text::Trim qw( );
extends 'HTML::FormHandler::Field::Compound';

use MusicBrainz::Server::Entity::ArtistCredit;
use MusicBrainz::Server::Entity::ArtistCreditName;
use MusicBrainz::Server::Translation qw( l ln );

has 'allow_unlinked' => ( isa => 'Bool', is => 'rw', default => '0' );

has_field 'names'             => ( type => 'Repeatable', num_when_empty => 1 );
has_field 'names.name'        => ( type => 'Text', required => 1);
has_field 'names.artist'      => ( type => '+MusicBrainz::Server::Form::Field::Artist' );
has_field 'names.join_phrase' => ( type => 'Text', trim => { transform => sub { shift } });

around 'validate_field' => sub {
    my $orig = shift;
    my $self = shift;

    my $ret = $self->$orig (@_);

    my $input = $self->result->input;

    my $artists = 0;
    for (@{ $input->{'names'} })
    {
        next unless $_;

        my $artist_id = Text::Trim::trim $_->{'artist'}->{'id'};
        my $name = Text::Trim::trim $_->{'name'};

        if ($artist_id && $name)
        {
            $artists++;
        }

        if (! $artist_id && $name)
        {
            if ($self->allow_unlinked)
            {
                $artists++;
            }
            else
            {
                # FIXME: better error message.
                $self->add_error (
                    l('Artist "{artist}" is unlinked, please select an existing artist',
                      { artist => $_->{'name'} }));
            }
        }
    }

    # Do not nag about the field being required if there are other
    # errors which already invalidate the field.
    return 0 if $self->has_errors;

    if ($self->required && ! $artists)
    {
        $self->add_error ("Artist credit field is required");
    }

    return !$self->has_errors;
};

# sub validate
# {
#     my $self = shift;

#     my @credits;
#     my @fields = $self->field('names')->fields;
#     while (@fields) {
#         my $field = shift @fields;

#         my $name = $field->field('name')->value;
#         my $id = $field->field('artist_id')->value;
#         my $join = $field->field('join_phrase')->value || undef;

#         push @credits, { artist => $id, name => $name };
#         push @credits, $join if $join || @fields;
#     }


#     $self->value(\@credits);
# }

# around 'fif' => sub {
#     my $orig = shift;
#     my $self = shift;

#     my $fif = $self->$orig (@_);

#     return MusicBrainz::Server::Entity::ArtistCredit->new unless $fif;

#     # FIXME: shouldn't happen.
#     return MusicBrainz::Server::Entity::ArtistCredit->new unless $fif->{'names'};

#     my @names;
#     for ( @{ $fif->{'names'} } )
#     {
#         next unless $_->{'name'};

#         my $acn = MusicBrainz::Server::Entity::ArtistCreditName->new(
#             name => $_->{'name'},
#             );
#         $acn->artist_id($_->{'artist_id'}) if looks_like_number ($_->{'artist_id'});
#         $acn->join_phrase($_->{'join_phrase'}) if $_->{'join_phrase'};
#         push @names, $acn;
#     }

#     my $ret = MusicBrainz::Server::Entity::ArtistCredit->new( names => \@names );
#     $self->form->ctx->model('Artist')->load(@{ $ret->names });

#     return $ret;
# };

=head1 LICENSE

Copyright (C) 2011 MetaBrainz Foundation

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
Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.

=cut

1;
