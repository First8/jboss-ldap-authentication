# jboss-ldap-authentication
Test authentication within JBoss using LDAP as the source of your users and grouping using Java-EE only.

This code is based on the following starting-points:
* [Configure JBoss with LDAP](http://www.mastertheboss.com/jboss-server/jboss-security/configure-jboss-with-ldap) of [ACME Labs](http://acme.com/software/)
* [JBoss AS7 Security Auditing](https://developer.jboss.org/wiki/JBossAS7SecurityAuditing)

## LDAP as authentication-source
Lightweight Directory Access Protocol is a protocol to communicate with a directory. Yes, simple as that. But how then can it be a source of authentication? Often companies store usernames in a server that can be accessed via LDAP. They also group these users to organize them and grant them access to services. Such Directories are often hierarchical. They place users in one tree and groups in an other. Or they group users in organizationalUnits.

LDAP servers identify all object within it using a DN (=Distinguished Name). These DN's identify the object and its position in the tree. For example DN `uid=joep,ou=People,dc=first8,dc=nl` will place the object `uid=joep` under organizationalUnit People within the domain first8 within domain nl.

Each object can have specific classes. Each class adds a set of attributes to an object. Some of these attributes are required to be set others are optional. Many of them allow multiple values to be set. For example the `person`-class will require `cn`- and `sn`-attributes and the `groupOfNames`-class will require `member`-attributes.

Using ldif-files one can store stuff outside the context of a LDAP-server. Within this project there is an example-ldif-file that contains users & roles used in this example application. We will later import this data.

## Setup ApacheDS
A LDAP-server that is easy to setup on your desktop is ApacheDS. As an example we will setup a domain called first8.nl (DN: dc=first8, dc=nl). To setup such a domain one has to tell ApacheDS to handle a partition for this. For this the server has to be configured. Within Apache Directory Studio one can simply double-click the LDAP-server in the 'LDAP Servers'-tab and select the 'Partitions'-tab. Here click the 'Add' button and fill-in an 'ID' (first8) and a 'suffix' (dc=first8,dc=nl). Then save the configuration. Now a restart is needed: Stop and Start the server from the 'LDAP Servers'-tab.

### Load the ldif
To load a simple set of data one can load the ldif-file from the src/data-dir (first8.nl.ldif). This will add the roles 'Admins' & 'Users' to the dc=first8, dc=nl tree. It will also add the users admin, joep & piet to the tree. For your convinience they all have the password 'secret'.

## Settings
To make this example work one has to configure the JBoss.

### logging
To see if any authentication happens, it is handy to turn on authentication-logging. This can be done by adding this snipit into the standalone.xml in section `<subsystem xmlns="urn:jboss:domain:logging:1.1">`:
```xml
<periodic-rotating-file-handler name="AUDIT">
    <level name="TRACE"/>
    <formatter>
	<pattern-formatter pattern="%d{HH:mm:ss,SSS} %-5p [%c] (%t) %s%E%n"/>
    </formatter>
    <file relative-to="jboss.server.log.dir" path="audit.log"/>
    <suffix value=".yyyy-MM-dd"/>
</periodic-rotating-file-handler>
<logger category="org.jboss.security.audit">
    <level name="TRACE"/>
    <handlers>
	<handler name="AUDIT"/>
    </handlers>
</logger>
```
This will create a file called `audit.log` within the logs-dir.

### LDAP connection
The LDAP connection is configured in the `<subsystem xmlns="urn:jboss:domain:security:1.1">` section of the standalone.xml inside the `<security-domains>`-tag.

We configure a connection to the ApacheDS server running on localhost. We use the default security-credentials used of ApacheDS: user `uid=admin,ou=system` and its password `secret`.

To find the users, a search will be done under the tree starting at `ou=People,dc=first8,dc=nl` and then the attribute `uid` is used. But to map a user to a group/role, a search is done under the `ou=Roles,dc=first8,dc=nl`-tree and the `member`-attribute is used find the DN of the user. Then the `cn`-attribute is taken from that object to function as the `security-role`-name. Which in turn is mapped to the `security-role` as mentioned in the next section.

Here's the complete snipit:
```xml
<security-domain name="First8-LDAP">
    <authentication>
	<login-module code="LdapExtended" flag="required">
	    <module-option name="java.naming.factory.initial" value="com.sun.jndi.ldap.LdapCtxFactory"/>
	    <module-option name="java.naming.provider.url" value="ldap://localhost:10389"/>
	    <module-option name="java.naming.security.authentication" value="simple"/>
	    <module-option name="bindDN" value="uid=admin,ou=system"/>
	    <module-option name="bindCredential" value="secret"/>
	    <module-option name="baseCtxDN" value="ou=People,dc=first8,dc=nl"/>
	    <module-option name="baseFilter" value="(uid={0})"/>
	    <module-option name="rolesCtxDN" value="ou=Roles,dc=first8,dc=nl"/>
	    <module-option name="roleFilter" value="(member={1})"/>
	    <module-option name="roleAttributeID" value="cn"/>
	    <module-option name="searchScope" value="ONELEVEL_SCOPE"/>
	    <module-option name="allowEmptyPasswords" value="false"/>
	</login-module>
    </authentication>
</security-domain>
```

## Mapping in jboss-web.xml & web.xml
Within the application in the `jboss-web.xml`-file the `security-domain`-tag links the security-domain of the application to the security-domain in your standalone.xml.

In the `web.xml` we specify which security-role's there are. And then we specify which login-config to use: BASIC. As a last step we specify which roles can access which url-patterns using the security-constraint allowing only certain HTTP-methods. With this one can make some parts read-only by only allowing GET-methods.

## Application
The example application is very crude: visit any of these pages to show the UserPrincipal:
* /jboss-ldap-authentication/admin/index.jsp - accessable only to Admins-group users
* /jboss-ldap-authentication/users/index.jsp - accessable only to Users-group users
* /jboss-ldap-authentication/all/index.jsp - accessable Users-group users & Admins-group users
* /jboss-ldap-authentication/free/index.jsp - accessable to even users that are not logged in
You will need to restart you browser to login as a different user. This is a property of the BASIC-HTTP-authentication mechanism.
