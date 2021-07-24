package Pkg::ninja;

use v5.10;
use strict;
use warnings;
use utf8;
use version; our $VERSION = version->declare("v0.1");

use File::Which;
use Cwd qw/getcwd/;

use Privileges::Drop;

sub new :prototype($%) {
    my ($class, %opts) = @_;
    my $ninja = $opts{ninja} // which 'ninja';
    my $nwd = $opts{pwd} // getcwd;

    die 'cannot find ninja executable'
        unless defined $ninja && -x $ninja;

    return bless { ninja => $ninja, nwd => $nwd }, $class;
}

sub have :prototype($$) {
    # ninja will be faster to determine this than us
    return 0;
}

sub install :prototype($$%) {
    my ($self, $pkg, %opts) = @_;

    print "[Pkg] installing $pkg... ";

    $ENV{CFLAGS} = $opts{compile_args}
        if exists $opts{compile_args};
    my $args = $opts{args} // '';

    qx{$self->{ninja} -C $self->{nwd}/$pkg $args};

    if ($? == 0) {
        say "ok"
    } else {
        # this expects error messages to break the line
        say "\n[Pkg] installing $pkg... not ok"
    }
    return ($? >> 8);
}

__END__
=pod

=encoding UTF-8

=head1 NAME

Pkg::pip - Build local packages with ninja

=head1 DESCRIPTION

Builds local helper programs with the build tool ninja. The package
identifier is a directory in which to run ninja, relative to the 
F<pkgs.ini> file in which it is specified.

The ninja file is expected to build and install without specifying any 
targets.

=cut
