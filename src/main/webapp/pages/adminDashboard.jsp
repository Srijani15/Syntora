<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
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
        <a href="logout" class="logout"><i class="fas fa-sign-out-alt"></i> Logout</a>
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
            <h2>Send Notifications</h2>
            <div class="card p-3 shadow-sm">
               
            <a href="${pageContext.request.contextPath}/pages/adminNotifications.jsp"><i class="fas fa-bell"></i> Notifications</a>
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