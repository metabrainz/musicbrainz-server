package MusicBrainz::Server::Data::Role::Validate;
use Moose::Role;
use MusicBrainz::Server::Data::Utils qw( partial_date_from_string partial_date_to_hash );

requires 'validator';

sub validate
{
    my ($self, $document) = @_;

    return $self->validator->process ($document);
}

sub edit_mapping
{
    my ($self, $document) = @_;

    delete $document->{id};

    if ($document->{'life-span'}) {
        my $lifespan = delete $document->{'life-span'};

        $document->{begin_date} = partial_date_to_hash (
            partial_date_from_string ($lifespan->{begin})) if $lifespan->{begin};
        $document->{end_date}  = partial_date_to_hash (
            partial_date_from_string ($lifespan->{end})) if $lifespan->{end};
    }

    $document->{sort_name} = delete $document->{'sort-name'};

    return %$document;
}

1;

=head1 COPYRIGHT

Copyright (C) 2011,2012 MetaBrainz Foundation

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
