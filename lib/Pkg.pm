package Pkg;

use v5.10;
use strict;
use warnings;
use utf8;

use File::Which qw/which/;

sub install :prototype($) { 0 }

sub new :prototype($%) {
    my ($_class, %opts) = @_; # remove Pkg from @_
    shift;
    my $mgr = $opts{manager} // &_find_mgr();

    require "Pkg/$mgr.pm";
    return "Pkg::$mgr"->new(@_);
}

sub _find_mgr :prototype() {
    return 'pkg_add' if $^O eq 'openbsd';
    return 'pkg'     if $^O eq 'freebsd';
    return 'win'     if $^O eq 'MSWin32';
    # TODO: implement the linux madness of package managers
}

1
