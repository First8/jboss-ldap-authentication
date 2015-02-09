#!/bin/bash

SCRIPTDIR=`dirname $0`

tar czvf ${SCRIPTDIR}/../jboss-ldap-authentication.tar.gz --exclude-vcs ${SCRIPTDIR}/../jboss-ldap-authentication
