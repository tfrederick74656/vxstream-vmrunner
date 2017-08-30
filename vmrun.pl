#########################################################################
# vmrun Wrapper for VxStream Sandbox					#
# Version 2.00, Updated 08/29/2018					#
# © Tyler Frederick (tyler.frederick@securityriskadvisors.com)		#
#########################################################################

# Global Modifiers
require 5.010_001;
use strict;
use warnings;
use feature 'switch';
no if ($] >= 5.018), 'warnings' => 'experimental';

# Runtime Constants 
use constant VMRUN_PATH => $ARGV[0];
use constant LOG_FILE   => $ARGV[1];
use constant LOG_LEVEL  => $ARGV[2];
use constant LOG_LEVEL_NONE  => 0;
use constant LOG_LEVEL_ERROR => 1;
use constant LOG_LEVEL_WARN  => 2;
use constant LOG_LEVEL_INFO  => 3;
use constant LOG_LEVEL_DEBUG => 4;
use constant COMMAND_LIST => 'start|stop|reset|suspend|pause|unpause|listSnapshots|snapshot|deleteSnapshot|revertToSnapshot|runProgramInGuest|fileExistsInGuest|directoryExistsInGuest|setSharedFolderState|addSharedFolder|removeSharedFolder|enableSharedFolders|disableSharedFolders|listProcessesInGuest|killProcessInGuest|runScriptInGuest|deleteFileInGuest|createDirectoryInGuest|deleteDirectoryInGuest|createTempfileInGuest|listDirectoryInGuest|copyFileFromHostToGuest|copyFileFromGuestToHost|renameFileInGuest|captureScreen|writeVariable|readVariable|getGuestIPAddress|vprobeVersion|vprobeLoad|vprobeLoadFile|vprobeReset|vprobeListProbes|vprobeListGLobals|list|upgradevm|installTools|checkToolsState|register|unregister|listRegisteredVM|deleteVM|clone';
use constant CMDLIST_NOARGS => 'start|stop|reset|suspend|pause|unpause|listSnapshots|enableSharedFolders|disableSharedFolders|listProcessesInGuest|killProcessInGuest|CreateTempfileInGuest|getGuestIPAddress|vprobeVersion|vprobeReset|vprobeListProbes|vprobeListGLobals|list|upgradevm|installTools|checkToolsState|register|unregister|listRegisteredVM|deleteVM';
use constant CMDLIST_STRAIGHTARGS => 'start|stop|reset|suspend|listSnapshots|enableSharedSolders|disableSharedFolders|killProcessInGuest|getGuestIPAddress';
use constant CMDLIST_QUOTESONLY => 'snapshot|revertToSnapshot|fileExistsInGuest|directoryExistsInGuest|removeSharedFolder|deleteFileInGuest|createDirectoryInGuest|deleteDirectoryInGuest|listDirectoryInGuest|captureScreen|vprobeLoad|vprobeLoadFile';
use constant CMDLIST_COPYFILE => 'copyFileFromHostToGuest|copyFileFromGuestToHost';
use constant CMDLIST_RUNPROGRAM => 'runProgramInGuest';

# Initialize Logging
my $log;
if(LOG_LEVEL > LOG_LEVEL_NONE) {
	open($log, '>>', LOG_FILE) or die "Error: Logging Failed\n";
}
logMsg (LOG_LEVEL_WARN, 'LOG', 'Session Started at '.localtime.". Log level: ".LOG_LEVEL);
sub logMsg {
        my ($msgLevel, $msgHeader, $msgBody) = @_;
        chomp $msgBody;
        if (defined $log && LOG_LEVEL >= $msgLevel) {
		say $log time." $msgLevel $msgHeader: $msgBody";
	}
}
sub logExit {
        logMsg (LOG_LEVEL_WARN, 'LOG', 'Session Completed at '.localtime);
        close $log;
}

# Parse Arguments
logMsg (LOG_LEVEL_DEBUG, 'PRS', 'Starting Phase: Parse Arguments');
my $cmdList = COMMAND_LIST;
my ($inputArgs, $athArgs, $cmdName, $vmxPath, $cmdArgs);
$inputArgs .= "$_ " foreach @ARGV;
logMsg (LOG_LEVEL_INFO, 'PRS', "Input arguments: $inputArgs");
if ($inputArgs =~ /^[^ ]+ [^ ]+ \d (?<athArgs>.+) (?<cmdName>$cmdList)(?: +(?<vmxPath>.+?\.vm(?:x|dk)) *(?: (?<cmdArgs>.+?))?)? *$/) {
	$athArgs = $+{athArgs};
	$cmdName = $+{cmdName};
	$vmxPath = $+{vmxPath};
	$cmdArgs = $+{cmdArgs};
	if (defined $athArgs) { logMsg(LOG_LEVEL_DEBUG, 'PRS', "athArgs: $athArgs"); }
	if (defined $cmdName) { logMsg(LOG_LEVEL_DEBUG, 'PRS', "cmdName: $cmdName"); }
	if (defined $vmxPath) { logMsg(LOG_LEVEL_DEBUG, 'PRS', "vmxPath: $vmxPath"); }
	if (defined $cmdArgs) { logMsg(LOG_LEVEL_DEBUG, 'PRS', "cmdArgs: $cmdArgs"); }
} else {
	logMsg (LOG_LEVEL_ERROR, 'PRS', 'Malformed argument list. Exiting.');
	logExit();
	die "Error: Malformed Argument List\n";
}


# Build Output String
logMsg (LOG_LEVEL_DEBUG, 'BOS', 'Starting Phase: Build Output String');

sub addQuotes {
        my $input = "\"".shift."\"";
	logMsg (LOG_LEVEL_DEBUG, 'QOT', "addQuotes returns $input");
	return $input;
}
my $outputArgs = "$athArgs $cmdName";
logMsg (LOG_LEVEL_DEBUG, 'BOS', "Processing coreArgs: $outputArgs");
if (defined $vmxPath && $vmxPath =~ m/^(\[.+\] .+\/.+)_.+\.vmdk$/) {
	$outputArgs .= " ".addQuotes("$1.vmx");
	logMsg (LOG_LEVEL_DEBUG, 'BOS', "Processing vmxPath: $outputArgs")
}
my $cmdListNoArgs = CMDLIST_NOARGS;
my $cmdListStraightArgs = CMDLIST_STRAIGHTARGS;
my $cmdListQuotesOnly = CMDLIST_QUOTESONLY;
my $cmdListCopyFile = CMDLIST_COPYFILE;
my $cmdListRunProgram = CMDLIST_RUNPROGRAM;
for ($cmdName) {
	when (/$cmdListNoArgs/) {
		logMsg(LOG_LEVEL_DEBUG, 'BOS', "Processing cmdListNoArgs: $outputArgs");
	}
	when (/$cmdListStraightArgs/) {
		$outputArgs .= " $cmdArgs";
		logMsg(LOG_LEVEL_DEBUG, 'BOS', "Processing cmdListStraightArgs: $outputArgs");
	}
	when (/$cmdListQuotesOnly/) {
		$outputArgs .= " ".addQuotes($cmdArgs);
		logMsg(LOG_LEVEL_DEBUG, 'BOS', "Processing cmdListQuotesOnly: $outputArgs");
	}
	when (/$cmdListCopyFile/) {
		if ($cmdArgs =~ /(?:^(\/.+) (C:.+)$|^(C:.+) (\/.+))/) {
			$outputArgs .= " ".addQuotes($1)." ".addQuotes($2);
		}
		logMsg(LOG_LEVEL_DEBUG, 'BOS', "Processing cmdListCopyFile: $outputArgs");
	}
	when (/$cmdListRunProgram/) {
		if($cmdArgs =~ /^(.+) (\/c C:.+)/) {
			$outputArgs .= " $1 ".addQuotes($2);
		}
		logMsg(LOG_LEVEL_DEBUG, 'BOS', "Processing cmdListRunProgram: $outputArgs");
	}
	default { 
		logMsg(LOG_LEVEL_ERROR, 'BOS', "Command $cmdName not implemented. Exiting.");
		logExit();
		exit "Error: Command Not Implemented\n";
	}
}
logMsg(LOG_LEVEL_INFO, 'BOS', "Output String: $outputArgs");

# Call vmrun and Patch Return
logMsg (LOG_LEVEL_DEBUG, 'RUN', 'Starting run block');
my $vmrPath = VMRUN_PATH;
logMsg (LOG_LEVEL_INFO, 'RUN', "Executing vmrun: $vmrPath $outputArgs");
my $returnIn = `$vmrPath $outputArgs`;
logMsg (LOG_LEVEL_DEBUG, 'RUN', "vmrun returned: $returnIn");
my $returnOut = "";
my @lines = split /\n/, $returnIn;
foreach my $line (@lines) {
	$_ = $line;
	s/(\[)(.+\/)(.+\] .+\/.+)(\.vm)(x)/$1$3_0-000001$4dk/;
	$returnOut .= "$_\n";
}
chomp $returnOut;
logMsg (LOG_LEVEL_INFO, 'RUN', "Return value: $returnOut");
print $returnOut, "\n";

# Cleanup and Exit
logExit();
exit 0;
