#!/bin/bash
#./check.sh
#
# Copyright (c) 2015 Midokura SARL, All Rights Reserved.
#
# - check an OpenStack cloud for typical user mistakes when setting up the MidoNet plugin
#
# This script will try to autodetect your server based on:
# - operating system type
# - installed packages

#
# check Ubuntu installation
#
check_ubuntu () {
    echo "002: checking Ubuntu"

    return
}

#
# check RedHat installation
#
check_redhat () {
    echo "003: checking RedHat"

    #
    # check if this is a neutron controller
    #
    if [[ ! "" == "$(yum list installed openstack-neutron 2>/dev/null | grep -v '^Loaded plugins:')" ]]; then
        echo "this server has openstack-neutron package installed, assuming its a neutron controller"

        echo "checking for midonet packages on this controller."
        echo "if this fails then one or more packages or services is missing from this machine."

        for PACKAGE in midolman python-midonetclient python-neutron-plugin-midonet; do
            echo "checking for package ${PACKAGE}"
            yum list installed "${PACKAGE}" 2>/dev/null | grep "^${PACKAGE}" || exit 1
        done

        #
        # check core plugin
        #
        if [[ "" == "$(grep ^core_plugin /etc/neutron/neutron.conf 2>/dev/null | grep 'midonet.neutron.plugin.MidonetPluginV2')" ]]; then
            echo "your neutron.conf does not have the correct core_plugin defined."
            exit 1
        fi

        #
        # check the softlink
        #
        if [[ "" == "$(readlink /etc/neutron/plugin.ini 2>/dev/null | grep /etc/neutron/plugins/midonet/midonet.ini)" ]]; then
            echo "your /etc/neutron/plugin.ini either does not exist or does not point to the midonet.ini."
            exit 1
        fi

        #
        # check if the plugin file exists
        #
        if [[ ! -f /etc/neutron/plugins/midonet/midonet.ini ]]; then
            echo "your /etc/neutron/plugins/midonet/midonet.ini plugin file does not exist."
            exit 1
        fi

        #
        # check if the api defined in the midonet.ini is reachable and if the user and password works
        #
        URI="$(grep ^midonet_uri /etc/neutron/plugins/midonet/midonet.ini  | awk -F= '{print $2;}' | xargs -n1 echo)"

    fi

    return
}


#
# main
#

echo "Welcome to Kaizen, the Midokura system checker"

# find out if we are in Redhat or an Ubuntu system
echo "001: checking for LSB release"
test -f /etc/lsb-release && source /etc/lsb-release

if [[ -f /etc/lsb-release ]]; then

    eval $(grep ^DISTRIB_ID /etc/lsb-release | xargs -n1 echo export)

    if [[ "Ubuntu" == "${DISTRIB_ID}" ]]; then
        THIS_IS_UBUNTU="1"
    fi
else
    if [[ -f "/etc/redhat-release" ]]; then
        THIS_IS_REDHAT="1"
    fi
fi

if [[ "1" == "${THIS_IS_UBUNTU}" || "1" == "${THIS_IS_REDHAT}" ]]; then

    if [[ "1" == "${THIS_IS_UBUNTU}" && "1" == "${THIS_IS_REDHAT}" ]]; then
        echo "your box is saying it runs Ubuntu and Redhat. this is wrong."
        exit 1
    fi

    if [[ "1" == "${THIS_IS_UBUNTU}" ]]; then
        check_ubuntu
    fi


    if [[ "1" == "${THIS_IS_REDHAT}" ]]; then
        check_redhat
    fi

else
    echo "unsupported operating system"
    exit 1
fi

exit 0
