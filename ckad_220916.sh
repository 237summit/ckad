sudo mkdir -p /data/ckad/build/apache-php/
#AWS EC2
#sudo chown -R ubuntu.ubuntu /data
#sudo usermod -a -G docker ubuntu

#VMWare VM
sudo chown -R user.user /data
sudo usermod -a -G docker user

# master


# exam set
# 2
kubectl create namespace presales


touch /opt/REPORT/2022/broken.txt /opt/REPORT/2022/error.txt
kubectl label node k8s-worker1 disktype=ssd gpu=true 
kubectl label node k8s-worker2 disktype=std


#4
kubectl run probe-pod --image=smlinux/web:probe --port 80
kubectl expose pod probe-pod --type=NodePort --target-port=80 --port=80

#5
kubectl create namespace production
kubectl create deployment app-deploy -n production --image=nginx --port=80 --replicas=2
kubectl create serviceaccount app-ac -n production 

#6
cat <<END > /data/ckad/ckad-cron.yaml
apiVersion: batch/v1
kind: Job
metadata:
  name: ckad
spec:
  template:
    spec:
      containers:
      - name: ckad
        image: busybox
        command:
        - /bin/sh
        - -c
        - uname; sleep 100
END

# 7
cat <<END > /data/ckad/build/apache-php/Dockerfile 
FROM ubuntu:20.04
ENV DEBIAN_FRONTEND=noninteractive
RUN  apt update && \
   apt install apache2 php libapache2-mod-php  -y
COPY index.php /var/www/html/index.php
EXPOSE 80
CMD ["apachectl", "-DFOREGROUND"]
END

cat <<END > /data/ckad/build/apache-php/index.php 
<?php phpinfo(); ?>
END

# 8
kubectl create namespace devops

#10
cat <<END > /data/ckad/web-deployment.yaml
apiVersion: apps/v1beta1
kind: Deployment
metadata:
  name: web-deployment
  labels:
    app: appjs
spec:
  replicas: 3
  selector:
    app: appjs
  template:
    metadata:
      labels:
        app: appjs
    spec:
      containers:
      - name: appjs
        image: smlinux/appjs
        ports:
        - containerPort: 8080
END

#12
cat <<EOF | kubectl apply -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: eshop-order
  namespace: devops
spec:
  replicas: 2
  selector:
    matchLabels:
      name: order
  template:
    metadata:
      name: order
      labels:
        name: order
    spec:
      containers:
      - name: nginx-container
        image: nginx:1.14
EOF


#13
cat <<END > /data/ckad/user-pod.yaml
apiVersion: v1
kind: Pod
metadata:
  name: user-pod
spec:
  containers:
  - name: alpine
    image: alpine
    command: ["/bin/sleep", "999999"]
END

#14
cat <<EOF | kubectl apply -f -
---
apiVersion: v1
kind: Namespace
metadata:
  name: migops
  labels:
    team: migops

---
# NetworkPolicy
kind: Pod
apiVersion: v1
metadata:
  name: web
  namespace: migops
  labels:
    app: webwas
    tier: frontend
spec:
  containers:
  - name: web
    image: smlinux/cent-mysql:v1
    command: ["/bin/bash"]
    args: ["-c", "while true; do echo hello; sleep 10;done"]

---
kind: Pod
apiVersion: v1
metadata:
  name: cache
  namespace: migops
  labels:
    app: webwas
    tier: application
spec:
  containers:
  - name: was
    image: smlinux/cent-mysql:v1
    command: ["/bin/bash"]
    args: ["-c", "while true; do echo hello; sleep 10;done"]
EOF

cat <<EOF | kubectl apply -f -
kind: Pod
apiVersion: v1
metadata:
  name: was
  namespace: migops
  labels:
    app: webwas
    tier: application
spec:
  containers:
  - name: was
    image: smlinux/cent-mysql:v1
    command: ["/bin/bash"]
    args: ["-c", "while true; do echo hello; sleep 10;done"]

---
kind: Pod
apiVersion: v1
metadata:
  name: db
  namespace: migops
spec:
  containers:
    - name: db
      image: mysql:5.7
      env:
      - name: MYSQL_ROOT_PASSWORD
        value: pass

---
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: webwas-network-policy
  namespace: migops
spec:
  ingress:
  - from:
    - podSelector:
        matchLabels:
          app: webwas
          tier: application
    ports:
    - port: 3306
      protocol: TCP
  podSelector:
    matchLabels:
      app: webwas
      tier: database
  policyTypes:
  - Ingress
  - Egress

EOF




#15
cat <<END > /data/ckad/deployment-ckad.yaml 
apiVersion: apps/v1
kind: Deployment
metadata:
  name: deployment-ckad
spec:
  replicas: 1
  selector:
    matchLabels:
      app: deployment-ckad
  template:
    metadata:
      labels:
        app: deployment-ckad
    spec:
      volumes:
      - name: tmplog
        emptyDir: {}

      containers:
      - image: busybox:stable
        name: main
        command: ["/bin/sh", "-c", "while [ true ]; do echo 'hello ckad' >> /tmp/log/input.log; sleep 10; done" ]
        volumeMounts:
        - name: tmplog
          mountPath: /tmp/log
END

cat <<END > /data/ckad/fluentd-conf-configmap.yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: fluent-conf
data:
  fluent.conf: |
    <source>
      @type tail
      <parse>
        @type none
      </parse>
      path /tmp/log/*
      path_key filename
      tag backend.application
    </source>
END

kubectl apply -f /data/ckad/fluentd-conf-configmap.yaml

---
#16
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Pod
metadata:
  name: sleeper
spec:
  containers:
  - command:
    - sleep
    - "1000000"
    image: ubuntu
    name: sleeper
EOF

echo "==================END================="

