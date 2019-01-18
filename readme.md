
## Status

This project is a partial fork from [Henry Zhang's](https://github.com/hainingzhang/) [Fabric_on_K8s](https://github.com/hainingzhang/articles/tree/master/fabric_on_kubernetes/Fabric-on-K8S/setupCluster) project, that has been optimized to deploy [Hyperledger Fabric](https://github.com/hyperledger/fabric) to Microsoft's [Azure Kubernetes Service](https://docs.microsoft.com/en-us/azure/aks/)

Deployment Guide developed from Henry's excellent article series [located here](https://hackernoon.com/how-to-deploy-hyperledger-fabric-on-kubernetes-1-a2ceb3ada078).

## Hyperledger Fabric

Hyperledger Fabric is a platform for distributed ledger solutions, underpinned
by a modular architecture delivering high degrees of confidentiality,
resiliency, flexibility and scalability. It is designed to support pluggable
implementations of different components, and accommodate the complexity and
intricacies that exist across the economic ecosystem.

Hyperledger Fabric delivers a uniquely elastic and extensible architecture,
distinguishing it from alternative blockchain solutions. Planning for the
future of enterprise blockchain requires building on top of a fully-vetted,
open source architecture; Hyperledger Fabric is your starting point.

## Requirements

[Azure Subscription](https://portal.azure.com) with access to deploy a Storage Account, AKS, and if using VNET, rights to create a VNET or use a subnet with an existing VNET.

[Azure Storage Account](https://docs.microsoft.com/en-us/azure/storage/) using [Azure Files](https://docs.microsoft.com/en-us/azure/storage/files/storage-files-introduction)

[Azure-CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli?view=azure-cli-latest)

[kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/) which can be installed from the Azure-CLI as well

[Python3.5](https://www.python.org/downloads/)

A [Code Editor](https://code.visualstudio.com/Download)

Not Required, but nice to have - [Storage Explorer](https://go.microsoft.com/fwlink/?LinkId=708343&clcid=0x409)

## Deployment steps

Create an Azure Subscription if you don't have one.  Link above will allow signup for a 30 day free trial. 

Install the prerequesites per their documentation

Log into Azure with Azure-CLI:
```
    az login 
```

Open the deployAzure.sh script in a code editor and change the values of the variables marked CHANGEME

Run deployAzure.sh
```
    bash deployAzure.sh
```

Install the kubectl app on your system if it's not already installed. 
```
    az aks install-cli
```

Check access to your cluster
```
    kubectl get namespaces
```
This should return the default and system namespaces running on the cluster

Open the deployPVSecret.sh and edit the variables marked CHANGEME and save.  Run this script to create the Kubernetes storage secret needed for where we will stage our files
```
    bash deployPVSecret.sh
```

Open the generateAll.sh and edit variables marked CHANGEME
Run generateAll.sh
```
    bash generateAll.sh
```
This will generate yaml template artifacts that we can use to deploy to our Kubernetes cluster along with ca and msp keys.  It will also uplaod these files to your Azure Storage Files shares.   It uses logic from cluster-config.yaml to build a 2 org blockchain network with a single orderer organization.  If you want to add/extend the number of organizations, modify cluster-config.yaml according to Harry's documentation listed above. 

Run run.py to deploy the configured 
```
    python3.5 ./transform/run.py
```

Check your running config
```
    kubectl get pods --all-namespaces
```
You should now see pods running in namespaces for the ordererorg, org1 and org2 if cluster-config.yaml hasn't been modified. 

## TODO

- Add steps for loading the chaincode
- Make org names for Azure resources reflect what is in cluster-config.yaml


## License <a name="license"></a>

Hyperledger Project source code files and binaries are made available under the Apache License, Version 2.0 (Apache-2.0), located in the [LICENSE](LICENSE) file. Hyperledger Project documentation files are made available under the Creative Commons Attribution 4.0 International License (CC-BY-4.0), available at http://creativecommons.org/licenses/by/4.0/.


The source in this project is covered under MIT and Apache licenses.