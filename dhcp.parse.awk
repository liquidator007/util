#!/usr/bin/awk -f
#
# Author: Matt Pascoe - matt@opennetadmin.com
#
# This awk script is used to extract relavant information from a dhcpd.conf
# config file and build dcm.pl output with appropriate fields.  This can be
# used to bootstrap a new database from existing site data.
# As usual, inspect the output for accuracy.
# Also you will get three types of output, subnet,pool,host.  You must
# add the subnet information first, then pool, then host.

# Note that for hosts, it will try a reverse lookup on the IP address
# to determine an appropriate dns name
#
# USAGE:
# make this script executable with `chmod +x dhcpparse.awk` and then
#
#   cat dhcpd.conf|./dhcpparse.awk|sort




# set the RECORD SEPARATOR, RS, to "}" ... records span multiple lines
BEGIN {RS="}"}

# TODO: figure out how to skip comment lines without having to use sed first

length($0) > 5 { total++

  for(i=1;i<=NF;i++) {

    counter[total] = total

    # if this field matches the word "host"
    if($i ~ /^host$/) {
      type[total] = "host"
      hostname[total]=$(i+1)
      # Remove the trailing { that might be there
      gsub(/{/, "", hostname[total])
    }

    # if this field matches the word "hardware"
    else if($i ~ /^hardware$/) {

      # get rid of the trailing semi-colon
      split($(i+2),arr,";")

      mac[total]=arr[1]
    }

    # if this field matches the word "hardware"
    else if($i ~ /^fixed-address$/) {

      # get rid of the trailing semi-colon
      split($(i+1),arr,";")

      ip[total]=arr[1]
    }

    # if this field matches the word "subnet"
    else if($i ~ /^subnet$/) {

      type[total] = "subnet"
      # get rid of the enclosing quotes
      split($(i+1),arr,"\"")

      subnetip[total]=arr[1]
    }

    # if this field matches the word "netmask"
    else if($i ~ /^netmask$/) {

      subnetmask[total]=$(i+1)
    }

    # if this field matches the word "range"
    else if($i ~ /^range$/) {
      total++
      type[total] = "pool"
      poolstart[total]=$(i+1)
      # get rid of the trailing semi-colon
      split($(i+2),arr,";")
      poolend[total]=arr[1]
    }

    # if this field matches the word "failover"
    if($i ~ /^#failover$/) {
      # get rid of the enclosing quotes
      split($(i+2),arr,"\"")

      failover[total]=arr[2]
    }
  }



  # do a host command reverse lookup on the IP to try and find a dns name
  if( length(ip[total]) > 0 ) {
    command = ("host " ip[total])
    command | getline tmpname
    close(command)
    split(tmpname,n,"pointer")

    # trim off leading spaces etc
    gsub(/^[ \t]+/, "", n[2])

    name[total] = substr(n[2],0,length(n[2])-1)
  }

  if( length(name[total]) == 0 ) {
    gsub(/\./, "-", hostname[total])
    # This option turns the ip into a fake name
    #name[total]="dhcpload-" ip[total]

    # This option just uses the text found in the conf for host
    name[total]=hostname[total]
  }


}

# for every entry we captured, display its appropriate info
END { for(entry in counter) {
#         if(type[entry] == "subnet") {
#             printf("dcm.pl -r %s_add ip=%s netmask=%s name='DHCPLOAD-%s' type='LAN'\n",\
#                 type[entry],subnetip[entry],subnetmask[entry],subnetip[entry])
#         }
#         if(type[entry] == "pool") {
#             printf("dcm.pl -r dhcp_pool_add start=%s end=%s\n",\
#                 poolstart[entry],poolend[entry])
#         }
         if(type[entry] == "host") {
             printf("%s;%s;%s\n",\
                 ip[entry],mac[entry],name[entry])
         }
    }
}
