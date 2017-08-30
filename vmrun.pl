#########################################################################
# vmrun Wrapper for VxStream Sandbox					#
# Version 1.00, Updated 08/29/2018					#
# © Tyler Frederick (tyler.frederick@securityriskadvisors.com)		#
#########################################################################

use strict;
use warnings;
use feature "switch";
no if ($] >= 5.018), 'warnings' => 'experimental';

my $vmrPath = "/usr/bin/vmrun";
my $logFile = "/home/vxstream/vmrunner.log";

my ($inpArgs, $athFlgs, $cmdName, $vmxPath, $cmdParm);
my $cmdList = "start|stop|reset|suspend|pause|unpause|listSnapshots|snapshot|deleteSnapshot|revertToSnapshot|runProgramInGuest|fileExistsInGuest|directoryExistsInGuest|setSharedFolderState|addSharedFolder|removeSharedFolder|enableSharedFolders|disableSharedFolders|listProcessesInGuest|killProcessInGuest|runScriptInGuest|deleteFileInGuest|createDirectoryInGuest|deleteDirectoryInGuest|createTempfileInGuest|listDirectoryInGuest|copyFileFromHostToGuest|copyFileFromGuestToHost|renameFileInGuest|captureScreen|writeVariable|readVariable|getGuestIPAddress|vprobeVersion|vprobeLoad|vprobeLoadFile|vprobeReset|vprobeListProbes|vprobeListGLobals|list|upgradevm|installTools|checkToolsState|register|unregister|listRegisteredVM|deleteVM|clone";

# Parse Input String
$inpArgs .= "$_ " foreach @ARGV;
if ($inpArgs =~ /^(?<athFlgs>.+) (?<cmdName>$cmdList)(?: +(?<vmxPath>.+?\.vm(?:x|dk)) *(?: (?<cmdParm>.+?))?)? *$/) {
	$athFlgs = $+{athFlgs};
	$cmdName = $+{cmdName};
	$vmxPath = $+{vmxPath};
	$cmdParm = $+{cmdParm};
} else {
	print "Error: Malformed Argument List", "\n";
	exit (1);
}


# Build Output String
my $output = "$athFlgs $cmdName";
if (defined $vmxPath && $vmxPath =~ m/^(\[.+\] .+\/.+)_.+\.vmdk$/) {
	$output .= " ".addQuotes("$1.vmx");
}
for ($cmdName) {
	when (/start|stop|reset|suspend|pause|unpause|listSnapshots|enableSharedFolders|disableSharedFolders|listProcessesInGuest|killProcessInGuest|CreateTempfileInGuest|getGuestIPAddress|vprobeVersion|vprobeReset|vprobeListProbes|vprobeListGLobals|list|upgradevm|installTools|checkToolsState|register|unregister|listRegisteredVM|deleteVM/) {}
	when (/start|stop|reset|suspend|listSnapshots|enableSharedSolders|disableSharedFolders|killProcessInGuest|getGuestIPAddress/) {
		$output .= " $cmdParm";
	}
	when (/snapshot|revertToSnapshot|fileExistsInGuest|directoryExistsInGuest|removeSharedFolder|deleteFileInGuest|createDirectoryInGuest|deleteDirectoryInGuest|listDirectoryInGuest|captureScreen|vprobeLoad|vprobeLoadFile/) {
		$output .= " ".addQuotes($cmdParm);
	}
	when (/copyFileFromHostToGuest|copyFileFromGuestToHost/) {
		if ($cmdParm =~ /(?:^(\/.+) (C:.+)$|^(C:.+) (\/.+))/) {
			$output .= " ".addQuotes($1)." ".addQuotes($2);
		}
	}
	when (/runProgramInGuest/) {
		if($cmdParm =~ /^(.+) (\/c C:.+)/) {
			$output .= " $1 ".addQuotes($2);
		}
	}
	default { 
		print "Error: Command Not Implemented", "\n";
		exit (2);
	}
}

my $return = `$vmrPath $output`;
my $print = fixReturn($return);
print $print, "\n";
writeLog();
exit (0);

sub addQuotes {
	my $input = "\"".shift."\"";
}

sub fixReturn {
	my $value = "";
	my @lines = split /\n/, shift;
	foreach my $line (@lines) {
		$_ = $line;
		print $line;
		s/(\[)(.+\/)(.+\] .+\/.+)(\.vm)(x)/$1$3_0-000001$4dk/;
		$value .= "$_\n";
	}
	print $value;
	chomp $value;
	print $value;
	return $value;
}

sub writeLog {
	open(my $fh, '>>', $logFile) or die "Error: Logging Failed";
	say $fh "Session Begin at ".localtime();
	say $fh "INP: $inpArgs";
	say $fh "OUT: $output";
	say $fh "RTN: $return";
	say $fh "PRT: ".shift; 
	close $fh;
}
