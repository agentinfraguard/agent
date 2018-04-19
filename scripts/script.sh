for j in ap-southeast-1 us-west-1 ap-northeast-1
do
# For linux instances
aws ec2 describe-instances --region $j --profile bastionrc --query 'Reservations[].Instances[?Platform!=`windows`].[InstanceId]' --output text > linuxInstances

instanceList=$(cat linuxInstances)

suffix=$(date +%Y%m%d%H%M)
filenameLinux="linuxInstanceNoCustomMetrics.$j.$suffix"

for i in $instanceList; do b=$(aws cloudwatch list-metrics --region $j --profile bastionrc --namespace System/Linux --dimensions Name=InstanceId,Value=$i --query 'Metrics[].[MetricName]' --output text); if [ -z "$b" ]; then b='empty'; fi; echo $i $b; done > linuxInstanceCustomStatus

cat linuxInstanceCustomStatus | grep -i empty | cut -f 1 -d ' ' > $filenameLinux

# For windows instances
aws ec2 describe-instances --region $j --profile bastionrc --query 'Reservations[].Instances[?Platform==`windows`].[InstanceId]' --output text > windowsInstances

instanceList=$(cat windowsInstances)

filenameWindows="windowsInstanceNoCustomMetrics.$j.$suffix"

for i in $instanceList; do b=$(aws cloudwatch list-metrics --region $j --profile bastionrc --namespace System/Windows --dimensions Name=InstanceId,Value=$i --query 'Metrics[].[MetricName]' --output text); if [ -z "$b" ]; then b='empty'; fi; echo $i $b; done > windowsInstanceCustomStatus

cat windowsInstanceCustomStatus | grep -i empty | cut -f 1 -d ' ' > $filenameWindows

done​
