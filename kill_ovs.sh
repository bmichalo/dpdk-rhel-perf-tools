#!/bin/bash

killall -q -w ovs-vswitchd
killall -q -w ovsdb-server
killall -q -w ovsdb-server ovs-vswitchd

