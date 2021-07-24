package Pkg::pip;

use v5.10;
use strict;
use warnings;
use utf8;
use version; our $VERSION = version->declare("v0.1");

sub new :prototype($%){
    my ($class, %opts) = @_;
    my $pip = $opts{pip} // &_find_pip();

    die 'cannot find pip executable'
        unless defined $pip;

    return bless { pip => $pip }, $class;
}

sub have :prototype($$) {
    my ($self, $pkg) = @_;
    use integer;
    local $? = 0;

    qx/$self->{pip} show $pkg/;

    return 1 * ($? == 0)
}

sub install :prototype($$) {
    my ($self, $pkg) = @_;
    use integer;
    local $? = 0;

    print "[Pkg] installing $pkg... ";
    
    qx/$self->{pip} install $pkg/;

    if ($? == 0) {
        say "ok"
    } else {
        say "\n[Pkg] installing $pkg... not ok"
    }
    return ($? >> 8);
}

sub _find_pip :prototype() {
    return 'pip' if ($^O eq 'MSWin32');
    return 'pip3' if ($^O eq 'linux');
    # hopefully the BSDs behave the same as OpenBSD does
    local $? = 0;
    my $ver = qx/python3 -V/;
    return undef if $? != 0;

    if ($ver =~ /\APython (\d+\.\d+)\.\d+\Z/) {
        my $my_pip = "/usr/local/bin/pip$1";
        if (-x $my_pip) {
            return $my_pip;
        }
    }

    return undef;
}

__END__
=pod

=encoding UTF-8

=head1 NAME

Pkg::pip - Python package manager

=head1 DESCRIPTION

This package provides a painless way to interact with the system pip.
Provides the B<install> and B<have> methods.

=cut
