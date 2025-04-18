<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, syntora.db.DBConnection" %>
<!DOCTYPE html>
<html>
<head>
    <title>Edit Student - Syntora</title>
    <link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/4.5.2/css/bootstrap.min.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/5.15.3/css/all.min.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
    <script src="https://ajax.googleapis.com/ajax/libs/jquery/3.5.1/jquery.min.js"></script>
    <script src="https://maxcdn.bootstrapcdn.com/bootstrap/4.5.2/js/bootstrap.min.js"></script>
    <style>
        body { padding-top: 20px; }
        .card-header { background-color: #007bff; color: #fff; }
    </style>
</head>
<body>
    <div class="container mt-4">
        <div class="card">
            <div class="card-header bg-primary text-white">
                <h2><i class="fas fa-user-edit"></i> Edit Student</h2>
            </div>
            <div class="card-body">
                <% 
                    String rollNumber = request.getParameter("id");
                    String department = request.getParameter("department");
                    String yearStr = request.getParameter("year");
                    String username = "", firstName = "", lastName = "", dob = "", address = "", dept = "", yr = "", semester = "";
                    if (rollNumber != null) {
                        try (Connection conn = DBConnection.getConnection()) {
                            // Corrected query to fetch username from users table
                            String sql = "SELECT u.username, s.roll_number, s.first_name, s.last_name, s.dob, s.address, u.department, u.year, u.semester " +
                                         "FROM students s JOIN users u ON s.user_id = u.id " +
                                         "WHERE u.role = 'student' " +
                                         (department != null && !department.isEmpty() ? "AND u.department = ?" : "") +
                                         (yearStr != null && !yearStr.isEmpty() ? "AND u.year = ?" : "") +
                                         " AND s.roll_number = ?";
                            PreparedStatement ps = conn.prepareStatement(sql);
                            int paramIndex = 1;
                            if (department != null && !department.isEmpty()) {
                                ps.setString(paramIndex++, department);
                            }
                            if (yearStr != null && !yearStr.isEmpty()) {
                                ps.setInt(paramIndex++, Integer.parseInt(yearStr));
                            }
                            ps.setString(paramIndex, rollNumber);
                            ResultSet rs = ps.executeQuery();
                            if (rs.next()) {
                                username = rs.getString("username") != null ? rs.getString("username") : "";
                                rollNumber = rs.getString("roll_number") != null ? rs.getString("roll_number") : "";
                                firstName = rs.getString("first_name") != null ? rs.getString("first_name") : "";
                                lastName = rs.getString("last_name") != null ? rs.getString("last_name") : "";
                                dob = rs.getString("dob") != null ? rs.getString("dob") : "";
                                address = rs.getString("address") != null ? rs.getString("address") : "";
                                dept = rs.getString("department") != null ? rs.getString("department") : "";
                                yr = rs.getInt("year") > 0 ? String.valueOf(rs.getInt("year")) : "";
                                semester = rs.getInt("semester") > 0 ? String.valueOf(rs.getInt("semester")) : "";
                                out.println("<p>Debug: Fetched - Roll: " + rollNumber + ", Name: " + firstName + " " + lastName + "</p>");
                            } else {
                                out.println("<p class='text-danger'>Student with roll number " + rollNumber + " not found.</p>");
                            }
                        } catch (Exception e) {
                            out.println("<p class='text-danger'>Error loading student details: " + e.getMessage() + "</p>");
                        }
                    } else {
                        out.println("<p class='text-danger'>No student selected.</p>");
                    }
                %>
                <form action="${pageContext.request.contextPath}/adminStudents" method="post">
                    <input type="hidden" name="action" value="update">
                    <input type="hidden" name="rollNumber" value="<%= rollNumber != null ? rollNumber : "" %>">
                    <input type="hidden" name="department" value="<%= department != null ? department : "" %>">
                    <input type="hidden" name="year" value="<%= yearStr != null ? yearStr : "" %>">
                    <div class="form-group">
                        <label for="username">Username</label>
                        <input type="text" class="form-control" id="username" name="username" value="<%= username %>" required>
                    </div>
                    <div class="form-group">
                        <label for="firstName">First Name</label>
                        <input type="text" class="form-control" id="firstName" name="first_name" value="<%= firstName %>" pattern="[A-Za-z]+" title="First name must contain only letters" required>
                    </div>
                    <div class="form-group">
                        <label for="lastName">Last Name</label>
                        <input type="text" class="form-control" id="lastName" name="last_name" value="<%= lastName %>" pattern="[A-Za-z]+" title="Last name must contain only letters" required>
                    </div>
                    <div class="form-group">
                        <label for="dob">Date of Birth</label>
                        <input type="date" class="form-control" id="dob" name="dob" value="<%= dob %>" max="2006-12-31" required>
                    </div>
                    <div class="form-group">
                        <label for="address">Address</label>
                        <textarea class="form-control" id="address" name="address" required><%= address %></textarea>
                    </div>
                    <div class="form-group">
                        <label for="department">Department</label>
                        <select class="form-control" id="department" name="department" required>
                            <option value="AIML" <%= "AIML".equals(dept) ? "selected" : "" %>>AIML</option>
                            <option value="CSE" <%= "CSE".equals(dept) ? "selected" : "" %>>CSE</option>
                            <option value="IT" <%= "IT".equals(dept) ? "selected" : "" %>>IT</option>
                            <option value="ECE" <%= "ECE".equals(dept) ? "selected" : "" %>>ECE</option>
                            <option value="EEE" <%= "EEE".equals(dept) ? "selected" : "" %>>EEE</option>
                        </select>
                    </div>
                    <div class="form-group">
                        <label for="year">Year</label>
                        <input type="number" class="form-control" id="year" name="year" value="<%= yr %>" min="1" max="5" required>
                    </div>
                    <div class="form-group">
                        <label for="semester">Semester</label>
                        <input type="number" class="form-control" id="semester" name="semester" value="<%= semester %>" min="1" max="2" required>
                    </div>
                    <button type="submit" class="btn btn-primary">Save Changes</button>
                    <a href="${pageContext.request.contextPath}/adminStudents?department=<%= department != null ? department : "" %>&year=<%= yearStr != null ? yearStr : "" %>" class="btn btn-secondary">Cancel</a>
                </form>
            </div>
        </div>
    </div>
</body>
</html>