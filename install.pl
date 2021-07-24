#!/usr/bin/perl

use v5.12;
use strict;
use warnings;
use utf8;
use version; our $VERSION = version->declare('v0.1');

## do not support running in taint mode under Win32
unless ($^O eq 'MSWin32') {
    $ENV{PATH} = '/usr/local/bin:/usr/bin:/usr/sbin'
}

use Getopt::Long qw/
    &VersionMessage
    :config
    no_auto_abbrev 
    no_bundling_override
    no_getopt_compat
    no_ignore_case
    no_ignore_case_always
    no_require_order

    gnu_compat
    bundling
/;
use Pod::Usage;

use lib 'lib';
use Pkg::INI qw/process_pkgs/;

sub msg :prototype(&$);

my %config = (
    help_cnt => -1, 
    theme    => 'TokyoNight',
    dry_run  => 0,
    user     => [getpwuid 1000]->[0],
);
#Getopt::Long::Configure("bundling");
GetOptions(
    'help|?|h+'     => \$config{help_cnt}, 
    'version|v'     => sub { VersionMessage() },
    'theme|T=s'     => \$config{theme},
    'dry-run|n!'    => \$config{dry_run},
    'user|U=s'      => \$config{user},
    'list-themes|L' => sub {
        opendir my $dir, 'themes';
        while (readdir $dir) {
            next if /^\./;
            say "- $_" if -f "themes/$_/pkgs.ini";
        }
    }
) or pod2usage(-verbose => 1, -exitval => 2);
pod2usage(-verbose => $config{help_cnt}) if $config{help_cnt} >= 0;

unless (-f "themes/$config{theme}/pkgs.ini") {
    die "[install.pl] specified theme '$config{theme}' is not a valid theme."
}

# TODO
#if ($config{dry_run}) {
    #require Pkg::Dry;
    #Pkg::Dry->import(qw/readpipe/);
#}

msg {
    if (-f "os/$^O/pkgs.ini") {
        process_pkgs("os/$^O/pkgs.ini", \%config);
        return "done";
    }
    else {
        return "dubious";
    }
} "setting up system specific requirements...";

msg {
    process_pkgs("themes/$config{theme}/pkgs.ini", \%config);
    return 'done';
} "setting up theme specific requirements...";

sub msg :prototype(&$) {
    my ($code, $msg) = @_;

    say "[install.pl] $msg";

    my $status = $code->();

    say "[install.pl] $msg $status";
}

__END__
=pod

=head1 NAME

install.pl - bodand's dotfile installer

=head1 SYNOPSIS

 ./install [-?vnT]

=head1 OPTIONS

=over 2

=item B<-?>, B<-h>, B<--help>

Print short usage help and exit.

=item B<-v>, B<--version>

Print version info and exit.

=item B<-T> I<thm>, B<--theme>=I<thm>

On the unices, install a theme specified by I<thm>.
On Windows this option is ignored. Default is C<TokyoNight>.

=item B<-n>, B<--I<(no-)>dry-run>

Do not install anything, just print what would've happened.
NOT IMPLEMENTED :).

=item B<-L>, B<--list-themes>

List currently available themes for installation.

=back

=cut
