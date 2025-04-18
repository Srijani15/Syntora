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
import javax.servlet.http.HttpSession;
import syntora.db.DBConnection;

@WebServlet("/sendNotification")
@SuppressWarnings("serial")
public class SendNotificationServlet extends HttpServlet {
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        // Get parameters
        String userType = request.getParameter("userType");
        String department = request.getParameter("department");
        String year = request.getParameter("year");
        String message = request.getParameter("message");
        HttpSession session = request.getSession();
        String username = (String) session.getAttribute("username"); // Ensure username is from session
        int senderId = -1;

        // Validate inputs
        if (userType == null || userType.trim().isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/pages/adminNotifications.jsp?error=Recipient_type_is_required");
            return;
        }
        userType = userType.trim().toLowerCase();
        if (!userType.matches("^(all|student|faculty)$")) {
            response.sendRedirect(request.getContextPath() + "/pages/adminNotifications.jsp?error=Invalid_recipient_type");
            return;
        }
        if (message == null || message.trim().isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/pages/adminNotifications.jsp?error=Message_is_required");
            return;
        }

        // Get sender ID
        try {
            senderId = getUserId(username);
        } catch (SQLException e) {
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/pages/adminNotifications.jsp?error=SQL_error_getting_sender_" + e.getMessage().replace(" ", "_"));
            return;
        }

        if (senderId == -1) {
            response.sendRedirect(request.getContextPath() + "/pages/adminNotifications.jsp?error=Invalid_sender");
            return;
        }

        Connection conn = null;
        try {
            conn = DBConnection.getConnection();
            conn.setAutoCommit(false); // Start transaction

            String sql = "";
            if ("all".equals(userType)) {
                sql = "INSERT INTO notifications (sender_id, user_id, user_type, department, message, date) VALUES (?, NULL, ?, ?, ?, CURDATE())";
                try (PreparedStatement ps = conn.prepareStatement(sql)) {
                    ps.setInt(1, senderId);
                    ps.setString(2, userType); // Set validated userType
                    ps.setString(3, department);
                    ps.setString(4, message);
                    ps.executeUpdate();
                }
            } else {
                sql = "SELECT id FROM users WHERE role = ? " +
                      (userType.equals("student") ? "AND department = ? " + (year != null && !year.equals("all") ? "AND year = ?" : "") : "AND department = ?");
                try (PreparedStatement psSelect = conn.prepareStatement(sql)) {
                    psSelect.setString(1, userType);
                    int paramIndex = 2;
                    if (userType.equals("student") && !department.equals("all")) {
                        psSelect.setString(paramIndex++, department);
                        if (year != null && !year.equals("all")) psSelect.setString(paramIndex, year);
                    } else if (!department.equals("all")) {
                        psSelect.setString(paramIndex, department);
                    }
                    try (ResultSet rs = psSelect.executeQuery()) {
                        while (rs.next()) {
                            int userId = rs.getInt("id");
                            sql = "INSERT INTO notifications (sender_id, user_id, user_type, department, message, date) VALUES (?, ?, ?, ?, ?, CURDATE())";
                            try (PreparedStatement psInsert = conn.prepareStatement(sql)) {
                                psInsert.setInt(1, senderId);
                                psInsert.setInt(2, userId);
                                psInsert.setString(3, userType); // Set validated userType
                                psInsert.setString(4, department);
                                psInsert.setString(5, message);
                                psInsert.executeUpdate();
                            }
                        }
                    }
                }
            }

            conn.commit(); // Commit transaction
            response.sendRedirect(request.getContextPath() + "/pages/adminNotifications.jsp");
        } catch (SQLException e) {
            if (conn != null) {
                try {
                    conn.rollback(); // Rollback on error
                } catch (SQLException ex) {
                    ex.printStackTrace();
                }
            }
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/pages/adminNotifications.jsp?error=SQL_error_" + e.getMessage().replace(" ", "_"));
        } catch (Exception e) {
            if (conn != null) {
                try {
                    conn.rollback(); // Rollback on general error
                } catch (SQLException ex) {
                    ex.printStackTrace();
                }
            }
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/pages/adminNotifications.jsp?error=General_error_" + e.getMessage().replace(" ", "_"));
        } finally {
            if (conn != null) {
                try {
                    conn.setAutoCommit(true);
                    conn.close();
                } catch (SQLException e) {
                    e.printStackTrace();
                }
            }
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