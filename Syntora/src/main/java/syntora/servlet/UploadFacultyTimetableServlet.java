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

@WebServlet("/UploadFacultyTimetableServlet")
@SuppressWarnings("serial")
public class UploadFacultyTimetableServlet extends HttpServlet {
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        int facultyId = Integer.parseInt(request.getParameter("facultyId"));
        String department = request.getParameter("department");
        int year = Integer.parseInt(request.getParameter("year"));
        int semester = Integer.parseInt(request.getParameter("semester"));

        try (Connection conn = DBConnection.getConnection()) {
            // Check if timetable exists, create if not
            int timetableId = getOrCreateTimetable(conn, department, year, semester);

            // Clear existing entries for this faculty, department, year, semester
            String deleteSql = "DELETE FROM timetable_entry WHERE timetable_id = ? AND faculty_id = ?";
            PreparedStatement deletePs = conn.prepareStatement(deleteSql);
            deletePs.setInt(1, timetableId);
            deletePs.setInt(2, facultyId);
            deletePs.executeUpdate();

            // Define time slots
            String[] timeSlots = {
                "9:00 - 9:50", "9:50 - 10:40", "10:50 - 11:40", "11:40 - 12:30",
                "1:20 - 2:10", "2:10 - 3:00", "3:00 - 4:00"
            };
            String[] days = {"monday", "tuesday", "wednesday", "thursday", "friday", "saturday"};

            // Insert new entries
            String insertSql = "INSERT INTO timetable_entry (timetable_id, day, time_slot, subject_id, faculty_id, text_note) VALUES (?, ?, ?, ?, ?, ?)";
            PreparedStatement insertPs = conn.prepareStatement(insertSql);

            for (String day : days) {
                for (int i = 1; i <= 7; i++) {
                    String slotKey = day + "_slot" + i;
                    String noteKey = day + "_note" + i;
                    String subjectIdStr = request.getParameter(slotKey);
                    String textNote = request.getParameter(noteKey);

                    if (subjectIdStr != null && !subjectIdStr.equals("-")) {
                        int subjectId = Integer.parseInt(subjectIdStr);

                        insertPs.setInt(1, timetableId);
                        insertPs.setString(2, day.substring(0, 1).toUpperCase() + day.substring(1));
                        insertPs.setString(3, timeSlots[i - 1]);
                        insertPs.setInt(4, subjectId);
                        insertPs.setInt(5, facultyId);
                        insertPs.setString(6, textNote != null ? textNote : "");
                        insertPs.executeUpdate();
                    }
                }
            }

            response.sendRedirect("pages/adminManageTimetable.jsp?status=success");
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("pages/editFacultyTimetable.jsp?status=error");
        }
    }

    private int getOrCreateTimetable(Connection conn, String department, int year, int semester) throws Exception {
        String sql = "SELECT id FROM timetable WHERE department = ? AND year = ? AND semester = ?";
        PreparedStatement ps = conn.prepareStatement(sql);
        ps.setString(1, department);
        ps.setInt(2, year);
        ps.setInt(3, semester);
        ResultSet rs = ps.executeQuery();

        if (rs.next()) {
            return rs.getInt("id");
        }

        String insertSql = "INSERT INTO timetable (department, year, semester) VALUES (?, ?, ?)";
        PreparedStatement insertPs = conn.prepareStatement(insertSql, PreparedStatement.RETURN_GENERATED_KEYS);
        insertPs.setString(1, department);
        insertPs.setInt(2, year);
        insertPs.setInt(3, semester);
        insertPs.executeUpdate();

        ResultSet generatedKeys = insertPs.getGeneratedKeys();
        if (generatedKeys.next()) {
            return generatedKeys.getInt(1);
        }

        throw new Exception("Failed to create timetable");
    }
}