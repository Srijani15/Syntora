<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, syntora.db.DBConnection" %>
<!DOCTYPE html>
<html>
<head>
    <title>Notifications - Syntora</title>
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@400;500;600&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://bootswatch.com/5/flatly/bootstrap.min.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/5.15.3/css/all.min.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
    <script src="https://ajax.googleapis.com/ajax/libs/jquery/3.5.1/jquery.min.js"></script>
    <script src="https://maxcdn.bootstrapcdn.com/bootstrap/4.5.2/js/bootstrap.min.js"></script>
</head>
<body>
    <button class="toggle-btn d-md-none"><i class="fas fa-bars"></i></button>
    <div class="sidebar">
        <h3><i class="fas fa-school"></i> Syntora Faculty</h3>
        <a href="#personalDetails" onclick="showContent('personalDetails')"><i class="fas fa-user"></i> Personal Details</a>
        <a href="#attendance" onclick="showContent('attendance')"><i class="fas fa-check-square"></i> Attendance</a>
        <a href="#subjects" onclick="showContent('subjects')"><i class="fas fa-book"></i> Subjects</a>
        <a href="#timetable" onclick="showContent('timetable')"><i class="fas fa-calendar-alt"></i> Timetable</a>
        <a href="#grades" onclick="showContent('grades')"><i class="fas fa-graduation-cap"></i> Grades</a>
        <a href="#remarks" onclick="showContent('remarks')"><i class="fas fa-comment"></i> Remarks</a>
        <a href="#notifications" onclick="showContent('notifications')" class="active"><i class="fas fa-bell"></i> Notifications</a>
        <a href="logout" class="logout"><i class="fas fa-sign-out-alt"></i> Logout</a>
    </div>
    <div class="content">
        <div id="notifications" class="tab-content active">
            <h2>Notifications</h2>
            <% if (request.getParameter("error") != null) { %>
                <div class="alert alert-danger"><%= request.getParameter("error") %></div>
            <% } %>
            <h3>Received Notifications</h3>
            <% 
                String username = (String) session.getAttribute("username");
                try (Connection conn = DBConnection.getConnection()) {
                    String sql = "SELECT n.message, n.date, u.username AS sender_name " +
                                 "FROM notifications n JOIN users u ON n.sender_id = u.id " +
                                 "WHERE n.user_id = (SELECT id FROM faculty WHERE email = ?) AND n.user_type = 'faculty' ORDER BY n.date DESC";
                    PreparedStatement ps = conn.prepareStatement(sql);
                    ps.setString(1, username);
                    ResultSet rs = ps.executeQuery();
            %>
            <table class="table table-striped">
                <thead><tr><th>Message</th><th>Date</th><th>Sent By</th></tr></thead>
                <tbody>
                <% while (rs.next()) { %>
                    <tr><td><%= rs.getString("message") %></td><td><%= rs.getString("date") %></td><td><%= rs.getString("sender_name") %></td></tr>
                <% } %>
                <% if (!rs.first()) { %>
                    <tr><td colspan="3" class="text-muted">No notifications received yet.</td></tr>
                <% } %>
                </tbody>
            </table>
            <% } catch (Exception e) {
                out.println("<p class='text-danger'>Error loading received notifications: " + e.getMessage() + "</p>");
            } %>

            <h3 class="mt-4">Sent Notifications</h3>
            <% 
                try (Connection conn = DBConnection.getConnection()) {
                    String sql = "SELECT n.message, n.date, u.username AS recipient_name " +
                                 "FROM notifications n JOIN users u ON n.user_id = u.id " +
                                 "WHERE n.sender_id = (SELECT id FROM faculty WHERE email = ?) AND n.user_type = 'student' ORDER BY n.date DESC";
                    PreparedStatement ps = conn.prepareStatement(sql);
                    ps.setString(1, username);
                    ResultSet rs = ps.executeQuery();
            %>
            <table class="table table-striped">
                <thead><tr><th>Message</th><th>Date</th><th>Sent To</th></tr></thead>
                <tbody>
                <% while (rs.next()) { %>
                    <tr><td><%= rs.getString("message") %></td><td><%= rs.getString("date") %></td><td><%= rs.getString("recipient_name") %></td></tr>
                <% } %>
                <% if (!rs.first()) { %>
                    <tr><td colspan="3" class="text-muted">No notifications sent yet.</td></tr>
                <% } %>
                </tbody>
            </table>
            <% } catch (Exception e) {
                out.println("<p class='text-danger'>Error loading sent notifications: " + e.getMessage() + "</p>");
            } %>

            <h3 class="mt-4">Send Notifications to Students</h3>
            <form action="${pageContext.request.contextPath}/sendFacultyNotification" method="post" class="card p-3">
                <div class="form-group">
                    <label for="department">Department</label>
                    <select name="department" id="department" class="form-control" required>
                        <option value="">Select Department</option>
                        <option value="all">All</option>
                        <option value="AIML">AIML</option>
                        <option value="CSE">CSE</option>
                        <option value="IT">IT</option>
                        <option value="ECE">ECE</option>
                        <option value="EEE">EEE</option>
                    </select>
                </div>
                <div class="form-group">
                    <label for="year">Year</label>
                    <select name="year" id="year" class="form-control">
                        <option value="">Select Year</option>
                        <option value="all">All</option>
                        <option value="1">1</option>
                        <option value="2">2</option>
                        <option value="3">3</option>
                        <option value="4">4</option>
                        <option value="5">5</option>
                    </select>
                </div>
                <div class="form-group">
                    <label for="message">Message</label>
                    <textarea name="message" id="message" class="form-control" rows="4" required></textarea>
                </div>
                <button type="submit" class="btn btn-primary">Send Notification</button>
            </form>
        </div>
    </div>
    <script>
        function showContent(tabId) {
            $(".tab-content").removeClass("active");
            $("#" + tabId).addClass("active");
            $(".sidebar a").removeClass("active");
            $(`.sidebar a[href="#${tabId}"]`).addClass("active");
        }

        $(".toggle-btn").click(function() {
            $(".sidebar").toggleClass("active");
        });

        showContent('notifications');
    </script>
</body>
</html>