<jsp:directive.tag language="java" pageEncoding="UTF-8" />
<%@ attribute name="name" type="java.lang.String" required="true"%>
<div id="userInfo">
	<style>
		table {
			border-collapse: collapse;
			border: 1px solid black;
		}
		th, td {
			padding: 4px;
			border: 1px solid black;
		}
		th {
			text-align: right;
		}
	</style>
	<h1><%=name%></h1>
	<table>
		<tbody>
			<tr>
				<th>request.getRemoteUser()</th>
				<td><%=request.getRemoteUser()%></td>
			</tr>
			<tr>
				<th>request.getUserPrincipal().getClass().getName()</th>
				<td><%=request.getUserPrincipal() == null ? "UserPrincipal==null" : request.getUserPrincipal().getClass().getName()%></td>
			</tr>
			<tr>
				<th>request.isUserInRole("Admins")</th>
				<td><%=request.isUserInRole("Admins")%></td>
			</tr>
			<tr>
				<th>request.isUserInRole("Users")</th>
				<td><%=request.isUserInRole("Users")%></td>
			</tr>
		</tbody>
	</table>
</div>
