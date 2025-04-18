package syntora.servlet;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.SQLException;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import syntora.db.DBConnection;

@WebServlet("/addRemark")
public class AddRemarkServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("username") == null) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }

        String rollNumber = request.getParameter("rollNumber");
        String remark = request.getParameter("remark");
        String username = (String) session.getAttribute("username");

        // Input validation
        if (rollNumber == null || rollNumber.trim().isEmpty() ||
            remark == null || remark.trim().isEmpty()) {
            response.sendRedirect(request.getContextPath() +
                                 "/pages/facultyDashboard.jsp?status=invalidInput#remarks");
            return;
        }

        try (Connection conn = DBConnection.getConnection()) {
            String sql = "INSERT INTO remarks (student_id, faculty_id, remark, date) " +
                         "SELECT s.id, f.id, ?, CURDATE() " +
                         "FROM students s " +
                         "JOIN faculty f ON f.user_id = (SELECT id FROM users WHERE username = ?) " +
                         "WHERE s.roll_number = ?";
            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setString(1, remark);
            ps.setString(2, username);
            ps.setString(3, rollNumber);

            int rowsAffected = ps.executeUpdate();
            if (rowsAffected > 0) {
                response.sendRedirect(request.getContextPath() +
                                     "/pages/facultyDashboard.jsp?status=success#remarks");
            } else {
                response.sendRedirect(request.getContextPath() +
                                     "/pages/facultyDashboard.jsp?status=notFound#remarks");
            }
        } catch (SQLException e) {
            System.err.println("Database error: " + e.getMessage()); // Replace with proper logging
            response.sendRedirect(request.getContextPath() +
                                 "/pages/facultyDashboard.jsp?status=error#remarks");
        }
    }
}