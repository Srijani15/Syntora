package syntora.servlet;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import syntora.db.DBConnection;

@WebServlet("/sendFacultyNotification")
@SuppressWarnings("serial")
public class SendFacultyNotificationServlet extends HttpServlet {
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String department = request.getParameter("department");
        String year = request.getParameter("year");
        String message = request.getParameter("message");
        String username = (String) request.getSession().getAttribute("username"); // Ensure username is from session
        int senderId = -1;

        // Handle SQLException for getUserId
        try {
            senderId = getUserId(username);
        } catch (SQLException e) {
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/pages/facultyNotifications.jsp?error=sql_" + e.getMessage().replace(" ", "_"));
            return;
        }

        if (senderId == -1) {
            response.sendRedirect(request.getContextPath() + "/pages/facultyNotifications.jsp?error=invalid_sender");
            return;
        }

        try (Connection conn = DBConnection.getConnection()) {
            String sql = "SELECT id FROM users WHERE role = 'student' " +
                         "AND department LIKE ? " + (year != null && !year.equals("all") ? "AND year = ?" : "");
            try (PreparedStatement psSelect = conn.prepareStatement(sql)) {
                psSelect.setString(1, department.equals("all") ? "%" : department);
                if (year != null && !year.equals("all")) psSelect.setString(2, year);
                try (ResultSet rs = psSelect.executeQuery()) {
                    while (rs.next()) {
                        int userId = rs.getInt("id");
                        sql = "INSERT INTO notifications (sender_id, user_id, user_type, department, message, date) VALUES (?, ?, ?, ?, ?, CURDATE())";
                        try (PreparedStatement psInsert = conn.prepareStatement(sql)) {
                            psInsert.setInt(1, senderId);
                            psInsert.setInt(2, userId);
                            psInsert.setString(3, "student");
                            psInsert.setString(4, department);
                            psInsert.setString(5, message);
                            psInsert.executeUpdate();
                        }
                    }
                }
            }
            response.sendRedirect(request.getContextPath() + "/pages/facultyNotifications.jsp");
        } catch (SQLException e) {
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/pages/facultyNotifications.jsp?error=sql_" + e.getMessage().replace(" ", "_"));
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/pages/facultyNotifications.jsp?error=general_" + e.getMessage().replace(" ", "_"));
        }
    }

    private int getUserId(String username) throws SQLException {
        if (username == null) return -1; // Handle null case
        try (Connection conn = DBConnection.getConnection()) {
            String sql = "SELECT id FROM users WHERE username = ?";
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setString(1, username);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) return rs.getInt("id");
                    return -1;
                }
            }
        }
    }
}