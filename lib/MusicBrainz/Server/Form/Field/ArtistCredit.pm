package MusicBrainz::Server::Form::Field::ArtistCredit;
use HTML::FormHandler::Moose;
extends 'HTML::FormHandler::Field::Compound';

use MusicBrainz::Server::Entity::ArtistCredit;
use MusicBrainz::Server::Entity::ArtistCreditName;

has_field 'names'=> (
    type => 'Repeatable',
    num_when_empty => 0
);

has_field 'names.name' => (
    type => 'Text',
    required => 1,
);

has_field 'names.artist_id' => (
    type => 'Integer',
);

has_field 'names.join_phrase' => (
    type => 'Text',
    trim => { transform => sub { shift } }
);

sub validate
{
    my $self = shift;

    my @credits;
    my @fields = $self->field('names')->fields;
    while (@fields) {
        my $field = shift @fields;

        my $name = $field->field('name')->value;
        my $id = $field->field('artist_id')->value;
        my $join = $field->field('join_phrase')->value || undef;

        push @credits, { artist => $id, name => $name };
        push @credits, $join if $join || @fields;
    }

    $self->value(\@credits);
}

around 'fif' => sub {
    my $orig = shift;
    my $self = shift;

    my $fif = $self->$orig (@_);

    return MusicBrainz::Server::Entity::ArtistCredit->new unless $fif;

    # FIXME: shouldn't happen.
    return MusicBrainz::Server::Entity::ArtistCredit->new unless $fif->{'names'};

    my @names;
    for ( @{ $fif->{'names'} } )
    {
        my $acn = MusicBrainz::Server::Entity::ArtistCreditName->new(
            name => $_->{'name'},
            );
        $acn->artist_id($_->{'artist_id'});
        $acn->join_phrase($_->{'join_phrase'}) if $_->{'join_phrase'};
        push @names, $acn;
    }

    my $ret = MusicBrainz::Server::Entity::ArtistCredit->new( names => \@names );
    $self->form->ctx->model('Artist')->load(@{ $ret->names });

    return $ret;
};

1;
