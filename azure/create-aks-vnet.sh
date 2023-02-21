#!/bin/bash

set -e

printHelp(){

cat << CMD
   Usage: $0 <cmd> [<args>]
   args:
      -vnet_name                 The name of the vnet which you want to create.
      -vnet_prefix       	 Address prefix of the vnet
      -subnet_name		 subnet id for aks cluster
      -subnet_prefix       	 Address prefix of the subnet
      -resource_group            The resource group name.
      -subscription_id           subscription id of azure portal
      -client_secret       	 client secret for azure login
      -client_id           	 client id for azure login
      -tenant_id           	 tenant id for azure login
   Sample Usage:

      ./create_aks_vnet.sh  vnet_name="caa-vnet" vnet_prefix="192.168.0.0/16" subnet_name="caa-subnet" subnet_prefix="192.168.1.0/24" resource_group="akcluster" subscription_id="azure_subscription_id"  client_id="azure_client_id" client_secret="azure_client_secret" tenant_id="azure_tenant_id" 
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
     vnet_name)
        vnet_name=$value
        ;;
     vnet_prefix)
        vnet_prefix=$value
        ;;
     subnet_name)
        subnet_name=$value
        ;;
     subnet_prefix)
        subnet_prefix=$value
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

if [[ -z $vnet_name ]]; then
    echo 'Please set vnet_name arg to the name of the vnet you want to create.'
    exit 99
fi

if [[ -z $vnet_prefix ]]; then
    echo 'Please set location vnet_prefix to the prefix for vnet'
    exit 99
fi

if [[ -z $subnet_name ]]; then
    echo 'Please set subnet_name arg to the name of the subnet you want to create.'
    exit 99
fi

if [[ -z $subnet_prefix ]]; then
    echo 'Please set location subnet_prefix to the prefix for subnet'
    exit 99
fi

if [[ -z $resource_group ]]; then
    echo 'Please set resource_group arg to the resource group in which you want to create aks cluster'
    exit 99
fi

az network vnet create --resource-group "${resource_group}" --name "${vnet_name}" --address-prefix "${vnet_prefix}"   --subnet-name "${subnet_name} --subnet-prefix "${subnet_prefix}
