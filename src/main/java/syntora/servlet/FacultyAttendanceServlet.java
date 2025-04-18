package syntora.servlet;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import syntora.db.DBConnection;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

@WebServlet("/facultyAttendance")
@SuppressWarnings("serial")
public class FacultyAttendanceServlet extends HttpServlet {
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String[] studentIds = request.getParameterValues("studentId");
        String[] statuses = request.getParameterValues("status");
        String date = request.getParameter("date");

        try (Connection conn = DBConnection.getConnection()) {
            String sql = "INSERT INTO attendance (student_id, date, status) VALUES (?, ?, ?) ON DUPLICATE KEY UPDATE status = ?";
            PreparedStatement ps = conn.prepareStatement(sql);
            for (int i = 0; i < studentIds.length; i++) {
                ps.setInt(1, Integer.parseInt(studentIds[i]));
                ps.setString(2, date);
                ps.setString(3, statuses[i]);
                ps.setString(4, statuses[i]);
                ps.executeUpdate();
            }
            response.sendRedirect("facultyDashboard.jsp");
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("facultyDashboard.jsp?error=true");
        }
    }
}