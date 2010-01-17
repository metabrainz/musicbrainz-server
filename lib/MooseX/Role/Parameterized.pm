package MooseX::Role::Parameterized;
use 5.008001;
use Moose::Role ();
use Moose::Exporter;
use Carp 'confess';
use Scalar::Util 'blessed';

use MooseX::Role::Parameterized::Meta::Role::Parameterizable;

our $VERSION = '0.15';
our $CURRENT_METACLASS;

Moose::Exporter->setup_import_methods(
    with_caller => ['parameter', 'role', 'method', 'has', 'with', 'extends',
                    'requires', 'excludes', 'augment', 'inner', 'before',
                    'after', 'around', 'super', 'override'],
    as_is => [ 'confess', 'blessed' ],
);

sub current_metaclass { $CURRENT_METACLASS }

sub parameter {
    my $caller = shift;

    confess "'parameter' may not be used inside of the role block"
        if $CURRENT_METACLASS && $CURRENT_METACLASS->genitor->name eq $caller;

    my $meta   = Class::MOP::class_of($caller);

    my $names = shift;
    $names = [$names] if !ref($names);

    for my $name (@$names) {
        $meta->add_parameter($name, @_);
    }
}

sub role (&) {
    my $caller         = shift;
    my $role_generator = shift;
    Class::MOP::class_of($caller)->role_generator($role_generator);
}

sub init_meta {
    my $self = shift;
    my %options = @_;
    $options{metaclass} ||= 'MooseX::Role::Parameterized::Meta::Role::Parameterizable';

    return Moose::Role->init_meta(%options);
}

sub has {
    my $caller = shift;
    my $meta   = $CURRENT_METACLASS || Class::MOP::class_of($caller);

    my $names = shift;
    $names = [$names] if !ref($names);

    for my $name (@$names) {
        $meta->add_attribute($name, @_);
    }
}

sub method {
    my $caller = shift;
    my $meta   = $CURRENT_METACLASS || Class::MOP::class_of($caller);

    my $name   = shift;
    my $body   = shift;

    my $method = $meta->method_metaclass->wrap(
        package_name => $caller,
        name         => $name,
        body         => $body,
    );

    $meta->add_method($name => $method);
}

sub _add_method_modifier {
    my $type   = shift;
    my $caller = shift;
    my $meta   = $CURRENT_METACLASS || Class::MOP::class_of($caller);

    my $code = pop @_;

    for (@_) {
        Carp::croak "Roles do not currently support "
            . ref($_)
            . " references for $type method modifiers"
            if ref $_;

        my $add_method = "add_${type}_method_modifier";
        $meta->$add_method($_, $code);
    }
}

sub before {
    _add_method_modifier('before', @_);
}

sub after {
    _add_method_modifier('after', @_);
}

sub around {
    _add_method_modifier('around', @_);
}

sub with {
    my $caller = shift;
    my $meta   = $CURRENT_METACLASS || Class::MOP::class_of($caller);

    Moose::Util::apply_all_roles($meta, @_);
}

sub requires {
    my $caller = shift;
    my $meta   = $CURRENT_METACLASS || Class::MOP::class_of($caller);

    Carp::croak "Must specify at least one method" unless @_;
    $meta->add_required_methods(@_);
}

sub excludes {
    my $caller = shift;
    my $meta   = $CURRENT_METACLASS || Class::MOP::class_of($caller);

    Carp::croak "Must specify at least one role" unless @_;
    $meta->add_excluded_roles(@_);
}

# see Moose.pm for discussion
sub super {
    return unless $Moose::SUPER_BODY;
    $Moose::SUPER_BODY->(@Moose::SUPER_ARGS);
}

sub override {
    my $caller = shift;
    my $meta   = $CURRENT_METACLASS || Class::MOP::class_of($caller);

    my ($name, $code) = @_;
    $meta->add_override_method_modifier($name, $code);
}

sub extends { Carp::croak "Roles do not currently support 'extends'" }

sub inner { Carp::croak "Roles cannot support 'inner'" }

sub augment { Carp::croak "Roles cannot support 'augment'" }

1;

__END__

=head1 NAME

MooseX::Role::Parameterized - roles with composition parameters

=head1 SYNOPSIS

    package Counter;
    use MooseX::Role::Parameterized;

    parameter name => (
        isa      => 'Str',
        required => 1,
    );

    role {
        my $p = shift;

        my $name = $p->name;

        has $name => (
            is      => 'rw',
            isa     => 'Int',
            default => 0,
        );

        method "increment_$name" => sub {
            my $self = shift;
            $self->$name($self->$name + 1);
        };

        method "reset_$name" => sub {
            my $self = shift;
            $self->$name(0);
        };
    };

    package MyGame::Weapon;
    use Moose;

    with Counter => { name => 'enchantment' };

    package MyGame::Wand;
    use Moose;

    with Counter => { name => 'zapped' };

=head1 L<MooseX::Role::Parameterized::Tutorial>

B<Stop!> If you're new here, please read
L<MooseX::Role::Parameterized::Tutorial> for a much gentler introduction.

=head1 DESCRIPTION

Your parameterized role consists of two new things: parameter declarations
and a C<role> block.

Parameters are declared using the L</parameter> keyword which very much
resembles L<Moose/has>. You can use any option that L<Moose/has> accepts. The
default value for the C<is> option is C<ro> as that's a very common case. Use
C<< is => 'bare' >> if you want no accessor. These parameters will get their
values when the consuming class (or role) uses L<Moose/with>. A parameter
object will be constructed with these values, and passed to the C<role> block.

The C<role> block then uses the usual L<Moose::Role> keywords to build up a
role. You can shift off the parameter object to inspect what the consuming
class provided as parameters. You use the parameters to customize your
role however you wish.

There are many possible implementations for parameterized roles (hopefully with
a consistent enough API); I believe this to be the easiest and most flexible
design. Coincidentally, Pugs originally had an eerily similar design.

=head2 Why a parameters object?

I've been asked several times "Why use a parameter I<object> and not just a
parameter I<hashref>? That would eliminate the need to explicitly declare your
parameters."

The benefits of using an object are similar to the benefits of using Moose. You
get an easy way to specify lazy defaults, type constraint, delegation, and so
on. You get to use MooseX modules.

You also get the usual introspective and intercessory abilities that come
standard with the metaobject protocol. Ambitious users should be able to add
traits to the parameters metaclass to further customize behavior. Please let
me know if you're doing anything viciously complicated with this extension. :)

=head1 CAVEATS

You must use this syntax to declare methods in the role block:
C<< method NAME => sub { ... }; >>. This is due to a limitation in Perl. In
return though you can use parameters I<in your methods>!

L<Moose::Role/alias> and L<Moose::Role/excludes> are not yet supported. I'm
completely unsure of whether they should be handled by this module. Until we
figure out a plan, either declaring or providing a parameter named C<alias> or
C<excludes> is an error.

=head1 AUTHOR

Shawn M Moore, C<sartak@gmail.com>

=head1 EXAMPLES

=over 4

=item L<Fey::Role::HasAliasName>

=item L<Fey::Role::MakesAliasObjects>

=item L<Fey::Role::SQL::Cloneable>

=item L<Fey::Role::SetOperation>

=item L<IM::Engine::PluggableConstructor>

=item L<IM::Engine::RequiresPlugins>

=item L<KiokuDB::Role::Scan>

=item L<MooseX::RelatedClassRoles>

=item L<MooseX::Role::Matcher>

=item L<MooseX::Role::XMLRPC::Client>

=item L<MooseX::WithCache>

=item L<Net::Journyx::Object::Loadable>

=item L<NetHack::Item::Role::IncorporatesStats>

=item L<TAEB::Action::Role::Item>

=item L<WWW::Mechanize::TreeBuilder>

=back

=head1 SEE ALSO

L<http://sartak.blogspot.com/2009/05/parameterized-roles.html>

L<http://stevan-little.blogspot.com/2009/07/thoughts-on-parameterized-roles.html>

L<http://sartak.org/talks/yapc-asia-2009/(parameterized)-roles/>

=head1 COPYRIGHT AND LICENSE

Copyright 2007-2009 Infinity Interactive

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

=cut

