package Perl::Critic::Policy::MusicBrainz::RequirePodSectionsAlways;

use 5.006001;
use strict;
use warnings;
use Readonly;

use Perl::Critic::Utils qw{ :booleans :characters :severities :classification };
use base 'Perl::Critic::Policy';

our $VERSION = '1';

Readonly::Scalar my $NO_DOCS_DESCRIPTION =>
    'This file contains no POD sections.';
Readonly::Scalar my $NO_DOCS_EXPLANATION =>
    'Files should be documented.';

Readonly::Scalar my $NO_COPYRIGHT_SECTION_DESCRIPTION =>
    'This file is missing the COPYRIGHT AND LICENSE POD section.';
Readonly::Scalar my $NO_COPYRIGHT_SECTION_EXPLANATION =>
    'Every file should indicate its copyright and license.';

Readonly::Scalar my $NO_TEST_INFO_DESCRIPTION =>
    'This test file is missing the DESCRIPTION POD section.';
Readonly::Scalar my $NO_TEST_INFO_EXPLANATION =>
    'Every test file should indicate what it tests for in the DESCRIPTION.';

#-----------------------------------------------------------------------------

sub default_severity { return $SEVERITY_LOW            }
sub default_themes   { return qw( musicbrainz ) }
sub applies_to       { return 'PPI::Document'          }

#-----------------------------------------------------------------------------

sub violates {
    my ( $self, $elem, $doc ) = @_;

    # This policy does not apply unless there is some real code in the
    # file.  For example, if this file is just pure POD, then
    # presumably this file is ancillary documentation and you can use
    # whatever headings you want.
    return if ! $doc->schild(0);

    my %found_sections = ();
    my @violations = ();

    my $pods_ref = $doc->find('PPI::Token::Pod');
    if (not $pods_ref) {
        push @violations, $self->violation(
            $NO_DOCS_DESCRIPTION,
            $NO_DOCS_EXPLANATION,
            $doc,
        );

        return @violations;
    }

    # Round up the names of all the =head1 sections
    my $pod_of_record;
    for my $pod ( @{ $pods_ref } ) {
        for my $found ( $pod =~ m{ ^ =head1 \s+ ( .+? ) \s* $ }gxms ) {
            # Use first matching POD as POD of record (RT #59268)
            $pod_of_record ||= $pod;
            #Leading/trailing whitespace is already removed
            $found_sections{ uc $found } = 1;
        }
    }

    # Compare the required sections against those we found
    if ( not exists $found_sections{'COPYRIGHT AND LICENSE'} ) {
        push @violations, $self->violation(
            $NO_COPYRIGHT_SECTION_DESCRIPTION,
            $NO_COPYRIGHT_SECTION_EXPLANATION,
            $pod_of_record || $pods_ref->[0],
        );
    }


    my $includes_ref = $doc->find('PPI::Statement::Include');

    # We assume the file is a test if it imports a Test:: package
    my $is_test = scalar grep { m/ \b Test:: \b/xms }  @{ $includes_ref };

    if ( $is_test && (not exists $found_sections{'DESCRIPTION'}) ) {
        push @violations, $self->violation(
            $NO_TEST_INFO_DESCRIPTION,
            $NO_TEST_INFO_EXPLANATION,
            $pod_of_record || $pods_ref->[0],
        );
    }

    return @violations;
}

1;

__END__

#-----------------------------------------------------------------------------

=pod

=for stopwords licence

=head1 NAME

Perl::Critic::Policy::MusicBrainz::RequirePodSectionsAlways - Add a copyright section to every file.


=head1 AFFILIATION

This Policy is part of the MusicBrainz L<Perl::Critic|Perl::Critic>
distribution.


=head1 DESCRIPTION

This Policy requires every file to contain at least one POD C<=head1>
section: COPYRIGHT AND LICENSE.

This Policy is an adaptation of L<Documentation::RequirePodSections|Perl::Critic::Policy::Documentation::RequirePodSections>
since for some reason that does not care about a file missing POD entirely.

=head1 CONFIGURATION

This Policy is not configurable except for the standard options.

=head1 LIMITATIONS

Currently, this Policy does not look for the required POD section
below the C<=head1> level.

This Policy applies to the entire document, but can be disabled for a
particular document by a C<## no critic (RequireCopyrightSection)> annotation
anywhere between the beginning of the document and the first POD section
containing a C<=head1>, the C<__END__> (if any), or the C<__DATA__> (if any),
whichever comes first.


=head1 AUTHOR

MetaBrainz Foundation
Jeffrey Ryan Thalhammer <jeff@imaginative-software.com>


=head1 COPYRIGHT AND LICENSE

Copyright (C) 2022 MetaBrainz Foundation
Copyright (C) 2006-2011 Imaginative Software Systems.  All rights reserved.

This program is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.  The full text of this license
can be found in the LICENSE file included with this module

=cut

# Local Variables:
#   mode: cperl
#   cperl-indent-level: 4
#   fill-column: 78
#   indent-tabs-mode: nil
#   c-indentation-style: bsd
# End:
# ex: set ts=8 sts=4 sw=4 tw=78 ft=perl expandtab shiftround :