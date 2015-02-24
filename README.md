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

### Keycloak connection
To setup Keycloak to connect to your LDAP-server, you have to configure 'Federation'. This is done in the Users-page of your realm. First specify a name. Then fill-in if your want to sync the user-actions (like 'update password' & 'register user') to your LDAP. Then you have to specify the Connection URL. This is normally in the form of 'ldap://<ip-addres>:<port>'. Next you have to specify a Base DN. For the first8-domain this is 'dc=first8,dc=nl'. Furthermore you have to give the 'User DN Suffix' to indicate where the users are. In the case of first8 this is 'ou=People,dc=first8,dc=nl'. Finaly you have to specify `Bind DN` & `Bind Credential` which in case of a default Apache Directory Server is 'uid=admin,ou=system'/'secret'. Some of there steps can be checked using the 'Test *'-buttons next the the input boxes.

Now your application has to be registered in Keycloak. Keycloak needs to know which applications are authorized to connect and where to redirect again. The things to fill-in are: a name (eg. `jboss-ldap-authentication`), a `Redirect URI` (in our case `http://<your-host>:<port>/jboss-ldap-authentication/*`, mind the '*' at the end) and an `Admin URL` (for the JBoss-adapter this is the top-level of the war: `http://<your-host>:<port>/jboss-ldap-authentication`)

### JBoss part
To use Keyclock in JBoss an adaptor module needs to be installed. Download the adapter and extract it in the JBoss base-dir. Then register the adapter in the standalone.xml as described in chapter '8.2. JBoss/Wildfly Adapter' of the Keycloak-manual. NB: when using Keycloak in JBoss 7.1.1, the extension-name is slightly different.
To connect to Keycloak, two things need to be done per war. One: one has to set the `login-config/auth-method` to `KEYCLOAK` in `web.xml`. Two: one has to add `keycloak.json` to the `WEB-INF` directory. The content of the `keycloak.json`-file can be obtained from the application-page within you realm-configuration-page in Keycloak under the tab-page 'Installation'.

The default `keycloak.json`-file from the 'Installation'-page yields a UUID from the LDAP-server's item as the `request.RemoteUser`. This should be unique but surely does not look nice. One can specify a different attribute to take as the 'principal' by specifying a `principal-attribute` in the `keycloak.json`-file. Possible values are 'sub', 'preferred_username', 'email', 'name', 'nickname', 'given_name', 'family_name' as can be found in the manual chapter 8.1.

### Roles
Within Keycloak, one has to configure the roles that are defined in the `web.xml` and assign these roles to all appropriate users. Default roles can be setup that will apply to all your LDAP-users so you only have to manually handle the special cases.

## Logout
The logout with Keycloak is a two-step thing. The session within JBoss has to expire or be invalidated. And the session with Keycloak has to expire or be invalidated. If the JBoss-session has expired before the Keycloak one, the user will be auto-logged-in again by Keycloak. To sync this the LogoutServlet will invoke the 'logout()' of the current request and call the Keycloak-server to invalidate the session there.

## Mapping in jboss-web.xml & web.xml
Within the application in the `jboss-web.xml`-file the `security-domain`-tag links the security-domain of the application to the security-domain in your standalone.xml.

In the `web.xml` we specify which security-role's there are. And then we specify which login-config to use: BASIC. As a last step we specify which roles can access which url-patterns using the security-constraint allowing only certain HTTP-methods. With this one can make some parts read-only by only allowing GET-methods.

## Application
The example application is very crude: visit any of these pages to show the UserPrincipal:
* /jboss-ldap-authentication/admins/index.jsp - accessable only to Admins-group users
* /jboss-ldap-authentication/users/index.jsp - accessable only to Users-group users
* /jboss-ldap-authentication/all/index.jsp - accessable Users-group users & Admins-group users
* /jboss-ldap-authentication/free/index.jsp - accessable to even users that are not logged in
