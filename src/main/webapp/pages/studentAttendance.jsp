<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, syntora.db.DBConnection" %>
<div class="card shadow-sm mt-4">
    <div class="card-header bg-primary text-white d-flex justify-content-between align-items-center">
        <h4 class="mb-0"><i class="fas fa-check-square me-2"></i> Attendance</h4>
    </div>
    <div class="card-body">
        <form method="GET" class="row g-3 mb-3">
            <div class="col-md-4">
                <label class="form-label">Filter by Month</label>
                <input type="month" name="month" class="form-control" value="<%= request.getParameter("month") != null ? request.getParameter("month") : "" %>">
            </div>
            <div class="col-md-3 d-flex align-items-end">
                <button type="submit" class="btn btn-info"><i class="fas fa-filter"></i> Filter</button>
            </div>
        </form>

        <%
            String filterMonth = request.getParameter("month");
            String attendanceSql = "SELECT s.name, a.date, a.status " +
                                   "FROM attendance a JOIN subjects s ON a.subject_id = s.id " +
                                   "WHERE a.student_id = (SELECT id FROM students WHERE username = ?) ";
            if (filterMonth != null && !filterMonth.isEmpty()) {
                attendanceSql += "AND DATE_FORMAT(a.date, '%Y-%m') = ? ";
            }
            attendanceSql += "ORDER BY a.date DESC";

            try (Connection conn = DBConnection.getConnection()) {
                PreparedStatement ps = conn.prepareStatement(attendanceSql);
                ps.setString(1, (String) session.getAttribute("username"));
                if (filterMonth != null && !filterMonth.isEmpty()) {
                    ps.setString(2, filterMonth);
                }
                ResultSet rs = ps.executeQuery();
        %>
        <div class="table-responsive">
            <table class="table table-bordered table-striped">
                <thead class="table-light">
                    <tr><th>Date</th><th>Subject</th><th>Status</th></tr>
                </thead>
                <tbody>
                    <%
                        boolean hasData = false;
                        while (rs.next()) {
                            hasData = true;
                    %>
                    <tr>
                        <td><%= rs.getString("date") %></td>
                        <td><%= rs.getString("name") %></td>
                        <td><%= rs.getString("status") %></td>
                    </tr>
                    <% } if (!hasData) { %>
                    <tr><td colspan="3" class="text-muted text-center">No records found or attendance not marked yet.</td></tr>
                    <% } %>
                </tbody>
            </table>
        </div>
        <%
            rs.close(); 
            ps.close(); 
            } catch (Exception e) {
                out.println("<p class='text-danger'>Error fetching attendance: " + e.getMessage() + "</p>");
            }
        %>
    </div>
</div>
