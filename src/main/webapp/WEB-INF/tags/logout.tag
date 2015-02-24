<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<jsp:directive.tag language="java" pageEncoding="UTF-8" />
<div id="logout" style="float:right">
	<% if (request.getRemoteUser() != null) { %>
		<c:url value="/LogoutServlet" var="logoutUrl"/>
		<a href="${logoutUrl}">Logout</a>
	<% } else { %>
		Not logged in
	<% } %>
</div>
