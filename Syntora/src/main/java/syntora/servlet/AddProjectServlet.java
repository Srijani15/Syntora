package syntora.servlet;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import syntora.db.DBConnection;

@WebServlet("/addProject")
@SuppressWarnings("serial")
public class AddProjectServlet extends HttpServlet {
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String username = (String) request.getSession().getAttribute("username");
        String title = request.getParameter("title");
        String description = request.getParameter("description");
        String githubLink = request.getParameter("githubLink");

        if (username == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        if (title == null || title.trim().isEmpty() || description == null || description.trim().isEmpty()) {
            response.sendRedirect("studentDashboard.jsp?tab=projects&status=invalidInput");
            return;
        }

        if (githubLink != null && !githubLink.isEmpty() && !githubLink.startsWith("https://github.com/")) {
            response.sendRedirect("studentDashboard.jsp?tab=projects&status=invalidLink");
            return;
        }

        try (Connection conn = DBConnection.getConnection()) {
            String sql = "INSERT INTO projects (student_id, title, description, status, github_link) " +
                         "VALUES ((SELECT id FROM students WHERE user_id = (SELECT id FROM users WHERE username = ?)), ?, ?, 'Pending', ?)";
            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setString(1, username);
            ps.setString(2, title);
            ps.setString(3, description);
            ps.setString(4, githubLink != null && !githubLink.isEmpty() ? githubLink : null);
            ps.executeUpdate();
            ps.close();
            response.sendRedirect("studentDashboard.jsp?tab=projects&status=success");
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("studentDashboard.jsp?tab=projects&status=error");
        }
    }
}