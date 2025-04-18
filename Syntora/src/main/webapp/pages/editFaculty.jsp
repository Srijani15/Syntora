<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, syntora.db.DBConnection" %>
<!DOCTYPE html>
<html>
<head>
    <title>Edit Faculty - Syntora</title>
    <link rel="stylesheet" href="https://bootswatch.com/4/flatly/bootstrap.min.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/5.15.3/css/all.min.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
    <script src="https://ajax.googleapis.com/ajax/libs/jquery/3.5.1/jquery.min.js"></script>
    <script src="https://maxcdn.bootstrapcdn.com/bootstrap/4.5.2/js/bootstrap.min.js"></script>
</head>
<body>
    <nav class="navbar navbar-expand-lg navbar-dark bg-primary">
        <a class="navbar-brand" href="${pageContext.request.contextPath}/adminDashboard.jsp"><i class="fas fa-shield-alt"></i> Syntora Admin</a>
        <div class="collapse navbar-collapse" id="navbarNav">
            <ul class="navbar-nav ml-auto">
                <li class="nav-item">
                    <a class="nav-link" href="${pageContext.request.contextPath}/logout"><i class="fas fa-sign-out-alt"></i> Logout</a>
                </li>
            </ul>
        </div>
    </nav>
    <div class="container mt-4">
        <h2><%= request.getParameter("username") != null ? "Edit Faculty" : "Add New Faculty" %></h2>
        <% String username = request.getParameter("username");
           String title = "", firstName = "", lastName = "", department = "";
           if (username != null) {
               try (Connection conn = DBConnection.getConnection()) {
                   String sql = "SELECT f.title, f.first_name, f.last_name, u.department " +
                                "FROM faculty f JOIN users u ON f.user_id = u.id WHERE u.username = ?";
                   PreparedStatement ps = conn.prepareStatement(sql);
                   ps.setString(1, username);
                   ResultSet rs = ps.executeQuery();
                   if (rs.next()) {
                       title = rs.getString("title") != null ? rs.getString("title") : "";
                       firstName = rs.getString("first_name") != null ? rs.getString("first_name") : "";
                       lastName = rs.getString("last_name") != null ? rs.getString("last_name") : "";
                       department = rs.getString("department") != null ? rs.getString("department") : "";
                   }
               } catch (Exception e) {
                   e.printStackTrace();
               }
           }
        %>
        <form action="${pageContext.request.contextPath}/adminFaculty" method="post">
            <input type="hidden" name="action" value="<%= username != null ? "update" : "create" %>">
            <% if (username != null) { %>
                <input type="hidden" name="username" value="<%= username %>">
            <% } %>
            <div class="form-group">
                <label>Username</label>
                <input type="text" name="username" class="form-control" value="<%= username != null ? username : "" %>" <%= username != null ? "readonly" : "" %> required>
            </div>
            <div class="form-group">
                <label>Title</label>
                <input type="text" name="title" class="form-control" value="<%= title %>" required>
            </div>
            <div class="form-group">
                <label>First Name</label>
                <input type="text" name="first_name" class="form-control" value="<%= firstName %>" required>
            </div>
            <div class="form-group">
                <label>Last Name</label>
                <input type="text" name="last_name" class="form-control" value="<%= lastName %>" required>
            </div>
            <div class="form-group">
                <label>Department</label>
                <select name="department" class="form-control" required>
                    <option value="CSE" <%= "CSE".equals(department) ? "selected" : "" %>>CSE</option>
                    <option value="IT" <%= "IT".equals(department) ? "selected" : "" %>>IT</option>
                    <option value="AIML" <%= "AIML".equals(department) ? "selected" : "" %>>AIML</option>
                    <option value="ECE" <%= "ECE".equals(department) ? "selected" : "" %>>ECE</option>
                    <option value="EEE" <%= "EEE".equals(department) ? "selected" : "" %>>EEE</option>
                </select>
            </div>
            <button type="submit" class="btn btn-primary">Save</button>
            <a href="${pageContext.request.contextPath}/adminManageFaculty.jsp" class="btn btn-secondary">Back</a>
        </form>
    </div>
</body>
</html>