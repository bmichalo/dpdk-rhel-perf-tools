#!/bin/bash

killall -q -w ovs-vswitchd
killall -q -w ovsdb-server
killall -q -w ovsdb-server ovs-vswitchd
killall -q -w testpmd
rm -rf $ovs_run/ovs-vswitchd.pid
rm -rf $ovs_run/ovsdb-server.pid
rm -rf $ovs_etc/*db*

