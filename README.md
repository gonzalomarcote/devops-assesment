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

I have not used `anchore` to scan image vulnerabilities. I have used AWS solution as it is quiet simple and it is integrated in the ECR. You just need to create like this to scan automatically images on push:  
`aws ecr create-repository --repository-name stuff/litecoin --image-scanning-configuration scanOnPush=true --region eu-west-1`

Tag it and push it:  
`docker tag litecoin:0.18.1 0881XXXXXX.dkr.ecr.eu-west-1.amazonaws.com/stuff/litecoin:0.18.1`
`docker push 0881XXXXXX.dkr.ecr.eu-west-1.amazonaws.com/stuff/litecoin:10.18.1`  

You can inspect vulnerabilities from the portal or with aws cli with:
`aws ecr describe-image-scan-findings --repository-name stuff/litecoin --image-id imageTag=0.18.1 --region eu-west-1`

As it have detected one High vulnerability with [glibc](https://security-tracker.debian.org/tracker/CVE-2021-33574), I have fixed it updating needed packages from testing sources because this is a new vulnerability and it has not been _backported_ yet to stable.

### 2. K8s FTW
Kubernetes StatefulSet to run the above, using persistent volume claims and resource limits. 
I have created one simple `litecoin.yaml` StatefulSet with one persistent volume for the previous litecoin container.  
I have also defined some limits to the container with a memory request of `256Mi` and a CPU ussage of ¼ of a core. And also I have set a sum of limited resources for all of its containers in the `limits` section.  

### 3. All the continuouses 
A simple build and deployment pipeline for the above using groovy/Jenkinsfile, Travis CI or Gitlab CI.  
As I am always using Jenkins and nowadays I am using GitHub Actions I have decided to build a simple pipeline in GitHub Actions to build and deploy the previous litecoin example. You can find it in `.github/workflows/ci.yaml` and have comments inline.  

Basically, it will do:  
* Execute on some specific branches
* Assign some variables according to the branches (master|main -> prod, develop -> dev, etc)
* Configure AWS credentials and log to AWS ECR
* Build, tag and push litecoin to AWS ECR
* Kubectl and Helm installation
* Execute my python script that parse secrets stored in Vault and populate them in Helm yaml chart
* Finally it install it deploy StatefulSet with helm

### 4. Script kiddies
I have one grep and aws example in the Dockerfile (plus ather extra things like variables expansion in bash):  
`RUN SUM=$(curl -s -i https://download.litecoin.org/litecoin-${LITECOIN_VERSION}/linux/litecoin-${LITECOIN_VERSION}-linux-signatures.asc | grep litecoin-${LITECOIN_VERSION}-x86_64-linux-gnu.tar.gz | awk '{print $1}') && echo "${SUM} litecoin.tar.gz" | sha256sum -c -`

Here, I `grep` for litecoin tar.gz SHA256 line in the asc file, I choose the first element with `awk` and I compare it with the previous downloaded litcoin tar.gz source.

### 5. Script grown-ups
I love Python, to automate things when Bash is not enough. In the script `tools/vaultValues.py` you can find one example of one Python program I did to parse one Helm yaml chart and look for the secrets in one Hashicorp Vault and populate them. There are some tricky things like loop nested dictionary.
I did in 18 months ago. Now I thing there are some  kind of _official_ solutions to do this, but not 2 years ago, so I did my own solution.  
I will be happy to explain it in a tech meeting. Feel free to use it if you find it useful.

#### 6. Terraform lovers unite
And I also loves Terraform and I work with it every day. Check `terraform` dir for the needed files.  
Sufix is populated depending on the env by the terraform workspace (prod, dev, qa, etc).
