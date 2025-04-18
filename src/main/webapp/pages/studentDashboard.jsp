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
            <% try (Connection conn = DBConnection.getConnection()) {
                   String sql = "SELECT t.id FROM timetable t JOIN students s ON t.department = s.department AND t.year = s.year AND t.semester = s.semester WHERE s.username = ?";
                   PreparedStatement ps = conn.prepareStatement(sql);
                   ps.setString(1, username);
                   ResultSet rs = ps.executeQuery();
                   if (rs.next()) {
                       int timetableId = rs.getInt("id");
                       sql = "SELECT te.day, te.time_slot, s.name AS subject, CONCAT(f.first_name, ' ', f.last_name) AS faculty " +
                             "FROM timetable_entry te JOIN subjects s ON te.subject_id = s.id JOIN faculty f ON te.faculty_id = f.id " +
                             "WHERE te.timetable_id = ? ORDER BY FIELD(day, 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday')";
                       ps = conn.prepareStatement(sql);
                       ps.setInt(1, timetableId);
                       rs = ps.executeQuery();
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
                       String subject = "", faculty = "";
                       while (rs.next()) {
                           if (rs.getString("day").equals(day) && rs.getString("time_slot").equals(time)) {
                               subject = rs.getString("subject");
                               faculty = rs.getString("faculty");
                               break;
                           }
                       }
                %>
                <td><%= subject.isEmpty() ? "-" : subject + "<br><small>(" + faculty + ")</small>" %></td>
                <% } %>
                </tr>
                <% } %>
                </tbody>
            </table>
            <%      } else { %>
                <p>No timetable available.</p>
            <%      }
               } catch (Exception e) {
                   out.println("<p>Error loading timetable: " + e.getMessage() + "</p>");
               }
            %>
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
            <% try (Connection conn = DBConnection.getConnection()) {
                   String sql = "SELECT s.name, g.grade FROM grades g JOIN subjects s ON g.subject_id = s.id WHERE g.student_id = (SELECT id FROM students WHERE username = ?)";
                   PreparedStatement ps = conn.prepareStatement(sql);
                   ps.setString(1, username);
                   ResultSet rs = ps.executeQuery();
            %>
            <table class="table table-striped">
                <thead><tr><th>Subject</th><th>Grade</th></tr></thead>
                <tbody>
                <% while (rs.next()) { %>
                    <tr><td><%= rs.getString("name") %></td><td><%= rs.getString("grade") %></td></tr>
                <% } %>
                </tbody>
            </table>
            <%      } catch (Exception e) {
                    out.println("<p>Error loading grades: " + e.getMessage() + "</p>");
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
            <% if (request.getParameter("error") != null) { %>
                <div class="alert alert-danger"><%= request.getParameter("error") %></div>
            <% } %>
            <% 
                try (Connection conn = DBConnection.getConnection()) {
                    String sql = "SELECT n.message, n.date, u.username AS sender_name " +
                                 "FROM notifications n JOIN users u ON n.sender_id = u.id " +
                                 "WHERE n.user_id = (SELECT id FROM students WHERE username = ?) AND n.user_type = 'student' ORDER BY n.date DESC";
                    PreparedStatement ps = conn.prepareStatement(sql);
                    ps.setString(1, username); // Reuse username instead of re-declaring
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
                out.println("<p class='text-danger'>Error loading notifications: " + e.getMessage() + "</p>");
            } %>
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