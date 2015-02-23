<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ taglib prefix="util" tagdir="/WEB-INF/tags"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<title>LDAP Authentication in JBoss</title>
</head>
<body>
	<util:logout />
	<h1>LDAP Authentication in JBoss</h1>
	<p>This is an example application of logging-in in using an LDAP
		password-store.</p>
	<p>One can test access to these page-groups:
	<ul>
		<li>For <a href="./admins">admins</a></li>
		<li>For <a href="./users">users</a></li>
		<li>For <a href="./all">both admins & users</a></li>
		<li>For <a href="./free">anyone</a></li>
	</ul>
	</p>
</body>
</html>