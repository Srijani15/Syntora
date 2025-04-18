package syntora.servlet;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import syntora.db.DBConnection;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

@WebServlet("/login")
public class LoginServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String role = request.getParameter("role");
        String username = request.getParameter("username");
        String password = request.getParameter("password");

        try (Connection conn = DBConnection.getConnection()) {
            // CSRF Token Validation
            String csrfToken = request.getParameter("csrfToken");
            String sessionToken = (String) request.getSession().getAttribute("csrfToken");
            if (csrfToken == null || !csrfToken.equals(sessionToken)) {
                response.sendRedirect("login.jsp?error=true&message=Invalid CSRF Token");
                return;
            }

            // Query user from database
            String sql = "SELECT password FROM users WHERE username = ? AND role = ?";
            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setString(1, username);
            ps.setString(2, role);
            ResultSet rs = ps.executeQuery();

            if (rs.next()) {
                String storedPassword = rs.getString("password");
                if (password.equals(storedPassword)) {
                    HttpSession session = request.getSession();
                    session.setAttribute("username", username);
                    session.setAttribute("role", role);
                    session.setMaxInactiveInterval(30 * 60); // 30 minutes timeout

                    switch (role) {
                        case "student":
                            response.sendRedirect("studentDashboard.jsp");
                            break;
                        case "faculty":
                            response.sendRedirect("facultyDashboard.jsp");
                            break;
                        case "admin":
                            response.sendRedirect("adminDashboard.jsp");
                            break;
                        default:
                            response.sendRedirect("login.jsp?error=true&message=Invalid role");
                    }
                } else {
                    response.sendRedirect("login.jsp?error=true&message=Invalid credentials");
                }
            } else {
                response.sendRedirect("login.jsp?error=true&message=User not found");
            }
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("login.jsp?error=true&message=Server error");
        }
    }
}