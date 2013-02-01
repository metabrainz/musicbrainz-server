package MusicBrainz::Server::Entity::NES::Relationship;
use Moose;

use MusicBrainz::Server::Entity::Types;
use MusicBrainz::Server::Validation qw( trim_in_place );
use MusicBrainz::Server::Translation qw( l );
use Readonly;

has target => (
    is => 'ro',
);

has target_gid => (
    is => 'ro',
);

has target_type => (
    is => 'ro',
    required => 1
);

has link => (
    is => 'ro',
);

has 'phrase' => (
    is => 'ro',
    builder => '_build_phrase',
    lazy => 1
);

has 'verbose_phrase' => (
    is => 'ro',
    builder => '_build_verbose_phrase',
    lazy => 1
);

Readonly our $DIRECTION_FORWARD  => 1;
Readonly our $DIRECTION_BACKWARD => 2;

sub _join_attrs
{
    my @attrs = map { $_ } @{$_[0]};
    if (scalar(@attrs) > 1) {
        my $a = pop(@attrs);
        my $b = join(l(", "), @attrs);
        return l("{b} and {a}", {b => $b, a => $a});
    }
    elsif (scalar(@attrs) == 1) {
        return $attrs[0];
    }
    return '';
}

has direction => (
    default => $DIRECTION_FORWARD,
    is => 'ro',
);

sub _build_phrase {
    my ($self) = @_;
    $self->_interpolate(
        $self->direction == $DIRECTION_FORWARD
            ? $self->link->type->l_link_phrase()
            : $self->link->type->l_reverse_link_phrase());
}

sub _build_verbose_phrase {
    my ($self) = @_;
    $self->_interpolate($self->link->type->short_link_phrase);
}

sub _interpolate
{
    my ($self, $phrase) = @_;

    my @attrs = $self->link->all_attributes;
    my %attrs;
    foreach my $attr (@attrs) {
        my $name = lc $attr->root->name;
        my $value = $attr->l_name();
        if (exists $attrs{$name}) {
            push @{$attrs{$name}}, $value;
        }
        else {
            $attrs{$name} = [ $value ];
        }
    }

    my $replace_attrs = sub {
        my ($name, $alt) = @_;
        if (!$alt) {
            return '' unless exists $attrs{$name};
            return _join_attrs($attrs{$name});
        }
        else {
            my ($alt1, $alt2) = split /\|/, $alt;
            return $alt2 || '' unless exists $attrs{$name};
            my $attr = _join_attrs($attrs{$name});
            $alt1 =~ s/%/$attr/eg;
            return $alt1;
        }
    };
    $phrase =~ s/{(.*?)(?::(.*?))?}/$replace_attrs->(lc $1, $2)/eg;
    trim_in_place($phrase);

    return $phrase;
}

1;
