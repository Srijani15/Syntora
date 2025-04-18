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
        String semester = request.getParameter("semester");
        String message = request.getParameter("message");
        HttpSession session = request.getSession();
        String username = (String) session.getAttribute("username");
        int senderId = -1;

        // Validate inputs
        if (userType == null || userType.trim().isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/adminDashboard.jsp?error=Recipient_type_is_required#sendNotifications");
            return;
        }
        userType = userType.trim().toLowerCase();
        if (!userType.matches("^(all|student|faculty)$")) {
            response.sendRedirect(request.getContextPath() + "/adminDashboard.jsp?error=Invalid_recipient_type#sendNotifications");
            return;
        }
        if (message == null || message.trim().isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/adminDashboard.jsp?error=Message_is_required#sendNotifications");
            return;
        }
        if (!"all".equals(userType)) {
            if (department == null || department.trim().isEmpty()) {
                response.sendRedirect(request.getContextPath() + "/adminDashboard.jsp?error=Department_is_required#sendNotifications");
                return;
            }
            if ("student".equals(userType)) {
                if (year == null || year.trim().isEmpty()) {
                    response.sendRedirect(request.getContextPath() + "/adminDashboard.jsp?error=Year_is_required#sendNotifications");
                    return;
                }
                if (semester == null || semester.trim().isEmpty()) {
                    response.sendRedirect(request.getContextPath() + "/adminDashboard.jsp?error=Semester_is_required#sendNotifications");
                    return;
                }
            }
        }

        // Get sender ID
        try {
            senderId = getUserId(username);
        } catch (SQLException e) {
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/adminDashboard.jsp?error=SQL_error_getting_sender_" + e.getMessage().replace(" ", "_") + "#sendNotifications");
            return;
        }

        if (senderId == -1) {
            response.sendRedirect(request.getContextPath() + "/adminDashboard.jsp?error=Invalid_sender#sendNotifications");
            return;
        }

        Connection conn = null;
        try {
            conn = DBConnection.getConnection();
            conn.setAutoCommit(false);

            String sql = "";
            if ("all".equals(userType)) {
                sql = "INSERT INTO notifications (sender_id, user_id, user_type, department, year, semester, message, date) VALUES (?, NULL, ?, ?, ?, ?, ?, CURDATE())";
                try (PreparedStatement ps = conn.prepareStatement(sql)) {
                    ps.setInt(1, senderId);
                    ps.setString(2, userType);
                    ps.setString(3, department != null ? department : "all");
                    ps.setString(4, year != null ? year : "all");
                    ps.setString(5, semester != null ? semester : "all");
                    ps.setString(6, message);
                    ps.executeUpdate();
                }
            } else {
                sql = "SELECT id FROM users WHERE role = ? " +
                      (userType.equals("student") ? 
                          (!"all".equals(department) ? "AND department = ? " : "") +
                          (!"all".equals(year) ? "AND year = ? " : "") +
                          (!"all".equals(semester) ? "AND semester = ?" : "") :
                          (!"all".equals(department) ? "AND department = ?" : ""));
                try (PreparedStatement psSelect = conn.prepareStatement(sql)) {
                    psSelect.setString(1, userType);
                    int paramIndex = 2;
                    if (userType.equals("student")) {
                        if (!"all".equals(department)) psSelect.setString(paramIndex++, department);
                        if (!"all".equals(year)) psSelect.setString(paramIndex++, year);
                        if (!"all".equals(semester)) psSelect.setString(paramIndex, semester);
                    } else if (!"all".equals(department)) {
                        psSelect.setString(paramIndex, department);
                    }
                    try (ResultSet rs = psSelect.executeQuery()) {
                        while (rs.next()) {
                            int userId = rs.getInt("id");
                            sql = "INSERT INTO notifications (sender_id, user_id, user_type, department, year, semester, message, date) VALUES (?, ?, ?, ?, ?, ?, ?, CURDATE())";
                            try (PreparedStatement psInsert = conn.prepareStatement(sql)) {
                                psInsert.setInt(1, senderId);
                                psInsert.setInt(2, userId);
                                psInsert.setString(3, userType);
                                psInsert.setString(4, department);
                                psInsert.setString(5, userType.equals("student") ? year : null);
                                psInsert.setString(6, userType.equals("student") ? semester : null);
                                psInsert.setString(7, message);
                                psInsert.executeUpdate();
                            }
                        }
                    }
                }
            }

            conn.commit();
            response.sendRedirect(request.getContextPath() + "/adminDashboard.jsp?success=Notification_sent#sendNotifications");
        } catch (SQLException e) {
            if (conn != null) {
                try {
                    conn.rollback();
                } catch (SQLException ex) {
                    ex.printStackTrace();
                }
            }
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/adminDashboard.jsp?error=SQL_error_" + e.getMessage().replace(" ", "_") + "#sendNotifications");
        } catch (Exception e) {
            if (conn != null) {
                try {
                    conn.rollback();
                } catch (SQLException ex) {
                    ex.printStackTrace();
                }
            }
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/adminDashboard.jsp?error=General_error_" + e.getMessage().replace(" ", "_") + "#sendNotifications");
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