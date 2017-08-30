#########################################################################
# vmrun Wrapper for VxStream Sandbox					#
# Version 0.80, Updated 08/29/2018					#
# © Tyler Frederick (tyler.frederick@securityriskadvisors.com)		#
#########################################################################

use strict;
use warnings;
use feature "switch";
no if ($] >= 5.018), 'warnings' => 'experimental';
print "\n";

# Declare Variables
my ($args, $hostType, $hostName, $hostUser, $hostPass, $guestUser, $guestPass, $cmdName, $cmdParm, $vmxPath);
$args = "", $hostType = "", $hostName = "", $hostUser = "", $hostPass = "", $guestUser = "", $guestPass = "", $cmdName = "", $cmdParm = "", $vmxPath = "";

# Parse Input String
$args .= "$_ " foreach @ARGV;
if($args =~ /^-T (?<hostType>ws|server|server1|fusion|esx|vc|player) +-h (?<hostName>(?:25[0-5]\.|2[0-4][0-9]\.|[01]?[0-9]{1,2}\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-9]{1,2})|[a-zA-Z0-9](?:[-a-zA-Z0-9]{0,61}[a-zA-Z0-9])?) +-u (?<hostUser>[a-z][-a-z0-9_]*) +-p (?<hostPassword>[^ ]+)(?: +-gu (?<guestUser>[a-z][-a-z0-9_]*) +-gp (?<guestPassword>[^ ]+))? +(?i)(?<commandName>start|stop|reset|suspend|pause|unpause|listSnapshots|snapshot|deleteSnapshot|revertToSnapshot|runProgramInGuest|fileExistsInGuest|directoryExistsInGuest|setSharedFolderState|addSharedFolder|removeSharedFolder|enableSharedFolders|disableSharedFolders|listProcessesInGuest|killProcessInGuest|runScriptInGuest|deleteFileInGuest|createDirectoryInGuest|deleteDirectoryInGuest|CreateTempfileInGuest|listDirectoryInGuest|CopyFileFromHostToGuest|CopyFileFromGuestToHost|renameFileInGuest|captureScreen|writeVariable|readVariable|getGuestIPAddress|vprobeVersion|vprobeLoad|vprobeLoadFile|vprobeReset|vprobeListProbes|vprobeListGLobals|list|upgradevm|installTools|checkToolsState|register|unregister|listRegisteredVM|deleteVM|clone)(?-i)(?: +(?<vmxPath>.+?\.vm(?:x|dk)) *(?: (?<commandParameters>.+?))?)? *$/) {
	$hostType = $+{hostType};
	$hostName = $+{hostName};
	$hostUser = $+{hostUser};
	$hostPass = $+{hostPassword};	
	$guestUser = $+{guestUser};
	$guestPass = $+{guestPassword};
	$cmdName = $+{commandName};
	$cmdParm = $+{commandParameters};	
	$vmxPath = $+{vmxPath};
} else {
	print "Error: The parameters included are incorrect. Verify that all arguments required for the speficied command are included.", "\n";
	exit(1);
}

# Build Output String - Essential Parameters
my $output = "-T $hostType -h $hostName -u $hostUser -p $hostPass";
if(defined $guestUser && $guestUser ne "" && defined $guestPass && $guestPass ne "") {$output .= " -gu $guestUser -gp $guestPass";}
$output .= " $cmdName";
if(lc($cmdName) ne "list" && lc($cmdName) ne "listregisteredvm") {
	if($vmxPath =~ /(\[[a-zA-Z0-9]+\] [a-zA-Z0-9]+\/[a-zA-Z0-9]+)_[0-9]-[0-9]{6}\.vmdk/) {$vmxPath = "$1.vmx";}
	if($vmxPath !~ /^\".+\"$/) {$vmxPath = addQuotes($vmxPath);}
	$output .= " $vmxPath";
}

# Build Output String - Command-Specific Parameters
for (lc($cmdName)) {
	when ("list" || "listregisteredvm") {}
	when ("pause" || "unpause" || "listprocessesinguest" || "createtempfileinguest" || "vprobeversion" || "vprobereset" || "vprobelistprobes" || "vprobelistglobals" || "upgradevm" || "installtools" || "checktoolsstate" || "register" || "unregister" || "deletevm") {}
	when ("start" || "stop" || "reset" || "suspend" || "listsnapshots" || "enablesharedfolders" || "disablesharedfolders" || "killprocessinguest" || "getguestipaddress" || "snapshot" || "reverttosnapshot") { ... }
	when ("deletesnapshot") { ... }
	default { ... }
}

print $output, "\n";
run();

sub addQuotes {my $input = "\"".shift."\"";}
sub run {
	my $return = system("/usr/bin/vmrun $output");
	print $return;
}

#print "\n$output\n\n";
print "\n\n";
