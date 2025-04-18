<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, syntora.db.DBConnection" %>
<!DOCTYPE html>
<html>
<head>
    <title>Student Dashboard - Syntora</title>
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
        <h3><i class="fas fa-school"></i> Syntora Student</h3>
        <a href="#personalDetails" onclick="showContent('personalDetails')"><i class="fas fa-user"></i> Personal Details</a>
        <a href="#attendance" onclick="showContent('attendance')"><i class="fas fa-check-square"></i> Attendance</a>
        <a href="#subjects" onclick="showContent('subjects')"><i class="fas fa-book"></i> Subjects</a>
        <a href="#timetable" onclick="showContent('timetable')"><i class="fas fa-calendar-alt"></i> Timetable</a>
        <a href="#projects" onclick="showContent('projects')"><i class="fas fa-project-diagram"></i> Projects</a>
        <a href="#grades" onclick="showContent('grades')"><i class="fas fa-graduation-cap"></i> Grades</a>
        <a href="#remarks" onclick="showContent('remarks')"><i class="fas fa-comment"></i> Remarks</a>
        <a href="#notifications" onclick="showContent('notifications')"><i class="fas fa-bell"></i> Notifications</a>
        <a href="logout" class="logout"><i class="fas fa-sign-out-alt"></i> Logout</a>
    </div>
    <div class="content">
        <div id="personalDetails" class="tab-content active">
    <h2>Personal Details</h2>
    <%
        String username = (String) session.getAttribute("username");
        if (username == null) {
            out.println("<p>Error: No user logged in. Please log in again.</p>");
        } else {
            try (Connection conn = DBConnection.getConnection()) {
                if (conn == null) {
                    out.println("<p>Error: Database connection failed.</p>");
                } else {
                    String sql = "SELECT s.roll_number, s.first_name, s.last_name, s.dob, s.address, u.department, u.year, u.semester " +
                                 "FROM students s JOIN users u ON s.user_id = u.id WHERE u.username = ?";
                    PreparedStatement ps = conn.prepareStatement(sql);
                    ps.setString(1, username);
                    ResultSet rs = ps.executeQuery();
                    if (rs.next()) {
    %>
    <div class="card shadow-sm">
        <div class="card-header bg-primary text-white">
            <strong><i class="fas fa-user"></i> Student Information</strong>
        </div>
        <div class="card-body">
            <div class="row mb-2">
                <div class="col-md-6"><strong>Roll Number:</strong> <%= rs.getString("roll_number") %></div>
                <div class="col-md-6"><strong>Name:</strong> <%= rs.getString("first_name") %> <%= rs.getString("last_name") %></div>
            </div>
            <div class="row mb-2">
                <div class="col-md-6"><strong>DOB:</strong> <%= rs.getString("dob") %></div>
                <div class="col-md-6"><strong>Address:</strong> <%= rs.getString("address") %></div>
            </div>
            <div class="row mb-2">
                <div class="col-md-6"><strong>Department:</strong> <%= rs.getString("department") %></div>
                <div class="col-md-3"><strong>Year:</strong> <%= rs.getInt("year") %></div>
                <div class="col-md-3"><strong>Semester:</strong> <%= rs.getInt("semester") %></div>
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
                e.printStackTrace(); // Log to server console
            }
        }
    %>
</div>

        <!-- Other tab-content sections remain unchanged -->
                <div id="attendance" class="tab-content">
            <h2>Attendance</h2>
            <div class="card shadow-sm">
                <div class="card-header bg-primary text-white">
                    <strong><i class="fas fa-check-square"></i> Subject-wise Attendance</strong>
                </div>
                <div class="card-body">
                    <%
                        try (Connection conn = DBConnection.getConnection()) {
                            if (conn == null) {
                                out.println("<p class='text-danger'>Error: Database connection failed.</p>");
                            } else {
                                // Debug: Log username (uncomment if needed)
                                // out.println("<!-- Debug: Username from session: " + username + " -->");

                                // Step 1: Get student_id, department, year, semester
                                String studentSql = "SELECT s.id AS student_id, u.department, u.year, u.semester " +
                                                  "FROM students s JOIN users u ON s.user_id = u.id " +
                                                  "WHERE u.username = ?";
                                PreparedStatement studentPs = conn.prepareStatement(studentSql);
                                studentPs.setString(1, username);
                                ResultSet studentRs = studentPs.executeQuery();
                                int studentId = -1;
                                String department = null;
                                int year = -1, semester = -1;

                                if (studentRs.next()) {
                                    studentId = studentRs.getInt("student_id");
                                    department = studentRs.getString("department");
                                    year = studentRs.getInt("year");
                                    semester = studentRs.getInt("semester");
                                } else {
                                    out.println("<p class='text-danger'>Error: No student record found for username: " + username + "</p>");
                                    studentRs.close();
                                    studentPs.close();
                                    return;
                                }
                                studentRs.close();
                                studentPs.close();

                                // Debug: Log student details (uncomment if needed)
                                // out.println("<!-- Debug: Student ID: " + studentId + ", Dept: " + department + ", Year: " + year + ", Sem: " + semester + " -->");

                                // Step 2: Get all subjects for the student's department, year, semester
                                String subjectSql = "SELECT id, name FROM subjects " +
                                                  "WHERE department = ? AND year = ? AND semester = ? " +
                                                  "ORDER BY name";
                                PreparedStatement subjectPs = conn.prepareStatement(subjectSql);
                                subjectPs.setString(1, department);
                                subjectPs.setInt(2, year);
                                subjectPs.setInt(3, semester);
                                ResultSet subjectRs = subjectPs.executeQuery();
                                boolean hasSubjects = false;

                                while (subjectRs.next()) {
                                    hasSubjects = true;
                                    int subjectId = subjectRs.getInt("id");
                                    String subjectName = subjectRs.getString("name");

                                    // Step 3: Get attendance for this subject and student
                                    String attendanceSql = "SELECT date, status FROM attendance " +
                                                         "WHERE student_id = ? AND subject_id = ? " +
                                                         "ORDER BY date DESC";
                                    PreparedStatement attendancePs = conn.prepareStatement(attendanceSql);
                                    attendancePs.setInt(1, studentId);
                                    attendancePs.setInt(2, subjectId);
                                    ResultSet attendanceRs = attendancePs.executeQuery();
                    %>
                    <h5 class="mb-3"><%= subjectName %></h5>
                    <table class="table table-bordered table-hover attendance-table">
                        <thead>
                            <tr><th>Date</th><th>Status</th></tr>
                        </thead>
                        <tbody>
                            <%
                                boolean hasAttendance = false;
                                while (attendanceRs.next()) {
                                    hasAttendance = true;
                                    String status = attendanceRs.getString("status");
                                    // Validate status to ensure only valid values are shown
                                    if ("Present".equals(status) || "Absent".equals(status)) {
                            %>
                            <tr>
                                <td><%= attendanceRs.getString("date") %></td>
                                <td><%= status %></td>
                            </tr>
                            <%
                                    }
                                }
                                if (!hasAttendance) {
                            %>
                            <tr>
                                <td>-</td>
                                <td>-</td>
                            </tr>
                            <%
                                }
                            %>
                        </tbody>
                    </table>
                    <%
                                    attendanceRs.close();
                                    attendancePs.close();
                                }
                                subjectRs.close();
                                subjectPs.close();

                                if (!hasSubjects) {
                                    out.println("<p class='text-muted'>No subjects assigned for " + 
                                                (department != null ? department : "Unknown") + 
                                                " - Year " + year + " - Semester " + semester + ".</p>");
                                }
                            }
                        } catch (SQLException e) {
                            out.println("<p class='text-danger'>SQL Error: " + e.getMessage() + "</p>");
                            e.printStackTrace();
                        } catch (Exception e) {
                            out.println("<p class='text-danger'>Unexpected Error: " + e.getMessage() + "</p>");
                            e.printStackTrace();
                        }
                    %>
                </div>
            </div>
        </div>
<div id="subjects" class="tab-content">
    <h2>Subjects</h2>
    <%
        try (Connection conn = DBConnection.getConnection()) {
            String sql = "SELECT u.department, u.year, u.semester " +
                         "FROM users u JOIN students s ON u.id = s.user_id " +
                         "WHERE u.username = ?";
            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setString(1, username);
            ResultSet rs = ps.executeQuery();

            if (rs.next()) {
                String dept = rs.getString("department");
                int year = rs.getInt("year");
                int sem = rs.getInt("semester");

                PreparedStatement subjectPs = conn.prepareStatement(
                    "SELECT sub.name, sub.syllabus_image, CONCAT(f.first_name, ' ', f.last_name) AS faculty_name " +
                    "FROM subjects sub " +
                    "LEFT JOIN faculty f ON sub.faculty_id = f.id " +
                    "WHERE sub.department = ? AND sub.year = ? AND sub.semester = ?"
                );
                subjectPs.setString(1, dept);
                subjectPs.setInt(2, year);
                subjectPs.setInt(3, sem);
                ResultSet subjectRs = subjectPs.executeQuery();
    %>
    <div class="row">
        <%
            boolean found = false;
            while (subjectRs.next()) {
                found = true;
        %>
        <div class="col-md-6 mb-4">
            <div class="card h-100 shadow-sm">
                <div class="card-header bg-primary text-white">
                    <strong><i class="fas fa-book"></i> <%= subjectRs.getString("name") %></strong>
                </div>
                <div class="card-body">
                    <p><strong>Faculty:</strong> <%= subjectRs.getString("faculty_name") != null ? subjectRs.getString("faculty_name") : "Not Assigned" %></p>
                    <%
                        String syllabusImage = subjectRs.getString("syllabus_image");
                        if (syllabusImage != null && !syllabusImage.trim().isEmpty()) {
                    %>
                        <div>
    <strong>Syllabus:</strong><br>
    <img src="${pageContext.request.contextPath}/uploads/syllabus/<%= syllabusImage %>"
         alt="Syllabus"
         class="img-fluid mt-2 rounded border syllabus-thumbnail"
         style="max-height: 300px; cursor: pointer;"
         data-img-url="${pageContext.request.contextPath}/uploads/syllabus/<%= syllabusImage %>" />
</div>

                    <%
                        } else {
                    %>
                        <p class="text-muted">No syllabus uploaded.</p>
                    <%
                        }
                    %>
                </div>
            </div>
        </div>
        <% } %>
        <% if (!found) { %>
            <p class="text-muted px-3">No subjects assigned yet.</p>
        <% } %>
    </div>
    <%
                subjectRs.close();
                subjectPs.close();
            } else {
                out.println("<p class='text-danger'>Student academic info not found.</p>");
            }
            rs.close();
            ps.close();
        } catch (Exception e) {
            out.println("<p>Error loading subjects: " + e.getMessage() + "</p>");
        }
    %>
</div>


        <div id="timetable" class="tab-content">
    <h2>Timetable</h2>
    <div class="card shadow-sm">
        <div class="card-header bg-primary text-white">
            <strong><i class="fas fa-calendar-alt"></i> Your Timetable</strong>
        </div>
        <div class="card-body">
            <%
                try (Connection conn = DBConnection.getConnection()) {
                    // Get student details (department, year, semester)
                    String userSql = "SELECT department, year, semester " +
                                    "FROM users u JOIN students s ON u.id = s.user_id " +
                                    "WHERE u.username = ?";
                    PreparedStatement userPs = conn.prepareStatement(userSql);
                    userPs.setString(1, username);
                    ResultSet userRs = userPs.executeQuery();

                    if (userRs.next()) {
                        String department = userRs.getString("department");
                        int year = userRs.getInt("year");
                        int semester = userRs.getInt("semester");

                        // Query timetable table for the image
                        String timetableSql = "SELECT image_path FROM timetable " +
                                             "WHERE department = ? AND year = ? AND semester = ?";
                        PreparedStatement timetablePs = conn.prepareStatement(timetableSql);
                        timetablePs.setString(1, department);
                        timetablePs.setInt(2, year);
                        timetablePs.setInt(3, semester);
                        ResultSet timetableRs = timetablePs.executeQuery();

                        if (timetableRs.next()) {
                            String imagePath = timetableRs.getString("image_path");
                            if (imagePath != null && !imagePath.trim().isEmpty()) {
            %>
                            <div class="text-center">
                                <img src="${pageContext.request.contextPath}/<%= imagePath %>" 
                                     alt="Timetable" 
                                     class="img-fluid rounded border timetable-image"
                                     style="max-width: 100%; max-height: 600px; cursor: pointer;"
                                     data-img-url="${pageContext.request.contextPath}/<%= imagePath %>">
                            </div>
            <%
                            } else {
            %>
                            <p class="text-muted">No timetable image uploaded.</p>
            <%
                            }
                        } else {
            %>
                            <p class="text-muted">No timetable available for <%= department %> - Year <%= year %> - Semester <%= semester %>.</p>
            <%
                        }
                        timetableRs.close();
                        timetablePs.close();
                    } else {
            %>
                        <p class="text-danger">Error: Student academic info not found.</p>
            <%
                    }
                    userRs.close();
                    userPs.close();
                } catch (Exception e) {
                    out.println("<p class='text-danger'>Error loading timetable: " + e.getMessage() + "</p>");
                    e.printStackTrace();
                }
            %>
        </div>
    </div>
</div>
        <div id="projects" class="tab-content">
    <h2>Projects</h2>
    <%
        String status = request.getParameter("status");
        if ("success".equals(status)) {
            out.println("<div class='alert alert-success alert-dismissible fade show' role='alert'>" +
                        "<i class='fas fa-check-circle'></i> Project added successfully!" +
                        "<button type='button' class='close' data-dismiss='alert' aria-label='Close'><span aria-hidden='true'>×</span></button>" +
                        "</div>");
        } else if ("error".equals(status)) {
            out.println("<div class='alert alert-danger alert-dismissible fade show' role='alert'>" +
                        "<i class='fas fa-exclamation-circle'></i> Error adding project. Please try again." +
                        "<button type='button' class='close' data-dismiss='alert' aria-label='Close'><span aria-hidden='true'>×</span></button>" +
                        "</div>");
        } else if ("invalidInput".equals(status)) {
            out.println("<div class='alert alert-warning alert-dismissible fade show' role='alert'>" +
                        "<i class='fas fa-exclamation-triangle'></i> Please fill all required fields." +
                        "<button type='button' class='close' data-dismiss='alert' aria-label='Close'><span aria-hidden='true'>×</span></button>" +
                        "</div>");
        } else if ("invalidLink".equals(status)) {
            out.println("<div class='alert alert-warning alert-dismissible fade show' role='alert'>" +
                        "<i class='fas fa-exclamation-triangle'></i> Invalid GitHub link. Please use a valid GitHub URL." +
                        "<button type='button' class='close' data-dismiss='alert' aria-label='Close'><span aria-hidden='true'>×</span></button>" +
                        "</div>");
        }
    %>

    <!-- Add Project Form -->
    <div class="card shadow-sm mb-4">
        <div class="card-header bg-primary text-white">
            <strong><i class="fas fa-plus-circle"></i> Add New Project</strong>
        </div>
        <div class="card-body">
            <form action="${pageContext.request.contextPath}/addProject" method="post">
                <div class="form-group mb-3">
                    <label for="title">Project Title:</label>
                    <input type="text" name="title" id="title" class="form-control" required>
                </div>
                <div class="form-group mb-3">
                    <label for="description">Description:</label>
                    <textarea name="description" id="description" class="form-control" rows="4" required></textarea>
                </div>
                <div class="form-group mb-3">
                    <label for="githubLink">GitHub Link (Optional):</label>
                    <input type="url" name="githubLink" id="githubLink" class="form-control" placeholder="https://github.com/username/repo">
                </div>
                <button type="submit" class="btn btn-success">
                    <i class="fas fa-save"></i> Add Project
                </button>
            </form>
        </div>
    </div>

    <!-- Existing Projects -->
    <%
        try (Connection conn = DBConnection.getConnection()) {
            String studentIdQuery = "SELECT s.id FROM students s JOIN users u ON s.user_id = u.id WHERE u.username = ?";
            PreparedStatement psStudent = conn.prepareStatement(studentIdQuery);
            psStudent.setString(1, username);
            ResultSet rsStudent = psStudent.executeQuery();

            int studentId = -1;
            if (rsStudent.next()) {
                studentId = rsStudent.getInt("id");
            }
            rsStudent.close();
            psStudent.close();

            if (studentId != -1) {
                String sql = "SELECT title, description, status, github_link FROM projects WHERE student_id = ? ORDER BY id DESC";
                PreparedStatement ps = conn.prepareStatement(sql);
                ps.setInt(1, studentId);
                ResultSet rs = ps.executeQuery();
                boolean hasProjects = false;
    %>
    <div class="row">
        <%
            while (rs.next()) {
                hasProjects = true;
        %>
        <div class="col-md-6 mb-4">
            <div class="card h-100 shadow-sm">
                <div class="card-header bg-primary text-white">
                    <strong><i class="fas fa-project-diagram"></i> <%= rs.getString("title") %></strong>
                </div>
                <div class="card-body">
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
            <p class="text-muted">No projects added yet.</p>
        </div>
        <% } %>
    </div>
    <%
                rs.close();
                ps.close();
            } else {
                out.println("<p class='text-danger'>Student record not found for the current user.</p>");
            }
        } catch (Exception e) {
            out.println("<p class='text-danger'>Error loading projects: " + e.getMessage() + "</p>");
            e.printStackTrace();
        }
    %>
</div>

<div id="grades" class="tab-content">
            <h2>Grades</h2>
            <%
                try (Connection conn = DBConnection.getConnection()) {
                    String sql = "SELECT s.name AS subject, g.grade " +
                                 "FROM grades g " +
                                 "JOIN students st ON g.student_id = st.id " +
                                 "JOIN users u ON st.user_id = u.id " +
                                 "JOIN subjects s ON g.subject_id = s.id " +
                                 "WHERE u.username = ? ORDER BY s.name";
                    PreparedStatement ps = conn.prepareStatement(sql);
                    ps.setString(1, username);
                    ResultSet rs = ps.executeQuery();
                    boolean hasGrades = false;
            %>
            <div class="card shadow-sm grades-card">
                <div class="card-header bg-primary text-white">
                    <strong><i class="fas fa-graduation-cap"></i> Academic Grades</strong>
                </div>
                <div class="card-body">
                    <table class="table table-striped table-hover grades-table">
                        <thead>
                            <tr>
                                <th>Subject</th>
                                <th>Grade</th>
                            </tr>
                        </thead>
                        <tbody>
                            <%
                                while (rs.next()) {
                                    hasGrades = true;
                                    String grade = rs.getString("grade");
                                    String gradeClass = "";
                                    switch (grade != null ? grade.toUpperCase() : "") {
                                        case "A":
                                            gradeClass = "grade-A";
                                            break;
                                        case "B":
                                            gradeClass = "grade-B";
                                            break;
                                        case "C":
                                            gradeClass = "grade-C";
                                            break;
                                        case "D":
                                        case "F":
                                            gradeClass = "grade-D";
                                            break;
                                        default:
                                            gradeClass = "";
                                    }
                            %>
                            <tr>
                                <td><%= rs.getString("subject") %></td>
                                <td class="<%= gradeClass %>"><%= grade %></td>
                            </tr>
                            <%
                                }
                                if (!hasGrades) {
                            %>
                            <tr>
                                <td colspan="2" class="text-muted text-center">No grades available.</td>
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
                } catch (Exception e) {
                    out.println("<p class='text-danger'>Error loading grades: " + e.getMessage() + "</p>");
                    e.printStackTrace();
                }
            %>
        </div>


        <div id="remarks" class="tab-content">
            <h2>Remarks</h2>
            <% try (Connection conn = DBConnection.getConnection()) {
                   String sql = "SELECT r.remark, r.date, CONCAT(f.first_name, ' ', f.last_name) AS faculty_name " +
                                "FROM remarks r " +
                                "JOIN faculty f ON r.faculty_id = f.id " +
                                "WHERE r.student_id = (SELECT id FROM students WHERE user_id = (SELECT id FROM users WHERE username = ?)) " +
                                "ORDER BY r.date DESC";
                   PreparedStatement ps = conn.prepareStatement(sql);
                   ps.setString(1, username);
                   ResultSet rs = ps.executeQuery();
                   boolean hasRemarks = false;
            %>
            <div class="row">
                <% while (rs.next()) { 
                       hasRemarks = true;
                %>
                <div class="col-md-6 mb-4">
                    <div class="card h-100 shadow-sm">
                        <div class="card-header bg-primary text-white">
                            <strong><i class="fas fa-comment"></i> Remark from <%= rs.getString("faculty_name") %></strong>
                        </div>
                        <div class="card-body">
                            <p class="card-text"><%= rs.getString("remark") %></p>
                            <p class="text-muted"><small><i class="fas fa-calendar"></i> <%= rs.getString("date") %></small></p>
                        </div>
                    </div>
                </div>
                <% } %>
                <% if (!hasRemarks) { %>
                <div class="col-12">
                    <p class="text-muted">No remarks available.</p>
                </div>
                <% } %>
            </div>
            <%
                   rs.close();
                   ps.close();
               } catch (Exception e) {
                   out.println("<p class='text-danger'>Error loading remarks: " + e.getMessage() + "</p>");
                   e.printStackTrace();
               }
            %>
        </div>
    <div id="notifications" class="tab-content">
            <h2>Notifications</h2>
            <div class="card p-3 shadow-sm">
                <%
                    int studentId = -1;
                    String studentDepartment = null;
                    String studentYear = null;
                    try (Connection conn = DBConnection.getConnection()) {
                        String sql = "SELECT id, department, year FROM users WHERE username = ?";
                        PreparedStatement ps = conn.prepareStatement(sql);
                        ps.setString(1, (String) session.getAttribute("username"));
                        ResultSet rs = ps.executeQuery();
                        if (rs.next()) {
                            studentId = rs.getInt("id");
                            studentDepartment = rs.getString("department");
                            studentYear = rs.getString("year");
                        }
                        rs.close();
                        ps.close();

                        if (studentId != -1) {
                            sql = "SELECT sender_id, user_type, department, year, message, date " +
                                  "FROM notifications " +
                                  "WHERE (user_id = ? OR (user_type = 'all' AND (department = ? OR department = 'all') AND (year = ? OR year = 'all'))) " +
                                  "ORDER BY date DESC";
                            ps = conn.prepareStatement(sql);
                            ps.setInt(1, studentId);
                            ps.setString(2, studentDepartment != null ? studentDepartment : "all");
                            ps.setString(3, studentYear != null ? studentYear : "all");
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
                <div class="alert alert-warning">Unable to retrieve student ID.</div>
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

        $(".toggle-btn").click(function() {
            $(".sidebar").toggleClass("active");
        });
        

        $(document).ready(function() {
            var hash = window.location.hash.replace("#", "");
            var validTabs = ["personalDetails", "attendance", "subjects", "timetable", "projects", "grades", "remarks", "notifications"];
            if (hash && validTabs.includes(hash)) {
                showContent(hash);
            } else {
                showContent("personalDetails");
            }
        });
        
        $(".sidebar a.logout").click(function(e) {
            window.location.href = $(this).attr("href");
        });
   
        $(document).on("click", ".syllabus-thumbnail", function () {
            const imgUrl = $(this).data("img-url");
            $("#modalImage").attr("src", imgUrl);
            $("#imageModal").modal("show");
        });

    </script>
    <!-- Fullscreen Image Modal -->
<div class="modal fade" id="imageModal" tabindex="-1" role="dialog" aria-labelledby="imageModalLabel" aria-hidden="true">
  <div class="modal-dialog modal-xl modal-dialog-centered" role="document">
    <div class="modal-content bg-dark">
      <div class="modal-body text-center p-0">
        <img src="" id="modalImage" class="img-fluid w-100" alt="Syllabus">
      </div>
    </div>
  </div>
</div>
    
</body>
</html>