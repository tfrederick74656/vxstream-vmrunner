# vxstream-vmrunner

### ABOUT
This is a tool to address two major bugs in [VxStream Sandbox](https://www.vxstream-sandbox.com/)'s support for VMware ESXi:
* Calls to the VMware VIX API binary (vmrun) are sent unquoted, which is typically fine for controlling VMware Workstation instances where pathnames are contiguous, but fails miserably when dealing with ESXi datastore paths, such as `[datastore1] VM1/VM1.vmx`.
* VxStream Sandbox seems to expect the 'vmrun list' command to return a full path to the VMDK file, instead of to the VMX file. In order for interaction to succeed, a return string such as `[ha-datastore/datastore1] VM1/VM1.vmx` needs to be patched to `[datastore1] VM1/VM1_0-000001.vmdk`.

### USAGE
* Follow all of the steps on [How to setup a VMWare guest](https://team.vxstream-sandbox.com/display/VSS/How+to+setup+a+VMWare+guest).
* Copy the vmrun.pl and vmrun.sh scripts to an appropriate location.
* Edit the vmrun.sh file and change `PERL_PATH`, `VMRUN_PATH`, and `SCRIPT_PATH` to reflect your environment. You may also optionally configure logging by setting the `LOG_PATH` and `LOG_LEVEL` parameters.
* Edit the `VxAnalysisController/vxstreamcontrol.properties` (or the .override file, depending on your configuration), and set `vmwareRunPath.Unix` to the location of the vmrun.sh file. E.x. `vmwareRunPath.Unix=/home/vxstream/vmrun.sh`.

### NOTES
* Tested on VxStream Sandbox 6.8.0, VMware VIX 1.14.5, Perl 5.22.1, and Ubuntu 16.04.3.
* Perl should be installed as part of the bootstrap installation scripts, but if not, install at least version 5.10.1.
* The script can be executed manually simply by passing it a vmrun argument list. E.x. `vmrun.sh -T esx -h hostname -u username -p password -gu guestuser -gp guestpassword copyFileFromHostToGuest, [datastore] VM/VM.vmx /some/local/file C:\remotefile`
* A list of supported commands is provided below. This is not inclusive of all vmrun commands, and may not account for all commands issued by VxStream.

### SUPPORTED COMMANDS
`captureScreen`, `checkToolsState`, `copyFileFromGuestToHost`, `copyFileFromHostToGuest`, `createDirectoryInGuest`, `CreateTempfileInGuest`, `deleteDirectoryInGuest`, `deleteFileInGuest`, `deleteVM`, `directoryExistsInGuest`, `disableSharedFolders`, `enableSharedFolders`, `fileExistsInGuest`, `getGuestIPAddress`, `installTools`, `killProcessInGuest`, `list`, `listDirectoryInGuest`, `listProcessesInGuest`, `listRegisteredVM`, `listSnapshots`, `pause`, `register`, `removeSharedFolder`, `reset`, `revertToSnapshot`, `runProgramInGuest`, `snapshot`, `start`, `stop`, `suspend`, `unpause`, `unregister`, `upgradevm`, `vprobeListGlobals`, `vprobeListProbes`, `vprobeLoad`, `vprobeLoadFile`, `vprobeReset`, `vprobeVersion`

### DISCLAIMER
THIS SOFTWARE IS PROVIDED "AS IS" AND ANY EXPRESSED OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE REGENTS OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
