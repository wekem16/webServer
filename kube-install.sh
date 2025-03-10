sudo swapoff -a

sudo modprobe overlay
sudo modprobe br_netfilter

sudo tee /etc/sysctl.d/kubernetes.conf<<EOF
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
net.ipv4.ip_forward = 1
EOF

sudo tee /etc/modules-load.d/k8s.conf <<EOF
overlay
br_netfilter
EOF

sudo sysctl --system

# Add Docker's official GPG key:
sudo apt-get update
sudo apt-get install apt-transport-https ca-certificates curl gpg -y
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc
 
# Add the repository to Apt sources:
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update

sudo apt-get install containerd.io

sudo mkdir -p /etc/containerd
sudo containerd config default | sudo tee /etc/containerd/config.toml >/dev/null 2>&1
sudo sed -i 's/SystemdCgroup \= false/SystemdCgroup \= true/g' /etc/containerd/config.toml
sudo sed -i 's/sandbox_image = "registry.k8s.io\/pause:3.*"/sandbox_image = "registry.k8s.io\/pause:3.9"/g' /etc/containerd/config.toml

sudo systemctl restart containerd
sudo systemctl enable containerd

echo 1 | sudo tee /proc/sys/net/ipv4/ip_forward
sudo sh -c "echo 'net.ipv4.ip_forward = 1' >> /etc/sysctl.conf"

sudo sysctl -p

sudo mkdir -p -m 755 /etc/apt/keyrings

curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.30/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg

echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.30/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list

sudo apt-get update
sudo apt-get install kubelet kubeadm kubectl -y
sudo apt-mark hold kubelet kubeadm kubectl

sudo systemctl enable --now kubelet
-------------------------------------------------------------------------------------------------

sudo kubeadm init --apiserver-advertise-address=172.31.16.124   --pod-network-cidr=10.244.0.0/16

wget https://github.com/weaveworks/weave/releases/download/v2.6.0/weave-daemonset-k8s-1.11.yaml


sed -i 's~rbac.authorization.k8s.io/v1beta1~rbac.authorization.k8s.io/v1~g'