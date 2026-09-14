# EKS Model Deployment

First, i pushed the Docker image to docker hub.

Then, i created an EKS cluster in AWS.

![Created Cluster](screenshots/created%20cluster.png)

Then, i created a node group inside the cluster.

![Created Node Group](screenshots/created%20node%20group.png)

now i have 2 EC2 instances
![EC2 instances](screenshots/Ec2%20instances.png)

image for the 2 nodes:
![nodes](screenshots/2%20nodes.png)

Then, i connected `kubectl` to the cluster and applied the YAML files.

Then, i installed Traefik using Helm to route external requests.

After that, i applied `ingress.yml` to define the routing rules.

Test request:

![Request Example](screenshots/request%20example.png)