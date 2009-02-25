package Catalyst::Plugin::I18N::Gettext;

use strict;
use warnings;

use I18N::LangTags ();
use I18N::LangTags::Detect;

use Data::Dumper;

our $VERSION = '0.01';

our $trans_path;

sub setup {
    my $self = shift;
    $self->NEXT::setup(@_);
    my $calldir = $self;
    $calldir =~ s{::}{/}g;   
    my $file = "$calldir.pm";
    $trans_path = $INC{$file};
    $trans_path =~ s{\.pm$}{/\.\./\.\./\.\./po};
    $self->log->debug($trans_path);
}

sub languages {
    my ( $c, $languages ) = @_;
    if ($languages) { $c->{languages} = $languages }
    else {
        $c->{languages} ||= [
            I18N::LangTags::implicate_supers(
                I18N::LangTags::Detect->http_accept_langs(
                    $c->request->header('Accept-Language')
                )
            ),
            'i-default'
        ];
    }
    return $c->{languages};
}

sub language {
    my $c = shift;
    my @avail_lang = grep { -e "$trans_path/$_.mo" } (@{$c->languages});
    return $avail_lang[0];
}

sub gettext
{
	my ($c, $msgid, $vars) = @_;

        my %v = %$vars if (ref $vars eq "HASH");

	return __expand($c->_dcngettext ($msgid, undef, undef), %v);
}

sub ngettext
{
	my ($c, $msgid, $msgid_plural, $n, $vars) = @_;

        my %vars = %$vars if (ref $vars eq "HASH");

	return __expand($c->_dcngettext ($msgid, $msgid_plural, $n), %vars);
}

sub _dcngettext
{

    my ($c, $msgid, $msgid_plural, $n) = @_;
    
    return unless defined $msgid;
    
    my @trans = ($msgid, $msgid_plural);

    my $plural = defined $msgid_plural;
    
    my $domain = $c->__load_catalog ($trans_path, $c->language);

    if ($domain) {
    
        my $trans_ref = $domain->{messages}->{$msgid};

        if (defined $trans_ref) {
            @trans = @$trans_ref;
            shift @trans;
        }
    }

    my $trans = $trans[0];
    if ($plural) {
        if ($domain) {
            my $nplurals = 0;
            ($nplurals, $plural) = &{$domain->{plural_func}} ($n);
            $plural = 0 unless defined $plural;
            $nplurals = 0 unless defined $nplurals;
            $plural = 0 if $nplurals <= $plural;
        } else {
            $plural = $n != 1 || 0;
        }
        
        $trans = $trans[$plural] if defined $trans[$plural];
    }

    return $trans;
}

sub __expand
{
    my ($translation, %args) = @_;

    my $re = join '|', map { quotemeta $_ } keys %args;

    $translation =~ s/\{($re)\|(.*?)\}/defined $args{$1} ? "<a href=\"" . $args{$1} . "\">$2<\/a>" : "{$1}"/ge;
    $translation =~ s/\{($re)\}/defined $args{$1} ? $args{$1} : "{$1}"/ge;

    return $translation;
}


sub __load_catalog
    {
	my ($c, $directory, $lang) = @_;

        return unless ($lang);

	my $filename = "$directory/$lang.mo";

        # Alternatively we could check the filename for evil characters ...
	# (Important for CGIs).
	return unless -f $filename && -r $filename;

	local $/;
	local *HANDLE;

	open HANDLE, "<$filename"
            or return;
	binmode HANDLE;
	my $raw = <HANDLE>;
	close HANDLE;

	# Corrupted?
	return if ! defined $raw || length $raw < 28;

	my $filesize = length $raw;

	# Read the magic number in order to determine the byte order.
	my $domain = {};
	my $unpack = 'N';
	$domain->{potter} = unpack $unpack, substr $raw, 0, 4;

	if ($domain->{potter} == 0xde120495) {
            $unpack = 'V';
	} elsif ($domain->{potter} != 0x950412de) {
            return;
	}
	my $domain_unpack = $unpack x 6;

	my ($revision, $num_strings, $msgids_off, $msgstrs_off,
            $hash_size, $hash_off) = 
                unpack (($unpack x 6), substr $raw, 4, 24);

	return unless $revision == 0; # Invalid revision number.

	$domain->{revision} = $revision;
	$domain->{num_strings} = $num_strings;
	$domain->{msgids_off} = $msgids_off;
	$domain->{msgstrs_off} = $msgstrs_off;
	$domain->{hash_size} = $hash_size;
	$domain->{hash_off} = $hash_off;
	
	return if $msgids_off + 4 * $num_strings > $filesize;
	return if $msgstrs_off + 4 * $num_strings > $filesize;
	
	my @orig_tab = unpack (($unpack x (2 * $num_strings)), 
                               substr $raw, $msgids_off, 8 * $num_strings);
	my @trans_tab = unpack (($unpack x (2 * $num_strings)), 
                                substr $raw, $msgstrs_off, 8 * $num_strings);
	
	my $messages = {};
	
	for (my $count = 0; $count < 2 * $num_strings; $count += 2) {
            my $orig_length = $orig_tab[$count];
            my $orig_offset = $orig_tab[$count + 1];
            my $trans_length = $trans_tab[$count];
            my $trans_offset = $trans_tab[$count + 1];
		
            return if $orig_offset + $orig_length > $filesize;
            return if $trans_offset + $trans_length > $filesize;
		
            my @origs = split /\000/, substr $raw, $orig_offset, $orig_length;
            my @trans = split /\000/, substr $raw, $trans_offset, $trans_length;
		
            # The singular is the key, the plural plus all translations is the
            # value.
            my $msgid = $origs[0];
            $msgid = '' unless defined $msgid && length $msgid;
            my $msgstr = [ $origs[1], @trans ];
            $messages->{$msgid} = $msgstr;
	}
	
	$domain->{messages} = $messages;
	
	# Try to find po header information.
	my $po_header = {};
	my $null_entry = $messages->{''}->[1];
	if ($null_entry) {
            my @lines = split /\n/, $null_entry;
            foreach my $line (@lines) {
                my ($key, $value) = split /:/, $line, 2;
                $key =~ s/-/_/g;
                $po_header->{lc $key} = $value;
            }
	}
	$domain->{po_header} = $po_header;
	
	if (exists $domain->{po_header}->{content_type}) {
            my $content_type = $domain->{po_header}->{content_type};
            if ($content_type =~ s/.*=//) {
                $domain->{po_header}->{charset} = $content_type;
            }
	}
	
	my $code = $domain->{po_header}->{plural_forms} || '';
	
	# Whitespace, locale-independent.
	my $s = '[ \t\r\n\013\014]';
	
	# Untaint the plural header.
	# Keep line breaks as is (Perl 5_005 compatibility).
	if ($code =~ m{^($s*
                           nplurals$s*=$s*[0-9]+
                           $s*;$s*
                           plural$s*=$s*(?:$s|[-\?\|\&=!<>+*/\%:;a-zA-Z0-9_\(\)])+
                       )}xms) {
            $domain->{po_header}->{plural_forms} = $1;
	} else {
            $domain->{po_header}->{plural_forms} = '';
	}
	
	# Determine plural rules.
	# The leading and trailing space is necessary to be able to match
	# against word boundaries.
	my $plural_func;
	
	if ($domain->{po_header}->{plural_forms}) {
            my $code = ' ' . $domain->{po_header}->{plural_forms} . ' ';
            # Surround this whole comparison stuff with spaces
            $code =~ 
                s/([!<>=]+)/ $1 /g;

            $code =~ 
                s/([^_a-zA-Z0-9])([_a-z][_A-Za-z0-9]*)([^_a-zA-Z0-9])/$1\$$2$3/g;
		
            $code = "sub { my \$n = shift; 
				   my (\$plural, \$nplurals); 
				   $code; 
				   return (\$nplurals, \$plural ? \$plural : 0); }";
		
            # Now try to evaluate the code.	 There is no need to run the code in
            # a Safe compartment.  The above substitutions should have destroyed
            # all evil code.  Corrections are welcome!
            $plural_func = eval $code;
            undef $plural_func if $@;
	}
	
	# Default is Germanic plural (which is incorrect for French).
	$plural_func = eval "sub { (2, 1 != shift || 0) }" unless $plural_func;
	
	$domain->{plural_func} = $plural_func;
	
	return $domain;
    }

1;
