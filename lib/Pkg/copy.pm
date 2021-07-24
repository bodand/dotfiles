package Pkg::copy;

use v5.10;
use strict;
use warnings;
use utf8;
use version; our $VERSION = version->declare("v0.1");

use File::Spec;
use File::Path qw/make_path/;
use File::Copy qw/cp/;

use Privileges::Drop;

sub new :prototype($%){
    my ($class, %opts) = @_;
    return bless { 
        pwd  => $opts{pwd},
        user => $opts{user} 
    }, $class;
}

sub have :prototype($$) {
    my ($self, $pkg) = @_;
    $pkg =~ /([^@]*(?:\\.[^@]*)*)\@/;
    my $res = $1;
    return -f $res;
}

sub install :prototype($$) {
    my ($self, $pkg) = @_;

    my $pid = fork;
    die "fork failed while trying to drop privileges"
    	unless defined $pid;

    if ($pid) {
        waitpid $pid, 0;
    }
    else {
        $pkg =~ /([^@]*(?:\\.[^@]*)*)\@(\S+)/;
        my ($dst, $src) = ($1, $2);
        $src = File::Spec->rel2abs($src, $self->{pwd});

        my %smol_env = (
            USER => $self->{user},
            HOME => &_userhome($self->{user}),
        );
        $dst =~ s/(?<!\\)\$(\w+)/$smol_env{$1}/g;
        $src =~ s/(?<!\\)\$(\w+)/$smol_env{$1}/g;

        my $dst_cfg = substr $dst, 0, 1;
        if ($dst_cfg eq '=') {
            $dst = substr $dst, 1;
        }
        else {
            drop_privileges($self->{user});
        }

        print "[Pkg] installing $dst... ";


        my ($vol, $dir, $file) = File::Spec->splitpath($dst);
        $vol .= '/' if $vol;
        unless (defined eval {
            make_path("$vol$dir");
        }) {
            say "\n[Pkg] $dst... not ok: cannot create directory path";
            exit -1;
        }

        local $! = 0;
        if (cp($src, $dst)) {
            say "ok";
            exit 0;
        }
        else {
            say "not ok: $!";
            exit -1;
        }
    }
}

sub _userhome :prototype($) {
    my ($user) = @_;
    my @data = getpwnam $user;
    return $data[7];
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
