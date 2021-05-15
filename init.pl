#! /usr/bin/env perl
use v5.10;
use strict;
use warnings;
use utf8;

use Cwd qw/getcwd/;

my $pwd = Cwd::getcwd;

my %os_config = ();
$os_config{default} = {
	DIR_SEP      => "/",
	SUDO         => "sudo",
	SYMLINKER    => "../compat/ln",
	WHICH_EXE    => "../compat/which",
	DIRECTORY    => $pwd,
	SYS_USR_HOME => $ENV{HOME},
};
$os_config{MSWin32} = {
	DIR_SEP      => "\\",
	SUDO         => "",
	SYMLINKER    => "..\\compat\\ln.bat",
	WHICH_EXE    => "..\\compat\\which.bat",
	SYS_USR_HOME => $ENV{USERPROFILE},
};

sub get_config($) { 
	my ($cfg) = @_;
	$os_config{$^O}->{$cfg} // $os_config{default}->{$cfg}
}
sub make_opt($) {
	my ($name) = @_;
	"$name=" . get_config($name)
}

if (-d "$pwd/$^O") {
    chdir "$^O";
    system "make", "-s",
    	   make_opt("DIR_SEP"),
    	   make_opt("SUDO"),
    	   make_opt("SYMLINKER"),
    	   make_opt("WHICH_EXE"),
    	   make_opt("DIRECTORY"),
    	   make_opt("SYS_USR_HOME"),
    	   "install";
}
