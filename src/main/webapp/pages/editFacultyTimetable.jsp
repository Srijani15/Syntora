<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.List" %>
<%@ page import="model.FacultyDAO, model.SubjectDAO, model.Faculty, model.Subject" %>
<%
    List<Faculty> facultyList = FacultyDAO.getAllFaculty();
    List<Subject> subjectList = SubjectDAO.getAllSubjects();
%>
<!DOCTYPE html>
<html>
<head>
    <title>Edit Faculty Timetable | Syntora Admin</title>
    <link rel="stylesheet" href="https://bootswatch.com/5/flatly/bootstrap.min.css">
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@400;600&display=swap" rel="stylesheet">
    <style>
        body {
            font-family: 'Poppins', sans-serif;
            background-color: #f8f9fa;
        }
        .container {
            max-width: 1100px;
            margin-top: 40px;
        }
        h2 {
            font-weight: 600;
        }
        .table thead {
            background-color: #0275d8;
            color: white;
        }
        .form-select, .form-control {
            font-size: 14px;
        }
        .day-label {
            font-weight: 500;
        }
        .btn-back {
            margin-bottom: 20px;
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="text-end">
            <a href="${pageContext.request.contextPath}/pages/adminManageTimetable.jsp" class="btn btn-secondary btn-sm btn-back">
                <i class="fas fa-arrow-left"></i> Back to Manage Timetables
            </a>
        </div>
        <div class="card shadow p-4">
            <h2 class="text-center mb-4">Edit Faculty Timetable</h2>
            <form action="${pageContext.request.contextPath}/UploadFacultyTimetableServlet" method="post">
                <div class="row mb-3">
                    <div class="col-md-3">
                        <label class="form-label">Faculty</label>
                        <select class="form-select" name="facultyId" required>
                            <option value="">Select</option>
                            <% for (Faculty f : facultyList) { %>
                                <option value="<%= f.getId() %>"><%= f.getTitle() + " " + f.getFirstName() + " " + f.getLastName() %></option>
                            <% } %>
                        </select>
                    </div>
                    <div class="col-md-3">
                        <label class="form-label">Department</label>
                        <select class="form-select" name="department" required>
                            <option value="">Select</option>
                            <option value="CSE">CSE</option>
                            <option value="ECE">ECE</option>
                            <option value="ME">ME</option>
                        </select>
                    </div>
                    <div class="col-md-3">
                        <label class="form-label">Year</label>
                        <select class="form-select" name="year" required>
                            <option value="">Select</option>
                            <option value="1">1st</option>
                            <option value="2">2nd</option>
                            <option value="3">3rd</option>
                            <option value="4">4th</option>
                        </select>
                    </div>
                    <div class="col-md-3">
                        <label class="form-label">Semester</label>
                        <select class="form-select" name="semester" required>
                            <option value="">Select</option>
                            <option value="1">1</option>
                            <option value="2">2</option>
                        </select>
                    </div>
                </div>

                <table class="table table-bordered align-middle text-center">
                    <thead>
                        <tr>
                            <th>Day</th>
                            <th>9:00 - 9:50</th>
                            <th>9:50 - 10:40</th>
                            <th>10:50 - 11:40</th>
                            <th>11:40 - 12:30</th>
                            <th>1:20 - 2:10</th>
                            <th>2:10 - 3:00</th>
                            <th>3:00 - 4:00</th>
                        </tr>
                    </thead>
                    <tbody>
                        <%
                            String[] days = {"Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"};
                            for (String day : days) {
                        %>
                        <tr>
                            <td class="day-label"><%= day %></td>
                            <% for (int i = 1; i <= 7; i++) { %>
                                <td>
                                    <select class="form-select" name="<%= day.toLowerCase() + "_slot" + i %>">
                                        <option value="-">-</option>
                                        <% for (Subject s : subjectList) { %>
                                            <option value="<%= s.getId() %>"><%= s.getName() %></option>
                                        <% } %>
                                    </select>
                                    <input type="text" class="form-control mt-1" name="<%= day.toLowerCase() + "_note" + i %>" placeholder="Optional Note">
                                </td>
                            <% } %>
                        </tr>
                        <% } %>
                        <tr class="table-light text-center fw-bold">
                            <td colspan="8">
                                <span>Note: 10:50 - 11:00 → Break, 12:40 - 1:20 → Lunch</span>
                            </td>
                        </tr>
                    </tbody>
                </table>

                <div class="text-center mt-4">
                    <button type="submit" class="btn btn-primary btn-lg px-5">Save Timetable</button>
                </div>
            </form>
        </div>
    </div>
</body>
</html>
