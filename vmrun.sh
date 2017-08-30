# Connection String, Operation, Argument In
cs=`echo $@ | sed -r 's|(-T [^ ]+ -h [^ ]+ -u [^ ]+ -p [^ ]+)(.*)|\1|'`
op=`echo $@ | sed -r 's|(-T [^ ]+ -h [^ ]+ -u [^ ]+ -p [^ ]+) ([^ ]+)(.*)|\2|'`
ai=`echo $@ | sed -r 's|(-T [^ ]+ -h [^ ]+ -u [^ ]+ -p [^ ]+) ([^ ]+) (.*)|\3|'`

patch_vmx_path()
{
 a1=`echo $ai | sed -r 's|(\[[a-zA-Z0-9]+\] [a-zA-Z0-9]+\/[a-zA-Z0-9]+)(_[0-9]-[0-9]{6}.vmdk.*)|"\1.vmx"|'`
}

get_second_argument()
{
 a2=`echo $ai | sed -r 's|(.+\.vmdk )(.+)|\2|'`
}


# Get Argument Out
case $op in
 "list")
	out="$cs $op";;
 "start")
	patch_vmx_path
	get_second_argument
	out="$cs $op $a1 $a2";;
 "revertToSnapshot")
	patch_vmx_path
	get_second_argument
	a2=\"$a2\"
	out="$cs $op $a1 $a2";;
esac

rc=`wc -l /home/vxstream/vmrun.log | cut -c1`
if [ $rc -eq 6 ]
then
	eval /usr/bin/vmrun $out | grep "Total\|datastore2" | sed 's|: 2|: 1|' | sed 's|\[ha-datacenter\/datastore2\] VM1\/VM1.vmx|[datastore2] VM1/VM1_0-000001.vmdk|'
else
	eval /usr/bin/vmrun $out | grep "Total\|datastore2" | sed 's|: 2|: 1|'
fi

echo $@ >> /home/vxstream/vmrun.log
echo $out >> /home/vxstream/vmrun.log

#CMD=`echo $@ | sed -r 's|^(.*?) (\[[a-zA-Z0-9]+\] [a-zA-Z0-9]+\/[a-zA-Z0-9]+)(_[0-9]-[0-9]{6}.vmdk)|\1 "\2.vmx"|' | sed -r 's|(.*\.vmx") ([a-zA-Z0-9 ]+)$|\1 "\2"|'`
