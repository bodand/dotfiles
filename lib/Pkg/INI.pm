package Pkg::INI;

use v5.10;
use strict;
use warnings;
use utf8;

use Config::INI::Reader;
require Exporter;
our @ISA = qw/Exporter/;
our @EXPORT_OK = qw/process_pkgs/;

use Privileges::Drop;
use File::Spec;

use lib '..';
use Pkg;

sub _process_mgr :prototype($$%);
sub _rm_packages :prototype(\@);

sub process_pkgs :prototype($$) {
    my ($file, $config) = @_;
    my $pkgs = Config::INI::Reader->read_file($file);
    my ($vol, $dir, undef) = File::Spec->splitpath($file);
    $vol .= '/' if $vol;

    if (exists $pkgs->{system}) {
        my $sys = Pkg->new(%$config);

        my $packages = $pkgs->{system}{packages};
        delete $pkgs->{system}{packages};

        _process_mgr($sys, $packages, %{$pkgs->{system}});

        delete $pkgs->{system};
    }

    if (exists $pkgs->{_}) {
        warn "ungrouped entries ignored in $file";
        delete $pkgs->{_};
    }

    for my $mgr_name (keys %$pkgs) {
        my $mgr = Pkg->new(manager => $mgr_name, pwd => "$vol$dir", %$config);

        my $packages = $pkgs->{$mgr_name}{packages};
        delete $pkgs->{$mgr_name}{packages};

        _process_mgr($mgr, $packages, %{$pkgs->{$mgr_name}});
    }
}

sub _rm_packages :prototype(\@) {
    my ($opts) = @_;
    my $idx = 0;
    ++$idx until $opts->[$idx] eq 'packages' 
              or $idx == @$opts;
    splice @$opts, $idx, 1
        unless $idx == @$opts;
}

sub _process_mgr :prototype($$%) {
    my ($mgr, $pkgs, %opts) = @_;
    
    for my $pkg (split /\s+/, $pkgs) {
        $mgr->install($pkg, %opts); 
    }
}

1 

__END__
=pod

=encoding UTF8-8

=head1 NAME

Pkg::INI - read and process pkg.ini files for dotfiles

=head1 DESCRIPTION

A module which reads and processes the F<pkg.ini> files in the F<os/*/> and F<themes/*/> 
directories.

The F<pkg.ini> file contains the different packages needed to make the specific 
OS into a shape which I can use without disturbances, and the required executables 
for the creation of the theme, for example the TokyoNight theme requires the C<i3-gaps>
package, which is therefore listed in its F<pkg.ini> file.

The disctinction between whether something is needed for the theme or for the OS 
is kind of blurry therefore the simple answer is whether I'm going to use it for 
other things as well, other than to create the desktop. Things like Rust, therefore, 
fall into the theme specific category, since I don't use Rust at the moment, although 
this categorization is ""unstable"" since I might just start using Rust for things, 
in which case it'll get lifted into OS specific requirement.

=head1 The pkg.ini file

The pkg.ini file is a simple ini file, no special syntax is used.

The groups can be specified to C<system> which means the current OS' package manager,
or any of the specific package managers under C<Pkg::> (if specifying INI, behavior 
is undefined).

Sections allows (interprets) for the following setions under each group:

=over 2

=item B<args>

Extra arguments to be passed to the package manager. They always appended to
the called package manager invocation, but are before the first non-flag option.

=item B<compile_args>

Extra arguments to package managers that do compiling, for example L<Pkg::cargo>.
How this is interpreted depends on the package manager wrapper, some like the
C<system> manager might actually just silently ignore it.

=item B<packages>

A whitespace separated list of packages to install with that package manager.
They will be installed separately, in the order listed.

=back

The order of groups getting considered is that the C<system> group is executed
first if it exists, while all other groups are executed after in undefined order.

=head2 The Win32 ""package manager""

B<!WARNING!> 

The ""system package manager"" is funky on Windows, where it is implemented using 
a combination of manually downloading and installing installers and using B<scoop> 
which's automaticall installed. 

For more information see the L<Pkg::win32> module.

=cut
