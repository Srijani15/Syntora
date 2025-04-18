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

@WebServlet("/adminTimetables")
public class AdminTimetablesServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String action = request.getParameter("action");
        String actionEntry = request.getParameter("actionEntry");

        String department = request.getParameter("department");
        String yearStr = request.getParameter("year");
        String semesterStr = request.getParameter("semester");

        String day = request.getParameter("day");
        String timeSlot = request.getParameter("timeSlot");

        String subjectIdStr = request.getParameter("subjectId");
        String facultyIdStr = request.getParameter("facultyId");
        String timetableIdStr = request.getParameter("timetableId");

        int id = -1;

        try (Connection conn = DBConnection.getConnection()) {
            if ("create".equals(action) || "update".equals(action)) {
                if (department != null && yearStr != null && semesterStr != null) {
                    int year = Integer.parseInt(yearStr);
                    int semester = Integer.parseInt(semesterStr);

                    String sql = "INSERT INTO timetable (department, year, semester) VALUES (?, ?, ?) " +
                                 "ON DUPLICATE KEY UPDATE department = ?, year = ?, semester = ?";
                    PreparedStatement ps = conn.prepareStatement(sql, PreparedStatement.RETURN_GENERATED_KEYS);
                    ps.setString(1, department);
                    ps.setInt(2, year);
                    ps.setInt(3, semester);
                    ps.setString(4, department);
                    ps.setInt(5, year);
                    ps.setInt(6, semester);
                    ps.executeUpdate();

                    ResultSet rs = ps.getGeneratedKeys();
                    if (rs.next()) {
                        id = rs.getInt(1);
                    } else {
                        String getSql = "SELECT id FROM timetable WHERE department = ? AND year = ? AND semester = ?";
                        ps = conn.prepareStatement(getSql);
                        ps.setString(1, department);
                        ps.setInt(2, year);
                        ps.setInt(3, semester);
                        rs = ps.executeQuery();
                        if (rs.next()) {
                            id = rs.getInt("id");
                        }
                    }
                }
            }

            if ("addEntry".equals(actionEntry) && timetableIdStr != null && subjectIdStr != null && facultyIdStr != null && day != null && timeSlot != null) {
                int timetableId = Integer.parseInt(timetableIdStr);
                int subjectId = Integer.parseInt(subjectIdStr);
                int facultyId = Integer.parseInt(facultyIdStr);

                String sql = "INSERT INTO timetable_entry (timetable_id, day, time_slot, subject_id, faculty_id) VALUES (?, ?, ?, ?, ?)";
                PreparedStatement ps = conn.prepareStatement(sql);
                ps.setInt(1, timetableId);
                ps.setString(2, day);
                ps.setString(3, timeSlot);
                ps.setInt(4, subjectId);
                ps.setInt(5, facultyId);
                ps.executeUpdate();
            }

            response.sendRedirect("pages/adminManageTimetable.jsp?status=success&id=" + id);
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("pages/adminManageTimetable.jsp?status=error");
        }
    }

    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String action = request.getParameter("action");
        String actionEntry = request.getParameter("actionEntry");

        try (Connection conn = DBConnection.getConnection()) {
            if ("delete".equals(action)) {
                int id = Integer.parseInt(request.getParameter("id"));
                String sql = "DELETE FROM timetable WHERE id = ?";
                PreparedStatement ps = conn.prepareStatement(sql);
                ps.setInt(1, id);
                ps.executeUpdate();
                response.sendRedirect("pages/adminManageTimetable.jsp?status=success");
            } else if ("deleteEntry".equals(actionEntry)) {
                int id = Integer.parseInt(request.getParameter("id"));
                int entryId = Integer.parseInt(request.getParameter("entryId"));
                String sql = "DELETE FROM timetable_entry WHERE id = ?";
                PreparedStatement ps = conn.prepareStatement(sql);
                ps.setInt(1, entryId);
                ps.executeUpdate();
                response.sendRedirect("pages/editTimetable.jsp?id=" + id + "&status=success");
            }
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("pages/adminManageTimetable.jsp?status=error");
        }
    }
}
