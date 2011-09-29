#!/usr/bin/perl -w

use strict;

my @headers = (
	"generated/utsrelease.h",
	"linux/utsrelease.h",
	"linux/version.h",
);

if (@ARGV < 1) {
	print "Usage: generate-dot-version <srcdir>\n";
	exit 1;
}

my $srcdir = $ARGV[0];

if (! -d $srcdir) {
	print "Not a directory: $srcdir\n";
	exit 1;
}

sub print_uts_release($)
{
	my $path = shift;

	open IN, "<$path" or die $!;

	while (<IN>) {
		if (m/#define\s+UTS_RELEASE\s+"(\d+)\.(\d+)\.(\d+)(.*)"/) {
			print "VERSION:=$1\n";
			print "PATCHLEVEL:=$2\n";
			print "SUBLEVEL:=$3\n";
			print "KERNELRELEASE:=$1.$2.$3$4\n";
			last;
		}
	}

	close IN;
}

sub print_directories($)
{
	my $srcdir = shift;
	my $outdir = undef;

	open IN, "<$srcdir/Makefile" or die $!;

	while (<IN>) {
		if (m/^KERNELSRC\s*:=\s*(\S.*)\n/ || m/^MAKEARGS\s*:=\s*-C\s*(\S.*)\n/) {
			$outdir = $srcdir;
			$srcdir = $1;
			last;
		}
	}

	close IN;

	if (defined $outdir) {
		print "OUTDIR:=$outdir\n";
	}

	print "SRCDIR:=$srcdir\n";
}

for (@headers) {
	my $path = "$srcdir/include/$_";
	if (-f $path) {
		print_uts_release($path);
		last;
	}
}

print_directories($srcdir);

