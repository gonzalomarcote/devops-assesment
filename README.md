# devops-assesment
Gonzo's DevOps assesment

### 1. Docker-ayes
A Dockerfile that runs Litecoin 0.18.1 in a container.
I have been checking some info, specifically [here](https://github.com/uphold/docker-litecoin-core) and [here](https://github.com/NicolasDorier/docker-bitcoin), but just to gather some info to build the entrypoint script and finally I have created my own solution. 

Build it with: 
`docker build . -t "litecoin:0.18.1"` 

Run it with: 
`docker run --name my-litecoin -d -p 9332:9332 -p 9333:9333 -p 19332:19332 -p 19333:19333 -p 19444:19444 litecoin:0.18.1` 

You can check logs with: 
`docker logs my-litecoin -f` 

Push it and pull it to your favorite registry. In my case: 
`docker tag litecoin:0.18.1 0881XXXXXX.dkr.ecr.eu-west-1.amazonaws.com/stuff/litecoin:0.18.1` 
`docker push 0881XXXXXX.dkr.ecr.eu-west-1.amazonaws.com/stuff/litecoin:10.18.1` 

### 2. K8s FTW
Kubernetes StatefulSet to run the above, using persistent volume claims and resource limits. 

### 3. All the continuouses 
Asimple build and deployment pipeline for the above using groovy/Jenkinsfile, Travis CI or Gitlab CI. 
