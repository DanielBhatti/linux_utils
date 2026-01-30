set -euo pipefail

echo "date/host/kernel"
date
hostnamectl || true
uname -a

echo -e "\n===CPU"
lscpu

echo -e "\n===Memory"
free -h
grep -E 'MemTotal|MemFree|MemAvailable|SwapTotal|SwapFree' /proc/meminfo

echo -e "\n===Disk: Filesystem"
df -hT
df -i

echo -e "\n===Disk: Partitions"
lsblk -o NAME,TYPE,SIZE,FSTYPE,FSVER,MOUNTPOINTS,MODEL,SERIAL,ROTA,TRAN,SCHED

echo -e "\n===Disk (Kernel)"
cat /proc/partitions
sysctl vm.swappiness vm.dirty_background_ratio vm.dirty_ratio fs.file-mac 2>/dev/null || true
ulimit -n || true

echo -e "\n===Network: Links and Addresses"
ip -br link
ip -br addr

echo -e "\n===Network: Routes and DNS"
ip route
(resolvectl status || cat /etc/resolv.conf) 2>/dev/null || true

echo -e "\n===System Load/Uptime"
uptime
cat /proc/loadavg

echo -e "\n===Top Current Consumers: CPU"
ps -eo pid,ppid,user,comm,%cpu,%mem,rss --sort=-%cpu | head -n 20

echo -e "\n===Top Current Consumers: Memory"
ps -eo pid,ppid,user,comm,%cpu,%mem,rss --sort=-%mem | head -n 20

echo -e "Services/Containers"
(systemctl --no-pager --type=service --state=running | head -n 60) 2>/dev/null || true
(docker ps --format "table {{.ID}}\t{{.Names}}\t{{.Status}}\t{{.Image}}" | head -n 20) 2>/dev/null || true # can also check podman

echo -e "\n===Virtualization"
(systemd-detect-virt || true)
(dmesg | egrep -i 'hypervisor|kvm|vmware|xen' | tail -n 20) 2>/dev/null || true

