package nl.first8.jboss.ldap.form;

import java.io.IOException;
import java.util.logging.Level;
import java.util.logging.Logger;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

@WebServlet("/LogoutServlet")
public class LogoutServlet extends HttpServlet {
	private static final Logger LOG = Logger.getLogger(LogoutServlet.class
			.getName());

	private static final long serialVersionUID = 1L;

	protected void doGet(HttpServletRequest request,
			HttpServletResponse response) throws ServletException, IOException {
		LOG.log(Level.INFO, "Logging {0} out", request.getRemoteUser());
		HttpSession session = request.getSession(false);
		if (session != null) {
			session.invalidate();
		}
		String referrer = request.getHeader("Referrer");
		if (referrer == null || referrer.trim().isEmpty()) {
			referrer = "./";
		}
		response.sendRedirect(referrer);
	}
}
