use v5.10;
use strict;
use warnings;
use utf8;

use Cwd qw/getcwd/;

my $pwd = Cwd::getcwd;

if ($^O =~ /Win32/) {
    $pwd =~ s{/}{\\}g;
    say "Initing on Windows in '$pwd'";

    chdir "common";
    system "make", 
            "DIR_SEP=\\", 
            "SYMLINKER=..\\compat\\ln.bat", 
            "PWD=$pwd\\common", 
            "SYS_USR_HOME=$ENV{USERPROFILE}",
            "install";
    chdir "..";
} elsif ($^O =~ /linux/) {
    say "Initing on Linux in '$pwd'";

    chdir "common";
    system "make",
            "DIR_SEP=/",
            "SYMLINKER=ln -s",
            "PWD=$pwd/common",
            "SYS_USR_HOME=$ENV{HOME}",
            "install";
    chdir "..";
}

if (-d "$pwd/$^O") {
    chdir "$^O";
    system "make", "install";
}
