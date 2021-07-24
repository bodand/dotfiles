#!/usr/bin/perl

use v5.10;
use strict;
use warnings;
use utf8;
use version; our $VERSION = version->declare('v0.1.2');

use IO::KQueue;
use IO::Socket::UNIX;
use IO::Handle;
use IPC::Open3;
use DateTime;
use JSON;
use constant {
    RUN_COMMAND       => 0,  COMMAND       => 0,
    GET_WORKSPACES    => 1,  WORKSPACES    => 1,
    SUBSCRIBE         => 2,  # same
    GET_OUTPUTS       => 3,  OUTPUTS       => 3,
    GET_TREE          => 4,  TREE          => 4,
    GET_MAKRS         => 5,  MARKS         => 5,
    GET_BAR_CONFIG    => 6,  BAR_CONFIG    => 6,
    GET_VERSION       => 7,  VERSION       => 7,
    GET_BINDING_MODES => 8,  BINDING_MODES => 8, 
    GET_CONFIG        => 9,  # same
    SEND_TICK         => 10, TICK          => 10,
    SYNC              => 11, # does not exist
    GET_BINDING_STATE => 12, BINDING_STATE => 12,

    I3EV_WORKSPACE        => 0,
    I3EV_OUTPUT           => 1,
    I3EV_MODE             => 2,
    I3EV_WINDOW           => 3,
    I3EV_BARCONFIG_UPDATE => 4,
    I3EV_BINDING          => 5,
    I3EV_SHUTDOWN         => 6,
    I3EV_TICK             => 7,
};

sub new_bar :prototype();
sub recv_i3 :prototype($$);
sub send_i3 :prototype($$;$);
sub process_i3 :prototype($$);
sub color :prototype($$$);

my $usr = [getpwuid $>]->[0];

my %xrdb = ();
for my $entry (split /\n/, qx/xrdb -query/) {
    my @arr = split /:\s+/, $entry;
    $xrdb{$arr[0]} = $arr[1];
}

my %colors = (
    bg => $xrdb{'*.background'},
    fg => $xrdb{'*.foreground'}
);
while (my ($key, $val) = each %xrdb) {
    next unless $key =~ /^$usr\.color\.(.+)/;
    $colors{$1} = $val;
}

my ($pid, $bar_in, $bar_out, undef) = new_bar;
$bar_out->blocking(0);

# wait in hopes of i3 sets itself up by now
sleep 1;

chomp(my $i3_ipc = qx/i3 --get-socketpath/);
my $i3 = IO::Socket::UNIX->new(Peer => $i3_ipc);
die "cannot connect to i3: $IO::Socket::errstr"
    unless defined $i3;
my $i3_fd = $i3->fileno;

## Event loop ##################################################################
my $kq = IO::KQueue->new;

$kq->EV_SET(
    $pid,
    EVFILT_PROC,
    EV_ADD,
    NOTE_EXIT);
$kq->EV_SET(
    $i3_fd,
    EVFILT_READ,
    EV_ADD);
$kq->EV_SET(
    fileno($bar_out),
    EVFILT_READ,
    EV_ADD);
$kq->EV_SET(
    1, # second counter
    EVFILT_TIMER,
    EV_ADD,
    0,
    1000);
$kq->EV_SET(
    2, # minute counter
    EVFILT_TIMER,
    EV_ADD,
    0,
    60 * 1000);

send_i3 $i3, GET_VERSION;
send_i3 $i3, GET_WORKSPACES;
send_i3 $i3, SUBSCRIBE, encode_json ['workspace', 'window'];

# Workspaces 
my @workspaces = ();
my $ws_str = '';
# Current focus
my $focus_str = '';
# Clock
my $dt = DateTime->now;
my $clock_str = &join_clock($dt);

EVENT: while (1) {
    my @events = $kq->kevent();

    for my $ev (@events) {
        if ($ev->[KQ_IDENT] == 1
         && $ev->[KQ_FILTER] == EVFILT_TIMER) {
            $dt->add(seconds => $ev->[KQ_DATA]);
            $clock_str = &join_clock($dt); 
        }
        elsif ($ev->[KQ_IDENT] == 2
            && $ev->[KQ_FILTER] == EVFILT_TIMER) {
            # construct new DateTime every minute to fix misalignments
            $dt = DateTime->now;
            $clock_str = &join_clock($dt); 
        }
        elsif ($ev->[KQ_IDENT] == $i3_fd
            && $ev->[KQ_FILTER] == EVFILT_READ) {
            my ($type, $json) = recv_i3($i3, $ev->[KQ_DATA]);
            process_i3 $type, $json;
        }
        elsif ($ev->[KQ_IDENT] == fileno($bar_out)
            && $ev->[KQ_FILTER] == EVFILT_READ) {
            while (<$bar_out>) {
                chomp;
                if ($_ eq 'power') {
                    send_i3 $i3, COMMAND, qq/exec "$xrdb{"$usr.apps.power"}"/;
                }
            }
        }
        elsif ($ev->[KQ_IDENT] == $pid
            && $ev->[KQ_FILTER] == EVFILT_PROC) {
            warn "lemonbar died - restarting";

            ($pid, $bar_in, $bar_out, undef) = new_bar;
            $bar_out->blocking(0);

            $kq->EV_SET(
                $pid,
                EVFILT_PROC,
                EV_ADD,
                NOTE_EXIT);
            $kq->EV_SET(
                fileno($bar_out),
                EVFILT_READ,
                EV_ADD);
        }
    }


    say {$bar_in} "%{l}%{A:power:} \N{U+F924} %{A}$ws_str%{c}$focus_str%{r}$clock_str";
}

sub recv_i3 :prototype($$) {
    my ($i3, undef) = @_;
    state $json = JSON->new;
    
    my $meta = '';
    $i3->recv($meta, 6 + 32/8 * 2, 0);
    
    my ($len, $type) = unpack('x6LL', $meta);

    my $msg = '';
    my $rem = $len;
    do {
        my $part = '';
        $i3->recv($part, $rem, 0);
        $rem -= length $part;
        $msg .= $part;
    } until (length $msg == $len);

    local $@ = '';
    my $obj = eval {
        return decode_json($msg);
    };
    if ($obj) {
        return ($type, $obj);
    }
    else {
        warn "--WARNING--\ndecode_json: $@: $msg";
    }

    return undef;
}

sub send_i3 :prototype($$;$) {
    my ($i3, $type, $cmd) = @_;
    $cmd //= '';
    my $len = eval {
        use bytes;
        return length($cmd);
    };
    $i3->write(
        "i3-ipc" 
        . pack("LL", $len, $type)
        . $cmd
    );
}

sub process_i3 :prototype($$) {
    my $type = shift;
    return unless defined $type;
    if (($type >> 31) == 1) {
        # i3 event
        my $ev_type = $type & 0x7F;
        if ($ev_type == I3EV_WORKSPACE) {
            goto &event_WORKSPACE;
        }
        elsif ($ev_type == I3EV_WINDOW) {
            goto &event_WINDOW;
        }

        warn "ignoring unhandled event type: $type";
        return
    }

    if ($type == WORKSPACES) {
        goto &process_WORKSPACES;
    }
    elsif ($type == VERSION) {
        goto &process_VERSION;
    }
    elsif ($type == SUBSCRIBE) {
        goto &process_SUBSCRIBE;
    }
    elsif ($type == COMMAND) {
        goto &process_COMMAND;
    }

    warn "ignoring unhandled response type: $type";
}

sub new_bar :prototype() {
    my $pid = open3(my $bar_in, my $bar_out, my $bar_err, 
                    'lemonbar', '-p', '-g', 'x22',
                    '-f', $xrdb{"$usr.font.default"},
                    '-B', $colors{bg}, 
                    '-F', $colors{fg});
    binmode $bar_in, ':utf8';
    return ($pid, $bar_in, $bar_out, $bar_err);
}

sub color :prototype($$$) {
    my ($text, $bg, $fg) = @_;
    my $fmt_bg = '';
    my $fmt_fg = '';
    $fmt_bg = "B$bg" if (defined $bg);
    $fmt_fg = "F$fg" if (defined $fg);
    "%{$fmt_fg $fmt_bg}$text"
}

sub join_clock :prototype($) {
    color "\N{U+E0B3} " . $_[0]->ymd() . " \N{U+E0B2}%{R} " . $_[0]->hms() . " %{R}", 
          $colors{bg}, 
          $colors{purple};
}

sub join_workspaces :prototype($) {
    my ($wss) = @_;
    my $ret = '';
    my $skip_beg = 0;
    for my $ws (@$wss) {
        if ($ws->{focus}) {
            if (length $ret) {
                $ret =~ s/(%\{R\})?([\N{U+E0B0}\N{U+E0B1}])(%\{R\})?$//n;
            }

            $ret .= color "%{R}\N{U+E0B0}%{R}",
                          undef,
                          $colors{purple};
            $ret .= color " $ws->{name} %{R}\N{U+E0B0}%{R}",
                          $colors{purple},
                          $colors{bg};
        }
        elsif ($ws->{urgent}) {
            if (length $ret) {
                $ret =~ s/(%\{R\})?([\N{U+E0B0}\N{U+E0B1}])(%\{R\})?$//n;
            }
            
            $ret .= color "%{R}\N{U+E0B0}%{R}", 
                          undef,
                          $colors{red};
            $ret .= color " $ws->{name} %{R}\N{U+E0B0}%{R}",
                          $colors{red},
                          $colors{bg};
        }
        else {
            unless (length $ret) {
                $ret .= color "\N{U+E0B1}",
                              '-',
                              $colors{purple};
            }
            $ret .= color " $ws->{name} \N{U+E0B1}",
                            '-',
                            $colors{purple}
        }
    }
    $ret .= color '', '-', '-';
    return $ret;
}

## event callbacks 
sub process_WORKSPACES {
    my ($json) = @_;
    for my $ws (@$json) {
        push @workspaces, {
            id     => $ws->{num},
            name   => $ws->{name},
            focus  => $ws->{focused},
            urgent => $ws->{urgent}
        }
    }
    $ws_str = &join_workspaces(\@workspaces);
}

sub process_VERSION {
    my ($json) = @_;
    say "connected to i3 $json->{human_readable}";
}

sub process_SUBSCRIBE {
    my ($json) = @_;
    if ($json->{success}) {
        say "subscribed to i3 events"
    }
    else {
        die "couldn't subscribe to i3 events"
    }
}

sub process_COMMAND {
    my ($json) = @_;
    say "command response";
    for (@{$json}) {
        for my $key (keys %$_) {
            print "\t$key -> $_->{$key}\n"
        }
    }
    say '';
}

sub event_WORKSPACE {
    my ($json) = @_;
    if ($json->{change} eq 'focus') {
        my $new_focus = $json->{current};
        for my $ws (@workspaces) {
            $ws->{focus} = $ws->{id} == $new_focus->{num};
        }
    } 
    elsif ($json->{change} eq 'init') {
        my $new_ws = $json->{current};
        my $idx = 0;
        while ($idx < @workspaces 
            && $workspaces[$idx]->{id} < $new_ws->{num}) {
            ++$idx;
        }
        splice @workspaces, $idx, 0, {
            id     => $new_ws->{num},
            name   => $new_ws->{name},
            focus  => 1,
            urgent => $new_ws->{urgent}
        };
        $focus_str = ''; # nothing open on new ws
    }
    elsif ($json->{change} eq 'empty') {
        my $dead_ws = $json->{current};
        my $idx = 0;
        while ($workspaces[$idx]->{id} != $dead_ws->{num}) {
            ++$idx;
        }
        splice @workspaces, $idx, 1;
    }
    elsif ($json->{change} eq 'urgent') {
        my $panicing_ws = $json->{current};
        my $idx = 0;
        while ($workspaces[$idx]->{id} != $panicing_ws->{num}) {
            ++$idx;
        }
        $workspaces[$idx]->{urgent} = $panicing_ws->{urgent};
    }
    else {
        warn "unhandled workspace/$json->{change}";
    }
    $ws_str = &join_workspaces(\@workspaces);
}

sub event_WINDOW {
    my ($json) = @_;
    if ($json->{change} eq 'focus'
     || $json->{change} eq 'title'
     || $json->{change} eq 'new') {
        my $window = $json->{container}{window_properties};
        if ($window->{class} ne 'Bar') {
            $focus_str = "$window->{class} "
                         . color("\N{U+E0BB}", '-', $colors{purple})
                         . color(" $window->{title}", '-', '-');
        }
    }
    elsif ($json->{change} eq 'close') {
        $focus_str = '';
    }
    else {
        warn "unhandled window/$json->{change}";
    }
}


