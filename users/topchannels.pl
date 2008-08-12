# script for irssi
# Copyright (c) 2008 Heikki Hokkanen <hoxu@users.sf.net>

use Irssi;
#use Data::Dumper;
use POSIX qw(strftime);
use strict;

use vars qw($VERSION %IRSSI);

$VERSION = '0.0.1';
%IRSSI = (
	authors => 'Heikki Hokkanen',
	contact => 'hoxu at users.sf.net',
	name => 'topchannels',
	description => 'List channels ordered by size',
	license => 'GPLv2 / GPLv3',
);

# -----[ Variables ]------------------------------------------------------------

# -----[ Functions ]------------------------------------------------------------

sub message {
	my ($msg) = @_;
	#print("%g#%n: $msg");
	print("$msg");
}

##
# Read chanpeak.pl data if available
sub readpeaks {
	# hardcoded default in chanpeak
	# <channel> <chatnet> <peak> <stamp>
	my $peakfile = "$ENV{HOME}/.irssi/peak.data";

	# chatnet -> channel -> { peak, stamp }
	my %peaks = ();

	if (not -f $peakfile) { return; }

	open(FILE, '<', $peakfile);
	while (my $line = <FILE>) {
		if ($line =~ /^(\S+) (\S+) (\d+) (\d+)$/) {
			$peaks{$2}{$1} = {
				'peak' => $3,
				'stamp' => $4,
			};
		}
	}
	
	close(FILE);

	return \%peaks;
}

sub cmd_topchannels {
	my ($data, $server, $witem) = @_;

	my $format = "%-3d %-20s %-15s %4s %4s"; # %8s";

	#message("=== Top channels ===");
	message("%Y". sprintf($format, 0, "Channel", "Chatnet", "#", "Peak") ."%n");

	# collect the data
	my @data = ();
	foreach my $channel (Irssi::channels()) {
		#Irssi::print(Dumper($channel));
		#last;

		my $name = $channel->{name};
		my $chatnet = $channel->{server}->{chatnet};
		my @nicks = $channel->nicks();

		my %info = (
			'name' => $name,
			'chatnet' => $chatnet,
			'nicks' => scalar(@nicks),
			#'createtime' => strftime('%Y-%m-%d', localtime($channel->{createtime})),
		);
		push(@data, \%info);
	}

	# sort by channel size
	@data = sort {$a->{nicks} <=> $b->{nicks}} @data;

	my $peaks = readpeaks();

	my $pos = 1;
	foreach my $c (@data) {
		message(sprintf($format, $pos, $c->{name}, $c->{chatnet}, $c->{nicks}, $peaks->{$c->{chatnet}}{$c->{name}}->{peak})); #, $c->{createtime}));
		$pos++;
	}
}

# -----[ Commands ]-------------------------------------------------------------

Irssi::command_bind('topchannels', 'cmd_topchannels');

# -----[ Signal hooks ]---------------------------------------------------------

# -----[ Settings ]-------------------------------------------------------------

# -----[ Setup ]----------------------------------------------------------------

# -----[ -----------------------------------------------------------------------

