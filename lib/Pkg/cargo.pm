package Pkg::cargo;

use v5.10;
use strict;
use warnings;
use utf8;
use version; our $VERSION = version->declare("v0.1");

use File::Which;
use File::Temp qw/tempfile/;

use Privileges::Drop;

sub new :prototype($%) {
    my ($class, %opts) = @_;
    my $cargo = $opts{cargo} // which 'cargo';

    die 'cannot find cargo executable'
        unless defined $cargo && -x $cargo;

    return bless { cargo => $cargo }, $class;
}

sub have :prototype($$) {
    my ($self, $pkg) = @_;
    
    my ($fh, $fname) = tempfile;
    qx/$self->{cargo} install --list > $fname/;

    my $pkg_len = length $pkg;
    my $version = undef;
    while (<$fh>) {
        next if /^\s/;
        chomp;
        
        my $pkg_name = substr $_, 0, $pkg_len;
        if ($pkg eq $pkg_name) {
            $version = substr $_, $pkg_len + 2, -1;
            last;
        }
    }

    return 0 unless defined $version;

    seek $fh, 0, 0;
    qx/$self->{cargo} search alacritty > $fname/;

    my $new_ver = undef;
    while (<$fh>) {
        if (/\A$pkg = "([^"]+)"/) {
            $new_ver = $1;
            last;
        }
    }

    return 1 unless defined $new_ver;

    return version->declare("v$version") >= version->declare("v$new_ver")
}

sub install :prototype($$%) {
    my ($self, $pkg, %opts) = @_;

    my $pid = fork;
    die "fork failed while trying to drop privileges"
        unless defined $pid;

    if ($pid) {
        local $? = 0;
        waitpid $pid, 0;

        if ($? == 0) {
            say "ok"
        } else {
            # this expects error messages to break the line
            say "\n[Pkg] installing $pkg... not ok"
        }
        return ($? >> 8);
    }
    else {
        use integer;

        print "[Pkg] installing $pkg... ";

        drop_privileges('bodand');

        if ($self->have($pkg)) {
            print "have... ";
            exit 0;
        }

        $ENV{RUSTCFLAGS} = $opts{compile_args}
            if exists $opts{compile_args};
        my $args = $opts{args} // '';

        exec "$self->{cargo} $args install $pkg";
    }
}

__END__
=pod

=encoding UTF-8

=head1 NAME

Pkg::pip - Rust package manager

=head1 DESCRIPTION

This package provides a painless way to interact with the cargo tool.
Provides the B<install> and B<have> methods.

=cut
