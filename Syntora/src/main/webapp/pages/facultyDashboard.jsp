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
            <%
                if (username != null) {
                    try (Connection conn = DBConnection.getConnection()) {
                        // Get faculty_id from username
                        String facultySql = "SELECT f.id AS faculty_id " +
                                           "FROM faculty f JOIN users u ON f.user_id = u.id " +
                                           "WHERE u.username = ?";
                        PreparedStatement facultyPs = conn.prepareStatement(facultySql);
                        facultyPs.setString(1, username);
                        ResultSet facultyRs = facultyPs.executeQuery();

                        if (facultyRs.next()) {
                            int facultyId = facultyRs.getInt("faculty_id");

                            // Query subjects taught by the faculty
                            String sql = "SELECT DISTINCT s.name AS subject_name, t.department, t.year, t.semester " +
                                         "FROM timetable_entry te " +
                                         "JOIN timetable t ON te.timetable_id = t.id " +
                                         "JOIN subjects s ON te.subject_id = s.id " +
                                         "WHERE te.faculty_id = ? " +
                                         "ORDER BY t.department, t.year, t.semester";
                            PreparedStatement ps = conn.prepareStatement(sql);
                            ps.setInt(1, facultyId);
                            ResultSet rs = ps.executeQuery();
                            boolean hasSubjects = false;
            %>
            <div class="card shadow-sm">
                <div class="card-header bg-primary text-white">
                    <strong><i class="fas fa-book"></i> Subjects You Are Teaching</strong>
                </div>
                <div class="card-body">
                    <table class="table table-bordered table-hover">
                        <thead>
                            <tr>
                                <th>Subject</th>
                                <th>Department</th>
                                <th>Year</th>
                                <th>Semester</th>
                            </tr>
                        </thead>
                        <tbody>
                            <%
                                while (rs.next()) {
                                    hasSubjects = true;
                            %>
                            <tr>
                                <td><%= rs.getString("subject_name") %></td>
                                <td><%= rs.getString("department") %></td>
                                <td><%= rs.getInt("year") %></td>
                                <td><%= rs.getInt("semester") %></td>
                            </tr>
                            <%
                                }
                                if (!hasSubjects) {
                            %>
                            <tr>
                                <td colspan="4" class="text-muted text-center">No subjects assigned to you.</td>
                            </tr>
                            <%
                                }
                            %>
                        </tbody>
                    </table>
                </div>
            </div>
            <%
                            rs.close();
                            ps.close();
                        } else {
            %>
            <p class="text-danger text-center">Error: Faculty record not found for username <%= username %>.</p>
            <%
                        }
                        facultyRs.close();
                        facultyPs.close();
                    } catch (Exception e) {
                        out.println("<p class='text-danger text-center'>Error loading subjects: " + e.getMessage() + "</p>");
                        e.printStackTrace();
                    }
                } else {
            %>
            <p class="text-danger text-center">Error: No user logged in. Please log in again.</p>
            <%
                }
            %>
        </div>

<div id="timetable" class="tab-content">
    <h2>Timetable</h2>
    <div class="card shadow-sm">
        <div class="card-header bg-primary text-white">
            <strong><i class="fas fa-calendar-alt"></i> Your Teaching Schedule</strong>
        </div>
        <div class="card-body">
            <%
                try (Connection conn = DBConnection.getConnection()) {
                    // Get faculty_id from users and faculty tables
                    String facultySql = "SELECT f.id AS faculty_id " +
                                       "FROM faculty f JOIN users u ON f.user_id = u.id " +
                                       "WHERE u.username = ?";
                    PreparedStatement facultyPs = conn.prepareStatement(facultySql);
                    facultyPs.setString(1, username);
                    ResultSet facultyRs = facultyPs.executeQuery();

                    if (facultyRs.next()) {
                        int facultyId = facultyRs.getInt("faculty_id");

                        // Query timetable entries
                        String sql = "SELECT te.day, te.time_slot, te.text_note, s.name AS subject, t.department, t.year, t.semester " +
                                     "FROM timetable_entry te " +
                                     "JOIN timetable t ON te.timetable_id = t.id " +
                                     "JOIN subjects s ON te.subject_id = s.id " +
                                     "WHERE te.faculty_id = ? " +
                                     "ORDER BY FIELD(te.day, 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'), te.time_slot";
                        PreparedStatement ps = conn.prepareStatement(sql);
                        ps.setInt(1, facultyId);
                        ResultSet rs = ps.executeQuery();

                        // Store timetable data in a map for efficient rendering
                        java.util.Map<String, java.util.Map<String, String>> timetableData = new java.util.HashMap<>();
                        String[] timeSlots = {"9:00 - 9:50", "9:50 - 10:40", "10:50 - 11:40", "11:40 - 12:30", "1:20 - 2:10", "2:10 - 3:00", "3:00 - 4:00"};
                        String[] days = {"Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"};

                        // Initialize the map
                        for (String day : days) {
                            timetableData.put(day, new java.util.HashMap<String, String>());
                            for (String slot : timeSlots) {
                                timetableData.get(day).put(slot, "");
                            }
                        }

                        // Populate the map with timetable data
                        boolean hasEntries = false;
                        while (rs.next()) {
                            hasEntries = true;
                            String day = rs.getString("day");
                            String timeSlot = rs.getString("time_slot");
                            String subject = rs.getString("subject");
                            String entryDepartment = rs.getString("department");
                            int year = rs.getInt("year");
                            int semester = rs.getInt("semester");
                            String textNote = rs.getString("text_note");

                            String entry = subject + "<br><small>" + entryDepartment + " - Year " + year + " - Sem " + semester + "</small>";
                            if (textNote != null && !textNote.trim().isEmpty()) {
                                entry += "<br><small>Note: " + textNote + "</small>";
                            }
                            timetableData.get(day).put(timeSlot, entry);
                        }
            %>
            <table class="table table-bordered table-hover text-center">
                <thead>
                    <tr>
                        <th>Time</th>
                        <%
                            for (String day : days) {
                        %>
                            <th><%= day %></th>
                        <%
                            }
                        %>
                    </tr>
                </thead>
                <tbody>
                    <%
                        for (String time : timeSlots) {
                    %>
                    <tr>
                        <td><%= time %></td>
                        <%
                            for (String day : days) {
                                String entry = timetableData.get(day).get(time);
                        %>
                        <td><%= entry.isEmpty() ? "-" : entry %></td>
                        <%
                            }
                        %>
                    </tr>
                    <%
                        }
                    %>
                </tbody>
            </table>
            <%
                        if (!hasEntries) {
            %>
            <p class="text-muted text-center">No timetable entries assigned for you.</p>
            <%
                        }
                        rs.close();
                        ps.close();
                    } else {
            %>
            <p class="text-danger text-center">Error: Faculty record not found for username <%= username %>.</p>
            <%
                    }
                    facultyRs.close();
                    facultyPs.close();
                } catch (Exception e) {
                    out.println("<p class='text-danger text-center'>Error loading timetable: " + e.getMessage() + "</p>");
                    e.printStackTrace();
                }
            %>
        </div>
    </div>

    <!-- Student Timetable Image Section -->
    <div class="card shadow-sm mt-4">
        <div class="card-header bg-primary text-white">
            <strong><i class="fas fa-calendar-alt"></i> Student Timetable Image</strong>
        </div>
        <div class="card-body">
            <form method="GET" action="facultyDashboard.jsp#timetable">
                <input type="hidden" name="form" value="studentTimetable">
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
                        <button type="submit" class="btn btn-primary w-100">Load Timetable</button>
                    </div>
                </div>
            </form>
            <%
                String studentTimetableFormType = request.getParameter("form");
                String studentTimetableDept = request.getParameter("department");
                String studentTimetableYearStr = request.getParameter("year");
                String studentTimetableSemesterStr = request.getParameter("semester");

                if ("studentTimetable".equals(studentTimetableFormType) && studentTimetableDept != null && studentTimetableYearStr != null && studentTimetableSemesterStr != null) {
                    try (Connection conn = DBConnection.getConnection()) {
                        int year = Integer.parseInt(studentTimetableYearStr);
                        int semester = Integer.parseInt(studentTimetableSemesterStr);

                        String sql = "SELECT image_path FROM timetable " +
                                     "WHERE department = ? AND year = ? AND semester = ?";
                        PreparedStatement ps = conn.prepareStatement(sql);
                        ps.setString(1, studentTimetableDept);
                        ps.setInt(2, year);
                        ps.setInt(3, semester);
                        ResultSet rs = ps.executeQuery();

                        if (rs.next()) {
                            String imagePath = rs.getString("image_path");
                            if (imagePath != null && !imagePath.trim().isEmpty()) {
            %>
                            <div class="text-center">
                                <img src="${pageContext.request.contextPath}/<%= imagePath %>" 
                                     alt="Student Timetable" 
                                     class="img-fluid rounded border timetable-image"
                                     style="max-width: 100%; max-height: 600px; cursor: pointer;"
                                     data-img-url="${pageContext.request.contextPath}/<%= imagePath %>">
                            </div>
            <%
                            } else {
            %>
                            <p class="text-muted text-center">No timetable image uploaded for <%= studentTimetableDept %> - Year <%= year %> - Semester <%= semester %>.</p>
            <%
                            }
                        } else {
            %>
                            <p class="text-muted text-center">No timetable available for <%= studentTimetableDept %> - Year <%= year %> - Semester <%= semester %>.</p>
            <%
                        }
                        rs.close();
                        ps.close();
                    } catch (Exception e) {
                        out.println("<p class='text-danger text-center'>Error loading student timetable: " + e.getMessage() + "</p>");
                        e.printStackTrace();
                    }
                }
            %>
        </div>
    </div>

    <!-- Fullscreen Image Modal -->
    <div class="modal fade" id="imageModal" tabindex="-1" role="dialog" aria-labelledby="imageModalLabel" aria-hidden="true">
        <div class="modal-dialog modal-xl modal-dialog-centered" role="document">
            <div class="modal-content bg-dark">
                <div class="modal-body text-center p-0">
                    <img src="" id="modalImage" class="img-fluid w-100" alt="Timetable">
                </div>
            </div>
        </div>
    </div>
</div>
       <div id="grades" class="tab-content">
            <h2>Update Grades</h2>
            <div class="card shadow-sm mb-4">
                <div class="card-header">Select Criteria</div>
                <div class="card-body">
                    <form method="GET" action="facultyDashboard.jsp#grades">
                        <input type="hidden" name="form" value="grades">
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
                String gradesDepartment = request.getParameter("department");
                String gradesYearStr = request.getParameter("year");
                String gradesSemesterStr = request.getParameter("semester");

                if ("grades".equals(formType) && gradesDepartment != null && gradesYearStr != null && gradesSemesterStr != null) {
                    try (Connection conn = DBConnection.getConnection()) {
                        int year = Integer.parseInt(gradesYearStr);
                        int semester = Integer.parseInt(gradesSemesterStr);
                        String sql = "SELECT s.roll_number, s.first_name, s.last_name, s.id " +
                                     "FROM students s JOIN users u ON s.user_id = u.id " +
                                     "WHERE u.department = ? AND u.year = ? AND u.semester = ?";
                        PreparedStatement ps = conn.prepareStatement(sql);
                        ps.setString(1, gradesDepartment);
                        ps.setInt(2, year);
                        ps.setInt(3, semester);
                        ResultSet rs = ps.executeQuery();

                        String subjectQuery = "SELECT id, name FROM subjects WHERE department = ? AND year = ? AND semester = ?";
                        PreparedStatement subPs = conn.prepareStatement(subjectQuery);
                        subPs.setString(1, gradesDepartment);
                        subPs.setInt(2, year);
                        subPs.setInt(3, semester);
                        ResultSet subRs = subPs.executeQuery();
            %>
            <div class="card shadow-sm">
                <div class="card-header">Grades for <%= gradesDepartment %> - Year <%= year %> - Semester <%= semester %></div>
                <div class="card-body">
                    <form method="POST" action="${pageContext.request.contextPath}/updateGrades">
                        <input type="hidden" name="department" value="<%= gradesDepartment %>">
                        <input type="hidden" name="year" value="<%= year %>">
                        <input type="hidden" name="semester" value="<%= semester %>">
                        <div class="row mb-3">
                            <div class="col-md-12">
                                <label>Select Subject:</label>
                                <select name="subjectId" class="form-control" required>
                                    <option value="">Select Subject</option>
                                    <% while (subRs.next()) { %>
                                        <option value="<%= subRs.getInt("id") %>"><%= subRs.getString("name") %></option>
                                    <% } %>
                                </select>
                            </div>
                        </div>
                        <table class="table table-bordered table-hover">
                            <thead>
                                <tr><th>Roll Number</th><th>Name</th><th>Grade</th></tr>
                            </thead>
                            <tbody>
                                <% while (rs.next()) { %>
                                    <tr>
                                        <td><%= rs.getString("roll_number") %></td>
                                        <td><%= rs.getString("first_name") %> <%= rs.getString("last_name") %></td>
                                        <td>
                                            <input type="text" name="grade_<%= rs.getString("roll_number") %>" class="form-control" placeholder="Enter grade (e.g., A, B, C)">
                                            <input type="hidden" name="rollNumbers" value="<%= rs.getString("roll_number") %>">
                                        </td>
                                    </tr>
                                <% } %>
                            </tbody>
                        </table>
                        <button type="submit" class="btn btn-success">Submit Grades</button>
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
            <h2>Received Notifications</h2>
            <div class="card p-3 shadow-sm">
                <%
                    int facultyId = -1;
                    String facultyDepartment = null;
                    try (Connection conn = DBConnection.getConnection()) {
                        String sql = "SELECT id, department FROM users WHERE username = ?";
                        PreparedStatement ps = conn.prepareStatement(sql);
                        ps.setString(1, (String) session.getAttribute("username"));
                        ResultSet rs = ps.executeQuery();
                        if (rs.next()) {
                            facultyId = rs.getInt("id");
                            facultyDepartment = rs.getString("department");
                        }
                        rs.close();
                        ps.close();

                        if (facultyId != -1) {
                            sql = "SELECT sender_id, user_type, department, year, message, date " +
                                  "FROM notifications " +
                                  "WHERE (user_id = ? OR (user_type = 'all' AND (department = ? OR department = 'all'))) " +
                                  "ORDER BY date DESC";
                            ps = conn.prepareStatement(sql);
                            ps.setInt(1, facultyId);
                            ps.setString(2, facultyDepartment != null ? facultyDepartment : "all");
                            rs = ps.executeQuery();
                %>
                <table class="table table-bordered table-hover">
                    <thead>
                        <tr>
                            <th>Sender</th>
                            <th>Recipient Type</th>
                            <th>Department</th>
                            <th>Year</th>
                            <th>Message</th>
                            <th>Date</th>
                        </tr>
                    </thead>
                    <tbody>
                        <%
                            boolean hasNotifications = false;
                            while (rs.next()) {
                                hasNotifications = true;
                                int senderId = rs.getInt("sender_id");
                                String userType = rs.getString("user_type");
                                String notificationDepartment = rs.getString("department");
                                String year = rs.getString("year");
                                String message = rs.getString("message");
                                String date = rs.getString("date");

                                String senderName = "Unknown";
                                sql = "SELECT username FROM users WHERE id = ?";
                                try (PreparedStatement psSender = conn.prepareStatement(sql)) {
                                    psSender.setInt(1, senderId);
                                    try (ResultSet rsSender = psSender.executeQuery()) {
                                        if (rsSender.next()) {
                                            senderName = rsSender.getString("username");
                                        }
                                    }
                                }
                        %>
                        <tr>
                            <td><%= senderName %></td>
                            <td><%= userType != null ? userType : "-" %></td>
                            <td><%= notificationDepartment != null ? notificationDepartment : "-" %></td>
                            <td><%= year != null ? year : "-" %></td>
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
                            <td colspan="6" class="text-muted">No notifications received.</td>
                        </tr>
                        <%
                            }
                        %>
                    </tbody>
                </table>
                <%
                        } else {
                %>
                <div class="alert alert-warning">Unable to retrieve faculty ID.</div>
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