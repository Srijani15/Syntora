<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, syntora.db.DBConnection" %>
<!DOCTYPE html>
<html>
<head>
    <title>Manage Subjects - Syntora</title>
    <link rel="stylesheet" href="https://bootswatch.com/5/flatly/bootstrap.min.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/5.15.3/css/all.min.css">
</head>
<body>
    <div class="container mt-5">
        <div class="card shadow">
            <div class="card-header bg-primary text-white">
                <h3><i class="fas fa-book me-2"></i> Manage Subjects</h3>
            </div>
            <div class="card-body">

                <!-- 🔙 Back Button -->
                <a href="${pageContext.request.contextPath}/adminDashboard.jsp" class="btn btn-secondary mb-4">
                    <i class="fas fa-arrow-left"></i> Back to Dashboard
                </a>

                <!-- ➕ Add Subject Form -->
                <form action="${pageContext.request.contextPath}/adminSubjects" method="post" enctype="multipart/form-data" class="row g-3 mb-4">
                    <div class="col-md-3">
                        <label for="name">Subject Name</label>
                        <input type="text" name="name" id="name" class="form-control" required />
                    </div>
                    <div class="col-md-2">
                        <label for="department">Department</label>
                        <select name="department" id="department" class="form-control" required>
                            <option value="">Select</option>
                            <option value="AIML">AIML</option>
                            <option value="CSE">CSE</option>
                            <option value="IT">IT</option>
                            <option value="ECE">ECE</option>
                            <option value="EEE">EEE</option>
                        </select>
                    </div>
                    <div class="col-md-2">
                        <label for="year">Year</label>
                        <select name="year" id="year" class="form-control" required>
                            <option value="">Select</option>
                            <option value="1">1</option>
                            <option value="2">2</option>
                            <option value="3">3</option>
                            <option value="4">4</option>
                        </select>
                    </div>
                    <div class="col-md-2">
                        <label for="semester">Semester</label>
                        <select name="semester" id="semester" class="form-control" required>
                            <option value="">Select</option>
                            <option value="1">1</option>
                            <option value="2">2</option>
                        </select>
                    </div>
                    <div class="col-md-3">
                        <label for="faculty_id">Faculty</label>
                        <select name="faculty_id" id="faculty_id" class="form-control" required>
                            <option value="">Select Faculty</option>
                            <%
                                try (Connection conn = DBConnection.getConnection()) {
                                    PreparedStatement ps = conn.prepareStatement(
                                        "SELECT f.id, f.first_name, f.last_name FROM faculty f JOIN users u ON f.user_id = u.id"
                                    );
                                    ResultSet rs = ps.executeQuery();
                                    while (rs.next()) {
                            %>
                                <option value="<%= rs.getInt("id") %>">
                                    <%= rs.getString("first_name") %> <%= rs.getString("last_name") %>
                                </option>
                            <%
                                    }
                                    rs.close(); ps.close();
                                } catch (Exception e) {
                                    out.println("<option disabled>Error loading faculty</option>");
                                }
                            %>
                        </select>
                    </div>
                    <div class="col-md-3">
                        <label for="syllabus_image">Syllabus Image</label>
                        <input type="file" name="syllabus_image" id="syllabus_image" class="form-control" accept="image/*" required />
                    </div>
                    <div class="col-md-2 d-flex align-items-end">
                        <button type="submit" class="btn btn-success w-100">
                            <i class="fas fa-plus-circle"></i> Add
                        </button>
                    </div>
                </form>

                <!-- 🔎 Filter Form -->
                <form method="get" action="adminSubjects" class="row g-3 mb-4">
                    <div class="col-md-3">
                        <label>Department</label>
                        <select name="filterDept" class="form-control" required>
                            <option value="">Select</option>
                            <option value="AIML">AIML</option>
                            <option value="CSE">CSE</option>
                            <option value="IT">IT</option>
                            <option value="ECE">ECE</option>
                            <option value="EEE">EEE</option>
                        </select>
                    </div>
                    <div class="col-md-2">
                        <label>Year</label>
                        <select name="filterYear" class="form-control" required>
                            <option value="">Select</option>
                            <option value="1">1</option>
                            <option value="2">2</option>
                            <option value="3">3</option>
                            <option value="4">4</option>
                        </select>
                    </div>
                    <div class="col-md-2">
                        <label>Semester</label>
                        <select name="filterSem" class="form-control" required>
                            <option value="">Select</option>
                            <option value="1">1</option>
                            <option value="2">2</option>
                        </select>
                    </div>
                    <div class="col-md-2 d-flex align-items-end">
                        <button type="submit" class="btn btn-info w-100"><i class="fas fa-search"></i> Filter</button>
                    </div>
                </form>

                <!-- 📋 Filtered Subject Table -->
                <%
                    String dept = request.getParameter("filterDept");
                    String yr = request.getParameter("filterYear");
                    String sem = request.getParameter("filterSem");

                    if (dept != null && yr != null && sem != null && !dept.isEmpty()) {
                        try (Connection conn = DBConnection.getConnection()) {
                            String sql = "SELECT * FROM subjects WHERE department = ? AND year = ? AND semester = ? ORDER BY name";
                            PreparedStatement ps = conn.prepareStatement(sql);
                            ps.setString(1, dept);
                            ps.setInt(2, Integer.parseInt(yr));
                            ps.setInt(3, Integer.parseInt(sem));
                            ResultSet rs = ps.executeQuery();
                %>
                <h5 class="mt-4">Subjects for Dept: <%= dept %>, Year: <%= yr %>, Semester: <%= sem %></h5>
                <table class="table table-bordered">
                    <thead class="table-light">
                        <tr>
                            <th>ID</th>
                            <th>Subject</th>
                            <th>Actions</th>
                        </tr>
                    </thead>
                    <tbody>
                        <%
                            boolean hasSubjects = false;
                            while (rs.next()) {
                                hasSubjects = true;
                        %>
                        <tr>
                            <td><%= rs.getInt("id") %></td>
                            <td><%= rs.getString("name") %></td>
                            <td>
                                <a href="adminSubjects?action=delete&id=<%= rs.getInt("id") %>" class="btn btn-danger btn-sm" onclick="return confirm('Delete this subject?')">
                                    <i class="fas fa-trash-alt"></i> Delete
                                </a>
                            </td>
                        </tr>
                        <% } %>
                        <% if (!hasSubjects) { %>
                        <tr><td colspan="3" class="text-center">No subjects found.</td></tr>
                        <% } %>
                    </tbody>
                </table>
                <%
                            rs.close(); ps.close();
                        } catch (Exception e) {
                            out.println("<div class='alert alert-danger'>Error loading subjects: " + e.getMessage() + "</div>");
                        }
                    } else {
                %>
                    <p class="text-muted">Select a department, year, and semester to view subjects.</p>
                <% } %>

            </div>
        </div>
    </div>
</body>
</html>
