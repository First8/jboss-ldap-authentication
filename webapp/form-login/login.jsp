<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<title>Login</title>
</head>
<body>
	<form method="POST" action='<%= response.encodeURL("j_security_check") %>' >
		<table>
			<tr>
				<th>Username</th>
				<td><input type="text" name="j_username"></td>
			</tr>
			<tr>
				<th>Password</th>
				<td><input type="password" name="j_password"></td>
			</tr>
			<tr>
				<th>&nbsp;</th>
				<td><input type="submit" value="Login" /></td>
			</tr>
		</table>
	</form>
</body>
</html>