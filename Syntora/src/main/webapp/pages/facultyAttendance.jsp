<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, syntora.db.DBConnection" %>
<h2>Manage Attendance</h2>
<%
    String username = (String) session.getAttribute("username");
    try (Connection conn = DBConnection.getConnection()) {
        String sql = "SELECT DISTINCT s.id, s.roll_number, CONCAT(s.first_name, ' ', s.last_name) AS student_name " +
                     "FROM students s " +
                     "JOIN timetable t ON s.department = t.department AND s.year = t.year AND s.semester = t.semester " +
                     "JOIN timetable_entry te ON t.id = te.timetable_id " +
                     "WHERE te.faculty_id = (SELECT id FROM faculty WHERE username = ?)";
        PreparedStatement ps = conn.prepareStatement(sql);
        ps.setString(1, username);
        ResultSet rs = ps.executeQuery();
%>
<table class="table table-striped">
    <thead>
        <tr>
            <th>Roll Number</th>
            <th>Student Name</th>
            <th>Mark Attendance</th>
        </tr>
    </thead>
    <tbody>
        <% while (rs.next()) { %>
            <tr>
                <td><%= rs.getString("roll_number") %></td>
                <td><%= rs.getString("student_name") %></td>
                <td>
                    <form action="markAttendance" method="post">
                        <input type="hidden" name="studentId" value="<%= rs.getInt("id") %>">
                        <select name="status">
                            <option value="Present">Present</option>
                            <option value="Absent">Absent</option>
                        </select>
                        <button type="submit" class="btn btn-primary btn-sm">Mark</button>
                    </form>
                </td>
            </tr>
        <% } %>
    </tbody>
</table>
<%  } catch (Exception e) {
        e.printStackTrace();
        out.println("<p>Error loading students.</p>");
    }
%>