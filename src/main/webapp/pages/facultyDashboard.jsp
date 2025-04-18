<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, syntora.db.DBConnection, java.text.SimpleDateFormat, java.util.Date" %>
<!DOCTYPE html>
<html>
<head>
    <title>Faculty Dashboard - Syntora</title>
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@400;500;600&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://bootswatch.com/5/flatly/bootstrap.min.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/5.15.3/css/all.min.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
    <script src="https://ajax.googleapis.com/ajax/libs/jquery/3.5.1/jquery.min.js"></script>
    <script src="https://maxcdn.bootstrapcdn.com/bootstrap/4.5.2/js/bootstrap.min.js"></script>
    <style>
        /* Ensure logout link is always clickable */
        .sidebar a.logout {
            pointer-events: auto !important;
            opacity: 1 !important;
            cursor: pointer !important;
        }
        /* Prevent sidebar links from being disabled */
        .sidebar a {
            display: block;
        }
    </style>
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
        <a href="#projects" onclick="showContent('projects')"><i class="fas fa-project-diagram"></i> Projects</a>
        <a href="#notifications" onclick="showContent('notifications')"><i class="fas fa-bell"></i> Notifications</a>
        <a href="${pageContext.request.contextPath}/pages/facultySendNotifications.jsp" class="active"><i class="fas fa-paper-plane"></i> Send Notifications</a>
        <a href="${pageContext.request.contextPath}/logout" class="logout"><i class="fas fa-sign-out-alt"></i> Logout</a>
    </div>
    <div class="content">
        <div id="personalDetails" class="tab-content active">
    <h2>Personal Details</h2>
    <%
        String username = (String) session.getAttribute("username");
        if (username == null) {
            out.println("<p class='text-danger'>Error: No user logged in. Please log in again.</p>");
        } else {
            try (Connection conn = DBConnection.getConnection()) {
                if (conn == null) {
                    out.println("<p class='text-danger'>Error: Database connection failed.</p>");
                } else {
                    String sql = "SELECT f.title, f.first_name, f.last_name, u.email, u.department " +
                                 "FROM faculty f JOIN users u ON f.user_id = u.id WHERE u.username = ?";
                    PreparedStatement ps = conn.prepareStatement(sql);
                    ps.setString(1, username);
                    ResultSet rs = ps.executeQuery();
                    if (rs.next()) {
    %>
    <div class="card shadow-sm">
        <div class="card-header bg-primary text-white">
            <strong><i class="fas fa-user"></i> Faculty Information</strong>
        </div>
        <div class="card-body">
            <div class="row mb-2">
                <div class="col-md-6"><strong>Title:</strong> <%= rs.getString("title") %></div>
                <div class="col-md-6"><strong>Name:</strong> <%= rs.getString("first_name") %> <%= rs.getString("last_name") %></div>
            </div>
            <div class="row mb-2">
                <div class="col-md-6"><strong>Email:</strong> <%= rs.getString("email") %></div>
                <div class="col-md-6"><strong>Department:</strong> <%= rs.getString("department") %></div>
            </div>
        </div>
    </div>
    <%
                    } else {
                        out.println("<p class='text-danger'>No personal details found for username: " + username + "</p>");
                    }
                    rs.close();
                    ps.close();
                }
            } catch (Exception e) {
                out.println("<p class='text-danger'>Error loading details: " + e.getMessage() + "</p>");
                e.printStackTrace();
            }
        }
    %>
</div>

        <!-- Other sections unchanged -->
        <div id="attendance" class="tab-content">
            <h2>Mark Attendance</h2>
            <div class="card shadow-sm mb-4">
                <div class="card-header">Select Criteria</div>
                <div class="card-body">
                    <form method="GET" action="facultyDashboard.jsp#attendance">
                    <input type="hidden" name="form" value="attendance">
                        <div class="row mb-3">
                            <div class="col-md-3">
                                <label>Department:</label>
                                <select name="department" class="form-control" required>
                                    <option value="">Select Department</option>
                                    <option value="CSE">CSE</option>
                                    <option value="ECE">ECE</option>
                                    <option value="IT">IT</option>
                                    <option value="AIML">AIML</option>
                                    <option value="EEE">EEE</option>
                                </select>
                            </div>
                            <div class="col-md-3">
                                <label>Year:</label>
                                <select name="year" class="form-control" required>
                                    <option value="">Select Year</option>
                                    <option value="1">1st Year</option>
                                    <option value="2">2nd Year</option>
                                    <option value="3">3rd Year</option>
                                    <option value="4">4th Year</option>
                                </select>
                            </div>
                            <div class="col-md-3">
                                <label>Semester:</label>
                                <select name="semester" class="form-control" required>
                                    <option value="">Select Semester</option>
                                    <option value="1">1</option>
                                    <option value="2">2</option>
                                    
                                </select>
                            </div>
                            <div class="col-md-3 align-self-end">
                                <button type="submit" class="btn btn-primary w-100">Load Students</button>
                            </div>
                        </div>
                    </form>
                </div>
            </div>

            <%
            	String formType = request.getParameter("form");
                String department = request.getParameter("department");
                String yearStr = request.getParameter("year");
                String semesterStr = request.getParameter("semester");

                if ("attendance".equals(formType) && department != null && yearStr != null && semesterStr != null) {
                    try (Connection conn = DBConnection.getConnection()) {
                        int year = Integer.parseInt(yearStr);
                        int semester = Integer.parseInt(semesterStr);
                        String sql = "SELECT s.roll_number, s.first_name, s.last_name, s.id " +
                                     "FROM students s JOIN users u ON s.user_id = u.id " +
                                     "WHERE u.department = ? AND u.year = ? AND u.semester = ?";
                        PreparedStatement ps = conn.prepareStatement(sql);
                        ps.setString(1, department);
                        ps.setInt(2, year);
                        ps.setInt(3, semester);
                        ResultSet rs = ps.executeQuery();

                        String subjectQuery = "SELECT id, name FROM subjects WHERE department = ? AND year = ? AND semester = ?";
                        PreparedStatement subPs = conn.prepareStatement(subjectQuery);
                        subPs.setString(1, department);
                        subPs.setInt(2, year);
                        subPs.setInt(3, semester);
                        ResultSet subRs = subPs.executeQuery();

                        // Get current date in YYYY-MM-DD format
                        SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd");
                        String currentDate = sdf.format(new Date());
            %>
            <div class="card shadow-sm">
                <div class="card-header">Attendance for <%= department %> - Year <%= year %> - Semester <%= semester %></div>
                <div class="card-body">
                    <form method="POST" action="${pageContext.request.contextPath}/markAttendance">
                        <input type="hidden" name="department" value="<%= department %>">
                        <input type="hidden" name="year" value="<%= year %>">
                        <input type="hidden" name="semester" value="<%= semester %>">
                        <div class="row mb-3">
                            <div class="col-md-6">
                                <label>Select Subject:</label>
                                <select name="subjectId" class="form-control" required>
                                    <option value="">Select Subject</option>
                                    <% while (subRs.next()) { %>
                                        <option value="<%= subRs.getInt("id") %>"><%= subRs.getString("name") %></option>
                                    <% } %>
                                </select>
                            </div>
                            <div class="col-md-6">
                                <label>Date:</label>
                                <input type="date" name="attendanceDate" class="form-control attendance-date" value="<%= currentDate %>" required>
                            </div>
                        </div>
                        <table class="table table-bordered table-hover">
                            <thead>
                                <tr><th>Roll Number</th><th>Name</th><th>Status</th></tr>
                            </thead>
                            <tbody>
                                <% while (rs.next()) { %>
                                    <tr>
                                        <td><%= rs.getString("roll_number") %></td>
                                        <td><%= rs.getString("first_name") %> <%= rs.getString("last_name") %></td>
                                        <td>
                                            <select name="status_<%= rs.getString("roll_number") %>" class="form-control">
                                                <option value="Present">Present</option>
                                                <option value="Absent">Absent</option>
                                            </select>
                                            <input type="hidden" name="rollNumbers" value="<%= rs.getString("roll_number") %>">
                                        </td>
                                    </tr>
                                <% } %>
                            </tbody>
                        </table>
                        <button type="submit" class="btn btn-success">Submit Attendance</button>
                    </form>
                </div>
            </div>
            <%
                        rs.close();
                        ps.close();
                        subRs.close();
                        subPs.close();
                    } catch (Exception e) {
                        out.println("<p class='text-danger'>Error: " + e.getMessage() + "</p>");
                        e.printStackTrace();
                    }
                }
            %>
        </div>
        <div id="subjects" class="tab-content">
            <h2>Subjects Taught</h2>
            <% try (Connection conn = DBConnection.getConnection()) {
                   String sql = "SELECT DISTINCT s.name, t.year, t.semester FROM timetable_entry te JOIN timetable t ON te.timetable_id = t.id JOIN subjects s ON te.subject_id = s.id WHERE te.faculty_id = (SELECT id FROM faculty WHERE email = ?)";
                   PreparedStatement ps = conn.prepareStatement(sql);
                   ps.setString(1, username);
                   ResultSet rs = ps.executeQuery();
            %>
            <table class="table table-striped">
                <thead><tr><th>Subject</th><th>Year</th><th>Semester</th></tr></thead>
                <tbody>
                <% while (rs.next()) { %>
                    <tr><td><%= rs.getString("name") %></td><td><%= rs.getInt("year") %></td><td><%= rs.getInt("semester") %></td></tr>
                <% } %>
                </tbody>
            </table>
            <%      } catch (Exception e) {
                    out.println("<p>Error loading subjects: " + e.getMessage() + "</p>");
                }
            %>
        </div>
        <div id="timetable" class="tab-content">
            <h2>Timetable</h2>
            <% try (Connection conn = DBConnection.getConnection()) {
                   String sql = "SELECT te.day, te.time_slot, s.name AS subject, t.department, t.year, t.semester " +
                                "FROM timetable_entry te JOIN timetable t ON te.timetable_id = t.id JOIN subjects s ON te.subject_id = s.id " +
                                "WHERE te.faculty_id = (SELECT id FROM faculty WHERE email = ?) " +
                                "ORDER BY FIELD(day, 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday')";
                   PreparedStatement ps = conn.prepareStatement(sql);
                   ps.setString(1, username);
                   ResultSet rs = ps.executeQuery();
            %>
            <table class="table table-striped">
                <thead><tr><th>Time</th><th>Monday</th><th>Tuesday</th><th>Wednesday</th><th>Thursday</th><th>Friday</th><th>Saturday</th></tr></thead>
                <tbody>
                <% String[] times = {"9:00-10:00", "10:00-11:00", "11:00-12:00", "12:00-1:00", "2:00-3:00", "3:00-4:00"};
                   for (String time : times) {
                %>
                <tr><td><%= time %></td>
                <% for (String day : new String[]{"Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"}) {
                       rs.beforeFirst();
                       String subject = "";
                       while (rs.next()) {
                           if (rs.getString("day").equals(day) && rs.getString("time_slot").equals(time)) {
                               subject = rs.getString("subject");
                               break;
                           }
                       }
                %>
                <td><%= subject.isEmpty() ? "-" : subject %></td>
                <% } %>
                </tr>
                <% } %>
                </tbody>
            </table>
            <%      } catch (Exception e) {
                    out.println("<p>Error loading timetable: " + e.getMessage() + "</p>");
                }
            %>
        </div>
        <div id="grades" class="tab-content">
            <h2>Update Grades</h2>
            <% try (Connection conn = DBConnection.getConnection()) {
                   String sql = "SELECT DISTINCT s.id, s.roll_number, CONCAT(s.first_name, ' ', s.last_name) AS student_name " +
                                "FROM students s JOIN timetable t ON s.department = t.department AND s.year = t.year AND s.semester = t.semester " +
                                "JOIN timetable_entry te ON t.id = te.timetable_id WHERE te.faculty_id = (SELECT id FROM faculty WHERE email = ?)";
                   PreparedStatement ps = conn.prepareStatement(sql);
                   ps.setString(1, username);
                   ResultSet rs = ps.executeQuery();
            %>
            <form action="${pageContext.request.contextPath}/updateGrades" method="post" class="card">
                <div class="form-group">
                    <label>Student</label>
                    <select name="studentId" class="form-control" required>
                        <% while (rs.next()) { %>
                        <option value="<%= rs.getInt("id") %>"><%= rs.getString("roll_number") %> - <%= rs.getString("student_name") %></option>
                        <% } %>
                    </select>
                </div>
                <div class="form-group">
                    <label>Subject</label>
                    <select name="subjectId" class="form-control" required>
                        <% 
                            try (Connection conn2 = DBConnection.getConnection()) {
                                String sql2 = "SELECT DISTINCT s.id, s.name FROM subjects s JOIN timetable_entry te ON s.id = te.subject_id WHERE te.faculty_id = (SELECT id FROM faculty WHERE email = ?)";
                                PreparedStatement ps2 = conn2.prepareStatement(sql2);
                                ps2.setString(1, username);
                                ResultSet rs2 = ps2.executeQuery();
                                while (rs2.next()) {
                        %>
                        <option value="<%= rs2.getInt("id") %>"><%= rs2.getString("name") %></option>
                        <%      }
                            } catch (Exception e) {
                                out.println("<p>Error loading subjects: " + e.getMessage() + "</p>");
                            }
                        %>
                    </select>
                </div>
                <div class="form-group">
                    <label>Grade</label>
                    <input type="text" name="grade" class="form-control" required>
                </div>
                <button type="submit" class="btn">Update Grade</button>
            </form>
            <%      } catch (Exception e) {
                    out.println("<p>Error loading students: " + e.getMessage() + "</p>");
                }
            %>
        </div>
        <div id="remarks" class="tab-content">
            <h2>Add Remarks for Students</h2>
            <%
                String status = request.getParameter("status");
                if ("success".equals(status)) {
                    out.println("<div class='alert alert-success alert-dismissible fade show' role='alert'>" +
                                "<i class='fas fa-check-circle'></i> Remark added successfully!" +
                                "<button type='button' class='btn-close' data-bs-dismiss='alert' aria-label='Close'></button>" +
                                "</div>");
                } else if ("error".equals(status)) {
                    out.println("<div class='alert alert-danger alert-dismissible fade show' role='alert'>" +
                                "<i class='fas fa-exclamation-circle'></i> Error adding remark. Please try again." +
                                "<button type='button' class='btn-close' data-bs-dismiss='alert' aria-label='Close'></button>" +
                                "</div>");
                } else if ("notFound".equals(status)) {
                    out.println("<div class='alert alert-warning alert-dismissible fade show' role='alert'>" +
                                "<i class='fas fa-exclamation-triangle'></i> Student roll number not found." +
                                "<button type='button' class='btn-close' data-bs-dismiss='alert' aria-label='Close'></button>" +
                                "</div>");
                } else if ("invalidInput".equals(status)) {
                    out.println("<div class='alert alert-warning alert-dismissible fade show' role='alert'>" +
                                "<i class='fas fa-exclamation-triangle'></i> Please fill all required fields." +
                                "<button type='button' class='btn-close' data-bs-dismiss='alert' aria-label='Close'></button>" +
                                "</div>");
                }
            %>
            <div class="card shadow-sm mb-4">
                <div class="card-header bg-primary text-white">
                    <strong><i class="fas fa-comment"></i> Add Remark</strong>
                </div>
                <div class="card-body">
                    <form action="${pageContext.request.contextPath}/addRemark" method="post">
                        <div class="row mb-3">
                            <div class="col-md-3">
                                <label for="department">Department:</label>
                                <select name="department" id="department" class="form-control" required>
                                    <option value="">Select Department</option>
                                    <option value="CSE">CSE</option>
                                    <option value="ECE">ECE</option>
                                    <option value="IT">IT</option>
                                    <option value="AIML">AIML</option>
                                    <option value="EEE">EEE</option>
                                </select>
                            </div>
                            <div class="col-md-3">
                                <label for="year">Year:</label>
                                <select name="year" id="year" class="form-control" required>
                                    <option value="">Select Year</option>
                                    <option value="1">1st Year</option>
                                    <option value="2">2nd Year</option>
                                    <option value="3">3rd Year</option>
                                    <option value="4">4th Year</option>
                                </select>
                            </div>
                            <div class="col-md-3">
                                <label for="semester">Semester:</label>
                                <select name="semester" id="semester" class="form-control" required>
                                    <option value="">Select Semester</option>
                                    <option value="1">1</option>
                                    <option value="2">2</option>
                        
                                </select>
                            </div>
                            <div class="col-md-3">
                                <label for="rollNumber">Roll Number:</label>
                                <input type="text" name="rollNumber" id="rollNumber" class="form-control" required>
                            </div>
                        </div>
                        <div class="form-group mb-3">
                            <label for="remark">Remark:</label>
                            <textarea name="remark" id="remark" class="form-control" rows="4" required></textarea>
                        </div>
                        <div class="d-flex justify-content-between">
                            <button type="submit" class="btn btn-success">
                                <i class="fas fa-save"></i> Submit Remark
                            </button>
                            <button type="button" class="btn btn-primary" onclick="showContent('personalDetails')">
                                <i class="fas fa-arrow-left"></i> Back to Dashboard
                            </button>
                        </div>
                    </form>
                </div>
            </div>
        </div>
        <div id="projects" class="tab-content">
            <h2>Student Projects</h2>
            <div class="card shadow-sm mb-4">
                <div class="card-header bg-primary text-white">
                    <strong><i class="fas fa-project-diagram"></i> Select Criteria</strong>
                </div>
                <div class="card-body">
                    <form method="GET" action="facultyDashboard.jsp#projects">
                    <input type="hidden" name="form" value="projects">
                        <div class="row mb-3">
                            <div class="col-md-3">
                                <label for="department">Department:</label>
                                <select name="department" id="department" class="form-control" required>
                                    <option value="">Select Department</option>
                                    <option value="CSE">CSE</option>
                                    <option value="ECE">ECE</option>
                                    <option value="IT">IT</option>
                                    <option value="AIML">AIML</option>
                                    <option value="EEE">EEE</option>
                                </select>
                            </div>
                            <div class="col-md-3">
                                <label for="year">Year:</label>
                                <select name="year" id="year" class="form-control" required>
                                    <option value="">Select Year</option>
                                    <option value="1">1st Year</option>
                                    <option value="2">2nd Year</option>
                                    <option value="3">3rd Year</option>
                                    <option value="4">4th Year</option>
                                </select>
                            </div>
                            <div class="col-md-3">
                                <label for="semester">Semester:</label>
                                <select name="semester" id="semester" class="form-control" required>
                                    <option value="">Select Semester</option>
                                    <option value="1">1</option>
                                    <option value="2">2</option>
                                   
                                </select>
                            </div>
                            <div class="col-md-3 align-self-end">
                                <button type="submit" class="btn btn-primary w-100">Load Projects</button>
                            </div>
                        </div>
                    </form>
                </div>
            </div>

            <%
                String projDepartment = request.getParameter("department");
                String projYearStr = request.getParameter("year");
                String projSemesterStr = request.getParameter("semester");

                if ("projects".equals(formType) && department != null && yearStr != null && semesterStr != null) {
                    try (Connection conn = DBConnection.getConnection()) {
                        int year = Integer.parseInt(projYearStr);
                        int semester = Integer.parseInt(projSemesterStr);
                        String sql = "SELECT s.roll_number, s.first_name, s.last_name, p.title, p.description, p.status, p.github_link " +
                                     "FROM projects p " +
                                     "JOIN students s ON p.student_id = s.id " +
                                     "JOIN users u ON s.user_id = u.id " +
                                     "WHERE u.department = ? AND u.year = ? AND u.semester = ? " +
                                     "ORDER BY s.roll_number, p.id DESC";
                        PreparedStatement ps = conn.prepareStatement(sql);
                        ps.setString(1, projDepartment);
                        ps.setInt(2, year);
                        ps.setInt(3, semester);
                        ResultSet rs = ps.executeQuery();
                        boolean hasProjects = false;
            %>
            <div class="card shadow-sm">
                <div class="card-header">Projects for <%= projDepartment %> - Year <%= year %> - Semester <%= semester %></div>
                <div class="card-body">
                    <div class="row">
                        <% while (rs.next()) { 
                               hasProjects = true;
                        %>
                        <div class="col-md-6 mb-4">
                            <div class="card h-100 shadow-sm">
                                <div class="card-header bg-primary text-white">
                                    <strong><i class="fas fa-project-diagram"></i> <%= rs.getString("title") %></strong>
                                </div>
                                <div class="card-body">
                                    <p><strong>Student:</strong> <%= rs.getString("roll_number") %> - <%= rs.getString("first_name") %> <%= rs.getString("last_name") %></p>
                                    <p><strong>Description:</strong> <%= rs.getString("description") %></p>
                                    <p><strong>Status:</strong> <%= rs.getString("status") %></p>
                                    <%
                                        String githubLink = rs.getString("github_link");
                                        if (githubLink != null && !githubLink.trim().isEmpty()) {
                                    %>
                                    <p>
                                        <strong>GitHub:</strong>
                                        <a href="<%= githubLink %>" target="_blank" class="github-link">
                                            <i class="fab fa-github"></i> <%= githubLink %>
                                        </a>
                                    </p>
                                    <%
                                        } else {
                                    %>
                                    <p class="text-muted"><strong>GitHub:</strong> Not provided</p>
                                    <%
                                        }
                                    %>
                                </div>
                            </div>
                        </div>
                        <% } %>
                        <% if (!hasProjects) { %>
                        <div class="col-12">
                            <p class="text-muted">No projects found for the selected criteria.</p>
                        </div>
                        <% } %>
                    </div>
                </div>
            </div>
            <%
                        rs.close();
                        ps.close();
                    } catch (Exception e) {
                        out.println("<p class='text-danger'>Error loading projects: " + e.getMessage() + "</p>");
                        e.printStackTrace();
                    }
                }
            %>
        </div>
        
        <div id="notifications" class="tab-content">
    <h2>Notifications</h2>
    <% try (Connection conn = DBConnection.getConnection()) {
           String sql = "SELECT n.message, n.date, CONCAT(u.first_name, ' ', u.last_name) AS sender_name " +
                        "FROM notifications n JOIN users u ON n.sender_id = u.id " +
                        "WHERE n.user_id = (SELECT id FROM users WHERE username = ?) AND n.user_type = 'faculty' " +
                        "ORDER BY n.date DESC";
           PreparedStatement ps = conn.prepareStatement(sql);
           ps.setString(1, username);
           ResultSet rs = ps.executeQuery();
           boolean hasNotifications = false;
    %>
    <div class="row">
        <% while (rs.next()) { 
               hasNotifications = true;
        %>
        <div class="col-md-6 mb-4">
            <div class="card h-100 shadow-sm">
                <div class="card-header bg-primary text-white">
                    <strong><i class="fas fa-bell"></i> Notification from <%= rs.getString("sender_name") %></strong>
                </div>
                <div class="card-body">
                    <p class="card-text"><%= rs.getString("message") %></p>
                    <p class="text-muted"><small><i class="fas fa-calendar"></i> <%= rs.getString("date") %></small></p>
                </div>
            </div>
        </div>
        <% } %>
        <% if (!hasNotifications) { %>
        <div class="col-12">
            <p class="text-muted">No notifications available.</p>
        </div>
        <% } %>
    </div>
    <%      rs.close();
            ps.close();
        } catch (Exception e) {
            out.println("<p class='text-danger'>Error loading notifications: " + e.getMessage() + "</p>");
        }
    %>
</div>
    </div>
    <script>
        function showContent(tabId) {
            $(".tab-content").removeClass("active");
            $("#" + tabId).addClass("active");
            $(".sidebar a").removeClass("active");
            $(".sidebar a:not(.logout)").removeClass("active");
            $(`.sidebar a[href="#${tabId}"]`).addClass("active");
        }
        $(".sidebar a.logout").click(function(e) {
            // Allow default navigation
            window.location.href = $(this).attr("href");
        });
        $(".toggle-btn").click(function() {
            $(".sidebar").toggleClass("active");
        });
        $(document).ready(function() {
            var hash = window.location.hash.replace("#", "");
            var validTabs = ["personalDetails", "attendance", "subjects", "timetable", "grades", "remarks", "projects", "notifications"];
            if (hash && validTabs.includes(hash)) {
                showContent(hash);
            } else {
                showContent("personalDetails");
            }
        });
    </script>
</body>
</html>