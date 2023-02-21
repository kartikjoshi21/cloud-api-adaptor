#!/bin/bash

set -o errexit

printHelp(){

cat << CMD
   Usage: $0 <cmd> [<args>]
   args:
      -name                      The name of the cluster which you want to create.
      -resource_group            The resource group name.
      -subscription_id           subscription id of azure portal
      -client_secret       	 client secret for azure login
      -client_id           	 client id for azure login
      -tenant_id           	 tenant id for azure login
   Sample Usage:

      ./delete_aks_cluster.sh name="testcluster" resource_group="akcluster" 
CMD

   exit 0

}

echo "args:"$@

if [[ -z $@ ]]; then
   printHelp
fi

for arg in "$@"
do
  key=$(echo $arg | cut -f1 -d=)
  value=$(echo $arg| cut -f2 -d=)
  case "$key" in
     name)
        cluster_name=$value
        ;;
     resource_group)
        resource_group=$value
        ;;
     subscription_id)
        subscription_id=$value
        ;;
     client_id)
        client_id=$value
        ;;
     client_secret)
        client_secret=$value
        ;;
     tenant_id)
        tenant_id=$value
        ;;
      -help)
         printHelp
         ;;
     *)
        echo "Ignoring unexpected arg $arg"
   esac
done

if [[ -z $cluster_name ]]; then
    echo 'Please set name arg to the name of the Cluster you want to create.'
    exit 99
fi

if [[ -z $resource_group ]]; then
    echo 'Please set resource_group arg to the resource group in which you want to create aks cluster'
    exit 99
fi

echo "deleting aks cluster"
az aks delete --resource-group "${resource_group}" --name "${cluster_name}"
