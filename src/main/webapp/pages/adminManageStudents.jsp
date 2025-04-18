<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html>
<head>
    <title>Manage Students - Syntora</title>
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
        .card-header { background-color: #007bff; color: #fff; }
        .dataTables_wrapper .dataTables_length, .dataTables_wrapper .dataTables_filter, .dataTables_wrapper .dataTables_info, .dataTables_wrapper .dataTables_paginate {
            margin-bottom: 15px; /* Ensure spacing between elements */
            padding: 8px 0; /* Add vertical padding for better separation */
        }
        .wide-container {
            max-width: 1400px; /* Wider layout */
            width: 90%; /* Takes up most of the viewport */
            margin: 0 auto;
        }
        #studentsTable {
            width: 100% !important; /* Ensure table takes full container width */
        }
        /* Prevent overlap by ensuring elements are properly spaced */
        .dataTables_length select {
            width: auto !important; /* Allow "Show entries" dropdown to adjust width */
            min-width: 80px;
    		padding: 6px 8px;
    		font-size: 14px;
    		background-color: #fff;
    		border: 1px solid #ccc;
    		border-radius: 6px; /* Space between dropdown and other elements */
        }
        .dataTables_filter input {
            margin-left: 15px; /* Space between search and other elements */
        }
        @media (max-width: 768px) {
            .wide-container {
                width: 100%; /* Full width on smaller screens */
            }
            .dataTables_length select {
                min-width: 80px; /* Adjust for smaller screens */
            }
        }
    </style>
</head>
<body>
    <div class="wide-container mt-4">
        <div class="card">
            <div class="card-header bg-primary text-white">
                <h2><i class="fas fa-users"></i> Manage Students (Department: ${param.department}, Year: ${param.year})</h2>
            </div>
            <div class="card-body">
                <a href="${pageContext.request.contextPath}/adminDashboard.jsp" class="btn btn-secondary mb-3"><i class="fas fa-arrow-left"></i> Back to Dashboard</a>
                <c:choose>
                    <c:when test="${empty students}">
                        <p class="text-danger">No students found for Department: ${param.department}, Year: ${param.year}. Please check the filters or database.</p>
                    </c:when>
                    <c:otherwise>
                        <table id="studentsTable" class="table table-striped" style="width: 100%;">
                            <thead>
                                <tr>
                                    <th>Roll Number</th>
                                    <th>Name</th>
                                    <th>Department</th>
                                    <th>Year</th>
                                    <th>Semester</th>
                                    <th>DOB</th>
                                    <th>Address</th>
                                    <th>Actions</th>
                                </tr>
                            </thead>
                            <tbody>
                                <c:forEach var="student" items="${students}">
                                    <tr>
                                        <td>${student.rollNumber}</td>
                                        <td>${student.firstName} ${student.lastName}</td>
                                        <td>${student.department}</td>
                                        <td>${student.year}</td>
                                        <td>${student.semester}</td>
                                        <td>${student.dob}</td>
                                        <td>${student.address}</td>
                                        <td>
                                            <a href="${pageContext.request.contextPath}/pages/editStudent.jsp?id=${student.rollNumber}&department=${param.department}&year=${param.year}" class="btn btn-sm btn-primary"><i class="fas fa-edit"></i> Edit</a>
                                            <a href="${pageContext.request.contextPath}/adminStudents?action=delete&roll=${student.rollNumber}&department=${param.department}&year=${param.year}" class="btn btn-sm btn-danger" onclick="return confirm('Are you sure?')"><i class="fas fa-trash"></i> Delete</a>
                                        </td>
                                    </tr>
                                </c:forEach>
                            </tbody>
                        </table>
                    </c:otherwise>
                </c:choose>
            </div>
        </div>
    </div>
    <script>
        $(document).ready(function() {
            $('#studentsTable').DataTable({
                "paging": true,
                "searching": true,
                "ordering": true,
                "info": true,
                "lengthMenu": [5, 10, 25, 50], // Ensure these options are valid
                "pageLength": 10, // Default number of entries
                "order": [[0, "asc"]], // Sort by roll number
                "columns": [
                    null,
                    null,
                    null,
                    null,
                    null,
                    null,
                    null,
                    { "orderable": false }
                ]
            });
        });
    </script>
</body>
</html>