package nl.first8.jboss.ldap.keycloak;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import javax.ws.rs.core.UriBuilder;
import java.io.IOException;
import java.util.logging.Level;
import java.util.logging.Logger;

@WebServlet("/LogoutServlet")
public class LogoutServlet extends HttpServlet {
    private static final Logger LOG = Logger.getLogger(LogoutServlet.class
            .getName());

    private static final long serialVersionUID = 1L;

    private static final String REALM_NAME = "first8";
    private static final String KEYCLOAK_BASE_URL = "http://10.200.1.55:8080";

    protected void doGet(HttpServletRequest request,
                         HttpServletResponse response) throws ServletException, IOException {
        LOG.log(Level.INFO, "Logging {0} out", request.getRemoteUser());
        request.logout();
        HttpSession session = request.getSession(false);
        if (session != null) {
            session.invalidate();
        }
        response.sendRedirect(getLogoutLocation(request));
        addNoCache(response);
    }

    private String getLogoutLocation(HttpServletRequest request) {
        UriBuilder uriBuilder = UriBuilder.fromPath(request.getContextPath())
                .scheme(request.getScheme())
                .host(request.getLocalName())
                .port(request.getLocalPort());
        String encodedRedirectUri = uriBuilder.build().toASCIIString();
        LOG.log(Level.INFO, "Redirect to {0}", encodedRedirectUri);

        return String.format("%s/auth/realms/%s/tokens/logout" +
                        "?redirect_uri=%s", //
                KEYCLOAK_BASE_URL, //
                REALM_NAME, //
                encodedRedirectUri);
    }

    private void addNoCache(HttpServletResponse response) {
        response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate"); // HTTP 1.1.
        response.setHeader("Pragma", "no-cache"); // HTTP 1.0.
        response.setDateHeader("Expires", 0); // Proxies.
    }
}
