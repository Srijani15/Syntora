package syntora.servlet;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import syntora.db.DBConnection;

@WebServlet("/markAttendance")
public class MarkAttendanceServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String[] rollNumbers = request.getParameterValues("rollNumbers");
        int subjectId = Integer.parseInt(request.getParameter("subjectId"));
        String attendanceDate = request.getParameter("attendanceDate");

        try (Connection conn = DBConnection.getConnection()) {
            // Check for existing records and update or insert
            String checkSql = "SELECT id FROM attendance WHERE student_id = (SELECT id FROM students WHERE roll_number = ?) AND subject_id = ? AND date = ?";
            String insertSql = "INSERT INTO attendance (student_id, subject_id, date, status) VALUES ((SELECT id FROM students WHERE roll_number = ?), ?, ?, ?)";
            String updateSql = "UPDATE attendance SET status = ? WHERE id = ?";

            for (String rollNumber : rollNumbers) {
                String status = request.getParameter("status_" + rollNumber);

                // Validate status
                if (!"Present".equals(status) && !"Absent".equals(status)) {
                    continue; // Skip invalid status
                }

                // Check if record exists
                PreparedStatement checkPs = conn.prepareStatement(checkSql);
                checkPs.setString(1, rollNumber);
                checkPs.setInt(2, subjectId);
                checkPs.setString(3, attendanceDate);
                ResultSet rs = checkPs.executeQuery();

                if (rs.next()) {
                    // Update existing record
                    int attendanceId = rs.getInt("id");
                    PreparedStatement updatePs = conn.prepareStatement(updateSql);
                    updatePs.setString(1, status);
                    updatePs.setInt(2, attendanceId);
                    updatePs.executeUpdate();
                    updatePs.close();
                } else {
                    // Insert new record
                    PreparedStatement insertPs = conn.prepareStatement(insertSql);
                    insertPs.setString(1, rollNumber);
                    insertPs.setInt(2, subjectId);
                    insertPs.setString(3, attendanceDate);
                    insertPs.setString(4, status);
                    insertPs.executeUpdate();
                    insertPs.close();
                }
                rs.close();
                checkPs.close();
            }

            response.sendRedirect("pages/facultyDashboard.jsp?status=marked#attendance");
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("pages/facultyDashboard.jsp?status=error#attendance");
        }
    }
}