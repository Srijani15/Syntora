<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, syntora.db.DBConnection" %>
<h2>Grades</h2>
<%
    String username = (String) session.getAttribute("username");
    try (Connection conn = DBConnection.getConnection()) {
        String sql = "SELECT s.name AS subject, g.grade " +
                     "FROM grades g " +
                     "JOIN students st ON g.student_id = st.id " +
                     "JOIN subjects s ON g.subject_id = s.id " +
                     "WHERE st.username = ?";
        PreparedStatement ps = conn.prepareStatement(sql);
        ps.setString(1, username);
        ResultSet rs = ps.executeQuery();
%>
<table class="table table-striped">
    <thead>
        <tr>
            <th>Subject</th>
            <th>Grade</th>
        </tr>
    </thead>
    <tbody>
        <% while (rs.next()) { %>
            <tr>
                <td><%= rs.getString("subject") %></td>
                <td><%= rs.getString("grade") %></td>
            </tr>
        <% } %>
    </tbody>
</table>
<%  } catch (Exception e) {
        e.printStackTrace();
        out.println("<p>Error loading grades.</p>");
    }
%>