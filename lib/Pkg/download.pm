package Pkg::download;

use v5.10;
use strict;
use warnings;
use utf8;
use version; our $VERSION = version->declare("v0.1");

use LWP::UserAgent;
use File::Spec;
use File::Path qw/make_path/;

sub new :prototype($%){
    my ($class, %opts) = @_;
    return bless { 
        ua => LWP::UserAgent->new(agent => 'curl/7.77.0'), 
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

    $pkg =~ /([^@]*(?:\\.[^@]*)*)\@(\S+)/;
    my ($dst, $src) = ($1, $2);

    my %smol_env = (
        USER => $self->{user},
        HOME => &_userhome($self->{user}),
    );
    $dst =~ s/(?<!\\)\$(\w+)/$smol_env{$1}/g;
    $src =~ s/(?<!\\)\$(\w+)/$smol_env{$1}/g;

    print "[Pkg] installing $dst... ";

    my ($vol, $dir, $file) = File::Spec->splitpath($dst);
    $vol .= '/' if $vol;
    unless (defined eval {
        make_path("$vol$dir");
    }) {
        say "\n[Pkg] $dst... not ok: cannot create directory path";
        return -1;
    }

    my $res = $self->{ua}->get($src, ':content_file' => $dst);

    if ($res->is_success) {
        say "ok";
        return 0;
    }
    else {
        say "not ok: ", $res->code, ' ', $res->message;
        return $res->code;
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
