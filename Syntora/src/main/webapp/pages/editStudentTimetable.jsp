<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
    <title>Student Timetable Upload | Syntora Admin</title>
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@400;600&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://bootswatch.com/5/flatly/bootstrap.min.css">
    <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
    <style>
        body {
            font-family: 'Poppins', sans-serif;
            background-color: #f8f9fa;
        }
        .container {
            max-width: 700px;
            margin-top: 60px;
        }
        .card {
            padding: 30px;
            border-radius: 15px;
        }
        h2 {
            font-weight: 600;
        }
        .form-label {
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
        <div class="card shadow">
            <h2 class="text-center mb-4">Upload Student Timetable</h2>
            <form action="${pageContext.request.contextPath}/UploadStudentTimetableServlet" method="post" enctype="multipart/form-data">
                <div class="mb-3">
                    <label for="department" class="form-label">Department</label>
                    <select class="form-select" id="department" name="department" required>
                        <option value="">Select Department</option>
                        <option value="CSE">CSE</option>
                        <option value="ECE">ECE</option>
                        <option value="AIML">AIML</option>
                        <option value="EEE">EEE</option>
                        <option value="IT">IT</option>
                    </select>
                </div>
                <div class="mb-3">
                    <label for="year" class="form-label">Year</label>
                    <select class="form-select" id="year" name="year" required>
                        <option value="">Select Year</option>
                        <option value="1">1st</option>
                        <option value="2">2nd</option>
                        <option value="3">3rd</option>
                        <option value="4">4th</option>
                    </select>
                </div>
                <div class="mb-3">
                    <label for="semester" class="form-label">Semester</label>
                    <select class="form-select" id="semester" name="semester" required>
                        <option value="">Select Semester</option>
                        <option value="1">1</option>
                        <option value="2">2</option>
                    </select>
                </div>
                <div class="mb-3">
                    <label for="timetableImage" class="form-label">Upload Timetable Image</label>
                    <input type="file" class="form-control" id="timetableImage" name="timetableImage" accept="image/*" required>
                </div>
                <div class="d-grid mt-4">
                    <button type="submit" class="btn btn-primary btn-lg">Upload</button>
                </div>
            </form>
        </div>
    </div>
</body>
</html>
