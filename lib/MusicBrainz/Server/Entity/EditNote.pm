package MusicBrainz::Server::Entity::EditNote;

use 5.18.2;

use JSON::XS;
use Moose;
use namespace::autoclean;

use MusicBrainz::Server::Constants qw( $EDITOR_MODBOT );
use MusicBrainz::Server::Data::Utils qw( datetime_to_iso8601 );
use MusicBrainz::Server::Entity::Types;
use MusicBrainz::Server::Filters qw( format_editnote );
use MusicBrainz::Server::Types qw( DateTime );

extends 'MusicBrainz::Server::Entity';

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

my %domain_classes = (
    'attributes' => 'Attributes',
    'countries' => 'Countries',
    'instrument_descriptions' => 'InstrumentDescriptions',
    'instruments' => 'Instruments',
    'languages' => 'Languages',
    'relationships' => 'Relationships',
    'scripts' => 'Scripts',
    'statistics' => 'Statistics',
);

sub _localize_text {
    my ($text, $depth) = @_;

    state $json = JSON::XS->new->utf8(0);

    if (my ($source) = ($text =~ m/^localize:(.+)$/)) {
        $source = $json->decode($source);

        my $version = $source->{version} // 0;
        my $fn_package = 'MusicBrainz::Server::Translation';
        my $fn_name = 'l';
        my @args = ($source->{message} // '');
        my $source_vars;

        if ($version == 0) {
            # old versions of `localized_note` passed substitution
            # variables as `args`.
            $source_vars = $source->{args};
        } elsif ($version == 1) {
            push @args, @{ $source->{args} // [] };

            $fn_name = $source->{function} // 'l';
            $source_vars = $source->{vars};

            my $domain = $source->{domain};
            if (defined $domain && $domain ne 'mb_server') {
                $fn_package .= ('::' . $domain_classes{$domain});
            }
        }

        if (defined $source_vars) {
            my %vars = map {
                my $value = $source_vars->{$_};
                $_ => (ref($value) ? $value : _localize_text($value // '', $depth + 1))
            } keys %{$source_vars};
            push @args, \%vars;
        }

        my $fn_package_path = ($fn_package =~ s/::/\//gr) . '.pm';
        require $fn_package_path;

        my $function = \&{ "${fn_package}::${fn_name}" };
        $text = $function->(@args);
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

around TO_JSON => sub {
    my ($orig, $self) = @_;

    my $json = $self->$orig;
    $json->{editor_id} = $self->editor_id + 0;
    $json->{editor} = $self->editor->TO_JSON;
    $json->{post_time} = datetime_to_iso8601($self->post_time);
    $json->{formatted_text} = $self->editor_id == 4 ? $self->localize : format_editnote($self->text);

    return $json;
};

no Moose;
__PACKAGE__->meta->make_immutable;
1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2009 Oliver Charles

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
