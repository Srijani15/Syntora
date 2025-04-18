<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, syntora.db.DBConnection" %>
<!DOCTYPE html>
<html>
<head>
    <title>Manage Student Attendance - Syntora</title>
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@400;500;600&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://bootswatch.com/5/flatly/bootstrap.min.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/5.15.3/css/all.min.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
    <script src="https://ajax.googleapis.com/ajax/libs/jquery/3.5.1/jquery.min.js"></script>
    <script src="https://maxcdn.bootstrapcdn.com/ajax/libs/bootstrap/4.5.2/js/bootstrap.min.js"></script>
</head>
<body>
    <div class="container mt-4">
        <h2>Manage Student Attendance</h2>
        <a href="${pageContext.request.contextPath}/adminDashboard.jsp#manageAttendance" class="btn btn-secondary mb-3"><i class="fas fa-arrow-left"></i> Back to Dashboard</a>
        <%
            String rollNumber = request.getParameter("rollNumber");
            String department = request.getParameter("department");
            String year = request.getParameter("year");
            String semester = request.getParameter("semester");
            String error = request.getParameter("error");

            if (error != null) {
        %>
        <div class="alert alert-danger alert-dismissible fade show" role="alert">
            <i class="fas fa-exclamation-circle"></i> Error updating attendance. Please try again.
            <button type="button" class="close" data-dismiss="alert" aria-label="Close"><span aria-hidden="true">×</span></button>
        </div>
        <%
            }

            if (rollNumber == null || department == null || year == null || semester == null ||
                rollNumber.trim().isEmpty() || department.trim().isEmpty() || year.trim().isEmpty() || semester.trim().isEmpty()) {
        %>
        <div class="alert alert-warning" role="alert">
            <i class="fas fa-exclamation-triangle"></i> Please provide all required fields: Roll Number, Department, Year, and Semester.
        </div>
        <%
            } else {
                try (Connection conn = DBConnection.getConnection()) {
                    if (conn == null) {
                        out.println("<div class='alert alert-danger' role='alert'><i class='fas fa-exclamation-circle'></i> Database connection failed.</div>");
                    } else {
                        // Get student details
                        String studentSql = "SELECT s.id, s.first_name, s.last_name " +
                                          "FROM students s JOIN users u ON s.user_id = u.id " +
                                          "WHERE s.roll_number = ? AND u.department = ? AND u.year = ? AND u.semester = ?";
                        PreparedStatement studentPs = conn.prepareStatement(studentSql);
                        studentPs.setString(1, rollNumber);
                        studentPs.setString(2, department);
                        studentPs.setInt(3, Integer.parseInt(year));
                        studentPs.setInt(4, Integer.parseInt(semester));
                        ResultSet studentRs = studentPs.executeQuery();
                        int studentId = -1;
                        String studentName = null;

                        if (studentRs.next()) {
                            studentId = studentRs.getInt("id");
                            studentName = studentRs.getString("first_name") + " " + studentRs.getString("last_name");
                        }
                        studentRs.close();
                        studentPs.close();

                        if (studentId == -1) {
        %>
        <div class="alert alert-warning" role="alert">
            <i class="fas fa-exclamation-triangle"></i> No student found with Roll Number: <%= rollNumber %> in <%= department %>, Year <%= year %>, Semester <%= semester %>.
        </div>
        <%
                        } else {
        %>
        <div class="card shadow-sm mb-4">
            <div class="card-header bg-primary text-white">
                <strong><i class="fas fa-user"></i> Attendance for <%= studentName %> (<%= rollNumber %>)</strong>
            </div>
            <div class="card-body">
                <%
                    // Get subjects
                    String subjectSql = "SELECT id, name FROM subjects WHERE department = ? AND year = ? AND semester = ? ORDER BY name";
                    PreparedStatement subjectPs = conn.prepareStatement(subjectSql);
                    subjectPs.setString(1, department);
                    subjectPs.setInt(2, Integer.parseInt(year));
                    subjectPs.setInt(3, Integer.parseInt(semester));
                    ResultSet subjectRs = subjectPs.executeQuery();
                    boolean hasSubjects = false;

                    while (subjectRs.next()) {
                        hasSubjects = true;
                        int subjectId = subjectRs.getInt("id");
                        String subjectName = subjectRs.getString("name");

                        // Get attendance
                        String attendanceSql = "SELECT id, date, status FROM attendance WHERE student_id = ? AND subject_id = ? ORDER BY date DESC";
                        PreparedStatement attendancePs = conn.prepareStatement(attendanceSql);
                        attendancePs.setInt(1, studentId);
                        attendancePs.setInt(2, subjectId);
                        ResultSet attendanceRs = attendancePs.executeQuery();
                %>
                <h5 class="mb-3"><%= subjectName %></h5>
                <table class="table table-bordered table-hover">
                    <thead>
                        <tr>
                            <th>Date</th>
                            <th>Status</th>
                            <th>Actions</th>
                        </tr>
                    </thead>
                    <tbody>
                        <%
                            boolean hasAttendance = false;
                            while (attendanceRs.next()) {
                                hasAttendance = true;
                                int attendanceId = attendanceRs.getInt("id");
                                String date = attendanceRs.getString("date");
                                String status = attendanceRs.getString("status");
                        %>
                        <tr>
                            <td><%= date %></td>
                            <td>
                                <form action="${pageContext.request.contextPath}/adminAttendance" method="post" class="form-inline">
                                    <input type="hidden" name="action" value="edit">
                                    <input type="hidden" name="id" value="<%= attendanceId %>">
                                    <input type="hidden" name="rollNumber" value="<%= rollNumber %>">
                                    <input type="hidden" name="department" value="<%= department %>">
                                    <input type="hidden" name="year" value="<%= year %>">
                                    <input type="hidden" name="semester" value="<%= semester %>">
                                    <select name="status" class="form-control form-control-sm mr-2">
                                        <option value="Present" <%= "Present".equals(status) ? "selected" : "" %>>Present</option>
                                        <option value="Absent" <%= "Absent".equals(status) ? "selected" : "" %>>Absent</option>
                                    </select>
                                    <button type="submit" class="btn btn-sm btn-success"><i class="fas fa-save"></i> Save</button>
                                </form>
                            </td>
                            <td>
                                <form action="${pageContext.request.contextPath}/adminAttendance" method="post" class="d-inline">
                                    <input type="hidden" name="action" value="delete">
                                    <input type="hidden" name="id" value="<%= attendanceId %>">
                                    <input type="hidden" name="rollNumber" value="<%= rollNumber %>">
                                    <input type="hidden" name="department" value="<%= department %>">
                                    <input type="hidden" name="year" value="<%= year %>">
                                    <input type="hidden" name="semester" value="<%= semester %>">
                                    <button type="submit" class="btn btn-sm btn-danger" onclick="return confirm('Are you sure you want to delete this record?');"><i class="fas fa-trash"></i> Delete</button>
                                </form>
                            </td>
                        </tr>
                        <%
                            }
                            if (!hasAttendance) {
                        %>
                        <tr>
                            <td colspan="3" class="text-muted">No attendance records found.</td>
                        </tr>
                        <%
                            }
                            attendanceRs.close();
                            attendancePs.close();
                        %>
                    </tbody>
                </table>
                <%
                    }
                    subjectRs.close();
                    subjectPs.close();

                    if (!hasSubjects) {
                %>
                <p class="text-muted">No subjects assigned for <%= department %> - Year <%= year %> - Semester <%= semester %>.</p>
                <%
                    }
                %>
            </div>
        </div>
        <%
                        }
                    }
                } catch (Exception e) {
                    out.println("<div class='alert alert-danger' role='alert'><i class='fas fa-exclamation-circle'></i> Error: " + e.getMessage() + "</div>");
                    e.printStackTrace();
                }
            }
        %>
    </div>
</body>
</html>