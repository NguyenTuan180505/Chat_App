<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Register - ChatApp</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css" rel="stylesheet">
    <style>
        body {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            min-height: 100vh;
        }
        .card {
            border: none;
            border-radius: 15px;
            box-shadow: 0 10px 30px rgba(0,0,0,0.2);
        }
        .form-control {
            border-radius: 10px;
        }
        .btn {
            border-radius: 10px;
            padding: 12px;
        }
    </style>
</head>
<body class="d-flex align-items-center">
<div class="container">
    <div class="row justify-content-center">
        <div class="col-md-6 col-lg-5">
            <div class="card p-4">
                <div class="text-center mb-4">
                    <i class="fas fa-user-plus fa-3x text-success"></i>
                    <h2 class="mt-3">Tạo tài khoản</h2>
                    <p class="text-muted">Đăng ký để tham gia chat ngay</p>
                </div>

                <form id="registerForm">
                    <div class="mb-3">
                        <label class="form-label">Username</label>
                        <input type="text" name="username" id="username"
                               class="form-control" placeholder="Nhập username" required>
                    </div>

                    <div class="mb-3">
                        <label class="form-label">Mật khẩu</label>
                        <input type="password" name="password" id="password"
                               class="form-control" placeholder="Nhập mật khẩu" required>
                    </div>

                    <div class="mb-3">
                        <label class="form-label">Họ và tên</label>
                        <input type="text" name="fullName" id="fullName"
                               class="form-control" placeholder="Nhập họ và tên">
                    </div>

                    <div class="mb-3">
                        <label class="form-label">Số điện thoại</label>
                        <input type="tel" name="phone" id="phone"
                               class="form-control" placeholder="Nhập số điện thoại">
                    </div>

                    <div id="errorMsg" class="alert alert-danger d-none"></div>
                    <div id="successMsg" class="alert alert-success d-none"></div>

                    <button type="submit" id="btnRegister" class="btn btn-success w-100">
                        <span class="spinner-border spinner-border-sm d-none" id="loading"></span>
                        Đăng ký
                    </button>
                </form>

                <div class="text-center mt-4">
                    <p class="mb-0">Đã có tài khoản?
                        <a href="/auth/login" class="text-decoration-none fw-bold">Đăng nhập ngay</a>
                    </p>
                </div>
            </div>
        </div>
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
<!-- Phần <script> thay thế phần cũ -->
<script>
    document.getElementById('registerForm').addEventListener('submit', async function(e) {
        e.preventDefault();

        const btn = document.getElementById('btnRegister');
        const loading = document.getElementById('loading');
        const errorMsg = document.getElementById('errorMsg');
        const successMsg = document.getElementById('successMsg');

        errorMsg.classList.add('d-none');
        successMsg.classList.add('d-none');

        btn.disabled = true;
        loading.classList.remove('d-none');

        const formData = new FormData(this);

        try {
            const response = await fetch('/auth/register', {
                method: 'POST',
                body: formData,
                headers: {
                    'X-Requested-With': 'XMLHttpRequest'
                }
            });

            let result;
            const contentType = response.headers.get("content-type");

            if (contentType && contentType.includes("application/json")) {
                result = await response.json();
            } else {
                // Trường hợp lỗi không phải JSON
                result = { success: false, message: "Lỗi server. Vui lòng thử lại!" };
            }

            if (result.success) {
                successMsg.textContent = result.message;
                successMsg.classList.remove('d-none');

                setTimeout(() => {
                    window.location.href = '/auth/login';
                }, 1800);
            } else {
                errorMsg.textContent = result.message || 'Đăng ký thất bại!';
                errorMsg.classList.remove('d-none');
            }
        } catch (err) {
            errorMsg.textContent = 'Không thể kết nối đến server. Vui lòng kiểm tra mạng!';
            errorMsg.classList.remove('d-none');
        } finally {
            btn.disabled = false;
            loading.classList.add('d-none');
        }
    });
</script>
</body>
</html>