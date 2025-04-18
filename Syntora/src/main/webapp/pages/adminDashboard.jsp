<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, syntora.db.DBConnection" %>
<!DOCTYPE html>
<html>
<head>
    <title>Admin Dashboard - Syntora</title>
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@400;500;600&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://bootswatch.com/5/flatly/bootstrap.min.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/5.15.3/css/all.min.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
    <script src="https://ajax.googleapis.com/ajax/libs/jquery/3.5.1/jquery.min.js"></script>
    <script src="https://maxcdn.bootstrapcdn.com/bootstrap/4.5.2/js/bootstrap.min.js"></script>
    <style>
    .sidebar a.logout {
        pointer-events: auto !important;
        opacity: 1 !important;
        cursor: pointer !important;
    }
    .sidebar a {
        display: block;
    }
</style>
</head>
<body>
    <button class="toggle-btn d-md-none"><i class="fas fa-bars"></i></button>
    <div class="sidebar">
        <h3><i class="fas fa-school"></i> Syntora Admin</h3>
        <a href="#manageStudents" onclick="showContent('manageStudents')" class="active"><i class="fas fa-users"></i> Manage Students</a>
        <a href="#manageFaculty" onclick="showContent('manageFaculty')"><i class="fas fa-chalkboard-teacher"></i> Manage Faculty</a>
        <a href="#manageSubjects" onclick="showContent('manageSubjects')"><i class="fas fa-book"></i> Manage Subjects</a>
        <a href="#manageTimetables" onclick="showContent('manageTimetables')"><i class="fas fa-calendar-alt"></i> Manage Timetables</a>
        <a href="#manageAttendance" onclick="showContent('manageAttendance')"><i class="fas fa-check-square"></i> Manage Attendance</a>
        <a href="#sendNotifications" onclick="showContent('sendNotifications')"><i class="fas fa-bell"></i> Send Notifications</a>
        <a href="${pageContext.request.contextPath}/logout" class="logout"><i class="fas fa-sign-out-alt"></i> Logout</a>
    </div>
    <div class="content">
        <div id="welcome" class="tab-content">
            <h2>Welcome, <%= session.getAttribute("username") %>!</h2>
        </div>
        <div id="manageStudents" class="tab-content active">
            <h2>Manage Students</h2>
            <form action="${pageContext.request.contextPath}/adminStudents" method="get" class="card p-3">
                <div class="form-group">
                    <label for="department">Department</label>
                    <select name="department" id="department" class="form-control" required>
                        <option value="">Select Department</option>
                        <option value="AIML">AIML</option>
                        <option value="CSE">CSE</option>
                        <option value="IT">IT</option>
                        <option value="ECE">ECE</option>
                        <option value="EEE">EEE</option>
                    </select>
                </div>
                <div class="form-group">
                    <label for="year">Year</label>
                    <select name="year" id="year" class="form-control" required>
                        <option value="">Select Year</option>
                        <option value="1">1</option>
                        <option value="2">2</option>
                        <option value="3">3</option>
                        <option value="4">4</option>
                        <option value="5">5</option>
                    </select>
                </div>
                <button type="submit" class="btn btn-primary">View and Manage</button>
            </form>
        </div>
        <div id="manageFaculty" class="tab-content">
            <h2>Manage Faculty</h2>
            <form action="${pageContext.request.contextPath}/pages/adminManageFaculty.jsp" method="get" class="card p-3">
                <div class="form-group">
                    <label for="department">Department</label>
                    <select name="department" id="department" class="form-control" required>
                        <option value="">Select Department</option>
                        <option value="CSE" <%= "CSE".equals(request.getParameter("department")) ? "selected" : "" %>>CSE</option>
                        <option value="IT" <%= "IT".equals(request.getParameter("department")) ? "selected" : "" %>>IT</option>
                        <option value="AIML" <%= "AIML".equals(request.getParameter("department")) ? "selected" : "" %>>AIML</option>
                        <option value="ECE" <%= "ECE".equals(request.getParameter("department")) ? "selected" : "" %>>ECE</option>
                        <option value="EEE" <%= "EEE".equals(request.getParameter("department")) ? "selected" : "" %>>EEE</option>
                    </select>
                </div>
                <button type="submit" class="btn btn-primary">View and Manage</button>
            </form>
        </div>
        <div id="manageSubjects" class="tab-content">
            <h2>Manage Subjects</h2>
            <form action="${pageContext.request.contextPath}/adminSubjects" method="get">
    <button type="submit" class="btn btn-primary">View and Manage</button>
</form>
        </div>
        <div id="manageTimetables" class="tab-content">
    <h2>Manage Timetables</h2>
    <form action="${pageContext.request.contextPath}/pages/adminManageTimetable.jsp" method="get">
        <button type="submit" class="btn btn-primary">View and Manage</button>
    </form>
</div>

        <div id="manageAttendance" class="tab-content">
            <h2>Manage Attendance</h2>
            <div class="card p-3 shadow-sm">
                <form action="${pageContext.request.contextPath}/adminAttendance" method="get">
                    <div class="form-group">
                        <label for="rollNumber">Roll Number</label>
                        <input type="text" name="rollNumber" id="rollNumber" class="form-control" placeholder="Enter Roll Number (e.g., CS301)" required>
                    </div>
                    <div class="form-group">
                        <label for="department">Department</label>
                        <select name="department" id="department" class="form-control" required>
                            <option value="">Select Department</option>
                            <option value="AIML">AIML</option>
                            <option value="CSE">CSE</option>
                            <option value="IT">IT</option>
                            <option value="ECE">ECE</option>
                            <option value="EEE">EEE</option>
                        </select>
                    </div>
                    <div class="form-group">
                        <label for="year">Year</label>
                        <select name="year" id="year" class="form-control" required>
                            <option value="">Select Year</option>
                            <option value="1">1</option>
                            <option value="2">2</option>
                            <option value="3">3</option>
                            <option value="4">4</option>
                            <option value="5">5</option>
                        </select>
                    </div>
                    <div class="form-group">
                        <label for="semester">Semester</label>
                        <select name="semester" id="semester" class="form-control" required>
                            <option value="">Select Semester</option>
                            <option value="1">1</option>
                            <option value="2">2</option>
                          
                        </select>
                    </div>
                    <button type="submit" class="btn btn-primary"><i class="fas fa-eye"></i> View and Manage</button>
                </form>
            </div>
        </div>
       <div id="sendNotifications" class="tab-content">
            <h2>Notifications</h2>
            <div class="card p-3 shadow-sm">
                <h4>Send Notification</h4>
                <% if ("Notification_sent".equals(request.getParameter("success"))) { %>
                <div class="alert alert-success alert-dismissible fade show" role="alert">
                    Notification sent successfully!
                    <button type="button" class="close" data-dismiss="alert" aria-label="Close"><span aria-hidden="true">&times;</span></button>
                </div>
                <% } %>
                <% if (request.getParameter("error") != null) { %>
                <div class="alert alert-danger alert-dismissible fade show" role="alert">
                    Error: <%= request.getParameter("error").replace("_", " ") %>
                    <button type="button" class="close" data-dismiss="alert" aria-label="Close"><span aria-hidden="true">&times;</span></button>
                </div>
                <% } %>
                <form action="${pageContext.request.contextPath}/sendNotification" method="post" class="mb-4">
                    <div class="form-group">
                        <label for="userType">Recipient Type</label>
                        <select name="userType" id="userType" class="form-control" required onchange="toggleFields()">
                            <option value="">Select Recipient</option>
                            <option value="student">Students</option>
                            <option value="faculty">Faculty</option>
                            <option value="all">All</option>
                        </select>
                    </div>
                    <div class="form-group" id="departmentGroup">
                        <label for="department">Department</label>
                        <select name="department" id="department" class="form-control">
                            <option value="all">All Departments</option>
                            <option value="AIML">AIML</option>
                            <option value="CSE">CSE</option>
                            <option value="IT">IT</option>
                            <option value="ECE">ECE</option>
                            <option value="EEE">EEE</option>
                        </select>
                    </div>
                    <div class="form-group" id="yearGroup" style="display: none;">
                        <label for="year">Year</label>
                        <select name="year" id="year" class="form-control">
                            <option value="all">All Years</option>
                            <option value="1">1</option>
                            <option value="2">2</option>
                            <option value="3">3</option>
                            <option value="4">4</option>
                            <option value="5">5</option>
                        </select>
                    </div>
                    <div class="form-group" id="semesterGroup" style="display: none;">
                        <label for="semester">Semester</label>
                        <select name="semester" id="semester" class="form-control">
                            <option value="all">All Semesters</option>
                            <option value="1">1</option>
                            <option value="2">2</option>
                            <option value="3">3</option>
                            <option value="4">4</option>
                            <option value="5">5</option>
                            <option value="6">6</option>
                            <option value="7">7</option>
                            <option value="8">8</option>
                        </select>
                    </div>
                    <div class="form-group">
                        <label for="message">Message</label>
                        <textarea name="message" id="message" class="form-control" rows="5" required placeholder="Enter your message"></textarea>
                    </div>
                    <button type="submit" class="btn btn-primary"><i class="fas fa-paper-plane"></i> Send Notification</button>
                </form>
                <hr>
                <h4>Sent Notifications</h4>
                <%
                    int senderId = -1;
                    try (Connection conn = DBConnection.getConnection()) {
                        String sql = "SELECT id FROM users WHERE username = ?";
                        PreparedStatement ps = conn.prepareStatement(sql);
                        ps.setString(1, (String) session.getAttribute("username"));
                        ResultSet rs = ps.executeQuery();
                        if (rs.next()) {
                            senderId = rs.getInt("id");
                        }
                        rs.close();
                        ps.close();

                        if (senderId != -1) {
                            sql = "SELECT user_type, department, year, semester, message, date " +
                                  "FROM notifications WHERE sender_id = ? ORDER BY date DESC";
                            ps = conn.prepareStatement(sql);
                            ps.setInt(1, senderId);
                            rs = ps.executeQuery();
                %>
                <table class="table table-bordered table-hover">
                    <thead>
                        <tr>
                            <th>Recipient Type</th>
                            <th>Department</th>
                            <th>Year</th>
                            <th>Semester</th>
                            <th>Message</th>
                            <th>Date</th>
                        </tr>
                    </thead>
                    <tbody>
                        <%
                            boolean hasNotifications = false;
                            while (rs.next()) {
                                hasNotifications = true;
                                String userType = rs.getString("user_type");
                                String department = rs.getString("department");
                                String year = rs.getString("year");
                                String semester = rs.getString("semester");
                                String message = rs.getString("message");
                                String date = rs.getString("date");
                        %>
                        <tr>
                            <td><%= userType != null ? userType : "-" %></td>
                            <td><%= department != null ? department : "-" %></td>
                            <td><%= year != null ? year : "-" %></td>
                            <td><%= semester != null ? semester : "-" %></td>
                            <td><%= message != null ? message : "-" %></td>
                            <td><%= date != null ? date : "-" %></td>
                        </tr>
                        <%
                            }
                            rs.close();
                            ps.close();
                            if (!hasNotifications) {
                        %>
                        <tr>
                            <td colspan="6" class="text-muted">No notifications sent.</td>
                        </tr>
                        <%
                            }
                        %>
                    </tbody>
                </table>
                <%
                        } else {
                %>
                <div class="alert alert-warning">Unable to retrieve sender ID.</div>
                <%
                        }
                    } catch (SQLException e) {
                %>
                <div class="alert alert-danger">Error retrieving notifications: <%= e.getMessage() %></div>
                <%
                        e.printStackTrace();
                    }
                %>
            </div>
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
        $(".sidebar a.logout").click(function(e) {
            e.preventDefault();
            window.location.href = $(this).attr("href");
        });
        function toggleYearField() {
            var recipientType = $("#recipientType").val();
            if (recipientType === "student") {
                $("#yearGroup").show();
            } else {
                $("#yearGroup").hide();
            }
        }

        $(document).ready(function() {
            var hash = window.location.hash.replace("#", "");
            var validTabs = ["manageStudents", "manageFaculty", "manageSubjects", "manageTimetables", "manageAttendance", "sendNotifications"];
            if (hash && validTabs.includes(hash)) {
                showContent(hash);
            } else {
                showContent("manageStudents");
            }
        }); // Default tab
    </script>
</body>
</html>