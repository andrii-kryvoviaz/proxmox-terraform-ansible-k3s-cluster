[master]
${k3s_master_ips}

[node]
${k3s_node_ips}

[k3s_cluster:children]
master
node