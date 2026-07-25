# 1. Scaffold a working starter chart (it deploys a sample nginx out of the box)
$ helm create hello

# 2. Look at what you got, then preview the rendered YAML WITHOUT installing
$ helm template ./hello | less
#  helm template shows how the files will look like after they get the values,so we make sure its 100% ready to get deployed

# 3. Check it for mistakes (typos, bad structure, missing values)
$ helm lint ./hello

# 4. Install it as a release named "hello-1", overriding a couple of values
$ helm install hello-1 ./hello --set replicaCount=2

# 5. Confirm it's running
$ helm list
$ helm status hello-1

# 6. Make a change and upgrade — creates revision 2
$ helm upgrade hello-1 ./hello --set replicaCount=4

# 7. Changed your mind — roll back to revision 1
$ helm rollback hello-1 1

# 8. When you're done, tear it all down
$ helm uninstall hello-1
