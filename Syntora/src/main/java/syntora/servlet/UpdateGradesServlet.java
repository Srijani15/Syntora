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
        String department = request.getParameter("department");
        String year = request.getParameter("year");
        String semester = request.getParameter("semester");
        int subjectId = Integer.parseInt(request.getParameter("subjectId"));
        String[] rollNumbers = request.getParameterValues("rollNumbers");

        try (Connection conn = DBConnection.getConnection()) {
            String sql = "INSERT INTO grades (student_id, subject_id, grade) " +
                         "SELECT id, ?, ? FROM students WHERE roll_number = ? " +
                         "ON DUPLICATE KEY UPDATE grade = ?";
            PreparedStatement ps = conn.prepareStatement(sql);

            boolean anyUpdate = false;
            for (String rollNumber : rollNumbers) {
                String grade = request.getParameter("grade_" + rollNumber);
                if (grade != null && !grade.trim().isEmpty()) {
                    ps.setInt(1, subjectId);
                    ps.setString(2, grade);
                    ps.setString(3, rollNumber);
                    ps.setString(4, grade);
                    ps.addBatch();
                    anyUpdate = true;
                }
            }

            if (anyUpdate) {
                ps.executeBatch();
                response.sendRedirect("pages/facultyDashboard.jsp?form=grades&department=" + department + 
                                     "&year=" + year + "&semester=" + semester + "&status=success#grades");
            } else {
                response.sendRedirect("pages/facultyDashboard.jsp?form=grades&department=" + department + 
                                     "&year=" + year + "&semester=" + semester + "&status=noGrades#grades");
            }
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("pages/facultyDashboard.jsp?form=grades&department=" + department + 
                                 "&year=" + year + "&semester=" + semester + "&status=error#grades");
        }
    }
}