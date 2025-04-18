package syntora.servlet;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import syntora.db.DBConnection;

@WebServlet("/updateGrades")
public class UpdateGradesServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String rollNumber = request.getParameter("rollNumber");
        int subjectId = Integer.parseInt(request.getParameter("subjectId"));
        String grade = request.getParameter("grade");

        try (Connection conn = DBConnection.getConnection()) {
            String sql = "INSERT INTO grades (student_id, subject_id, grade) " +
                         "SELECT id, ?, ? FROM students WHERE roll_number = ? " +
                         "ON DUPLICATE KEY UPDATE grade = ?";
            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setInt(1, subjectId);
            ps.setString(2, grade);
            ps.setString(3, rollNumber);
            ps.setString(4, grade);
            ps.executeUpdate();

            response.sendRedirect("pages/facultyDashboard.jsp?status=success");
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("pages/facultyDashboard.jsp?status=error");
        }
    }
}