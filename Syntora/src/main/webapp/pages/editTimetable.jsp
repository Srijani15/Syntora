<!-- editTimetable.jsp - Student Timetable Editor -->
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.sql.*, syntora.db.DBConnection" %>
<!DOCTYPE html>
<html>
<head>
    <title>Edit Student Timetable - Syntora</title>
    <link rel="stylesheet" href="https://bootswatch.com/5/flatly/bootstrap.min.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/5.15.3/css/all.min.css">
</head>
<body>
<div class="container mt-4">
    <a href="${pageContext.request.contextPath}/adminDashboard.jsp" class="btn btn-secondary mb-3">
        <i class="fas fa-arrow-left"></i> Back to Dashboard
    </a>
    <h3 class="mb-4">Edit Student Timetable</h3>

    <% int timetableId = request.getParameter("id") != null ? Integer.parseInt(request.getParameter("id")) : -1;
       if (timetableId == -1) {
           out.println("<div class='alert alert-danger'>No timetable selected.</div>");
           return;
       }

       try (Connection conn = DBConnection.getConnection()) {
           String metaSql = "SELECT * FROM timetable WHERE id = ?";
           PreparedStatement metaPs = conn.prepareStatement(metaSql);
           metaPs.setInt(1, timetableId);
           ResultSet metaRs = metaPs.executeQuery();
           if (!metaRs.next()) {
               out.println("<div class='alert alert-warning'>Timetable not found.</div>");
               return;
           }
           String dept = metaRs.getString("department");
           int year = metaRs.getInt("year");
           int sem = metaRs.getInt("semester");
    %>

    <div class="card mb-4">
        <div class="card-body">
            <h5 class="card-title">Timetable Info</h5>
            <p><strong>Department:</strong> <%= dept %> | <strong>Year:</strong> <%= year %> | <strong>Semester:</strong> <%= sem %></p>
        </div>
    </div>

    <form action="${pageContext.request.contextPath}/AdminTimetableEntryServlet" method="post">
        <input type="hidden" name="timetable_id" value="<%= timetableId %>" />

        <table class="table table-bordered">
            <thead>
                <tr>
                    <th>Day</th>
                    <th>Time Slot</th>
                    <th>Subject</th>
                    <th>Text Note (optional)</th>
                    <th>Delete</th>
                </tr>
            </thead>
            <tbody>
            <% String entrySql = "SELECT te.id, te.day, te.time_slot, te.subject_id, s.name AS subject_name, te.text_note FROM timetable_entry te LEFT JOIN subjects s ON te.subject_id = s.id WHERE te.timetable_id = ? ORDER BY FIELD(day, 'Monday','Tuesday','Wednesday','Thursday','Friday','Saturday')";
               PreparedStatement entryPs = conn.prepareStatement(entrySql);
               entryPs.setInt(1, timetableId);
               ResultSet rs = entryPs.executeQuery();
               while (rs.next()) {
            %>
                <tr>
                    <td><input type="text" name="day_<%= rs.getInt("id") %>" class="form-control" value="<%= rs.getString("day") %>" required></td>
                    <td><input type="text" name="time_slot_<%= rs.getInt("id") %>" class="form-control" value="<%= rs.getString("time_slot") %>" required></td>
                    <td>
                        <select name="subject_id_<%= rs.getInt("id") %>" class="form-control">
                            <option value="">-- Select --</option>
                            <%
                                String subjectSql = "SELECT id, name FROM subjects WHERE department=? AND year=? AND semester=?";
                                PreparedStatement subPs = conn.prepareStatement(subjectSql);
                                subPs.setString(1, dept);
                                subPs.setInt(2, year);
                                subPs.setInt(3, sem);
                                ResultSet subRs = subPs.executeQuery();
                                while (subRs.next()) {
                                    int sid = subRs.getInt("id");
                                    String sname = subRs.getString("name");
                            %>
                            <option value="<%= sid %>" <%= sid == rs.getInt("subject_id") ? "selected" : "" %>><%= sname %></option>
                            <% } subRs.close(); subPs.close(); %>
                        </select>
                    </td>
                    <td><input type="text" name="text_note_<%= rs.getInt("id") %>" class="form-control" value="<%= rs.getString("text_note") %>"></td>
                    <td><input type="checkbox" name="delete_<%= rs.getInt("id") %>" value="true"></td>
                </tr>
            <% } rs.close(); entryPs.close(); %>

            <tr class="table-info">
                <td><input type="text" name="new_day" class="form-control"></td>
                <td><input type="text" name="new_time_slot" class="form-control"></td>
                <td>
                    <select name="new_subject_id" class="form-control">
                        <option value="">-- Select --</option>
                        <%
                            String subjectSql = "SELECT id, name FROM subjects WHERE department=? AND year=? AND semester=?";
                            PreparedStatement subPs = conn.prepareStatement(subjectSql);
                            subPs.setString(1, dept);
                            subPs.setInt(2, year);
                            subPs.setInt(3, sem);
                            ResultSet subRs = subPs.executeQuery();
                            while (subRs.next()) {
                        %>
                        <option value="<%= subRs.getInt("id") %>"><%= subRs.getString("name") %></option>
                        <% } subRs.close(); subPs.close(); %>
                    </select>
                </td>
                <td><input type="text" name="new_text_note" class="form-control"></td>
                <td>-</td>
            </tr>
            </tbody>
        </table>
        <button type="submit" class="btn btn-success"><i class="fas fa-save"></i> Save Timetable</button>
    </form>

    <% } catch (Exception e) { %>
        <div class="alert alert-danger">Error loading timetable: <%= e.getMessage() %></div>
    <% } %>
</div>
</body>
</html>
