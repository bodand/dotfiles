package Pkg::pkg_add;

use v5.10;
use strict;
use warnings;
use utf8;
use version; our $VERSION = version->declare('v0.1');

use IPC::Open3;
use Symbol qw/gensym/;
use IO::KQueue;
use POSIX qw/WNOHANG/;
use IO::Handle;

sub new {
    my ($class, %opts) = @_;
    say '[Pkg] using pkg_add as package manager';

    my $self = bless { kq => IO::KQueue->new }, $class;

    $self->{kq}->EV_SET(
        fileno(STDIN),
        EVFILT_READ,
        EV_ADD);

    return $self;
}

sub have :prototype($$) {
    my ($self, $pkg) = @_;

    my $pid = open3(my $in,
                    my $out,
                    my $err = gensym,
                    'pkg_info', $pkg);
    $out->blocking(0);

    $self->{kq}->EV_SET(
        fileno($out),
        EVFILT_READ,
        EV_ADD);
    $self->{kq}->EV_SET(
        $pid,
        EVFILT_PROC,
        EV_ADD,
        NOTE_EXIT);

    local $? = 0;
    my $info_line = undef;
    EXEC_LOOP: while (1) {
        my @events = $self->{kq}->kevent(50);

        for my $ev (@events) {
            if ($ev->[KQ_IDENT] == fileno($out)) {
                unless (defined $info_line) {
                    $info_line = <$out>;

                    $self->{kq}->EV_SET(
                        fileno($out),
                        EVFILT_READ,
                        EV_DELETE);
                }
            }
            elsif ($ev->[KQ_IDENT] == $pid
                   && $ev->[KQ_FILTER] == EVFILT_PROC) {
                $? = $ev->[KQ_DATA];
                last EXEC_LOOP;
            }
        }
    }
    
    use integer;
    if (($? >> 8) == 1 || !defined $info_line) {
        return undef;
    }
    return 1 * ($info_line =~ /\AInformation for inst:/);
}

sub install :prototype($$) {
    my ($self, $pkg) = @_;
    print "[Pkg] installing $pkg... ";
    my $sep = 0;

    my $pid = open3(my $in, 
                    my $out,
                    my $err = gensym,
                    'pkg_add', '-i', $pkg);

    $self->{kq}->EV_SET(
        fileno($err),
        EVFILT_READ,
        EV_ADD);
    $self->{kq}->EV_SET(
        $pid,
        EVFILT_PROC,
        EV_ADD,
        NOTE_EXIT);

    my $stdin_block = STDIN->blocking();
    STDIN->blocking(0);
    $err->blocking(0);

    local $? = 0;
    EXEC_LOOP: while (1) {
        my @events = $self->{kq}->kevent(50);

        for my $ev (@events) {
            if ($ev->[KQ_IDENT] == fileno(STDIN)) {
                while (<STDIN>) {
                    print {$in} $_;
                }
            }
            elsif ($ev->[KQ_IDENT] == fileno($err)) {
                while (<$err>) {
                    print "\n" unless $sep++;
                    print;
                }
            }
            elsif ($ev->[KQ_IDENT]  == $pid
                && $ev->[KQ_FILTER] == EVFILT_PROC) {
                $? = $ev->[KQ_DATA];
                last EXEC_LOOP;
            }
        }
    }

    STDIN->blocking($stdin_block);
    $self->{kq}->EV_SET(
        fileno($err),
        EVFILT_READ,
        EV_DELETE);

    print "\n[Pkg] $pkg... " if $sep;
    if ($? == 0) {
        say 'ok'
    } 
    else {
        use integer;
        say 'not ok: ' . ($? >> 8);
    }
    return ($? >> 8)
}

1
