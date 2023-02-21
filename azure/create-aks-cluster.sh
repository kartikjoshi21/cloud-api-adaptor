#!/bin/bash

set -e
trap 'CleanupResources $? $LINENO' EXIT

CleanupResources() {
  if [ "$1" != "0" ]; then
    echo "Cleanup AKS cluster if created"
    az aks delete --name "${cluster_name}" --resource-group "${resource_group}"
  fi
}

printHelp(){

cat << CMD
   Usage: $0 <cmd> [<args>]
   args:
      -name                      The name of the cluster which you want to create.
      -location                  location to deploy aks cluster( like eastus)  
      -vm_size                   Size of the vm
      -ssh_key                   ssh-key to access aks 
      -resource_group            The resource group name.
      -subnet_id		 subnet id for aks cluster
      -subscription_id           subscription id of azure portal
      -client_secret       	 client secret for azure login
      -client_id           	 client id for azure login
      -tenant_id           	 tenant id for azure login
   Sample Usage:

      ./create_aks_cluster.sh name="testcluster" location="eastus" ssh_key="ssh-key"  resource_group="akcluster" subnet_id="/resources/mysubnetid" subscription_id="azure_subscription_id" client_id="azure_client_id" client_secret="azure_client_secret" tenant_id="azure_tenant_id" 
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
     ssh_key)
        ssh_key=$value
        ;;
     location)
        location=$value
        ;;
     subnet_id)
        subnet_id=$value
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


if [[ -z $location ]]; then
    echo 'Please set location arg to the location in which you want to create aks cluster'
    exit 99
fi

if [[ -z $ssh_key ]]; then
    echo 'Please set ssh_key arg to the ssh_key of aks cluster'
    exit 99
fi

if [[ -z $subnet_id ]]; then
    echo 'Please set location subnet_id to the subnet_id of the aks cluster'
    exit 99
fi

if [[ -z $resource_group ]]; then
    echo 'Please set resource_group arg to the resource group in which you want to create aks cluster'
    exit 99
fi




export ssh_key="~/.ssh/id_rsa.pub"

echo "creating aks cluster"
az aks create --resource-group "${resource_group}" --name "${cluster_name}" --location "${location}" --node-count 2 --node-vm-size "Standard_D8as_v5"  --admin-username "caa-aks" --vnet-subnet-id "${subnet_id}" --ssh-key-value="${ssh_key}" --os-sku Ubuntu --enable-node-public-ip

echo "Get k8s cluster credentials"
az aks get-credentials --resource-group "${RESOURCE_GROUP}" --name "${AKS_CLUSTER_NAME}" --overwrite-existing

echo  "Untaint and lebel nodes"
kubectl taint nodes --all node-role.kubernetes.io/control-plane-
kubectl label nodes --all node-role.kubernetes.io/worker=
kubectl wait --for=condition=Ready nodes --all --timeout=90s
kubectl get nodes -o wide
