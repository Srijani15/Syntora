<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, syntora.db.DBConnection" %>
<!DOCTYPE html>
<html>
<head>
    <title>Manage Faculty - Syntora</title>
    
    <!-- Bootstrap, DataTables, FontAwesome -->
    <link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/4.5.2/css/bootstrap.min.css">
    <link rel="stylesheet" href="https://cdn.datatables.net/1.10.22/css/dataTables.bootstrap4.min.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/5.15.3/css/all.min.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">

    <script src="https://ajax.googleapis.com/ajax/libs/jquery/3.5.1/jquery.min.js"></script>
    <script src="https://cdn.datatables.net/1.10.22/js/jquery.dataTables.min.js"></script>
    <script src="https://cdn.datatables.net/1.10.22/js/dataTables.bootstrap4.min.js"></script>
    <script src="https://maxcdn.bootstrapcdn.com/bootstrap/4.5.2/js/bootstrap.min.js"></script>

    <style>
        body { padding-top: 20px; }
        .wide-container { max-width: 1400px; width: 90%; margin: 0 auto; }
        .card-header { background-color: #007bff; color: white; }
        #facultyTable { width: 100% !important; }
        .dataTables_wrapper .dataTables_length select {
            width: auto !important;
            min-width: 80px;
    		padding: 6px 8px;
    		font-size: 14px;
    		background-color: #fff;
    		border: 1px solid #ccc;
    		border-radius: 6px;
        }
        .dataTables_filter input {
            margin-left: 15px;
        }
        @media (max-width: 768px) {
            .wide-container { width: 100%; }
            .dataTables_length select { min-width: 80px; }
        }
    </style>
</head>
<body>
    <div class="wide-container mt-4">
        <div class="card shadow-sm">
            <div class="card-header d-flex align-items-center">
                <h4 class="mb-0">
                    <i class="fas fa-chalkboard-teacher me-2"></i> 
                    Manage Faculty
                    <% String departmentParam = request.getParameter("department"); %>
                    <% if (departmentParam != null && !departmentParam.isEmpty()) { %>
                        (<strong>Department: <%= departmentParam %></strong>)
                    <% } %>
                </h4>
            </div>
            <div class="card-body">
                <a href="${pageContext.request.contextPath}/adminDashboard.jsp" class="btn btn-secondary mb-3">
                    <i class="fas fa-arrow-left"></i> Back to Dashboard
                </a>

                <% if ("error".equals(request.getParameter("status"))) { %>
                    <div class="alert alert-danger">Operation failed. Please try again.</div>
                <% } else if ("success".equals(request.getParameter("status"))) { %>
                    <div class="alert alert-success">Operation successful.</div>
                <% } %>

                <% if (departmentParam == null || departmentParam.isEmpty()) { %>
                    <!-- Department selection form if not selected -->
                    <form action="${pageContext.request.contextPath}/pages/adminManageFaculty.jsp" method="get" class="card p-3 mb-4">
                        <div class="form-group">
                            <label for="department">Department</label>
                            <select name="department" id="department" class="form-control" required>
                                <option value="">Select Department</option>
                                <option value="CSE">CSE</option>
                                <option value="IT">IT</option>
                                <option value="AIML">AIML</option>
                                <option value="ECE">ECE</option>
                                <option value="EEE">EEE</option>
                            </select>
                        </div>
                        <button type="submit" class="btn btn-primary">
                            <i class="fas fa-search"></i> View and Manage
                        </button>
                    </form>
                <% } else { %>
                    <!-- Show faculty table for selected department -->
                    <table id="facultyTable" class="table table-striped table-bordered">
                        <thead class="thead-dark">
                            <tr>
                                <th>Username</th>
                                <th>Title</th>
                                <th>Name</th>
                                <th>Department</th>
                                <th>Actions</th>
                            </tr>
                        </thead>
                        <tbody>
                            <%
                                try (Connection conn = DBConnection.getConnection()) {
                                    String sql = "SELECT u.username, f.title, f.first_name, f.last_name, u.department " +
                                                 "FROM faculty f JOIN users u ON f.user_id = u.id " +
                                                 "WHERE u.role = 'faculty' AND u.department = ?";
                                    PreparedStatement ps = conn.prepareStatement(sql);
                                    ps.setString(1, departmentParam);
                                    ResultSet rs = ps.executeQuery();
                                    while (rs.next()) {
                            %>
                                <tr>
                                    <td><%= rs.getString("username") %></td>
                                    <td><%= rs.getString("title") %></td>
                                    <td><%= rs.getString("first_name") %> <%= rs.getString("last_name") %></td>
                                    <td><%= rs.getString("department") %></td>
                                    <td>
                                        <a href="${pageContext.request.contextPath}/editFaculty.jsp?username=<%= rs.getString("username") %>&department=<%= departmentParam %>" class="btn btn-warning btn-sm">
                                            <i class="fas fa-edit"></i> Edit
                                        </a>
                                        <a href="${pageContext.request.contextPath}/adminFaculty?action=delete&username=<%= rs.getString("username") %>&department=<%= departmentParam %>" 
                                           class="btn btn-danger btn-sm" 
                                           onclick="return confirm('Are you sure?')">
                                            <i class="fas fa-trash"></i> Delete
                                        </a>
                                    </td>
                                </tr>
                            <%
                                    }
                                } catch (Exception e) {
                                    out.println("<tr><td colspan='5'>Error loading faculty data.</td></tr>");
                                }
                            %>
                        </tbody>
                    </table>
                    <a href="${pageContext.request.contextPath}/editFaculty.jsp?department=<%= departmentParam %>" class="btn btn-success mt-3">
                        <i class="fas fa-plus"></i> Add New Faculty
                    </a>
                <% } %>
            </div>
        </div>
    </div>

    <!-- DataTables Script -->
    <script>
        $(document).ready(function() {
            $('#facultyTable').DataTable({
                paging: true,
                searching: true,
                ordering: true,
                info: true,
                lengthMenu: [5, 10, 25, 50],
                pageLength: 10,
                order: [[0, "asc"]],
                columns: [
                    null,
                    null,
                    null,
                    null,
                    { orderable: false }
                ]
            });
        });
    </script>
</body>
</html>
