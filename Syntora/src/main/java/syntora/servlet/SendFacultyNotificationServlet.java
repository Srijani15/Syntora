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
        String username = (String) request.getSession().getAttribute("username");
        int senderId = -1;

        // Validate inputs
        if (department == null || department.trim().isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/pages/facultySendNotifications.jsp?error=Department_is_required");
            return;
        }
        if (year == null || year.trim().isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/pages/facultySendNotifications.jsp?error=Year_is_required");
            return;
        }
        if (message == null || message.trim().isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/pages/facultySendNotifications.jsp?error=Message_is_required");
            return;
        }

        // Get sender ID
        try {
            senderId = getUserId(username);
        } catch (SQLException e) {
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/pages/facultySendNotifications.jsp?error=SQL_error_" + e.getMessage().replace(" ", "_"));
            return;
        }

        if (senderId == -1) {
            response.sendRedirect(request.getContextPath() + "/pages/facultySendNotifications.jsp?error=Invalid_sender");
            return;
        }

        try (Connection conn = DBConnection.getConnection()) {
            String sql = "SELECT id FROM users WHERE role = 'student' " +
                         "AND department LIKE ? " + (year != null && !year.equals("all") ? "AND year = ?" : "");
            try (PreparedStatement psSelect = conn.prepareStatement(sql)) {
                psSelect.setString(1, department.equals("all") ? "%" : department);
                if (year != null && !year.equals("all")) psSelect.setString(2, year);
                try (ResultSet rs = psSelect.executeQuery()) {
                    boolean hasRecipients = false;
                    while (rs.next()) {
                        hasRecipients = true;
                        int userId = rs.getInt("id");
                        sql = "INSERT INTO notifications (sender_id, user_id, user_type, department, year, message, date) VALUES (?, ?, ?, ?, ?, ?, CURDATE())";
                        try (PreparedStatement psInsert = conn.prepareStatement(sql)) {
                            psInsert.setInt(1, senderId);
                            psInsert.setInt(2, userId);
                            psInsert.setString(3, "student");
                            psInsert.setString(4, department);
                            psInsert.setString(5, year);
                            psInsert.setString(6, message);
                            psInsert.executeUpdate();
                        }
                    }
                    if (!hasRecipients) {
                        response.sendRedirect(request.getContextPath() + "/pages/facultySendNotifications.jsp?error=No_matching_students_found");
                        return;
                    }
                }
            }
            response.sendRedirect(request.getContextPath() + "/pages/facultySendNotifications.jsp?success=Notification_sent");
        } catch (SQLException e) {
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/pages/facultySendNotifications.jsp?error=SQL_error_" + e.getMessage().replace(" ", "_"));
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/pages/facultySendNotifications.jsp?error=General_error_" + e.getMessage().replace(" ", "_"));
        }
    }

    private int getUserId(String username) throws SQLException {
        if (username == null) return -1;
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