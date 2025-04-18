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

@WebServlet("/AdminTimetableEntryServlet")
@SuppressWarnings("serial")
public class AdminTimetableEntryServlet extends HttpServlet {
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        int timetableId = Integer.parseInt(request.getParameter("timetable_id"));

        try (Connection conn = DBConnection.getConnection()) {
            // Update or delete existing entries
            String fetchSql = "SELECT id FROM timetable_entry WHERE timetable_id = ?";
            PreparedStatement ps = conn.prepareStatement(fetchSql);
            ps.setInt(1, timetableId);
            ResultSet rs = ps.executeQuery();

            while (rs.next()) {
                int entryId = rs.getInt("id");
                String delete = request.getParameter("delete_" + entryId);

                if ("true".equals(delete)) {
                    String delSql = "DELETE FROM timetable_entry WHERE id = ?";
                    ps = conn.prepareStatement(delSql);
                    ps.setInt(1, entryId);
                    ps.executeUpdate();
                } else {
                    String day = request.getParameter("day_" + entryId);
                    String timeSlot = request.getParameter("time_slot_" + entryId);
                    String subjectIdStr = request.getParameter("subject_id_" + entryId);
                    String textNote = request.getParameter("text_note_" + entryId);

                    Integer subjectId = (subjectIdStr != null && !subjectIdStr.isEmpty()) ? Integer.parseInt(subjectIdStr) : null;

                    String updateSql = "UPDATE timetable_entry SET day=?, time_slot=?, subject_id=?, text_note=? WHERE id=?";
                    ps = conn.prepareStatement(updateSql);
                    ps.setString(1, day);
                    ps.setString(2, timeSlot);
                    if (subjectId != null) {
                        ps.setInt(3, subjectId);
                    } else {
                        ps.setNull(3, java.sql.Types.INTEGER);
                    }
                    ps.setString(4, textNote);
                    ps.setInt(5, entryId);
                    ps.executeUpdate();
                }
            }

            // Add new entry if provided
            String newDay = request.getParameter("new_day");
            String newTimeSlot = request.getParameter("new_time_slot");
            String newSubjectId = request.getParameter("new_subject_id");
            String newTextNote = request.getParameter("new_text_note");

            if (newDay != null && newTimeSlot != null && newSubjectId != null && !newSubjectId.isEmpty()) {
                String insertSql = "INSERT INTO timetable_entry (timetable_id, day, time_slot, subject_id, text_note) VALUES (?, ?, ?, ?, ?)";
                ps = conn.prepareStatement(insertSql);
                ps.setInt(1, timetableId);
                ps.setString(2, newDay);
                ps.setString(3, newTimeSlot);
                ps.setInt(4, Integer.parseInt(newSubjectId));
                ps.setString(5, newTextNote);
                ps.executeUpdate();
            }

            response.sendRedirect("adminTimetables");
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("adminTimetables?error=true");
        }
    }
}
