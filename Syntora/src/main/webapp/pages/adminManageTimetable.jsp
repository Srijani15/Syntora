<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
    <title>Manage Timetables - Admin | Syntora</title>
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@400;500;600&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://bootswatch.com/5/flatly/bootstrap.min.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/5.15.3/css/all.min.css">
    <style>
        body {
            font-family: 'Poppins', sans-serif;
            background-color: #f8f9fa;
        }
        .container {
            max-width: 1500px;
            margin-top: 80px;
        }
        .card {
            padding: 25px;
            border-radius: 15px;
        }
        h2 {
            font-weight: 600;
        }
        .btn-back {
            margin-top: 20px;
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="text-end">
            <a href="${pageContext.request.contextPath}/pages/adminDashboard.jsp" class="btn btn-secondary btn-sm">
                <i class="fas fa-arrow-left"></i> Back to Dashboard
            </a>
        </div>
        <div class="card shadow mt-3">
            <h2 class="mb-4 text-center">Manage Timetables</h2>
            <p class="text-center">Choose which timetable you want to manage:</p>
            <div class="d-grid gap-3">
                <a href="${pageContext.request.contextPath}/pages/editStudentTimetable.jsp" class="btn btn-primary btn-lg">
                    <i class="fas fa-user-graduate"></i> Student Timetable
                </a>
                <a href="${pageContext.request.contextPath}/pages/editFacultyTimetable.jsp" class="btn btn-success btn-lg">
                    <i class="fas fa-chalkboard-teacher"></i> Faculty Timetable
                </a>
            </div>
        </div>
    </div>
</body>
</html>
