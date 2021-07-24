#!/usr/bin/perl

use v5.16;
use strict;
use warnings;
use utf8;
use version; our $VERSION = version->declare('v0.1.0');

use Pod::Usage;
my $ps;
BEGIN {
    $ps = eval {
        require Proc::ProcessTable;
        Proc::ProcessTable->import;
        Proc::ProcessTable->new;
    }
}

pod2usage(2) if @ARGV > 1;
pod2usage(-verbose => 2) if @ARGV && fc($ARGV[0]) eq fc('help');

my $have_sleep = eval {
    use IPC::Open3;
    my $pid = open3(my $in, my $out, my $err, 'apm');
    
    local $? = 0;
    waitpid $pid, 0;
    return undef if $?;

    if (defined $ps) {
        return scalar grep { $_->fname eq 'apmd' } @{$ps->table}
    }
    return 1
};
my $have_logout = eval {
    if (defined $ps) {
        return scalar grep { $_->fname eq 'i3' } @{$ps->table}
    }
    return undef;
};

if (@ARGV) {
    my $opt = fc($ARGV[0]);
    if ($opt eq fc('poweroff')) {
        exec 'doas', 'shutdown', '-p', 'now'
    }
    elsif ($opt eq fc('reboot')) {
        exec 'doas', 'reboot'
    }
    elsif ($have_logout) {
        if ($opt eq fc('logout')) {
            exec 'i3-msg', 'exit';
        }
    }
    elsif ($have_sleep) {
        if ($opt eq fc('sleep')) {
            exec 'zzz';
        }
        elsif ($opt eq fc('hibernate')) {
            exec 'ZZZ';
        }
    }
}

say for qw/poweroff reboot/;
if ($have_logout) {
    say for qw/logout/;
}
if ($have_sleep) {
    say for qw/sleep hibernate/;
}

__END__
=pod

=head1 NAME

power.pl - OpenBSD/i3 power/session manager script for Rofi

=head1 SYNOPSIS

power.pl [B<poweroff>|B<reboot>[|B<logout>][|B<sleep>|B<hibernate>]]

power.pl B<help>

=head1 DESCRIPTION

This Perl script is a rofi custom mode which manages powering off and related
operations on OpenBSD. Seamless operation requies that passwordless B<doas>
is allowed for L<turnoff(8)> and L<reboot(8)> under the current user.

When invoked without any parameters, it prints out the number of available 
actions to F<STDOUT>. The B<poweroff> and B<reboot> options are always 
available, but note that depending on hardware B<poweroff> may or may not 
power off the whole computer; see L<halt(8)>.

Other than B<poweroff> and B<reboot>, the B<sleep> and B<hibernate> options may
be available, these map to the behaviors of B<zzz>, and B<ZZZ> described in 
L<apm(8)>. They are available if L<apm(8)>'s exit code is C<0> and L<apmd(8)>
is found among the running processes. (The latter check is only performed
iff L<Proc::ProcessTable> is installed.)

The B<logout> action is available if B<i3> is detected to be running.

If the argument is not present in the list of possible arguments, the behavior
is the same as if nothing was provided.

Passed options are interpreted case-insensitively.

=cut

