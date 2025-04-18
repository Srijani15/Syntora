package syntora.servlet;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
//import java.sql.ResultSet;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import syntora.db.DBConnection;

@WebServlet("/adminFaculty")
public class AdminFacultyServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String action = request.getParameter("action");
        String username = request.getParameter("username");
        String title = request.getParameter("title");
        String firstName = request.getParameter("first_name");
        String lastName = request.getParameter("last_name");
        String department = request.getParameter("department");

        try (Connection conn = DBConnection.getConnection()) {
            if ("create".equals(action)) {
                String sql = "INSERT INTO users (username, email, password, role, department) VALUES (?, ?, ?, 'faculty', ?)";
                PreparedStatement ps = conn.prepareStatement(sql);
                ps.setString(1, username);
                ps.setString(2, username + "@syntora.com");
                ps.setString(3, "default"); // Note: In production, use hashed passwords
                ps.setString(4, department);
                ps.executeUpdate();

                sql = "INSERT INTO faculty (user_id, title, first_name, last_name) " +
                      "SELECT id, ?, ?, ? FROM users WHERE username = ?";
                ps = conn.prepareStatement(sql);
                ps.setString(1, title);
                ps.setString(2, firstName);
                ps.setString(3, lastName);
                ps.setString(4, username);
                ps.executeUpdate();
            } else if ("update".equals(action)) {
                String sql = "UPDATE faculty f JOIN users u ON f.user_id = u.id SET f.title = ?, f.first_name = ?, f.last_name = ?, u.department = ? WHERE u.username = ?";
                PreparedStatement ps = conn.prepareStatement(sql);
                ps.setString(1, title);
                ps.setString(2, firstName);
                ps.setString(3, lastName);
                ps.setString(4, department);
                ps.setString(5, username);
                ps.executeUpdate();
            }
            response.sendRedirect("pages/adminManageFaculty.jsp?status=success&department=" + (department != null ? department : ""));
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("pages/adminManageFaculty.jsp?status=error&department=" + (department != null ? department : ""));
        }
    }

    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String action = request.getParameter("action");
        String username = request.getParameter("username");
        String department = request.getParameter("department");

        if ("delete".equals(action)) {
            try (Connection conn = DBConnection.getConnection()) {
                String sql = "DELETE f, u FROM faculty f JOIN users u ON f.user_id = u.id WHERE u.username = ?";
                PreparedStatement ps = conn.prepareStatement(sql);
                ps.setString(1, username);
                ps.executeUpdate();
                response.sendRedirect("pages/adminManageFaculty.jsp?status=success&department=" + (department != null ? department : ""));
            } catch (Exception e) {
                e.printStackTrace();
                response.sendRedirect("pages/adminManageFaculty.jsp?status=error&department=" + (department != null ? department : ""));
            }
        }
    }
}