<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ page import="java.util.UUID" %>
<!DOCTYPE html>
<html>
<head>
    <title>Register - Syntora</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@400;600;700&display=swap" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet">
    <style>
        body {
            background: linear-gradient(135deg, #dbeafe 0%, #f1f5f9 100%);
            min-height: 100vh;
            display: flex;
            align-items: center;
            justify-content: center;
            padding: 20px;
            font-family: 'Poppins', sans-serif;
        }
        .register-container {
            max-width: 650px;
            width: 100%;
            background: #ffffff;
            border-radius: 20px;
            box-shadow: 0 15px 40px rgba(59, 130, 246, 0.15);
            overflow: hidden;
            transition: transform 0.3s ease, box-shadow 0.3s ease;
        }
        .register-container:hover {
            transform: translateY(-10px);
            box-shadow: 0 20px 50px rgba(59, 130, 246, 0.25);
        }
        .card-header {
            background: #3b82f6;
            padding: 25px;
            color: white;
            text-align: center;
            border-bottom: 4px solid #2563eb;
        }
        .form-control, .form-select {
            border-radius: 10px;
            padding: 12px;
            border: 1px solid #e2e8f0;
            transition: border-color 0.3s ease, box-shadow 0.3s ease;
        }
        .form-control:focus, .form-select:focus {
            border-color: #3b82f6;
            box-shadow: 0 0 8px rgba(59, 130, 246, 0.3);
        }
        .btn-primary {
            background: #3b82f6;
            border: none;
            padding: 12px;
            border-radius: 50px;
            font-weight: 600;
            text-transform: uppercase;
            box-shadow: 0 4px 15px rgba(59, 130, 246, 0.4);
            transition: all 0.3s ease;
        }
        .btn-primary:hover {
            background: #2563eb;
            transform: scale(1.1);
            box-shadow: 0 6px 20px rgba(59, 130, 246, 0.6);
        }
        .btn-secondary {
            background: #10b981;
            border: none;
            padding: 12px;
            border-radius: 50px;
            font-weight: 600;
            text-transform: uppercase;
            color: white;
            box-shadow: 0 4px 15px rgba(16, 185, 129, 0.4);
            transition: all 0.3s ease;
        }
        .btn-secondary:hover {
            background: #059669;
            transform: scale(1.1);
            box-shadow: 0 6px 20px rgba(16, 185, 129, 0.6);
        }
        .form-group label {
            font-weight: 600;
            color: #1e293b;
            margin-bottom: 6px;
        }
        .alert {
            border-radius: 10px;
            margin-bottom: 20px;
        }
        .alert-danger {
            background: #fee2e2;
            color: #b91c1c;
        }
        .alert-success {
            background: #d1fae5;
            color: #065f46;
        }
    </style>
</head>
<body>
    <div class="register-container">
        <div class="card-header">
            <h2><i class="fas fa-user-plus me-2"></i>Register with Syntora</h2>
        </div>
        <div class="card-body p-4">
            <%
                String csrfToken = UUID.randomUUID().toString();
                session.setAttribute("csrfToken", csrfToken);
            %>
            <c:if test="${param.error == 'true'}">
                <div class="alert alert-danger">${param.message != null ? param.message : 'Registration failed. Please try again.'}</div>
            </c:if>
            <c:if test="${param.success == 'true'}">
                <div class="alert alert-success">Registration successful! Please <a href="login.jsp">login</a>.</div>
            </c:if>
            <form action="${pageContext.request.contextPath}/register" method="post" onsubmit="return validatePasswords()">
                <input type="hidden" name="csrfToken" value="<%= csrfToken %>">
                <div class="row">
                    <div class="col-md-6 form-group mb-3">
                        <label><i class="fas fa-user me-2"></i>Username</label>
                        <input type="text" name="username" class="form-control" pattern="[A-Za-z0-9]{4,}" 
                               title="Username must be alphanumeric and at least 4 characters" required>
                    </div>
                    <div class="col-md-6 form-group mb-3">
                        <label><i class="fas fa-lock me-2"></i>Password</label>
                        <input type="password" name="password" id="password" class="form-control" pattern=".{6,}" 
                               title="Password must be at least 6 characters" required>
                    </div>
                </div>
                <div class="form-group mb-3">
                    <label><i class="fas fa-lock me-2"></i>Confirm Password</label>
                    <input type="password" name="confirm_password" id="confirm_password" class="form-control" 
                           pattern=".{6,}" title="Password must be at least 6 characters" required>
                </div>
                <div class="form-group mb-3">
                    <label><i class="fas fa-envelope me-2"></i>Email</label>
                    <input type="email" name="email" class="form-control" required>
                </div>
                <div class="row">
                    <div class="col-md-6 form-group mb-3">
                        <label><i class="fas fa-user me-2"></i>First Name</label>
                        <input type="text" name="first_name" class="form-control" pattern="[A-Za-z]+" 
                               title="First name must contain only letters" required>
                    </div>
                    <div class="col-md-6 form-group mb-3">
                        <label><i class="fas fa-user me-2"></i>Last Name</label>
                        <input type="text" name="last_name" class="form-control" pattern="[A-Za-z]+" 
                               title="Last name must contain only letters" required>
                    </div>
                </div>
                <div class="form-group mb-3">
                    <label><i class="fas fa-calendar-alt me-2"></i>Date of Birth</label>
                    <input type="date" name="dob" class="form-control" max="2006-12-31" required>
                </div>
                <div class="form-group mb-3">
                    <label><i class="fas fa-home me-2"></i>Address</label>
                    <textarea name="address" class="form-control" rows="3" required></textarea>
                </div>
                <div class="row">
                    <div class="col-md-6 form-group mb-3">
                        <label><i class="fas fa-users me-2"></i>Role</label>
                        <select name="role" id="role" class="form-select" required>
                            <option value="student">Student</option>
                            <option value="faculty">Faculty</option>
                        </select>
                    </div>
                    <div class="col-md-6 form-group mb-3">
                        <label><i class="fas fa-building me-2"></i>Department</label>
                        <select name="department" class="form-select" required>
                            <option value="AIML">AIML</option>
                            <option value="CSE">CSE</option>
                            <option value="IT">IT</option>
                            <option value="ECE">ECE</option>
                            <option value="EEE">EEE</option>
                        </select>
                    </div>
                </div>
                <div class="form-group mb-3" id="studentFields" style="display: none;">
                    <label><i class="fas fa-id-card me-2"></i>Roll Number</label>
                    <input type="text" name="roll_number" class="form-control" pattern="[A-Za-z0-9]+" 
                           title="Roll number must be alphanumeric">
                    <div class="row">
                        <div class="col-md-6">
                            <label><i class="fas fa-calendar me-2"></i>Year</label>
                            <input type="number" name="year" class="form-control" min="1" max="4">
                        </div>
                        <div class="col-md-6">
                            <label><i class="fas fa-calendar-check me-2"></i>Semester</label>
                            <input type="number" name="semester" class="form-control" min="1" max="2">
                        </div>
                    </div>
                </div>
                <div class="d-flex justify-content-between">
                    <button type="submit" class="btn btn-primary"><i class="fas fa-check me-2"></i>Register</button>
                    <a href="${pageContext.request.contextPath}/login.jsp" class="btn btn-secondary">
                        <i class="fas fa-sign-in-alt me-2"></i>Login
                    </a>
                </div>
            </form>
        </div>
    </div>
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    <script>
        const roleSelect = document.getElementById('role');
        const studentFields = document.getElementById('studentFields');
        roleSelect.addEventListener('change', function() {
            if (this.value === 'student') {
                studentFields.style.display = 'block';
                studentFields.querySelectorAll('input').forEach(input => input.required = true);
            } else {
                studentFields.style.display = 'none';
                studentFields.querySelectorAll('input').forEach(input => input.required = false);
            }
        });
        roleSelect.dispatchEvent(new Event('change'));

        function validatePasswords() {
            const password = document.getElementById('password').value;
            const confirmPassword = document.getElementById('confirm_password').value;
            if (password !== confirmPassword) {
                alert('Passwords do not match!');
                return false;
            }
            return true;
        }
    </script>
</body>
</html>