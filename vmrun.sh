#########################################################################
# vmrun Wrapper for VxStream Sandbox                                    #
# Version 2.10, Updated 08/30/2017                                      #
# © Tyler Frederick (tyler.frederick@securityriskadvisors.com)          #
#########################################################################

readonly PERL_PATH="/usr/bin/perl"		# Path to the Perl binary (5.10.1 or newer)
readonly VMRUN_PATH="/usr/bin/vmrun"		# Path to the VMware VIX API binary (vmrun)
readonly SCRIPT_PATH="/home/vxstream/vmrun.pl"	# Path to the vmrun.pl script
readonly LOG_PATH="/home/vxstream/vmrun.log"	# Path to a log file for the script
readonly LOG_LEVEL="0"				# 0 = None, 1 = Error, 2 = Warning/Basic, 3 = Info, 4 = Debug

$PERL_PATH "$SCRIPT_PATH" "$VMRUN_PATH" "$LOG_PATH" "$LOG_LEVEL" "$@"
