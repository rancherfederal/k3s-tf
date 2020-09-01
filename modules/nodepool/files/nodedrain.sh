#!/bin/bash
echo "Draining node"

/usr/local/bin/kubectl drain $(hostname -s) --ignore-daemonsets --delete-local-data --timeout=100s --force

echo "Deleting node"
/usr/local/bin/kubectl delete node $(hostname -s)

sleep 2
echo "Verifying node is deleted"
/usr/local/bin/kubectl get node $(hostname -s)
status=$?
count=0
while [ "${status}" -eq 0 ]
  do
    sleep 2
    ((count++))
    if [ "${count}" -ge 5 ]
      then
        echo "Node is still in the cluster, using --force and exiting"
        /usr/local/bin/kubectl delete node $(hostname -s) --force --grace-period=0
        break
    fi
    /usr/local/bin/kubectl get node $(hostname -s)
    status=$?
done