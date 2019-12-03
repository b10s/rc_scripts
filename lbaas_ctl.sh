#!/bin/bash

# token to access LBAAS API (12h alive)
#TODO: call script with init --token and tenant options
#  so it will put toket into env var or on disk /tmp (ensure what is better)
#TODO: check requirements: jq, curl, availability of the resource
#TODO: print usage
#TODO: get yaml with definition
#TODO: dry run with yaml output

token=""

TENANT="one-click"
# create a proper VIP usign the following IPs of master nodes:
master_ip_1="172.20.169.154"
master_ip_2="172.20.169.176"
master_ip_3="172.20.169.59"
master_port="6443"
server_group_name="one_click_srv_grp_lux"
load_balancer_name="one_click_lb_lux"



get_tenants () {
  curl -s -X GET "https://lbaas.r-local.net/tenants" -H  "accept: application/json" -H  "Authorization: $token" | jq
}

get_server_group () {
  local server_group="$1"
  curl -s -X GET "https://lbaas.r-local.net/tenants/$TENANT/server_groups/$server_group" -H  "accept: application/json" \
    -H  "Authorization: $token" | jq
}

# creates or updates server group
create_server_group () {
  local input=''
  local server_group="$1"
  local protocolo="{'protocol':'http','servers':["
  #TODO: many servers
  local srv_cnt=3
  echo "how many servers? (default: 3)"
  read input
  ! [[ -z $input ]] && srv_cnt="$input"
  #echo "$srv_cnt"
  declare -a servers
  #TODO: server name shoud be uniq
  for ((i=0;i<$srv_cnt;i++)); do
    local srv_name='master'
    local srv_ip='1.1.1.1'
    local srv_port=123
    echo "server name? (default: $srv_name)"
    read input
    ! [[ -z $input ]] && srv_name="$input"
    echo "server ip? (default: $srv_ip)"
    read input
    ! [[ -z $input ]] && srv_ip="$input"
    echo "server port? (default: $srv_port)"
    read input
    ! [[ -z $input ]] && srv_port="$input"
    
    servers+=( "{'name':'$srv_name','ip':'$srv_ip','port':$srv_port,'max_connections':100,'enabled':true}" )
  done
  local IFS=','
  #echo "${servers[*]}"
  #return
  local servers_par="${servers[*]}"
  local parameters2="],'health_check_type':'tcp',"
  local parameters3="'health_check_tcp':{'port':123}}"
  res="${protocolo}${server_groups}${servers_par}${parameters2}${parameters3}"
  res=$(echo "$res" | sed "s/'/\"/g")
  echo "$res"
  #TODO: check result
  curl -s -X PUT "https://lbaas.r-local.net/tenants/$TENANT/server_groups/$server_group" -H  "accept: application/json" \
    -H  "Authorization: $token" -H  "Content-Type: application/json" \
    -d "${res}" | jq
}

delete_server_group () {
  local server_group="$1"
  curl -s -X DELETE "https://lbaas.r-local.net/tenants/$TENANT/server_groups/$server_group" -H  \
    "accept: application/json" -H  "Authorization: $token" | jq
}


create_load_balancer () {
  local lb_name="$1"
  # for now - 2019 Dec 3 - only jpe2a DC is supported
  local dc='jpe2a'
  local param="{'data_center':'$dc','internet':'private','listeners':["
  declare -a listeners
  for ((i=0;i<1;i++)); do
    listeners+=( "{'port':80,'protocol':'http','forwarding_rules':[{'type':'default','server_group_name':'$server_group'}]}" )
  done
  local end="]}"
  local IFS=','
  local res="${param}${listeners[*]}${end}"
  res=$(echo "$res" | sed "s/'/\"/g")
  #echo "$res"
  #return

  curl -s -X PUT "https://lbaas.r-local.net/tenants/$TENANT/load_balancers/$lb_name" -H  "accept: application/json" \
    -H  "Authorization: $token" -H  "Content-Type: application/json" \
    -d "$res" | jq
    
 #   {\"port\":80,\"protocol\":\"http\",\"forwarding_rules\":[{\"type\":\"path_match\",\"rule\":\"/my_app/v1\",\"server_group_name\":\"my-server-group\"},{\"type\":\"host_match\",\"rule\":\"domain.com\",\"server_group_name\":\"my-other-server-group\"},{\"type\":\"default\",\"server_group_name\":\"my-default-server-group\"}]}
 #   ,{\"port\":443,\"protocol\":\"https\",\"forwarding_rules\":[{\"type\":\"default\"}],\"tls\":{\"certificates\":[{\"common_name\":\"*.rdcnw.net\"},{\"common_name\":\"*.r-local.net\"}]}}
 #   ]}"
}

delete_load_balancer () {
  local lb_name="$1"
  curl -s -X DELETE "https://lbaas.r-local.net/tenants/$TENANT/load_balancers/$lb_name" -H  "accept: application/json" -H  "Authorization: $token" | jq
}

die () { echo "ERR: $*" >&2; exit 1; }

# Usage info
show_help() {
cat << EOF
Usage: ${0##*/} [COMMAND]
Manages Load Balancer using LBAAS API

COMMANDS:
    -h                                              Display this help and exit
    -st|--show-tenants                              Shows tenants, server groups, load balancers, gslbs
    -ssg|--show_srv_group SERVER_GROUP_NAME         Shows the details of the server group
    -csg|--create_srv_group SERVER_GROUP_NAME       Creates the server group
    -dsg|--delete_srv_group SERVER_GROUP_NAME       Deletes the server group
    -clb|--create_load_balancer LOAD_BALANCER_NAME  Creates the load balancer
    -dlb|--delete_load_balancer LOAD_BALANCER_NAME  Deletes the load balancer
    -v                                              Verbose mode. Can be used multiple times for increased
                                                    verbosity.
EOF
}

main () {
  local usage="USAGE:"
  while :; do
      case "$1" in
        -h) show_help; ;;
        -st|--show-tenants) get_tenants; exit; ;;
        -dlb|--delete_load_balancer)
          if [ "$2" ]; then
            delete_load_balancer "$2";
            shift
          else
            die 'expect lb name'
          fi
          exit
          ;;
        -dsg|--delete_srv_group)
          if [ "$2" ]; then
            delete_server_group "$2";
            shift
          else
            die 'expect server group name'
          fi
          exit
          ;;
        -clb|--create_load_balancer)
          if [[ -n "$2" ]] && [[ -n "$3" ]]; then
          #if [ 1 ]; then
            create_load_balancer "$2" "$3"
            shift 2
          else
            die 'expect load balancer and server group names'
          fi
          exit
          ;;
        -csg|--create_srv_group)
          if [ "$2" ]; then
            create_server_group "$2";
            shift
          else
            die 'expect server group name'
          fi
          exit
          ;;
        -ssg|--show_srv_group)
          if [ "$2" ]; then
            get_server_group "$2";
            shift
          else
            die 'expect server group name'
          fi
          exit
          ;;
        -?*) die 'unknown option'; ;;
        *) break
      esac
    shift
  done
  show_help
}

main "$@"
